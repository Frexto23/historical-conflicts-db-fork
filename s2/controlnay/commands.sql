EXPLAIN (ANALYZE, BUFFERS) SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';

CREATE INDEX idx_store_sold_at ON store_checks(sold_at);

ANALYZE;

-- Второе 

EXPLAIN (ANALYZE, BUFFERS) SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';



CREATE INDEX idx_level_hash ON club_members USING hash (member_level);
ANALYZE;



-- Задание 3

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

UPDATE warehouse_items
SET stock = stock - 2
WHERE id = 1;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

DELETE FROM warehouse_items
WHERE id = 3;

SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;

