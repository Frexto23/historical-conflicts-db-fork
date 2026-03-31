-- Active: 1774340120181@@127.0.0.1@7433@course_db
SELECT * FROM war
WHERE war_name = 'MASTER INSERT WAR';

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

SELECT pg_is_in_recovery();

CREATE SUBSCRIPTION logical_sub
CONNECTION 'host=pg_course port=5432 user=replicator dbname=course_db password=pass'
PUBLICATION logical_pub
WITH (copy_data = false, create_slot = false, slot_name = 'logical_slot');

SELECT * FROM war
WHERE war_name = 'MASTER LOGICAL INSERT WAR';

SELECT * FROM test_dml;