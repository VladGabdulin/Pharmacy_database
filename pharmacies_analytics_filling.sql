/*
Направления аналитики:
1) Продажи и выручка - средний чек, прибыль, сезонные изменения спроса, распределение выручки по пользователям (сегментация по статусу), сравнение продаж в разных точках
2) Анализ покупательского поведения - частота и цели взаимодействий с приложением, популярность определенных типов событий
3) Эффективность скидок
4) Управление запасами (таблица Stock)
5) Обратная связь и рейтинг
*/

--СОЗДАНИЕ ТАБЛИЦ______________________________________

-- Таблица Users
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    user_status VARCHAR(50) NOT NULL REFERENCES Social_discounts(user_status),
    username VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    contact_info TEXT,
    total_orders INTEGER DEFAULT 0,
    total_spent DECIMAL(10, 2) DEFAULT 0.00,
    preferences JSON
);

-- Таблица Social_discounts
CREATE TABLE Social_discounts (
    user_status VARCHAR(50) PRIMARY KEY,
    discount DECIMAL(5, 2) NOT NULL
);

-- Таблица Customer_Behavior
CREATE TABLE Customer_Behavior (
    user_id INTEGER NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    event_date TIMESTAMP NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_metadata JSON,
    PRIMARY KEY (user_id, event_date, event_type)
);

-- Таблица Stock
CREATE TABLE Stock (
    stock_id SERIAL PRIMARY KEY,
    pharmacy_id INTEGER NOT NULL,
    medicine_id INTEGER NOT NULL,
    date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    expiration_date DATE
);

