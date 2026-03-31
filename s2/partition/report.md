# Секционирование Range

```sql
CREATE TABLE battle_range (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
) PARTITION BY RANGE (battle_date);

CREATE TABLE battle_range_ww1 PARTITION OF battle_range
FOR VALUES FROM ('1914-01-01') TO ('1919-01-01');

CREATE TABLE battle_range_interwar PARTITION OF battle_range
FOR VALUES FROM ('1919-01-01') TO ('1939-01-01');

CREATE TABLE battle_range_ww2 PARTITION OF battle_range
FOR VALUES FROM ('1939-01-01') TO ('1946-01-01');

CREATE TABLE battle_range_coldwar PARTITION OF battle_range
FOR VALUES FROM ('1946-01-01') TO ('1992-01-01');

CREATE TABLE battle_range_modern PARTITION OF battle_range
FOR VALUES FROM ('1992-01-01') TO ('2025-01-01');

CREATE INDEX idx_battle_range_date ON battle_range(battle_date);
```

```sql
EXPLAIN ANALYZE
SELECT * FROM battle_range
WHERE battle_date = '1943-07-12';
```

![Снимок экрана 2026-03-31 в 15.12.52.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.12.52.png)

```sql
CREATE TABLE battle_list (
    battle_id BIGINT,
    result TEXT NOT NULL,
    battle_date DATE,
    war_id BIGINT,
    PRIMARY KEY (battle_id, result)
) PARTITION BY LIST (result);

CREATE TABLE battle_list_win PARTITION OF battle_list
FOR VALUES IN ('win');

CREATE TABLE battle_list_loss PARTITION OF battle_list
FOR VALUES IN ('loss');

CREATE TABLE battle_list_draw PARTITION OF battle_list
FOR VALUES IN ('draw');

CREATE INDEX idx_battle_list_result ON battle_list(result);
```

```sql
EXPLAIN ANALYZE
SELECT * FROM battle_list
WHERE result = 'win';
```

![Снимок экрана 2026-03-31 в 15.15.50.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.15.50.png)


```sql
CREATE TABLE battle_hash (
    battle_id BIGINT,
    war_id BIGINT NOT NULL,
    battle_date DATE,
    result TEXT,
    PRIMARY KEY (battle_id, war_id)
) PARTITION BY HASH (war_id);

CREATE TABLE battle_hash_0 PARTITION OF battle_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE battle_hash_1 PARTITION OF battle_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE battle_hash_2 PARTITION OF battle_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE battle_hash_3 PARTITION OF battle_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 3);

CREATE INDEX idx_battle_hash_war_id ON battle_hash(war_id);
```

```sql
EXPLAIN ANALYZE
SELECT * FROM battle_hash
WHERE war_id = 10;
```

![Снимок экрана 2026-03-31 в 15.16.59.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.16.59.png)

```sql
EXPLAIN ANALYZE
SELECT * FROM battle_range
WHERE battle_date > '1943-07-12';
```

![Снимок экрана 2026-03-31 в 15.18.44.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.18.44.png)

# На мастере
```sql

CREATE PUBLICATION pub_battle
FOR TABLE battle_range
WITH (publish_via_partition_root = off);
```

# На логической реплике

```sql
CREATE TABLE battle_range (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);

CREATE TABLE battle_range_ww2 (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);

CREATE TABLE battle_range_ww1 (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);

CREATE TABLE battle_range_interwar (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);

CREATE TABLE battle_range_coldwar (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);

CREATE TABLE battle_range_modern (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);
```

```sql
CREATE SUBSCRIPTION sub_battle
CONNECTION 'host=pg_course port=5432 dbname=part user=admin password=admin_pass'
PUBLICATION pub_battle;
```

# На мастере 

```sql
INSERT INTO battle_range VALUES
(3, '1944-01-01', 'win', 1);
```

# На реплике
```sql
SELECT * FROM battle_range_ww2;
```

![Снимок экрана 2026-03-31 в 15.50.59.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.50.59.png)

```sql
DROP SUBSCRIPTION sub_battle;
```

# На мастере

```sql
DROP PUBLICATION pub_battle;
     
CREATE PUBLICATION pub_battle
FOR TABLE battle_range
WITH (publish_via_partition_root = on);
```

# На логической реплике 

```sql
CREATE SUBSCRIPTION sub_battle
CONNECTION 'host=pg_course port=5432 dbname=part user=admin password=admin_pass'
PUBLICATION pub_battle;
```

# На мастере

```sql
INSERT INTO battle_range VALUES
(3, '1944-01-01', 'win', 1);
```

# На логической реплике

```sql
SELECT * FROM battle_range_ww2;
```

![Снимок экрана 2026-03-31 в 15.57.08.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.57.08.png)

```sql
SELECT * FROM battle_range;
```

![Снимок экрана 2026-03-31 в 15.57.21.png](img/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202026-03-31%20%D0%B2%2015.57.21.png)

