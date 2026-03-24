-- Active: 1774245759125@@127.0.0.1@7432@course_db
-- Active: 1774245759125@@127.0.0.1@7432@course_db5759125@@127.0.0.1@7432@course_db6536972@@127.0.0.1@7434@course_db5759125@@127.0.0.1@7432@course_db
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
    'MASTER INSERT WAR',
    daterange('2000-01-01', '2005-01-01', '[]'),
    'fictional',
    123456,
    'Test war inserted on primary node for replication check',
    '{"source": "primary", "test": true}'
);

SELECT * FROM pg_stat_replication;

# LOGICAL

CREATE PUBLICATION logical_pub FOR ALL TABLES;

SELECT lsn FROM pg_create_logical_replication_slot('logical_slot', 'pgoutput');

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

CREATE TABLE test_dml (id serial PRIMARY KEY, data text);
CREATE PUBLICATION my_pub FOR TABLE test_dml;