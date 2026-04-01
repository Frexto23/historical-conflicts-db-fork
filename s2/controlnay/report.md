# 1 Задание

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

![Снимок экрана 2026-04-01 в 10.52.09.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2010.52.09.png)

## Оба создныхх вручную индекса не затрагивают условия в where так что они бесполезны, полезен автоматически созданный индекс на PK поле shop_id
## Планировщик выбирает seq scan потому что есть рендж запрос по датам, на которых нет индексов

```sql
CREATE INDEX idx_store_sold_at ON store_checks(sold_at);

ANALYZE;
```

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

![Снимок экрана 2026-04-01 в 10.54.30.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2010.54.30.png)

## Теперь используется bit map heap scan и bit map index scan, потому что появился индекс, и это стало быстрее
## да, нужно чтобы обновить данные в pg_statistic

# 2 Задание

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

![Снимок экрана 2026-04-01 в 11.04.56.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.04.56.png)

## idx_club_visits_visit_at полезен, так как используется рендж запрос который затрагивает это поле

```sql
CREATE INDEX idx_level_hash ON club_members USING hash (member_level);
ANALYZE;
```

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

![Снимок экрана 2026-04-01 в 11.13.03.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.13.03.png)

## Теперь используется bit map index scan в таблице клиентов по полю level
## Производительность повысилась
## преобладание shared hit или read в BUFFERS означает сколько раз было произведено
## медленно чтение данных с диска или если кеш в хорошем состоянии, то больше будет чтения из него

# Задание 3

```sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

![Снимок экрана 2026-04-01 в 11.17.25.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.17.25.png)

```sql
UPDATE warehouse_items
SET stock = stock - 2
WHERE id = 1;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

![Снимок экрана 2026-04-01 в 11.17.35.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.17.35.png)

## xmin - поменялся на id транзации этого update
## xmax остался равен нулю так все закомичено уже
## ctid изменился так как это теперь другая запись, которую создал update

```sql
DELETE FROM warehouse_items
WHERE id = 3;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

![Снимок экрана 2026-04-01 в 11.17.41.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.17.41.png)

## в MVCC каждый update это delete + insert, это нужно чтобы было меньше блокировок при параллельных транзакциях
## После delete строка как полагается удалилась для обычного читателя бд, это ожидаемое поведение, но фактически просто была помечена как удаленная через xmax

## - VACUUM - не блокирует таблицу, очищает метрвые строки
## - autovacuum - vacuum автомитеческий вызываемый
## - VACUUM FULL - жесткая блокировка для полной очистки

# Задание 5

```sql
CREATE TABLE shipment_stats (
    region_code TEXT NOT NULL,
    shipped_on DATE NOT NULL,
    packages INTEGER NOT NULL,
    avg_weight NUMERIC(8,2)
) PARTITION BY LIST (region_code);

CREATE TABLE shipment_stats_north PARTITION OF shipment_stats
FOR VALUES IN ('north');

CREATE TABLE shipment_stats_south PARTITION OF shipment_stats
FOR VALUES IN ('south');

CREATE TABLE shipment_stats_west PARTITION OF shipment_stats
FOR VALUES IN ('west');
```

```sql
INSERT INTO shipment_stats (region_code, shipped_on, packages, avg_weight)
SELECT
    'north',
    DATE '2025-02-01' + (g % 20),
    10 + (g % 150),
    ((g * 9) % 3000) / 100.0
FROM generate_series(1, 900) AS g;

INSERT INTO shipment_stats (region_code, shipped_on, packages, avg_weight)
SELECT
    'south',
    DATE '2025-02-01' + (g % 20),
    20 + (g % 170),
    ((g * 11) % 3500) / 100.0
FROM generate_series(1, 900) AS g;

INSERT INTO shipment_stats (region_code, shipped_on, packages, avg_weight)
SELECT
    'west',
    DATE '2025-02-01' + (g % 20),
    15 + (g % 160),
    ((g * 7) % 2800) / 100.0
FROM generate_series(1, 900) AS g;

ANALYZE;
```

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE region_code = 'north';
```

![Снимок экрана 2026-04-01 в 11.33.30.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.33.30.png)

## partition pruning есть используется только таблица north

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE shipped_on >= DATE '2025-02-10'
  AND shipped_on < DATE '2025-02-15';
```

![Снимок экрана 2026-04-01 в 11.34.09.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-04-01%20%D0%B2%2011.34.09.png)

## partition pruning нет, потому что в where не используется поле region_code
## partition pruning связан напрамую с наличием обычного индекса, потому что секционируемое поле должно быть частью всех unique constraints, тоесть частью pk, на котором есть индекс

