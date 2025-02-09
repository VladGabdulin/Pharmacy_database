-- Таблица Social_discounts (Социальные скидки)
CREATE TABLE Social_discounts (
    user_status VARCHAR(50) PRIMARY KEY,
    discount DECIMAL(5, 2) NOT NULL
);

-- Таблица Users (Пользователи)
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    user_status VARCHAR(50) NOT NULL REFERENCES Social_discounts(user_status),
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    contact_info TEXT
);

-- Таблица Pharmacy (Аптека)
CREATE TABLE Pharmacy (
    pharmacy_id SERIAL PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    telephone VARCHAR(15),
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100)
);

-- Таблица Medicine (Лекарство)
CREATE TABLE Medicine (
    medicine_id SERIAL PRIMARY KEY,
    manufacturer VARCHAR(100) NOT NULL,
    quantity_per_package INTEGER NOT NULL CHECK (quantity_per_package > 0),
    name VARCHAR(100) NOT NULL,
    readings TEXT,
    contraindication TEXT
);

-- Таблица Stock (Наличие)
CREATE TABLE Stock (
    stock_id SERIAL PRIMARY KEY,
    pharmacy_id INTEGER NOT NULL REFERENCES Pharmacy(pharmacy_id),
    medicine_id INTEGER NOT NULL REFERENCES Medicine(medicine_id),
    date DATE NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    expiration_date DATE NOT NULL
);

-- Таблица Orders (Заказы)
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users(user_id),
    season_discount_id INTEGER REFERENCES Season_discounts(season_discount_id),
    personal_discount_id INTEGER REFERENCES Personal_discounts(personal_discount_id),
    pharmacy_id INTEGER NOT NULL REFERENCES Pharmacy(pharmacy_id),
    order_status VARCHAR(50) NOT NULL,
    date DATE NOT NULL
);

-- Таблица Sales (Продажи)
CREATE TABLE Sales (
    sale_id SERIAL PRIMARY KEY,
    stock_id INTEGER NOT NULL REFERENCES Stock(stock_id),
    order_id INTEGER NOT NULL REFERENCES Orders(order_id),
    quantity_sold INTEGER NOT NULL CHECK (quantity_sold > 0)
);

-- Таблица Season_discounts (Сезонные скидки)
CREATE TABLE Season_discounts (
    season_discount_id SERIAL PRIMARY KEY,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    discount DECIMAL(5, 2) NOT NULL
);

-- Таблица Personal_discounts (Персональные скидки)
CREATE TABLE Personal_discounts (
    personal_discount_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users(user_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    discount DECIMAL(5, 2) NOT NULL
);

-- Таблица Reviews (Отзывы)
CREATE TABLE Reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES Users(user_id),
    pharmacy_id INTEGER NOT NULL REFERENCES Pharmacy(pharmacy_id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    review_date DATE NOT NULL
);
