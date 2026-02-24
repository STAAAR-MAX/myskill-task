-- Tujuan script:
-- Script ini digunakan untuk membuat tabel-tabel pd database finpro.
-- Setiap tabel akan dihapus terlebih dahulu jika sudah ada, kemudian dibuat kembali.
-- yang bersumber dari file .txt
===========================================================================================================
-- Membuat tabel order_detail untuk database FinPro
IF OBJECT_ID ('order_detail','U') IS NOT NULL
    DROP TABLE order_detail;
CREATE TABLE order_detail (
    transaction_id NVARCHAR(50),
    order_id NVARCHAR(50),
    order_date DATETIME,
    customer_id NVARCHAR(50),
    channel_type NVARCHAR(50),
    sku_id NVARCHAR(50),
    quantity INT,
    price INT,
    before_discount INT,
    discount_item INT,
    after_discount INT,
    is_gross INT,
    is_valid INT,
    is_net INT
);

-- Membuat tabel customer_detail untuk database FinPro
IF OBJECT_ID('customer_detail', 'U') IS NOT NULL
	DROP TABLE customer_detail;
CREATE TABLE customer_detail (
    customer_id NVARCHAR(50),
    registration_date DATE,
    customer_name NVARCHAR(50),
    customer_type NVARCHAR(50),
    birthday DATE,
    province NVARCHAR(50),
    registration_channel NVARCHAR(50)
);

-- Membuat tabel funnel_detail untuk database FinPro
IF OBJECT_ID ('funnel_detail', 'U') IS NOT NULL
	DROP TABLE funnel_detail;
CREATE TABLE funnel_detail (
    funnel_id NVARCHAR(50),
    channel_source NVARCHAR(50),
    customer_id NVARCHAR(50),
    sku_id NVARCHAR(50),
    funnel_date DATETIME,
    status NVARCHAR(50),
    event NVARCHAR(50),
    order_id NVARCHAR(50)
);

-- Membuat tabel transtion_detail
IF OBJECT_ID ('transaction_detail','U') IS NOT NULL
    DROP TABLE transaction_detail;
CREATE TABLE transaction_detai (
    transaction_id NVARCHAR(50),
    transaction_date DATETIME,
    customer_id  NVARCHAR(50),
    payment_method  NVARCHAR(50),
    before_tax INT,
    tax FLOAT,
    after_tax FLOAT,
    shipping_cost INT,
    transaction_discount FLOAT,
    total_paid FLOAT
);

-- Membuat tabel product_detail
IF OBJECT_ID ('product_detail','U') IS NOT NULL
    DROP TABLE product_detail;
CREATE TABLE product_detail (
    sku_id NVARCHAR(50),
    category NVARCHAR(50),
    brand NVARCHAR(50),
    product NVARCHAR(50),
    variant NVARCHAR(50),
    sku_name NVARCHAR(50),
    price INT,
    cogs INT
);


-- Membuat tabel payment_detail
IF OBJECT_ID ('payment_detail','U') IS NOT NULL
    DROP TABLE payment_detail;
CREATE TABLE payment_detail (
    id NVARCHAR(50),
    payment_method NVARCHAR(50)
);

