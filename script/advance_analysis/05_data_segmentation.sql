/*
===============================================================================
5. Analisis Segmentasi Data (Data Segmentation Analysis)
===============================================================================
Tujuan:
    - Mengelompokkan data ke dalam kategori yang bermakna
      untuk menghasilkan insight yang lebih terarah.
    - Digunakan untuk segmentasi pelanggan, kategorisasi produk,
      atau analisis berdasarkan wilayah.

Fungsi SQL yang Digunakan:
    - CASE: Menentukan logika segmentasi kustom.
    - GROUP BY: Mengelompokkan data ke dalam segmen.

Rumusnya: [MEASURE] by [MEASURE] , Jadi harus memilih satu dari dua ukuran tersebut dimana satu ukutan itu
		  akan dirubah menjadi rentang, lalu menggabungkan data berdasarkan ukuran ini
Misalnya: Total product by sales range, total customers by age

===============================================================================
Kelompokkan pelanggan ke dalam tiga segmen berdasarkan perilaku pengeluaran mereka:
- VIP: riwayat minimal 12 bulan dan pengeluaran lebih dari €5.000.
- Reguler: riwayat minimal 12 bulan tetapi pengeluaran €5.000 atau kurang.
- Baru: masa aktif kurang dari 12 bulan.
Kemudian temukan jumlah total pelanggan untuk setiap kelompok.*/

WITH CTE_summary AS(
SELECT 
    customer_name,
    MIN(order_date) first,
    MAX(order_date) last,
    DATEDIFF(month,MIN(order_date), MAX(order_date)) AS lifespan,
    SUM(sales) total_sales
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY  customer_name
),
CTE_segment AS (
SELECT 
    customer_name,
    first,
    last,
    lifespan,
    total_sales,
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN  lifespan >= 12 AND total_sales < 5000 THEN 'Reguler'
        ELSE 'New'
    END category
FROM CTE_summary
)
SELECT
    category,
    COUNT(*) total_customer
FROM CTE_segment
GROUP BY category
