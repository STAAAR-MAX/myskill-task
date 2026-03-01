/*
===============================================================================
Laporan Pelanggan (Customer Report)
===============================================================================
Tujuan:
    Laporan ini bertujuan untuk mengonsolidasikan metrik utama dan perilaku
    pelanggan berdasarkan data transaksi.

Highlight:
    1. Mengambil atribut penting pelanggan:
       - Nama pelanggan
       - Detail transaksi
    2. Melakukan segmentasi pelanggan berdasarkan:
       - Kategori pelanggan (VIP, Reguler, New)
    3. Menghitung metrik agregasi pada level pelanggan:
       - Total jumlah pesanan
       - Total nilai penjualan
       - Total kuantitas pembelian
       - Total produk yang dibeli
       - Lama hubungan pelanggan (lifespan dalam bulan)
    4. Menghitung Key Performance Indicators (KPI):
       - Recency (bulan sejak transaksi terakhir)
       - Average Order Value = Total Sales / Total Orders
       - Average Monthly Spend =  Total Sales / Lifespan (bulan)
===============================================================================
*/
-- =============================================================================
-- Membuat Report: gold.report_customers
-- =============================================================================

-- =============================================================================
-- 1. Base Query
-- Mengambil kolom-kolom penting dari tabel fakta dan dimensi pelanggan
-- =============================================================================
WITH CTE_base AS (
SELECT
    o.order_id,
    c.customer_key,
    c.customer_name,
    o.product_key,
    o.order_date,
    o.quantity,
    o.sales
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
),
CTE_summarize AS (
SELECT
    customer_key,
    customer_name,
    COUNT(order_id) total_order,
    COUNT(DISTINCT product_key) total_product,
    MAX(order_date) last_order,
    DATEDIFF(month, MIN(order_date),MAX(order_date)) lifespan,
    SUM(quantity) total_quantitas,
    SUM(sales) total_sales
FROM CTE_base
GROUP BY customer_key,customer_name
)

SELECT
    customer_key,
    customer_name,
    total_order,
    total_product,
    lifespan,
    DATEDIFF(month,last_order, '2021-01-01') recency,
    total_quantitas,
    total_sales,
    ROUND(total_sales/total_order,2) AS AOV,
    CASE
        WHEN lifespan !=0 THEN ROUND(total_sales/lifespan,2)
        ELSE total_sales
    END avg_monthly_spend,
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN  lifespan >= 12 AND total_sales < 5000 THEN 'Reguler'
        ELSE 'New'
    END category
FROM CTE_summarize
ORDER BY total_sales DESC
