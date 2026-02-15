-- Kamu sekarang memiliki tabel transaksi dari customer yang bertransaksi di Tokopaedi. Selanjutnya kamu diminta untuk

-- Tampilkan nama-nama konsumen segment Consumer yang pernah membeli meja

SELECT
	customer_name,
	segment,
	product_name,
	category,
	subcategory
FROM orders
WHERE segment LIKE 'Consumer' AND
subcategory LIKE 'Tables'

-- Tampilkan nama-nama konsumen dari segment Corporate dan Home Office yang berasal dari kota Los Angeles dan bertransaksi selama tahun 2018.
SELECT DISTINCT
	customer_name,
	city,
	segment,
	order_date
FROM orders
WHERE order_date >= '2018-01-01' AND order_date <='2018-12-31'
	  AND segment IN ('Corporate','Home Office')
	  AND city LIKE 'Los Angeles'
ORDER BY order_date ASC


