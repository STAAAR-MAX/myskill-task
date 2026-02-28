/*
===============================================================================
2. Analisis Kumulatif (Cumulative Analysis)
===============================================================================
Tujuan:
    - Menghitung total berjalan (running total) atau rata-rata bergerak
      untuk metrik utama.
    - Memantau kinerja secara kumulatif dari waktu ke waktu.
    - Berguna untuk analisis pertumbuhan dan identifikasi tren jangka panjang.

Rumus: gabungan cumulatif measeure by dimensi tanggal
misalnya running total sales by year, moving average of sales by month

Fungsi SQL yang Digunakan:
    - Fungsi Window: SUM() OVER(), AVG() OVER()
===============================================================================

TASK: hitung total sales per bulan dan running total of sales waktu ke waktu */
SELECT
    year_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY year_date) AS running_total
FROM (
SELECT
    DATETRUNC(month, order_date) year_date,
    ROUND(SUM(sales),2) total_sales
FROM gold.fact_orders
GROUP BY DATETRUNC(month, order_date)
)t

-- hitung pertahunnya
SELECT
    year_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY year_date) AS running_total
FROM (
SELECT
    DATETRUNC(year, order_date) year_date,
    ROUND(SUM(sales),2) total_sales
FROM gold.fact_orders
GROUP BY DATETRUNC(year, order_date)
)t

--hitung moving average sales by month
SELECT*
FROM (
    SELECT
        year_date,
        AVG_sales,
        AVG(AVG_sales) OVER(ORDER BY year_date) AS moving_avg
            FROM (
            SELECT
                DATETRUNC(month, order_date) year_date,
                ROUND(AVG(sales),2) AVG_sales
            FROM gold.fact_orders
            GROUP BY DATETRUNC(month, order_date)
                 )t
        )X
WHERE AVG_sales > moving_avg
    AND year_date >= '2020-01-01' AND year_date < '2021-01-01'
