ANALYZE war, battle, military_unit, casualty_report;

-- Запросы БЕЗ ИНДЕКСОВ

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM battle WHERE war_id = 500;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM battle WHERE battle_date > '1950-01-01';
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM military_unit WHERE size < 1000;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM casualty_report WHERE category IN ('military', 'civilian');
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM war WHERE war_name LIKE '%World%';

-- B‑tree

CREATE INDEX idx_battle_war_id_btree ON battle(war_id);
CREATE INDEX idx_battle_battle_date_btree ON battle(battle_date);
CREATE INDEX idx_military_unit_size_btree ON military_unit(size);
CREATE INDEX idx_casualty_report_category_btree ON casualty_report(category);
CREATE INDEX idx_war_war_name_btree ON war(war_name);

ANALYZE battle, military_unit, casualty_report, war;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM battle WHERE war_id = 500;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM battle WHERE battle_date > '1950-01-01';
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM military_unit WHERE size < 1000;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM casualty_report WHERE category IN ('military', 'civilian');
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM war WHERE war_name LIKE '%World%';

-- Удаляе B‑tree
DROP INDEX idx_battle_war_id_btree;
DROP INDEX idx_battle_battle_date_btree;
DROP INDEX idx_military_unit_size_btree;
DROP INDEX idx_casualty_report_category_btree;
DROP INDEX idx_war_war_name_btree;

-- Hash

CREATE INDEX idx_battle_war_id_hash ON battle USING hash (war_id);
CREATE INDEX idx_battle_battle_date_hash ON battle USING hash (battle_date);
CREATE INDEX idx_military_unit_size_hash ON military_unit USING hash (size);
CREATE INDEX idx_casualty_report_category_hash ON casualty_report USING hash (category);
CREATE INDEX idx_war_war_name_hash ON war USING hash (war_name);

ANALYZE battle, military_unit, casualty_report, war;


EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM battle WHERE war_id = 500;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM battle WHERE battle_date > '1950-01-01';
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM military_unit WHERE size < 1000;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM casualty_report WHERE category IN ('military', 'civilian');
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM war WHERE war_name LIKE '%World%';

-- Удаляем hash
DROP INDEX idx_battle_war_id_hash;
DROP INDEX idx_battle_battle_date_hash;
DROP INDEX idx_military_unit_size_hash;
DROP INDEX idx_casualty_report_category_hash;
DROP INDEX idx_war_war_name_hash;