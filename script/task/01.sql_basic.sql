
-- 1. Hapus & buat ulang database 'Tokopaedi' 
DROP DATABASE IF EXISTS "Tokopaedi";

CREATE DATABASE tokopaedi;

\c tokopaedi;

-- 2. Drop table jika ada & buat table 'orders'
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
	order_id        VARCHAR(50),
	customer_id     VARCHAR(50),
	postal_code     VARCHAR(50),
	product_id      VARCHAR(50),
	sales           DOUBLE PRECISION,
	quantity        INT,
	discount        DOUBLE PRECISION,
	profit          DOUBLE PRECISION,
	category        VARCHAR(50),
	subcategory     VARCHAR(50),
	product_name    VARCHAR(200),
	order_date      DATE,
	ship_date       DATE,
	ship_mode       VARCHAR(50),
	customer_name   VARCHAR(50),
	segment         VARCHAR(50),
	country         VARCHAR(50),
	city            VARCHAR(50),
	state           VARCHAR(50),
	region          VARCHAR(50)
);

-- 3. Memasukan data yg ada di file csv ke table
\copy orders
FROM 'D:/belajar/My skill/datasets/orders.csv'
DELIMITER ','
CSV HEADER;
