-- ==============================================================================
-- DDL Script: Create Silver Tables
-- ==============================================================================

-- Tujuan Script:
-- Script ini digunakan untuk membuat tabel-tabel pada schema 'silver'.
-- Jika tabel sudah ada sebelumnya, maka tabel tersebut akan dihapus (DROP)
-- dan dibuat ulang (CREATE) menggunakan struktur terbaru.
--
-- Script ini dijalankan untuk mendefinisikan ulang struktur DDL
-- dari tabel-tabel pada layer bronze ke layer silver.
--
-- Layer silver berfungsi sebagai penyimpanan data yang telah melalui
-- proses pembersihan dasar (cleansing), standarisasi, dan validasi awal
-- sebelum digunakan pada layer berikutnya (gold).
--
-- Sumber data pada layer silver berasal dari file CSV
-- yang telah dimuat sebelumnya ke layer bronze.
--
-- File Script  : ddl_silver.sql
-- Schema Target: silver
-- Database     : Data Warehouse
-- ==============================================================================

-- membuat tabel pada database Tokopaedi di silver layer
-- yang bersumber dari file CSV orders
IF OBJECT_ID('silver.orders','U') IS NOT NULL
DROP TABLE silver.orders
CREATE TABLE silver.orders (
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
	region          VARCHAR(50),
	dwh_create_time DATETIME2 DEFAULT GETDATE()
);
-- membuat tabel pada database Tokopaedi di silver layer
-- yang bersumber dari file CSV customer
IF OBJECT_ID ('silver.customer', 'U') IS NOT NULL
	DROP TABLE silver.customer;
CREATE TABLE silver.customer (
	customer_id NVARCHAR(50),
	customer_name NVARCHAR(50),
	segment NVARCHAR(50),
	dwh_create_time DATETIME2 DEFAULT GETDATE()

);

-- membuat tabel pada database Tokopaedi di silver layer
-- yang bersumber dari file CSV product
IF OBJECT_ID ('silver.product', 'U') IS NOT NULL
	DROP TABLE silver.product;
CREATE TABLE silver.product (
	product_id NVARCHAR(50),
	category NVARCHAR(50),
	subcategory NVARCHAR(50),
	product_name NVARCHAR(200),
	dwh_create_time DATETIME2 DEFAULT GETDATE()

);

-- membuat tabel pada database Tokopaedi di silver layer
-- yang bersumber dari file CSV region
IF OBJECT_ID ('silver.region', 'U') IS NOT NULL
	DROP TABLE silver.region;
CREATE TABLE silver.region (
	country NVARCHAR(50),
	city NVARCHAR(50),
	state NVARCHAR(50),
	postal_code NVARCHAR(50),
	region NVARCHAR(50),
	dwh_create_time DATETIME2 DEFAULT GETDATE()

);

-- membuat tabel pada database Tokopaedi di silver layer
-- yang bersumber dari file CSV shipment
IF OBJECT_ID ('silver.shipment', 'U') IS NOT NULL
	DROP TABLE silver.shipment;
CREATE TABLE silver.shipment (
	order_id NVARCHAR(50),
	order_date NVARCHAR(50),
	ship_date NVARCHAR(50),
	ship_mode NVARCHAR(50),
	dwh_create_time DATETIME2 DEFAULT GETDATE()
);
