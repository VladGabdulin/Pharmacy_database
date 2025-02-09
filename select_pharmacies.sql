--Запрос для получения информации о наличии лекарств, срок которых истекает в течение следующего месяца

SELECT 
    P.name AS pharmacy_name, 
    M.name AS medicine_name, 
    S.quantity, 
    S.expiration_date
FROM 
    Stock S
JOIN 
    Pharmacy P ON S.pharmacy_id = P.pharmacy_id
JOIN 
    Medicine M ON S.medicine_id = M.medicine_id
WHERE 
    S.expiration_date <= CURRENT_DATE + INTERVAL '1 month'
ORDER BY 
    S.expiration_date;


--Запрос для вывода статистики продаж по каждой аптеке 

SELECT
    P.name AS pharmacy_name,
    COUNT(SA.sale_id) AS total_sales_count,
    SUM(SA.quantity_sold * ST.price) AS total_sales_amount
FROM
    Sales SA
JOIN
    Stock ST ON SA.stock_id = ST.stock_id
JOIN
    Pharmacy P ON ST.pharmacy_id = P.pharmacy_id
WHERE
    ST.date BETWEEN '01-01-2024' AND '01-04-2024' 
GROUP BY
    P.pharmacy_id
ORDER BY
    total_sales_amount DESC;



--запрос для вывода отзывов с оценкой < 3

SELECT 
    P.name AS pharmacy_name, 
    U.username, 
    R.rating, 
    R.comment, 
    R.review_date
FROM 
    Reviews R
JOIN 
    Pharmacy P ON R.pharmacy_id = P.pharmacy_id
JOIN 
    Users U ON R.user_id = U.user_id
WHERE 
    R.rating < 3
ORDER BY 
    R.review_date DESC;


--Запрос для определения пользователей, которые сделали более двух заказов, и суммарной стоимости их заказов, включая скидки

SELECT 
    U.user_id,
    U.username,
    COUNT(O.order_id) AS total_orders,
    SUM(SD.discount + PD.discount) AS total_discount,
    SUM(ST.price * SL.quantity_sold * (1 - (COALESCE(SD.discount, 0) + COALESCE(PD.discount, 0)) / 100)) AS total_spent
FROM 
    Users U
JOIN 
    Orders O ON U.user_id = O.user_id
JOIN 
    Sales SL ON O.order_id = SL.order_id
JOIN 
    Stock ST ON SL.stock_id = ST.stock_id
LEFT JOIN 
    Season_discounts SD ON O.season_discount_id = SD.season_discount_id
LEFT JOIN 
    Personal_discounts PD ON O.personal_discount_id = PD.personal_discount_id
GROUP BY 
    U.user_id
HAVING 
    COUNT(O.order_id) > 2
ORDER BY 
    total_spent DESC;


--Запрос для анализа динамики продаж с детализацией по месяцам и аптекам

SELECT 
    P.name AS pharmacy_name,
    TO_CHAR(O.date, 'YYYY-MM') AS month,
    SUM(SL.quantity_sold) AS total_quantity_sold,
    SUM(ST.price * SL.quantity_sold) AS total_revenue
FROM 
    Sales SL
JOIN 
    Stock ST ON SL.stock_id = ST.stock_id
JOIN 
    Orders O ON SL.order_id = O.order_id
JOIN 
    Pharmacy P ON O.pharmacy_id = P.pharmacy_id
GROUP BY 
    P.pharmacy_id, TO_CHAR(O.date, 'YYYY-MM')
ORDER BY 
    pharmacy_name, month;




--Запрос для анализа эффективности скидок: расчет среднего количества заказов и дохода для пользователей с разными уровнями социальной скидки

SELECT 
    SD.user_status,
    SD.discount AS social_discount,
    COUNT(DISTINCT O.order_id) AS total_orders,
    AVG(ST.price * SL.quantity_sold * (1 - SD.discount / 100)) AS avg_revenue_per_order,
    SUM(ST.price * SL.quantity_sold * (1 - SD.discount / 100)) AS total_revenue
FROM 
    Users U
JOIN 
    Social_discounts SD ON U.user_status = SD.user_status
JOIN 
    Orders O ON U.user_id = O.user_id
JOIN 
    Sales SL ON O.order_id = SL.order_id
JOIN 
    Stock ST ON SL.stock_id = ST.stock_id
GROUP BY 
    SD.user_status, SD.discount
ORDER BY 
    total_revenue DESC;



--Запрос для определения популярных лекарств и анализа аптек с наибольшим спросом на них


WITH Popular_Medicines AS (
    SELECT 
        S.medicine_id,
        M.name AS medicine_name,
        SUM(SL.quantity_sold) AS total_quantity_sold
    FROM 
        Sales SL
    JOIN 
        Stock S ON SL.stock_id = S.stock_id
    JOIN 
        Medicine M ON S.medicine_id = M.medicine_id
    GROUP BY 
        S.medicine_id, M.name
    HAVING 
        SUM(SL.quantity_sold) > 10  
)
SELECT 
    PM.medicine_name,
    P.name AS pharmacy_name,
    SUM(SL.quantity_sold) AS pharmacy_sales_for_medicine
FROM 
    Popular_Medicines PM
JOIN 
    Stock S ON PM.medicine_id = S.medicine_id
JOIN 
    Sales SL ON S.stock_id = SL.stock_id
JOIN 
    Pharmacy P ON S.pharmacy_id = P.pharmacy_id
GROUP BY 
    PM.medicine_name, P.name
ORDER BY 
    PM.medicine_name, pharmacy_sales_for_medicine DESC;