-- Таблица Sales_Fact
CREATE TABLE Sales_Fact (
    sales_id SERIAL PRIMARY KEY,
    stock_id INTEGER NOT NULL REFERENCES Stock(stock_id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES Users(user_id) ON DELETE CASCADE,
    user_status VARCHAR(50) NOT NULL REFERENCES Social_discounts(user_status),
    sale_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    medicines INTEGER[][2] NOT NULL,
    season_discount_id INTEGER,
    season_discount DECIMAL(5, 2) DEFAULT 0.00,
    personal_discount_id INTEGER,
    personal_discount DECIMAL(5, 2) DEFAULT 0.00,
    review_rating INTEGER CHECK (review_rating >= 1 AND review_rating <= 5),
    review_comment TEXT
);


--ЗАПОЛНЕНИЕ ТАБЛИЦ________________________________________________


-- Функция для генерации случайного массива с вложенными массивами
CREATE OR REPLACE FUNCTION generate_medicines_array()
RETURNS integer[][2] AS $$
DECLARE
    result integer[][2];    -- Массив, который будем возвращать
    num_arrays integer;     -- Количество вложенных массивов
    i integer;              -- Индекс для цикла
    random_medicine integer; -- Случайное лекарство (ID)
    random_quantity integer; -- Случайное количество
BEGIN
    -- Генерируем случайное количество вложенных массивов (от 1 до 5)
    num_arrays := FLOOR(RANDOM() * 5) + 1;

    -- Инициализируем пустой массив
    result := '{}'::integer[][2];  -- Указываем явно тип массива

    -- Наполняем массив
    FOR i IN 1..num_arrays LOOP
        random_medicine := FLOOR(RANDOM() * 100) + 1; -- Лекарство (ID) в диапазоне 1-100
        random_quantity := FLOOR(RANDOM() * 10) + 1;  -- Количество (1-10)
        
        -- Конкатенируем текущий вложенный массив с результатом
        result := result || ARRAY[random_medicine, random_quantity]::integer[2];
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Обновление таблицы sales_fact
UPDATE sales_fact
SET medicines = generate_medicines_array();






--ТАБЛИЦА SALES_FACT

DO $$
DECLARE
    record_count INTEGER := 10000000;
    medicines INTEGER[]; -- Список идентификаторов лекарств
BEGIN
    FOR i IN 1..record_count LOOP
        -- Создаем массив лекарств
        medicines := ARRAY[
            (i % 5000 + 1),
            ((i + 1) % 5000 + 1)
        ];

        INSERT INTO Sales_Fact (
            stock_id, user_id, user_status, sale_date, total_amount, medicines, season_discount_id,
            season_discount, personal_discount_id, personal_discount, review_rating, review_comment
        )
        VALUES (
            i % 1000000 + 1, -- stock_id
            i % 1000000 + 1, -- user_id
            CASE
                WHEN i % 4 = 0 THEN 'VIP'
                WHEN i % 3 = 0 THEN 'Regular'
                ELSE 'New'
            END,
            NOW() - (i % 365) * INTERVAL '1 day',
            (i % 200) + 50.00, -- сумма от 50 до 250
            medicines, -- массив лекарств
            CASE WHEN i % 5 = 0 THEN i % 1000 + 1 ELSE NULL END, -- season_discount_id
            CASE WHEN i % 5 = 0 THEN (i % 15) + 5.00 ELSE 0.00 END, -- сезонная скидка
            CASE WHEN i % 7 = 0 THEN i % 2000 + 1 ELSE NULL END, -- personal_discount_id
            CASE WHEN i % 7 = 0 THEN (i % 20) + 5.00 ELSE 0.00 END, -- персональная скидка
            (i % 5) + 1, -- рейтинг отзыва
            CASE WHEN i % 10 = 0 THEN CONCAT('Review comment for sale ', i) ELSE NULL END
        );
    END LOOP;
END $$;



--ТАБЛИЦА CUSTOMER_BEHAVIOR

DO $$
DECLARE
    record_count INTEGER := 10000000;
    event_type TEXT;
    metadata JSON;
BEGIN
    FOR i IN 1..record_count LOOP
        -- Определение типа события и соответствующих метаданных
        event_type := CASE
            WHEN i % 3 = 0 THEN 'search'
            WHEN i % 3 = 1 THEN 'add_to_cart'
            ELSE 'purchase'
        END;

        metadata := CASE
            WHEN event_type = 'search' THEN json_build_object('search_term', CONCAT('search_', i))
            WHEN event_type = 'add_to_cart' THEN json_build_object('cart_items', (i % 10) + 1)
            ELSE json_build_object(
                'order_id', i,
                'payment_method', CASE WHEN i % 2 = 0 THEN 'credit_card' ELSE 'paypal' END
            )
        END;

        INSERT INTO Customer_Behavior (user_id, event_date, event_type, event_metadata)
        VALUES (
            i % 1000000 + 1, -- user_id
            NOW() - (i % 365) * INTERVAL '1 day',
            event_type,
            metadata
        );
    END LOOP;
END $$;


--ТАБЛИЦА STOCK

DO $$
DECLARE
    stock_count INTEGER := 1000000;
BEGIN
    FOR i IN 1..stock_count LOOP
        INSERT INTO Stock (
            pharmacy_id, medicine_id, date, price, quantity, expiration_date
        )
        VALUES (
            (1 + floor(random() * 1000))::INTEGER,
            (1 + floor(random() * 1000))::INTEGER,
            NOW() - (random() * INTERVAL '1 year'),
            (random() * 500)::NUMERIC(10, 2),
            (1 + floor(random() * 500))::INTEGER,
            NOW() + (random() * INTERVAL '2 years')
        );
    END LOOP;
END $$;

--ТАБЛИЦА USERS

DO $$
DECLARE
    user_count INTEGER := 1000000;
    category TEXT;
    brand TEXT;
BEGIN
    FOR i IN 1..user_count LOOP
        -- Определение значений для JSON вручную через CASE
        category := CASE
            WHEN i % 3 = 0 THEN 'Витамины'
            WHEN i % 3 = 1 THEN 'Противовирусные'
            ELSE 'Анальгетики'
        END;

        brand := CASE
            WHEN i % 3 = 0 THEN 'Brand1'
            WHEN i % 3 = 1 THEN 'Brand2'
            ELSE 'Brand3'
        END;

        INSERT INTO Users (
            username, password, role, contact_info, user_status, preferences
        )
        VALUES (
            CONCAT('user_', i),
            CONCAT('pass_', i),
            CASE WHEN i % 10 = 0 THEN 'admin' ELSE 'user' END,
            CONCAT('contact_', i, '@example.com'),
            CASE
                WHEN i % 4 = 0 THEN 'VIP'
                WHEN i % 3 = 0 THEN 'Regular'
                ELSE 'New'
            END,
            jsonb_build_object(
                'categories', category,
                'brands', brand,
                'notifications', jsonb_build_object(
                    'email', (i % 2) = 0,
                    'sms', (i % 3) = 0
                )
            )
        );
    END LOOP;
END $$;
