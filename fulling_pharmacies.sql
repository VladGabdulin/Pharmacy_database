COPY Social_discounts (user_status, discount)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Social_discounts.csv' DELIMITER ',' CSV HEADER;

COPY Users (user_id, user_status, username, password, role, contact_info)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Users.csv' DELIMITER ',' CSV HEADER;

COPY Pharmacy (pharmacy_id, address, telephone, name, specialization)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Pharmacy.csv' DELIMITER ',' CSV HEADER;

COPY Medicine (medicine_id, manufacturer, quantity_per_package, name, readings, contraindication)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Medicine.csv' DELIMITER ',' CSV HEADER;

COPY Stock (stock_id, pharmacy_id, medicine_id, date, price, quantity, expiration_date)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Stock.csv' DELIMITER ',' CSV HEADER;

COPY Personal_discounts (personal_discount_id, user_id, start_date, end_date, discount)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Personal_discounts.csv' DELIMITER ',' CSV HEADER;

COPY Season_discounts (season_discount_id, start_date, end_date, discount)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Season_discounts.csv' DELIMITER ',' CSV HEADER;

COPY Orders (order_id, user_id, season_discount_id, personal_discount_id, pharmacy_id, order_status, date)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Orders.csv' DELIMITER ',' CSV HEADER;

COPY Sales (sale_id, stock_id, order_id, quantity_sold)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Sales.csv' DELIMITER ',' CSV HEADER;

COPY Reviews (review_id, user_id, pharmacy_id, rating, comment, review_date)
FROM 'C:\Program Files\PostgreSQL\11\pharmacies_data\Reviews.csv' DELIMITER ',' CSV HEADER;


