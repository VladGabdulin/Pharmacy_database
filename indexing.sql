-- 1. Запрос к одной таблице с фильтрацией по нескольким полям
EXPLAIN ANALYZE
SELECT pharmacy_id, sale_date, SUM(total_amount)
FROM sales_fact
WHERE sale_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND pharmacy_id IN (1, 2, 3)
GROUP BY pharmacy_id, sale_date
ORDER BY sale_date;

-- 2. Запрос с несколькими связанными таблицами
EXPLAIN ANALYZE
SELECT sf.sales_id, sf.sale_date, sf.total_amount, st.pharmacy_id, st.medicine_id, u.user_status
FROM sales_fact sf
JOIN stock st ON sf.stock_id = st.stock_id
JOIN users u ON sf.user_id = u.user_id
WHERE sf.sale_date BETWEEN '2024-01-01' AND '2024-12-01'
  AND st.quantity > 50
  AND u.user_status IN ('VIP', 'Regular')
  AND st.expiration_date > CURRENT_DATE;


-- Создание индексов для ускорения запросов
CREATE INDEX idx_sales_fact_date_pharmacy ON sales_fact (sale_date, pharmacy_id);
CREATE INDEX idx_sales_fact_medicine ON sales_fact (stock_id);
CREATE INDEX idx_stock_medicine ON stock (medicine_id);
CREATE INDEX idx_medicines_name ON medicines (medicine_name);

-- План после создания индексов
EXPLAIN ANALYZE
SELECT pharmacy_id, sale_date, SUM(total_amount)
FROM sales_fact
WHERE sale_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND pharmacy_id IN (1, 2, 3)
GROUP BY pharmacy_id, sale_date
ORDER BY sale_date;

EXPLAIN ANALYZE
SELECT sf.sales_id, sf.sale_date, sf.total_amount, st.pharmacy_id, st.medicine_id, u.user_status
FROM sales_fact sf
JOIN stock st ON sf.stock_id = st.stock_id
JOIN users u ON sf.user_id = u.user_id
WHERE sf.sale_date BETWEEN '2024-01-01' AND '2024-12-01'
  AND st.quantity > 50
  AND u.user_status IN ('VIP', 'Regular')
  AND st.expiration_date > CURRENT_DATE;

-- Секционирование таблицы sales_fact по дате
CREATE TABLE sales_fact_2024 PARTITION OF sales_fact
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Индекс на секцию
CREATE INDEX idx_sales_fact_2024_date ON sales_fact_2024 (sale_date);

-- Удаление старых данных
DELETE FROM sales_fact
WHERE sale_date < '2023-01-01';

-- Анализ вставки данных (ускорение вставок через секционирование)
INSERT INTO sales_fact (sale_date, pharmacy_id, total_amount)
VALUES ('2024-05-15', 3, 500.00);

-- Полнотекстовый поиск по json-полю (например, description в medicines)
CREATE INDEX idx_medicines_description_gin ON medicines USING gin (to_tsvector('russian', description));

EXPLAIN ANALYZE
SELECT * FROM medicines
WHERE to_tsvector('russian', description) @@ to_tsquery('витамин & C');
