--Обновление статуса заказов, которые не были обработаны более 30 дней

UPDATE Orders
SET order_status = 'Expired'
WHERE order_status = 'Processing'
  AND date < CURRENT_DATE - INTERVAL '3 months'


--Установка персональной скидки для пользователей с частыми заказами за последний месяц

INSERT INTO Personal_discounts (user_id, start_date, end_date, discount)
SELECT U.user_id, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month', 10.0
FROM Users U
JOIN Orders O ON U.user_id = O.user_id
WHERE O.date BETWEEN CURRENT_DATE - INTERVAL '6 month' AND CURRENT_DATE
GROUP BY U.user_id
HAVING COUNT(O.order_id) > 2;

--установление хэширования паролей

UPDATE Users SET password = MD5(password);


--снос аптеки (вызывает нарушение ограничений)

DELETE FROM Pharmacy
WHERE pharmacy_id = 1;


--Удаление аптеки, если у нее нет в наличии лекарств и заказов

DELETE FROM Pharmacy
WHERE pharmacy_id = 5
AND NOT EXISTS (
    SELECT 1 FROM Stock WHERE pharmacy_id = 5
)
AND NOT EXISTS (
    SELECT 1 FROM Orders WHERE pharmacy_id = 5
);


DELETE FROM Pharmacy
WHERE pharmacy_id IN (
    SELECT pharmacy_id
    FROM Pharmacy
    WHERE NOT EXISTS (
        SELECT 1 FROM Stock WHERE pharmacy_id = Pharmacy.pharmacy_id
    )
    AND NOT EXISTS (
        SELECT 1 FROM Orders WHERE pharmacy_id = Pharmacy.pharmacy_id
    )
);


--Изменение цены на товар, нарушающее бизнес-правила (например, отрицательная цена)

UPDATE Stock
SET price = -50
WHERE stock_id = 10;



--Изменение даты окончания скидки на более раннюю, чем дата начала

UPDATE Season_discounts
SET end_date = '2024-01-01'
WHERE season_discount_id = 1


