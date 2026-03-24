-- Active: 1774245759125@@127.0.0.1@7432@course_db
-- =====================================================
-- Скрипт наполнения данными (s2/insert_data.sql) – ИСПРАВЛЕННЫЙ
-- Запускать после создания таблиц (s1/create_tables.sql)
-- =====================================================

BEGIN;

-- -----------------------------------------------------------------
-- Очистка таблиц (если требуется повторный запуск)
-- Раскомментируйте при необходимости
TRUNCATE TABLE casualty_report, military_unit, battle, war, state RESTART IDENTITY CASCADE;
-- -----------------------------------------------------------------

-- =====================================================
-- 2. Заполнение таблицы war (около 1000 строк)
--    daterange работает с date, проблем нет
-- =====================================================
INSERT INTO war (war_name, period, war_type, total_casualties, description, metadata)
SELECT
    'War ' || i,
    daterange(
        start_date,
        start_date + (random() * 3650)::int,   -- до 10 лет после начала
        '[]'
    ),
    CASE
        WHEN random() < 0.7 THEN 'International'
        WHEN random() < 0.9 THEN 'Civil'
        WHEN random() < 0.97 THEN 'Colonial'
        ELSE 'Religious'
    END,
    (random() * 1000000)::int,
    'War description ' || i || '. ' || md5(random()::text),
    jsonb_build_object('source', 'wiki', 'reliability', random())
FROM (
    SELECT
        i,
        ('1900-01-01'::date + (random() * 365 * 200)::int) AS start_date
    FROM generate_series(1, 1000) AS i
) AS sub;

-- =====================================================
-- 3. Заполнение таблицы battle (~350 000 строк)
--    с перекосом: 70% строк принадлежат первым 10% войн
-- =====================================================
DO $$
DECLARE
    war_ids BIGINT[];
    war_count INT;
    threshold INT;
BEGIN
    SELECT array_agg(war_id ORDER BY war_id) INTO war_ids FROM war;
    war_count := array_length(war_ids, 1);
    threshold := floor(war_count * 0.1)::int;

    INSERT INTO battle (war_id, battle_name, battle_date, location, intensity, result, report, extra_data, commander_ids)
    SELECT
        CASE WHEN random() < 0.7 THEN
            war_ids[1 + floor(random() * threshold)::int]
        ELSE
            war_ids[1 + threshold + floor(random() * (war_count - threshold))::int]
        END,
        'Battle ' || i,
        ('1900-01-01'::date + (random() * 365 * 200)::int),
        point(
            (random() * 180 - 90)::numeric(10,6),
            (random() * 360 - 180)::numeric(10,6)
        ),
        (random() * 10)::int,
        CASE (random() * 3)::int
            WHEN 0 THEN 'victory'
            WHEN 1 THEN 'defeat'
            WHEN 2 THEN 'draw'
            ELSE 'inconclusive'
        END,
        CASE WHEN random() < 0.1 THEN NULL
             ELSE 'Report for battle ' || i || '. ' || md5(random()::text)
        END,
        CASE WHEN random() < 0.1 THEN NULL
             ELSE jsonb_build_object('weather',
                  CASE (random() * 2)::int
                      WHEN 0 THEN 'sunny'
                      WHEN 1 THEN 'rainy'
                      ELSE 'foggy'
                  END)
        END,
        CASE WHEN random() < 0.1 THEN NULL
             ELSE array(
                 SELECT (random() * 1000)::int
                 FROM generate_series(1, (random() * 5 + 1)::int)
             )
        END
    FROM generate_series(1, 350000) AS i;
END $$;

-- =====================================================
-- 4. Заполнение таблицы military_unit (~350 000 строк)
--    Исправлено: tsrange требует timestamp without time zone,
--    поэтому приводим end_date и вычисляемое начало к ::timestamp
-- =====================================================
DO $$
DECLARE
    war_ids BIGINT[];
    war_count INT;
BEGIN
    SELECT array_agg(war_id ORDER BY war_id) INTO war_ids FROM war;
    war_count := array_length(war_ids, 1);

    INSERT INTO military_unit (war_id, unit_type, size, supply_level, active_period, attributes, notes)
    SELECT
        war_ids[1 + floor(random() * war_count)::int],
        CASE (random() * 4)::int
            WHEN 0 THEN 'Infantry'
            WHEN 1 THEN 'Cavalry'
            WHEN 2 THEN 'Artillery'
            WHEN 3 THEN 'Navy'
            ELSE 'Air Force'
        END,
        (random() * 10000)::int,
        (random() * 100)::int,
        tsrange(
            (end_date - (random() * interval '100 years'))::timestamp,  -- явное приведение к timestamp
            end_date::timestamp,
            '[]'
        ),
        jsonb_build_object(
            'veteran', random() > 0.7,
            'morale', random() * 100
        ),
        CASE WHEN random() < 0.1 THEN NULL
             ELSE 'Unit notes ' || md5(random()::text)
        END
    FROM (
        SELECT
            i,
            now() - (random() * interval '200 years') AS end_date   -- пока ещё timestamptz
        FROM generate_series(1, 350000) AS i
    ) AS sub;
END $$;

-- =====================================================
-- 5. Заполнение таблицы casualty_report (~400 000 строк)
-- =====================================================
DO $$
DECLARE
    battle_ids BIGINT[];
    battle_count INT;
BEGIN
    SELECT array_agg(battle_id ORDER BY battle_id) INTO battle_ids FROM battle;
    battle_count := array_length(battle_ids, 1);

    INSERT INTO casualty_report (battle_id, killed, wounded, missing, civilian, category, reported_at, details)
    SELECT
        battle_ids[1 + floor(random() * battle_count)::int],
        (random() * 5000)::int,
        (random() * 5000)::int,
        (random() * 1000)::int,
        random() < 0.3,
        CASE (random() * 2)::int
            WHEN 0 THEN 'military'
            WHEN 1 THEN 'civilian'
            ELSE 'unknown'
        END,
        now() - (random() * interval '100 years'),
        CASE WHEN random() < 0.1 THEN NULL
             ELSE 'Casualty details ' || md5(random()::text)
        END
    FROM generate_series(1, 400000) AS i;
END $$;

-- =====================================================
-- 6. Заполнение таблицы state (справочник)
-- =====================================================
INSERT INTO state (state_name, ideology) VALUES
    ('Russia', 'Communism'),
    ('USA', 'Democracy'),
    ('Germany', 'Nazism'),
    ('France', 'Democracy'),
    ('UK', 'Democracy'),
    ('Japan', 'Imperialism'),
    ('China', 'Communism')
ON CONFLICT (state_id) DO NOTHING;

-- =====================================================
-- Фиксация транзакции и обновление статистики
-- =====================================================
COMMIT;

ANALYZE war, battle, military_unit, casualty_report, state;