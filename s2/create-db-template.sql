-- Active: 1772545063605@@127.0.0.1@7432@course_db
CREATE TABLE war (
    war_id BIGSERIAL PRIMARY KEY,
    war_name TEXT NOT NULL,
    period DATERANGE NOT NULL,                
    war_type VARCHAR(20),                      
    total_casualties INT,
    description TEXT,                          
    metadata JSONB                             
);

CREATE TABLE battle (
    battle_id BIGSERIAL PRIMARY KEY,
    war_id BIGINT REFERENCES war(war_id),
    battle_name TEXT,
    battle_date DATE,
    location POINT,
    intensity SMALLINT,
    result VARCHAR(20),
    report TEXT,
    extra_data JSONB,
    commander_ids INT[]
);

CREATE TABLE military_unit (
    unit_id BIGSERIAL PRIMARY KEY,
    war_id BIGINT REFERENCES war(war_id),
    unit_type VARCHAR(30),          
    size INT,                       
    supply_level INT,
    active_period TSRANGE,          
    attributes JSONB,
    notes TEXT
);

CREATE TABLE casualty_report (
    report_id BIGSERIAL PRIMARY KEY,
    battle_id BIGINT REFERENCES battle(battle_id),
    killed INT,
    wounded INT,
    missing INT,
    civilian BOOLEAN,
    category VARCHAR(20),           
    reported_at TIMESTAMP,
    details TEXT
);

CREATE TABLE state (
    state_id SERIAL PRIMARY KEY,
    state_name TEXT,
    ideology VARCHAR(50)
);