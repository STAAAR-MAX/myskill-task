/*
===============================================================================
Eksplorasi Rentang Tanggal Data
===============================================================================
Tujuan:
    - Menentukan batas waktu awal dan akhir dari data utama.
    - Memahami cakupan periode data historis yang tersedia.

Fungsi SQL yang Digunakan:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/
-- temukan tanggal pemesanan pertama dan terakhir
SELECT
    MIN(order_date) first_order_date,
    MAX(order_date) last_order_date,
    DATEDIFF(year, MIN(order_date),MAX(order_date)) order_range_year
FROM gold.fact_orders;

-- temukan nama customer dgn tanggal order pertama dan terakhir 
SELECT
    customer_name,
    MIN(order_date) first_order_date,
    MAX(order_date) last_order_date,
    DATEDIFF(year, MIN(order_date),MAX(order_date)) order_range_year
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY customer_name
