
/*
===============================================================================
Analisis Magnitudo Data
===============================================================================
Tujuan:
    - Mengukur besaran data serta mengelompokkan hasil berdasarkan dimensi tertentu.
    - Memahami distribusi data pada berbagai kategori yang tersedia.

Fungsi SQL yang Digunakan:
    - Fungsi Agregasi: SUM(), COUNT(), AVG()
    - GROUP BY, ORDER BY
    - LEFT JOIN
===============================================================================
*/
-- Temukan total pelanggan berdasarkan region
SELECT
    state,
    COUNT(customer_key) total_customer
FROM gold.dim_customer
GROUP BY state
ORDER BY total_customer DESC

-- Temukan total pelanggan berdasarkan segment
SELECT
    segment,
    COUNT(customer_key) total_customer
FROM gold.dim_customer
GROUP BY segment
ORDER BY total_customer DESC

-- Temukan total produk berdasarkan kategori
SELECT
    category,
   COUNT(product_key) total_product
FROM gold.dim_product
GROUP BY category


-- berapa total revenue, profit dan AVG sales, profit yg dihasilan dari setiap kategory
SELECT
    p.category,
    ROUND(SUM(o.sales),2) total_sales,
    ROUND(AVG(o.sales),2) avg_sales,
    SUM(o.profit) total_profit,
    ROUND(AVG(o.profit),2) avg_profit
FROM gold.fact_orders o
LEFT JOIN gold.dim_product p
ON o.product_key = p.product_key
GROUP BY p.category


-- berapa total revenue dan profit yg dihasilkan berdasarkan tiap customers
SELECT TOP 10
    c.customer_key,
    c.customer_name,
    SUM(o.sales) total_sales,
    SUM(o.profit) total_profit
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY c.customer_key,c.customer_name
ORDER BY total_sales DESC

--bagaimana distribusi barang yg terjual dan revenuenya diberbagai kota
SELECT
    c.city,
    SUM(o.quantity) total_quantity,
    SUM(o.sales) total_sales
FROM gold.fact_orders o
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY c.city
ORDER BY 2 DESC
