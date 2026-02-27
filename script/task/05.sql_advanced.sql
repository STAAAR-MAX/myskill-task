/*
Tentukan kota mana yang memiliki revenue tertinggi
Dari kota pada poin sebelumnya, hitung rata-rata spending per konsumen pada kota tersebut
Tampilkan tabel berisi nama nama konsumen pada poin pertama yang memiliki spending di atas rata-rata
----------------------------------------------------------------------------------------------------------------

CTE_base
Tujuan:
Menghitung total spending tiap customer berdasarkan kota.
*/
WITH CTE_base AS (
SELECT
	c.customer_name,
	c.city,
	SUM(o.sales) AS total_spending
FROM gold.fact_orders o 
LEFT JOIN gold.dim_customer c
ON o.customer_key = c.customer_key
GROUP BY c.customer_name, c.city
),

/*
CTE_summarize
Tujuan:
Meringkas performa tiap kota berdasarkan total spending customer.

Menghasilkan:
- total revenue per kota
- rata-rata spending customer per kota
- ranking kota berdasarkan total revenue (tertinggi = rank 1)
*/
CTE_summarize AS (
SELECT 
	city,
	SUM(total_spending) AS total_revenue_bycity,
	AVG(total_spending) AS avg_revenue_bycity,
	DENSE_RANK() OVER (ORDER BY SUM(total_spending) DESC) as rnk
FROM CTE_base
GROUP by city
)

/*
Final Select
Tujuan:
Mengambil customer yang:

1. Berasal dari kota dengan total revenue tertinggi (Top City)
2. Memiliki spending di atas rata-rata customer di kota tersebut

Insight:
Mengidentifikasi high-value customer di kota dengan performa terbaik
*/
SELECT
	b.customer_name,
	s.city,
	ROUND(s.avg_revenue_bycity,2) AS avg_revenue_bycity,
	b.total_spending
FROM CTE_summarize s
LEFT JOIN CTE_base b
ON s.city = b.city
WHERE rnk = 1 
	AND total_spending > avg_revenue_bycity
ORDER BY total_spending DESC
