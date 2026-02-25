CREATE SCHEMA wars

CREATE TABLE wars.war(
    war_id SERIAL PRIMARY KEY,
    war_name VARCHAR(255),
    start_date DATE,
    end_date DATE
);

CREATE TABLE wars.event(
    event_id SERIAL PRIMARY KEY,
    event_name VARCHAR(255)
)

CREATE TABLE wars.source(
    source_id SERIAL PRIMARY KEY,
    source_name VARCHAR(255)
)

CREATE TABLE wars.treaty(
    treaty_id SERIAL PRIMARY KEY,
    treaty_name VARCHAR(255)
)

CREATE TABLE wars.commander(
    commander_id SERIAL PRIMARY KEY,
    commander_name VARCHAR(255)
)

CREATE TABLE wars.city(
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(255)
)

CREATE TABLE wars.state(
    state_id SERIAL PRIMARY KEY,
    state_name VARCHAR(255),
    ideology VARCHAR(255)
)

CREATE TABLE wars.leader(
    leader_id SERIAL PRIMARY KEY,
    leader_name VARCHAR(255),
    birth_date DATE,
    death_date DATE
)

CREATE TABLE wars.dynasty(
    dynasty_id SERIAL PRIMARY KEY,
    dynasty_name VARCHAR(255)
)

CREATE TABLE wars.alliance(
    alliance_id SERIAL PRIMARY KEY,
    alliance_name VARCHAR(255)
)


