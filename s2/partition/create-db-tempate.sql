-- Active: 1774529921311@@127.0.0.1@7433@part
CREATE DATABASE part;

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



CREATE TABLE battle_range_ww2 (
    battle_id BIGINT,
    battle_date DATE NOT NULL,
    result TEXT,
    war_id BIGINT,
    PRIMARY KEY (battle_id, battle_date)
);