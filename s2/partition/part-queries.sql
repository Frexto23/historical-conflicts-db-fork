-- Active: 1774529921311@@127.0.0.1@7433@part
EXPLAIN ANALYZE
SELECT * FROM battle_range
WHERE battle_date = '1943-07-12';

EXPLAIN ANALYZE
SELECT * FROM battle_list
WHERE result = 'win';

EXPLAIN ANALYZE
SELECT * FROM battle_hash
WHERE war_id = 10;

EXPLAIN ANALYZE
SELECT * FROM battle_range
WHERE battle_date > '1943-07-12';



CREATE PUBLICATION pub_battle
FOR TABLE battle_range
WITH (publish_via_partition_root = off);

CREATE SUBSCRIPTION sub_battle
CONNECTION 'host=pg_course port=5432 dbname=part user=admin password=admin_pass'
PUBLICATION pub_battle;

INSERT INTO battle_range VALUES
(3, '1944-01-01', 'win', 1);

SELECT * FROM battle_range;