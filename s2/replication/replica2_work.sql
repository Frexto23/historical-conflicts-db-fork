-- Active: 1774336536972@@127.0.0.1@7434@course_db
SELECT * FROM war
WHERE war_name = 'MASTER INSERT WAR';

SELECT pg_is_in_recovery(); -- должно быть true
SELECT now() - pg_last_xact_replay_timestamp() AS replication_delay;