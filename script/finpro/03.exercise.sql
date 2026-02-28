-- total sales per bulan untuk tahun 2024, berdasarkan tabel transaction_detail (kolom total_paid). 
SELECT
	DATETRUNC(month,transaction_date) AS month_periode,
	SUM(total_paid) AS total_sales
FROM transaction_detail
WHERE transaction_date >= '2024-01-01'
	AND transaction_date < '2025-01-01'
GROUP BY DATETRUNC(month,transaction_date)
ORDER BY total_sales DESC

---------------------------------------------------------------------------------------------------------------------

-- tampilkan volume (quantity) terjual per kategori setiap tahun dari 2020 s.d. 2024.
WITH CTE_base AS (
SELECT
	p.category,
	o.quantity,
	DATETRUNC(year,o.order_date) AS year_periode
FROM order_detail o
LEFT JOIN product_detail p
ON o.sku_id = p.sku_id
WHERE is_nett = 1
)
SELECT
	category,
	Year_periode,
	SUM(quantity) volume_quantity
FROM CTE_base
GROUP BY Year_periode,category
ORDER BY year_periode ASC,
		volume_quantity DESC

---------------------------------------------------------------------------------------------------------------------

/* analisis performa channel (web, app, offline) di 2024:
1. Total orders (distinct) dan revenue (after_discount) per bulan.
2. Hitung Yoy by month growth revenue per bulan 2024 vs 2023 dalam bulan yang sama 
*/
WITH CTE_base_query AS (
SELECT
	channel_type,
	DATETRUNC(month,order_date) AS month_date,
	COUNT(DISTINCT order_id) AS total_order,
	SUM(after_discount) AS total_revenue
	FROM order_detail
WHERE order_date >= '2023-01-01'
	AND order_date < '2025-01-01'
GROUP BY channel_type, DATETRUNC(month,order_date)
)
, CTE_MoM AS (
SELECT
	channel_type,
	total_order,
	FORMAT(month_date,'yyyy-MM') AS year_month,
	total_revenue,
	LAG(total_revenue) OVER (PARTITION BY channel_type, MONTH(month_date) ORDER BY YEAR(month_date)) AS prev_yearmonth
FROM CTE_base_query
)
SELECT
	channel_type,
	total_order,
	year_month,
	total_revenue,
	prev_yearmonth,
	ROUND((CAST(total_revenue AS FLOAT) - prev_yearmonth) / prev_yearmonth,2) * 100 AS [growth %]
FROM CTE_MoM
WHERE prev_yearmonth IS NOT NULL
ORDER BY [growth %] DESC

---------------------------------------------------------------------------------------------------------------------

/* Mohon dibuatkan laporan kinerja funnel untuk event “Organic” di funnel_detail periode 1 Jan–
31 Des 2024:
1. Total jumlah event organic per channel_source.
2. Total unique order_id (“converted”) dari event organic.
3. Conversion rate = total_orders ÷ total_events × 100%.
Data ini untuk memetakan efektivitas jalur organik.
*/
WITH CTE_base AS (
SELECT
	order_id,
	channel_source
FROM funnel_detail
WHERE event = 'Organic'
	AND funnel_date >= '2024-01-01'
	AND funnel_date < '2025-01-01'
)
SELECT
	channel_source,
	COUNT(*) AS total_event,
	COUNT(DISTINCT order_id) AS total_orders,
	ROUND((CAST(COUNT(DISTINCT order_id)AS FLOAT) /COUNT(*)) * 100,2) AS [conversion_rate %]
FROM CTE_base
GROUP BY channel_source
ORDER BY [conversion_rate %] DESC


CREATE CLUSTERED COLUMNSTORE INDEX idx_funnel_detail_CS
ON funnel_detail
---------------------------------------------------------------------------------------------------------------------

/* Mohon dibuatkan laporan per bulan selama 2024 untuk:
1. Jumlah pelanggan baru (distinct customer_id) yang registrasi per registration_channel.
2. Rata-rata selisih hari antara registration_date dan tanggal transaksi pertama
(order_date).
Hanya hitung pelanggan yang sudah melakukan minimal satu pembelian. Hasil akan dipakai
untuk optimasi onboarding.*/

WITH CTE_base AS (
SELECT
	o.customer_id,
	c.registration_channel,
	c.registration_date,
	CAST(o.order_date AS DATE) date_order,
	is_nett,
	ROW_NUMBER() OVER(PARTITION BY o.customer_id ORDER BY CAST(o.order_date AS DATE)) rn
FROM order_detail o
LEFT JOIN customer_detail c
ON o.customer_id = c.customer_id
WHERE c.registration_date > '2024-01-01' AND c.registration_date < '2025-01-01'
	AND is_nett =1
)
, CTE_first_order AS (
SELECT
	customer_id,
	registration_channel,
	registration_date,
	date_order,
	DATEDIFF(day,registration_date,date_order) diff_day
FROM CTE_base
WHERE rn =1
)
SELECT 
	registration_channel,
	DATETRUNC(month, date_order) AS month_date,
	COUNT(DISTINCT customer_id) AS new_cus,
	AVG(diff_day) AS AVG_diff_day
FROM CTE_first_order
GROUP BY registration_channel, DATETRUNC(month,date_order)
ORDER BY registration_channel, month_date 
