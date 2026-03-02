--======================================================================================================================
															-- EXERCISE --
-- ========================================================================================================================
-- total sales dan total tansaksi per bulan untuk tahun 2024, berdasarkan tabel transaction_detail (kolom total_paid). 
SELECT
	FORMAT(transaction_date, 'yyyy-MM') AS month_periode,
	COUNT(DISTINCT transaction_id) AS nr_transaction,
	SUM(total_paid) AS total_sales
FROM transaction_detail
WHERE transaction_date >= '2024-01-01'
	AND transaction_date < '2025-01-01'
GROUP BY FORMAT(transaction_date, 'yyyy-MM')
ORDER BY month_periode ASC;
---------------------------------------------------------------------------------------------------------------------

-- tampilkan volume (quantity) terjual per kategori setiap tahun dari 2020 s.d. 2024.
SELECT
	p.category,
	SUM(CASE WHEN YEAR(order_date) = 2020 THEN o.quantity ELSE 0 END) '2020',
	SUM(CASE WHEN YEAR(order_date) = 2021 THEN o.quantity ELSE 0 END) '2021',
	SUM(CASE WHEN YEAR(order_date) = 2022 THEN o.quantity ELSE 0 END) '2022',
	SUM(CASE WHEN YEAR(order_date) = 2023 THEN o.quantity ELSE 0 END) '2023',
	SUM(CASE WHEN YEAR(order_date) = 2024 THEN o.quantity ELSE 0 END) '2024'
FROM order_detail o
LEFT JOIN product_detail p
ON o.sku_id = p.sku_id
WHERE is_valid = 1 
	AND order_date >= '2020-01-01' 
	AND order_date< '2025-01-01'
GROUP BY p.category
ORDER BY p.category
---------------------------------------------------------------------------------------------------------------------

/* analisis performa channel (web, app, offline) di 2024:
1. Total orders (distinct) dan revenue (after_discount) per bulan.
2. Hitung Yoy by month growth revenue per bulan 2024 vs 2023 dalam bulan yang sama 
*/
WITH CTE_summary AS (
SELECT
	channel_type,
	DATEPART(year, order_date) year,
	DATEPART(month, order_date) month,
	COUNT(DISTINCT order_id) total_orders,
	SUM(after_discount) cy_total_revenue
FROM order_detail
WHERE order_date >= '2023-01-01' 
	AND order_date < '2025-01-01'
GROUP BY channel_type,
	DATEPART(year, order_date),
	DATEPART(month, order_date)
),
CTE_py AS (
SELECT
	channel_type,
	year,
	month,
	total_orders,
	cy_total_revenue,
	LAG(cy_total_revenue) OVER (PARTITION BY channel_type,month ORDER BY year) py_total_sales
FROM CTE_summary
)
SELECT
	channel_type,
	year,
	month,
	total_orders,
	cy_total_revenue,
	py_total_sales,
	(cy_total_revenue - py_total_sales) AS MoM,
	ROUND((CAST((cy_total_revenue - py_total_sales)AS FLOAT)/py_total_sales)*100,2) AS pct_growth,
	CASE
		WHEN (cy_total_revenue - py_total_sales) > 0 THEN 'Increase'
		WHEN (cy_total_revenue - py_total_sales) < 0 THEN 'Decrease'
		ELSE 'No Change'
	END category
FROM CTE_py
WHERE year = 2024
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
	ROW_NUMBER() OVER(PARTITION BY o.customer_id ORDER BY CAST(o.order_date AS DATE)) rn
FROM order_detail o
LEFT JOIN customer_detail c
ON o.customer_id = c.customer_id
WHERE is_valid = 1
	AND c.registration_date >= '2024-01-01' 
	AND c.registration_date < '2025-01-01'
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
	DATETRUNC(month, registration_date) AS month_date,
	COUNT(customer_id) AS new_cus,
	AVG(diff_day) AS AVG_diff_day
FROM CTE_first_order
GROUP BY registration_channel, DATETRUNC(month,registration_date)
ORDER BY registration_channel, month_date;

-- --------------------------------------Menggunakan subquery ---------------------
SELECT
	registration_channel,
	DATETRUNC(month,registration_date) month,
	COUNT(DISTINCT customer_id) total_cus,
	AVG(DATEDIFF(day, registration_date,order_date)) avg_day 
FROM (
		SELECT
			c.customer_id,
			c.registration_channel,
			c.registration_date,
			CAST(o.order_date AS DATE) AS order_date,
			ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY CAST(o.order_date AS DATE)) AS rn
		FROM order_detail o
		LEFT JOIN customer_detail c
		ON o.customer_id = c.customer_id
		WHERE is_valid = 1
			AND registration_date >= '2024-01-01'
			AND registration_date < '2025-01-01'
)t
WHERE rn =1
GROUP BY registration_channel,DATETRUNC(month,registration_date)
ORDER BY registration_channel,DATETRUNC(month,registration_date)
