-- Query transaksi yang merugikan saja yang terjadi di tahun 2018 hingga 2019 di kota Los Angeles. diurutkan dari kerugian terbesar
SELECT 
	order_id,
	city,
	order_date,
	profit
FROM orders
WHERE order_date >= '2018-01-01'
	  AND order_date <'2020-01-01' 
	  AND profit < 0
	  AND city = 'Los Angeles'
ORDER BY profit ASC

-- =========================================================================================================================== --

-- Query transaksi yang untung saja yang terjadi pada Q1 2018 di kota Henderson. diurutkan dari keuntungan terbesar
SELECT 
	order_id,
	city,
	order_date,
	profit
FROM orders
WHERE order_date >= '2018-01-01'
	  AND order_date <'2018-04-01' 
	  AND profit > 0
	  AND city = 'Henderson'
ORDER BY profit DESC
