CREATE USER test

-- Полный доступ к таблице Users
GRANT SELECT, INSERT, UPDATE ON TABLE Users TO test;

-- Выборочные права к таблице Customer_Behavior
GRANT SELECT (user_id, event_date, event_type), UPDATE (event_metadata) ON TABLE Customer_Behavior TO test;

-- Только SELECT к таблице Sales_Fact
GRANT SELECT ON TABLE Sales_Fact TO test;



-- Создание представления (выручка аптек за последний квартал) (неправильное, не автоматически изменяемое)
CREATE OR REPLACE VIEW Pharmacy_Last_Quarter_Revenue AS
SELECT 
    s.pharmacy_id,
    SUM(sf.total_amount) AS total_revenue_last_quarter,
    COUNT(sf.sales_id) AS total_sales_last_quarter
FROM 
    Sales_Fact sf
JOIN 
    Stock s ON sf.stock_id = s.stock_id
WHERE 
    sf.sale_date >= DATE_TRUNC('quarter', CURRENT_DATE) - INTERVAL '3 months'
    AND sf.sale_date < DATE_TRUNC('quarter', CURRENT_DATE)
GROUP BY 
    s.pharmacy_id;

-- Право SELECT пользователю test
GRANT SELECT ON Pharmacy_Last_Quarter_Revenue TO test;

-- Создание роли
CREATE ROLE test_role;

-- Назначение прав
GRANT UPDATE (total_revenue_last_quarter, total_sales_last_quarter) ON Pharmacy_Last_Quarter_Revenue TO test_role;

-- Назначение роли пользователю test
GRANT test_role TO test;

-- Проверка 
-- Сменить пользователя
SET SESSION AUTHORIZATION test;
-- Выборка данных из представления Pharmacy_Last_Quarter_Revenue
SELECT * FROM Pharmacy_Last_Quarter_Revenue;
-- Вставка нового пользователя
INSERT INTO Users (username, password, role, user_status) 
VALUES ('new_user', 'new_password', 'customer', 'Regular');

-- Обновление информации
UPDATE Users
SET total_spent = total_spent + 100
WHERE user_id = 1;

-- Обновление метаданных события
UPDATE Customer_Behavior
SET event_metadata = '{"updated_field": "new_value"}'
WHERE user_id = 1;

-- Попытка обновить столбец, на который прав нет (должна выдать ошибку)
UPDATE Customer_Behavior
SET event_type = 'purchase'
WHERE user_id = 1;

-- Только SELECT, попытка INSERT или UPDATE должна выдать ошибку
SELECT * FROM Sales_Fact;
INSERT INTO Sales_Fact (stock_id, user_id, sale_date, total_amount) 
VALUES (1, 1, NOW(), 100.00); -- Ошибка


-- Другое представление (правильное, автоматически изменяемое)

GRANT UPDATE (expiration_date) on inventory_expiry_warning TO test_role;
GRANT UPDATE (expiration_date) on Stock TO test_role;
GRANT SELECT ON Stock to test_role;

UPDATE inventory_expiry_warning 
SET expiration_date = CURRENT_DATE
WHERE stock_id = 1;

CREATE OR REPLACE VIEW inventory_expiry_warning AS
SELECT
    s.stock_id,
    s.pharmacy_id,
    s.medicine_id,
    s.quantity,
    s.expiration_date,
    CASE
        WHEN s.expiration_date < CURRENT_DATE THEN 'Expired'
        WHEN s.expiration_date < CURRENT_DATE + INTERVAL '30 days' THEN 'Expiring Soon'
        ELSE 'Valid'
    END AS expiry_status
FROM
    Stock s
WHERE
    s.quantity > 0
with check option;




-- Посмотреть текущего пользователя
SELECT current_user;
-- Сменить пользователя
SET SESSION AUTHORIZATION test;
-- Откатить изменения
RESET SESSION AUTHORIZATION;
