-- ==============================================================================
-- DDL Script: Create Gold Tables
-- ==============================================================================
-- Tujuan Script:
-- Script ini digunakan untuk membuat tabel-tabel pada schema 'gold'.
-- Jika tabel sudah ada sebelumnya, maka tabel tersebut akan dihapus (DROP)
-- dan dibuat ulang (CREATE) menggunakan struktur terbaru.
--
-- Script ini dijalankan untuk mendefinisikan struktur tabel dimensional
-- dan tabel fakta yang akan digunakan untuk kebutuhan analisis dan reporting.
--
-- Layer gold berfungsi sebagai penyimpanan data yang telah melalui proses
-- transformasi lanjutan dari layer silver sehingga siap digunakan untuk:
-- - Dashboard
-- - Reporting
-- - Analisis bisnis
--
-- Tabel pada layer ini disusun menggunakan pendekatan Star Schema,
-- yang terdiri dari:
-- - Dimension Table (dim_customer, dim_product, dim_shipment)
-- - Fact Table (fact_orders)
--
-- Sumber data pada layer gold berasal dari tabel yang telah dibersihkan
-- dan distandarisasi pada layer silver.
--
-- File Script  : ddl_gold.sql
-- Schema Target: gold
-- Database     : Data Warehouse
-- ==============================================================================

-- Tabel: gold.dim_product
-- Deskripsi:
-- Tabel dimensi yang menyimpan informasi terkait produk.
-- Digunakan untuk menyediakan atribut produk pada proses analisis penjualan.
--
-- Tabel ini berisi:
-- - Identitas unik produk (product_key)
-- - Informasi kategori dan subkategori
-- - Nama produk
--
-- Tabel ini akan menjadi referensi utama bagi fact_orders
-- dalam analisis performa produk.

IF OBJECT_ID ('gold.dim_product', 'U') IS NOT NULL
	DROP TABLE gold.dim_product
CREATE TABLE gold.dim_product (
	product_key INT IDENTITY(1,1),
	product_id NVARCHAR(50),
	category NVARCHAR(50),
	subcategory NVARCHAR(50),
	product_name NVARCHAR(200)
	CONSTRAINT PK_dim_product
	PRIMARY KEY (product_key)
);
-- ------------------------------------------------------------------------------
-- Tabel: gold.dim_shipment
-- Deskripsi:
-- Tabel dimensi yang menyimpan informasi metode pengiriman.
-- Digunakan untuk analisis performa logistik dan distribusi.
--
-- Tabel ini berisi:
-- - Identitas unik pengiriman (shipment_key)
-- - ID pesanan
-- - Mode pengiriman
--
-- Tabel ini menjadi referensi pada fact_orders
-- untuk analisis berdasarkan metode pengiriman.

IF OBJECT_ID ('gold.dim_shipment', 'U') IS NOT NULL
	DROP TABLE gold.dim_shipment;
CREATE TABLE gold.dim_shipment (
	shipment_key INT IDENTITY(1,1),
	order_id NVARCHAR(50),
	ship_mode NVARCHAR(50)
	CONSTRAINT PK_dim_shipment
	PRIMARY KEY (shipment_key)
);

-- ------------------------------------------------------------------------------
-- Tabel: gold.dim_customer
-- Deskripsi:
-- Tabel dimensi yang menyimpan informasi pelanggan.
-- Digunakan untuk analisis segmentasi dan distribusi pelanggan.
--
-- Tabel ini berisi:
-- - Identitas unik pelanggan (customer_key)
-- - Informasi demografis pelanggan
-- - Lokasi pelanggan
-- - Segmentasi pelanggan
--
-- Tabel ini akan digunakan sebagai referensi utama
-- dalam fact_orders untuk analisis berbasis pelanggan.

IF OBJECT_ID ('gold.dim_customer', 'U') IS NOT NULL
	DROP TABLE gold.dim_customer;
CREATE TABLE gold.dim_customer (
	customer_key INT IDENTITY (1,1),
	customer_id NVARCHAR(50),
	postal_code NVARCHAR(50),
	customer_name NVARCHAR(50),
	segment NVARCHAR(50),
	country NVARCHAR(50),
	city NVARCHAR(50),
	state NVARCHAR(50),
	region NVARCHAR(50)
	CONSTRAINT PK_dim_customer
	PRIMARY KEY (customer_key)
);

-- ------------------------------------------------------------------------------
-- Tabel: gold.fact_orders
-- Deskripsi:
-- Tabel fakta yang menyimpan data transaksi penjualan.
-- Digunakan sebagai sumber utama analisis kinerja bisnis.
--
-- Tabel ini berisi:
-- - Informasi transaksi pesanan
-- - Relasi ke dimensi pelanggan, produk, dan pengiriman
-- - Informasi tanggal pesanan dan pengiriman
-- - Metrik utama penjualan seperti:
--     - quantity
--     - sales
--     - discount
--     - profit
--
-- Tabel ini merupakan pusat dari Star Schema
-- dan digunakan untuk kebutuhan reporting dan dashboard.

IF OBJECT_ID ('gold.fact_orders', 'U') IS NOT NULL
	DROP TABLE gold.fact_orders;
CREATE TABLE gold.fact_orders (
	order_line_number INT IDENTITY (1,1),
	order_id NVARCHAR(50) NOT NULL,
	customer_key INT NOT NULL,
	product_key INT NOT NULL,
	shipment_key INT NOT NULL,
	order_date DATE,
	ship_date DATE,
	quantity INT,
	sales FLOAT,
	discount FLOAT,
	profit FLOAT
	CONSTRAINT PK_fact_orders 
	PRIMARY KEY (order_line_number)
);

-- Membuat Foreign Key 
-- Foreign Key	
	ALTER TABLE gold.fact_orders
	ADD CONSTRAINT FK_fact_orders_customer
	FOREIGN KEY (customer_key)
	REFERENCES gold.dim_customer(customer_key);

	ALTER TABLE gold.fact_orders
	ADD CONSTRAINT FK_fact_orders_product
	FOREIGN KEY (product_key)
	REFERENCES gold.dim_product(product_key);

	ALTER TABLE gold.fact_orders
	ADD CONSTRAINT FK_fact_orders_shipment
	FOREIGN KEY (shipment_key)
	REFERENCES gold.dim_shipment(shipment_key);
