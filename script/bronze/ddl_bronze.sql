-- Tujuan script:
-- Script ini digunakan untuk membuat tabel-tabel staging/operasional.
-- Setiap tabel akan dihapus terlebih dahulu jika sudah ada, kemudian dibuat kembali.
-- Script ini dijalankan untuk mendefinisikan ulang struktur tabel
-- sebagai tempat penyimpanan data mentah hasil import dari file CSV.
--===========================================================================================================  

-- membuat tabel order
-- yang bersumber dari file CSV customer
IF OBJECT_ID('bronze.orders','U') IS NOT NULL
DROP TABLE bronze.orders
CREATE TABLE bronze.orders (
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
-- Membuat tabel customer
-- yang bersumber dari file CSV customer
IF OBJECT_ID ('bronze.customer', 'U') IS NOT NULL
	DROP TABLE bronze.customer;
CREATE TABLE bronze.customer (
	customer_id NVARCHAR(50),
	customer_name NVARCHAR(50),
	segment NVARCHAR(50)
);

-- Membuat tabel product
-- yang bersumber dari file CSV product
IF OBJECT_ID ('bronze.product', 'U') IS NOT NULL
	DROP TABLE bronze.product;
CREATE TABLE bronze.product (
	product_id NVARCHAR(50),
	category NVARCHAR(50),
	subcategory NVARCHAR(50),
	product_name NVARCHAR(200)
);

-- Membuat tabel region
-- yang bersumber dari file CSV region
IF OBJECT_ID ('bronze.region', 'U') IS NOT NULL
	DROP TABLE bronze.region;
CREATE TABLE bronze.region (
	country NVARCHAR(50),
	city NVARCHAR(50),
	state NVARCHAR(50),
	postal_code NVARCHAR(50),
	region NVARCHAR(50)
);

-- Membuat tabel shipment
-- yang bersumber dari file CSV shipment
IF OBJECT_ID ('bronze.shipment', 'U') IS NOT NULL
	DROP TABLE bronze.shipment;
CREATE TABLE bronze.shipment (
	order_id NVARCHAR(50),
	order_date NVARCHAR(50),
	ship_date NVARCHAR(50),
	ship_mode NVARCHAR(50)
);
