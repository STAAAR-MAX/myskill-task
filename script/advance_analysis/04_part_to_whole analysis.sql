===============================================================================
4. Analisis Bagian terhadap Keseluruhan (Part-to-Whole Analysis)
===============================================================================
Tujuan:
    - Membandingkan kinerja atau metrik antar dimensi
      maupun antar periode waktu.
    - Mengevaluasi perbedaan kontribusi antar kategori.
    - Berguna untuk analisis A/B testing atau perbandingan wilayah.

Fungsi SQL yang Digunakan:
    - SUM(), AVG(): Menghitung nilai agregasi untuk keperluan perbandingan.
    - Fungsi Window: SUM() OVER() untuk perhitungan total keseluruhan.

Rumus: ([MEASURE]/TOTAL MEASURE])* 100 BY [DIMENSI]
Contohnya (sales/total sales)*100% by category
		  (quantity/total quantity)*100 by country
===============================================================================
TASK: kategori mana yg paling banyak berkontribusi pd seluruh penjualan
	*/
SELECT 
    category,
    total_salesbycat,
    SUM(total_salesbycat) OVER () sales,
    ROUND((total_salesbycat / SUM(total_salesbycat) OVER ())*100,2) [part_to_whole %]
FROM (
        SELECT  
            p.category,
            ROUND(SUM(o.sales),2) total_salesbycat
        FROM gold.fact_orders o
        LEFT JOIN gold.dim_product p
        ON o.product_key = p.product_key
        GROUP BY p.category
)t

-- TASK: kota mana yg paling banyak berkontribusi pd seluruh penjualan
WITH CTE_sum AS (
SELECT
    c.city,
    SUM(o.sales) total_sales_by_city
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY c.city
)
SELECT
    city,
    total_sales_by_city,
    SUM(total_sales_by_city) OVER() total_sales,
    ROUND((total_sales_by_city / SUM(total_sales_by_city) OVER())*100,2) AS [part_to_whole %]
FROM CTE_sum 
ORDER BY [part_to_whole %] DESC
