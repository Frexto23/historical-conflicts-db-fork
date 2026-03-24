SELECT 'war' AS table_name, COUNT(*) AS rows FROM war
UNION ALL
SELECT 'battle', COUNT(*) FROM battle
UNION ALL
SELECT 'military_unit', COUNT(*) FROM military_unit
UNION ALL
SELECT 'casualty_report', COUNT(*) FROM casualty_report
UNION ALL
SELECT 'state', COUNT(*) FROM state;

-- Для battle: report, extra_data, commander_ids
SELECT 
    'battle.report' AS column_name,
    COUNT(*) AS total,
    COUNT(report) AS not_null,
    COUNT(*) - COUNT(report) AS null_count,
    round(100.0 * (COUNT(*) - COUNT(report)) / COUNT(*), 2) AS null_percent
FROM battle
UNION ALL
SELECT 
    'battle.extra_data',
    COUNT(*),
    COUNT(extra_data),
    COUNT(*) - COUNT(extra_data),
    round(100.0 * (COUNT(*) - COUNT(extra_data)) / COUNT(*), 2)
FROM battle
UNION ALL
SELECT 
    'battle.commander_ids',
    COUNT(*),
    COUNT(commander_ids),
    COUNT(*) - COUNT(commander_ids),
    round(100.0 * (COUNT(*) - COUNT(commander_ids)) / COUNT(*), 2)
FROM battle;

WITH war_stats AS (
    SELECT 
        war_id,
        COUNT(*) AS battles_per_war,
        PERCENT_RANK() OVER (ORDER BY war_id) AS percentile
    FROM battle
    GROUP BY war_id
)
SELECT 
    SUM(CASE WHEN percentile <= 0.1 THEN battles_per_war ELSE 0 END) AS battles_in_top_10_percent_wars,
    SUM(battles_per_war) AS total_battles,
    round(100.0 * SUM(CASE WHEN percentile <= 0.1 THEN battles_per_war ELSE 0 END) / SUM(battles_per_war), 2) AS percent_in_top_10
FROM war_stats;

-- Низкая кардинальность (должно быть мало уникальных значений)
SELECT 'war.war_type' AS column_name, COUNT(DISTINCT war_type) AS unique_values FROM war
UNION ALL
SELECT 'battle.result', COUNT(DISTINCT result) FROM battle
UNION ALL
SELECT 'casualty_report.category', COUNT(DISTINCT category) FROM casualty_report
UNION ALL
SELECT 'state.ideology', COUNT(DISTINCT ideology) FROM state;

-- Высокая кардинальность (должно быть почти столько же, сколько строк)
SELECT 'battle.battle_name' AS column_name, COUNT(DISTINCT battle_name) AS unique_values, COUNT(*) AS total_rows FROM battle
UNION ALL
SELECT 'war.description', COUNT(DISTINCT description), COUNT(*) FROM war;

-- war: daterange
SELECT COUNT(*) AS invalid_periods
FROM war
WHERE lower(period) > upper(period);

-- military_unit: tsrange
SELECT COUNT(*) AS invalid_active_periods
FROM military_unit
WHERE lower(active_period) > upper(active_period);

-- Проверка, что есть непустые JSONB
SELECT 'war.metadata' AS field, COUNT(*) FILTER (WHERE metadata IS NOT NULL AND metadata != '{}') AS non_empty_count FROM war
UNION ALL
SELECT 'battle.extra_data', COUNT(*) FILTER (WHERE extra_data IS NOT NULL AND extra_data != '{}') FROM battle
UNION ALL
SELECT 'military_unit.attributes', COUNT(*) FILTER (WHERE attributes IS NOT NULL AND attributes != '{}') FROM military_unit;

-- Проверка массивов (commander_ids)
SELECT COUNT(*) FILTER (WHERE commander_ids IS NOT NULL AND array_length(commander_ids, 1) > 0) AS non_empty_arrays FROM battle;

-- Проверка point (location)
SELECT COUNT(*) FILTER (WHERE location IS NOT NULL) AS locations_present FROM battle;

SELECT 
    'war.description' AS field,
    COUNT(*) FILTER (WHERE description IS NOT NULL AND length(description) > 0) AS non_empty
FROM war
UNION ALL
SELECT 'battle.report', COUNT(*) FILTER (WHERE report IS NOT NULL AND length(report) > 0) FROM battle
UNION ALL
SELECT 'military_unit.notes', COUNT(*) FILTER (WHERE notes IS NOT NULL AND length(notes) > 0) FROM military_unit
UNION ALL
SELECT 'casualty_report.details', COUNT(*) FILTER (WHERE details IS NOT NULL AND length(details) > 0) FROM casualty_report;