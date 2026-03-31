-- Active: 1774245759125@@127.0.0.1@7432@part
BEGIN;

-- =========================================
-- Очистка
-- =========================================
TRUNCATE battle_range RESTART IDENTITY CASCADE;

-- =========================================
-- 1. RANGE (равномерно по периодам)
-- =========================================

INSERT INTO battle_range (battle_id, battle_date, result, war_id)
SELECT
    i,
    CASE
        WHEN i % 5 = 0 THEN DATE '1915-06-01'  -- WW1
        WHEN i % 5 = 1 THEN DATE '1930-06-01'  -- interwar
        WHEN i % 5 = 2 THEN DATE '1943-06-01'  -- WW2
        WHEN i % 5 = 3 THEN DATE '1970-06-01'  -- cold war
        ELSE DATE '2005-06-01'                 -- modern
    END,
    CASE (i % 3)
        WHEN 0 THEN 'win'
        WHEN 1 THEN 'loss'
        ELSE 'draw'
    END,
    (i % 100)
FROM generate_series(1, 100000) AS i;


-- =========================================
-- 2. LIST (равномерно по result)
-- =========================================

INSERT INTO battle_list (battle_id, result, battle_date, war_id)
SELECT
    i,
    CASE (i % 3)
        WHEN 0 THEN 'win'
        WHEN 1 THEN 'loss'
        ELSE 'draw'
    END,
    DATE '2000-01-01' + (i % 365),
    (i % 100)
FROM generate_series(1, 100000) AS i;


-- =========================================
-- 3. HASH (равномерно по war_id)
-- =========================================

INSERT INTO battle_hash (battle_id, war_id, battle_date, result)
SELECT
    i,
    i % 100,  -- равномерно → равномерный hash
    DATE '2000-01-01' + (i % 365),
    CASE (i % 3)
        WHEN 0 THEN 'win'
        WHEN 1 THEN 'loss'
        ELSE 'draw'
    END
FROM generate_series(1, 100000) AS i;


COMMIT;

ANALYZE battle_range, battle_list, battle_hash;