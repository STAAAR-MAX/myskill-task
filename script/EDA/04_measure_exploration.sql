/*
===============================================================================
Eksplorasi Measures (Metrik Utama)
===============================================================================
Tujuan:
    - Menghitung metrik agregat (misalnya total dan rata-rata) untuk
      memperoleh gambaran cepat terhadap data.
    - Mengidentifikasi tren umum maupun kemungkinan anomali pada data.

Fungsi SQL yang Digunakan:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Level aggregasi tertinggi | Level detail terendah
-- Task:
-- Temukan total orders,customer yg order,product yg terjual, kuantitas, penjualan, profit & avg sales,profit
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_key) total_customer_order,
    COUNT(DISTINCT product_key) total_product_sales,
    SUM(quantity) AS total_quantity,
    ROUND(SUM(sales),2) AS total_sales,
    SUM(profit) AS total_profit,
    ROUND(AVG(sales),2) AS avg_sales,
    ROUND(AVG(profit),2) AS avg_profit
FROM gold.fact_orders o

-- temukan total jumlah customer
SELECT
    COUNT(customer_key) total_customer
FROM gold.dim_customer

-- temukan total jumlah product
SELECT
    COUNT(product_key) total_product
FROM gold.dim_product
