/*
===============================================================================
03. Performa Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Tujuan:
    - Mengukur kinerja produk, pelanggan, atau wilayah dari waktu ke waktu.
    - Digunakan untuk benchmarking serta mengidentifikasi entitas
      dengan performa tinggi.
    - Memantau tren dan pertumbuhan tahunan maupun bulanan.

Fungsi SQL yang Digunakan:
    - LAG(): Mengakses data pada baris sebelumnya.
    - AVG() OVER(): Menghitung nilai rata-rata dalam suatu partisi.
    - CASE: Menentukan logika kondisi untuk analisis tren.

Rumusnya: CURRENT[MEASURE]] - TARGET[MEASURE]
Misalnya: current sales - average sales
		  current year sales - previous year sales -- YOY analisis
		  current sales - lowest sales
===============================================================================

TASK: Analisis kinerja tahunan produk dengan membandingkan penjualan setiap subcategory product dengan 
	kinerja penjualan rata-rata setiap produk dan hitung juda penjualan tahun sebelumnya (yoy).
*/
WITH CTE_base AS (
SELECT 
    p.subcategory,
    DATETRUNC(year, o.order_date) year_date,
    SUM(o.sales) cy_total_sales
FROM gold.fact_orders o
LEFT JOIN gold.dim_product p
ON o.product_key = p.product_key
GROUP BY p.subcategory,
    DATETRUNC(year, o.order_date)
),
CTE_subcategory AS (
SELECT
    subcategory,
    year_date,
    cy_total_sales,
    LAG(cy_total_sales) OVER(PARTITION BY subcategory ORDER BY year_date) AS py_total_sales,
    AVG(cy_total_sales) OVER(PARTITION BY subcategory) AS avg_sales
FROM CTE_base
)
SELECT 
    subcategory,
    year_date,
    cy_total_sales,
    py_total_sales,
    ROUND(cy_total_sales - py_total_sales,2) AS yoy,
    ROUND(avg_sales,2) avg_sales,
    CASE 
        WHEN cy_total_sales - py_total_sales > 0 THEN 'Increase'
        WHEN cy_total_sales - py_total_sales < 0 THEN 'Decrease'
    ELSE 'No Change'
END category,
    CASE 
        WHEN cy_total_sales > avg_sales THEN 'Above Average'
        ELSE 'Below Average'
    END criteria
FROM CTE_subcategory

--TASK: Analisis kinerja tahunan produk dengan membandingkan profit setiap kota dengan  
--      kinerja proft rata-rata setiap kota dan hitung juga profit tahun sebelumnya (yoy). hitung tahun 2020
WITH CTE_yearlysum AS (
SELECT
    c.state,
    FORMAT(o.order_date, 'yyyy-MM') year_month,
    ROUND(SUM(o.profit),2) total_profit
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
WHERE o.order_date >= '2020-01-01' AND o.order_date < '2021-01-01'
GROUP BY c.state,
        FORMAT(o.order_date, 'yyyy-MM')
),
CTE_state AS (
SELECT
    state,
    year_month,
    total_profit,
    LAG(total_profit) OVER(PARTITION BY state ORDER BY year_month) prev_profit,
    AVG(total_profit) OVER(PARTITION BY state) avg_profit
FROM CTE_yearlysum
)
SELECT
    state,
    year_month,
    total_profit,
    prev_profit,
    total_profit - prev_profit AS YoY,
    ROUND(avg_profit,2) avg_profit,
    CASE 
        WHEN total_profit - prev_profit > 0 THEN 'Increase'
        WHEN total_profit - prev_profit < 0 THEN 'Below'
        ELSE 'No change'
    END category
FROM CTE_state
WHERE total_profit > avg_profit
