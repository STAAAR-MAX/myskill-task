
/*
===============================================================================
Analisis Peringkat (Ranking)
===============================================================================
Tujuan:
    - Memberikan peringkat pada item (misalnya produk atau pelanggan)
      berdasarkan kinerja atau metrik tertentu.
    - Mengidentifikasi entitas dengan performa terbaik maupun terendah.

Fungsi SQL yang Digunakan:
    - Fungsi Ranking Window: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Klausa: GROUP BY, ORDER BY
    - subquery
===============================================================================
*/

-- apa top 10 produk dgn performa penjualan terbaik
SELECT *
FROM (
SELECT
    p.product_name,
    ROUND(SUM(o.sales),2) total_sales,
    ROW_NUMBER() OVER(ORDER BY  ROUND(SUM(o.sales),2) DESC) rnk
FROM gold.fact_orders o
LEFT JOIN gold.dim_product p
ON o.product_key = p.product_key
GROUP BY p.product_name
)t
WHERE rnk <=10

-- apa top 10 produk dgn performa penjualan terburuk
SELECT TOP 10
    p.product_name,
    ROUND(SUM(o.sales),2) total_sales,
    ROW_NUMBER() OVER(ORDER BY  ROUND(SUM(o.sales),2) ASC) rnk
FROM gold.fact_orders o
LEFT JOIN gold.dim_product p
ON o.product_key = p.product_key
GROUP BY p.product_name


-- Temukan 10 pelanggan teratas yg menghasilan revenue tertinggi
SELECT*
FROM(
SELECT
    c.customer_key,
    c.customer_name,
    SUM(o.sales) total_sales,
    SUM(o.quantity) total_quantity,
    ROW_NUMBER () OVER (ORDER BY SUM(o.sales) DESC) AS rnk
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY c.customer_key,c.customer_name
)t
WHERE rnk <=10
