-- Buktikan bahwa satu nama konsumen hanya memiliki satu customer id!
SELECT
	customer_name,
	COUNT(DISTINCT customer_id) AS nr_id
FROM orders
GROUP BY customer_name
HAVING COUNT(DISTINCT customer_id) > 1;

--==========================================================================
-- Produk (product_name) apa yang paling best selling secara kuantitas
SELECT
	product_name,
	SUM(quantity) AS total_quantity
FROM orders
GROUP BY product_name
ORDER BY total_quantity DESC;

--=========================================================================
-- Produk apa yang paling merugikan selama tahun 2017
SELECT
	product_name,
	SUM(profit) AS total_profit
FROM orders
GROUP BY product_name
ORDER BY total_profit ASC;
