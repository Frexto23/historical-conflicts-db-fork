-- Создание трёх новых ролей (admin уже существует)
CREATE ROLE reader WITH LOGIN PASSWORD 'reader_pass';
CREATE ROLE analyst WITH LOGIN PASSWORD 'analyst_pass';
CREATE ROLE editor WITH LOGIN PASSWORD 'editor_pass';


GRANT CONNECT ON DATABASE course_db TO reader;
GRANT USAGE ON SCHEMA public TO reader;
GRANT SELECT ON war, battle, state TO reader;
REVOKE ALL ON military_unit, casualty_report FROM reader;

-- Права для analyst
GRANT CONNECT ON DATABASE course_db TO analyst;
GRANT USAGE ON SCHEMA public TO analyst;
GRANT SELECT ON war, military_unit, state TO analyst;
GRANT SELECT, INSERT ON battle, casualty_report TO analyst;

-- Права для editor
GRANT CONNECT ON DATABASE course_db TO editor;
GRANT USAGE ON SCHEMA public TO editor;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO editor;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO editor;