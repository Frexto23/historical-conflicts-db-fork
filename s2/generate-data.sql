-- Active: 1772545063605@@127.0.0.1@7432@course_db
INSERT INTO war (war_name, period, war_type, total_casualties, description, metadata)
SELECT
    'War #' || g,
    daterange(
        date '1800-01-01' + (random()*20000)::int,
        date '1800-01-01' + (random()*20000 + 1000)::int
    ),
    (ARRAY['civil','world','religious','colonial','revolutionary'])[1 + (random()*4)::int], -- низкая кардинальность
    CASE WHEN random() < 0.15 THEN NULL ELSE (random()*1000000)::int END, -- 15% NULL
    'Large scale conflict number ' || g || ' with complex geopolitical background.',
    jsonb_build_object(
        'region', (ARRAY['Europe','Asia','Africa','America'])[1 + (random()*3)::int],
        'economic_factor', random()
    )
FROM generate_series(1,100) g;