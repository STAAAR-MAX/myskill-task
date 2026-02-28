/*
===============================================================================
1. Analisis Perubahan dari Waktu ke Waktu (Change Over Time Analysis)
===============================================================================
Tujuan:
    - Melacak tren, pertumbuhan, dan perubahan pada metrik utama dari waktu ke waktu.
    - Digunakan untuk analisis deret waktu (time-series) dan identifikasi pola musiman (seasonality).
    - Mengukur pertumbuhan atau penurunan kinerja pada periode tertentu.

Fungsi SQL yang Digunakan:
    - Fungsi Tanggal: DATEPART(), DATETRUNC(), FORMAT()
    - Fungsi Agregasi: SUM(), COUNT(), AVG()

Contohnya: total sales by year, average cost by month
===============================================================================
*/
-- Task: analisis performa total order, total customer,tota product,total quantity total sales dan total profit dari tahun ke tahun/
SELECT
    YEAR(order_date) AS year_date,
    COUNT(DISTINCT order_id) total_order,
    COUNT(DISTINCT customer_key) total_customer,
    COUNT(DISTINCT product_key) total_product,
    SUM(quantity) total_quantity,
    ROUND(SUM(sales),2) total_sales,
    ROUND(SUM(profit),2) total_profit
FROM gold.fact_orders
GROUP BY YEAR(order_date)
ORDER BY total_sales DESC

-- analisis untuk bulan ke bulan
SELECT
    YEAR(order_date) year,
    MONTH(order_date) AS month_date,
    COUNT(DISTINCT order_id) total_order,
    COUNT(DISTINCT customer_key) total_customer,
    COUNT(DISTINCT product_key) total_product,
    SUM(quantity) total_quantity,
    ROUND(SUM(sales),2) total_sales,
    ROUND(SUM(profit),2) total_profit
FROM gold.fact_orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY total_sales DESC

-- menggunakan DATETRUNC 
SELECT
    DATETRUNC(year, order_date) AS year_date,
    COUNT(DISTINCT order_id) total_order,
    COUNT(DISTINCT customer_key) total_customer,
    COUNT(DISTINCT product_key) total_product,
    SUM(quantity) total_quantity,
    ROUND(SUM(sales),2) total_sales,
    ROUND(SUM(profit),2) total_profit
FROM gold.fact_orders
GROUP BY DATETRUNC(year, order_date)
ORDER BY total_sales DESC

-- menggunakan format 
SELECT
    FORMAT(order_date, 'yyyy-MM') AS year_date,
    COUNT(DISTINCT order_id) total_order,
    COUNT(DISTINCT customer_key) total_customer,
    COUNT(DISTINCT product_key) total_product,
    SUM(quantity) total_quantity,
    ROUND(SUM(sales),2) total_sales,
    ROUND(SUM(profit),2) total_profit
FROM gold.fact_orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY total_sales DESC
