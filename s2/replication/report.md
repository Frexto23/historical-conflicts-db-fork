# На Master

```sql
INSERT INTO war (
    war_name,
    period,
    war_type,
    total_casualties,
    description,
    metadata
)
VALUES (
    'MASTER INSERT WAR',
    daterange('2000-01-01', '2005-01-01', '[]'),
    'fictional',
    123456,
    'Test war inserted on primary node for replication check',
    '{"source": "primary", "test": true}'
);
```

```sql
SELECT * FROM war
WHERE war_name = 'MASTER INSERT WAR';
```

![Снимок экрана 2026-03-24 в 11.01.37.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2011.01.37.png)

# На Replica 1

```sql
SELECT * FROM war
WHERE war_name = 'MASTER INSERT WAR';
```

![Снимок экрана 2026-03-24 в 11.16.22.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2011.16.22.png)

# На Replica 2

```sql
SELECT * FROM war
WHERE war_name = 'MASTER INSERT WAR';
```

![Снимок экрана 2026-03-24 в 11.16.28.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2011.16.28.png)

```sql
INSERT INTO war (
    war_name,
    period,
    war_type,
    total_casualties,
    description,
    metadata
)
VALUES (
    'REPLICA 2 INSERT WAR',
    daterange('2000-01-01', '2005-01-01', '[]'),
    'fictional',
    123456,
    'Test war inserted on primary node for replication check',
    '{"source": "primary", "test": true}'
);
```
![Снимок экрана 2026-03-24 в 11.18.52.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2011.18.52.png)

```sql
-- =====================================================
-- 4. Заполнение таблицы military_unit (~350 000 строк)
--    Исправлено: tsrange требует timestamp without time zone,
--    поэтому приводим end_date и вычисляемое начало к ::timestamp
-- =====================================================
DO $$
DECLARE
    war_ids BIGINT[];
    war_count INT;
BEGIN
    SELECT array_agg(war_id ORDER BY war_id) INTO war_ids FROM war;
    war_count := array_length(war_ids, 1);

    INSERT INTO military_unit (war_id, unit_type, size, supply_level, active_period, attributes, notes)
    SELECT
        war_ids[1 + floor(random() * war_count)::int],
        CASE (random() * 4)::int
            WHEN 0 THEN 'Infantry'
            WHEN 1 THEN 'Cavalry'
            WHEN 2 THEN 'Artillery'
            WHEN 3 THEN 'Navy'
            ELSE 'Air Force'
        END,
        (random() * 10000)::int,
        (random() * 100)::int,
        tsrange(
            (end_date - (random() * interval '100 years'))::timestamp,  -- явное приведение к timestamp
            end_date::timestamp,
            '[]'
        ),
        jsonb_build_object(
            'veteran', random() > 0.7,
            'morale', random() * 100
        ),
        CASE WHEN random() < 0.1 THEN NULL
             ELSE 'Unit notes ' || md5(random()::text)
        END
    FROM (
        SELECT
            i,
            now() - (random() * interval '200 years') AS end_date   -- пока ещё timestamptz
        FROM generate_series(1, 350000) AS i
    ) AS sub;
END $$;
```

```sql
SELECT * FROM pg_stat_replication;
```

![Снимок экрана 2026-03-24 в 11.45.23.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2011.45.23.png)

# LOGICAL На мастере

```sql
CREATE PUBLICATION logical_pub FOR ALL TABLES;
```

```sql
SELECT lsn FROM pg_create_logical_replication_slot('logical_slot', 'pgoutput');
```

0/503FBEC8

![Снимок экрана 2026-03-24 в 12.39.52.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2012.39.52.png)

# На логической реплике 

```sql
CREATE SUBSCRIPTION logical_sub
CONNECTION 'host=pg_course port=5432 user=replicator dbname=course_db password=pass'
PUBLICATION logical_pub
WITH (copy_data = false, create_slot = false, slot_name = 'logical_slot');
```

# На мастере
```sql
INSERT INTO war (
    war_name,
    period,
    war_type,
    total_casualties,
    description,
    metadata
)
VALUES (
    'MASTER LOGICAL INSERT WAR',
    daterange('2000-01-01', '2005-01-01', '[]'),
    'fictional',
    123456,
    'Test war inserted on primary node for replication check',
    '{"source": "primary", "test": true}'
);
```

# На логической реплике

```sql
SELECT * FROM war
WHERE war_name = 'MASTER LOGICAL INSERT WAR';
```
![Снимок экрана 2026-03-24 в 16.30.23.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2016.30.23.png)

# На мастере

```sql
CREATE TABLE test_dml (id serial PRIMARY KEY, data text);
CREATE PUBLICATION my_pub FOR TABLE test_dml;
```

# На логической реплике

```sql
SELECT * FROM test_dml;
```
![Снимок экрана 2026-03-24 в 16.36.36.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2016.36.36.png)

# Проверку replication status

```sql
SELECT * FROM pg_stat_replication;
```

![Снимок экрана 2026-03-24 в 16.39.24.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-24%20%D0%B2%2016.39.24.png)
