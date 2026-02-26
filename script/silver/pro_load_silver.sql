-- ===============================================================================================================
-- Stored Procedure  : silver.load_Tokopaedi
-- Deskripsi        :
-- Stored procedure ini digunakan untuk memuat dan memproses data dari bronze layer ke dalam schema silver 
-- sebagai bagian dari tahap standarisasi, pembersihan, dan normalisasi data Tokopaedi.
--
-- Script Purpose   :
-- 1. Mengosongkan (TRUNCATE) seluruh tabel pada silver layer sebelum proses pemuatan data dimulai.
-- 2. Memuat data terstandardisasi dari tabel bronze ke tabel silver melalui proses INSERT SELECT.
-- 3. Melakukan transformasi ringan seperti perbaikan format product_name (REPLACE '.' menjadi ',').
-- 4. Menghitung durasi waktu loading untuk setiap tabel yang diproses.
-- 5. Menghitung total durasi proses loading seluruh tabel dalam satu batch eksekusi.
-- 6. Menyediakan mekanisme error handling untuk menampilkan ERROR_MESSAGE(), ERROR_NUMBER(), dan ERROR_STATE()
--    apabila terjadi kegagalan selama proses loading silver layer.
--
-- Tabel yang Dimuat :
-- - silver.orders   (Sumber: bronze.orders)
-- - silver.customer (Sumber: bronze.customer)
-- - silver.product  (Sumber: bronze.product)
-- - silver.region   (Sumber: bronze.region)
-- - silver.shipment (Sumber: bronze.shipment)
--
-- Mekanisme Proses  :
-- - Set waktu mulai batch proses
-- - Untuk setiap tabel:
--     a. TRUNCATE TABLE pada tabel silver
--     b. INSERT SELECT dari bronze ke silver
--     c. Lakukan transformasi ringan bila diperlukan (contoh: cleansing product_name)
--     d. Hitung durasi loading setiap tabel
-- - Set waktu selesai batch proses
-- - Tampilkan total durasi loading
-- - Jika terjadi error, tampilkan detail error menggunakan fungsi:
--       ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_STATE()
--
-- Parameter        :
-- Tidak memiliki parameter input dan tidak mengembalikan nilai return parameter.
--
-- Contoh Penggunaan:
-- EXEC silver.load_Tokopaedi;
-- ===============================================================================================================
EXEC silver.load_Tokopaedi;

CREATE OR ALTER PROCEDURE silver.load_Tokopaedi AS
BEGIN
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=========================================================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=========================================================================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.orders';
		TRUNCATE TABLE silver.orders;

		PRINT '>> Inserting Table silver.orders';
		INSERT INTO silver.orders (
			order_id,
			customer_id,
			postal_code,
			product_id,
			sales,
			quantity,
			discount,
			profit,
			category,
			subcategory,
			product_name,
			order_date,
			ship_date,
			ship_mode,
			customer_name,
			segment,
			country,
			city,
			state,
			region
		)
		SELECT
			order_date,
			customer_id,
			postal_code,
			product_id,
			sales,
			quantity,
			discount,
			profit,
			category,
			subcategory,
			product_name,
			order_date,
			ship_date,
			ship_mode,
			customer_name,
			segment,
			country,
			city,
			state,
			region
		FROM bronze.orders;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
		PRINT '>> -----------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.customer';
		TRUNCATE TABLE silver.customer;

		PRINT '>> Inserting Table silver.customer';
		INSERT INTO silver.customer (
			customer_id,
			customer_name,
			segment
		)
		SELECT
			customer_id,
			customer_name,
			segment
		FROM bronze.customer;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration '+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
		PRINT '>> -----------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.product';
		TRUNCATE TABLE silver.product;

		PRINT '>> Inserting Table silver.product';
		INSERT INTO silver.product (
			product_id,
			category,
			subcategory,
			product_name
		)
		SELECT
			product_id,
			category,
			subcategory,
		REPLACE(product_name,'.',',') AS product_name
		FROM bronze.product;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration '+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
		PRINT '>> -----------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.region';
		TRUNCATE TABLE silver.region;

		PRINT '>> Inserting Table silver.region';
		INSERT INTO silver.region (
			country,
			city,
			state,
			postal_code,
			region
		)
		SELECT
			country,
			city,
			state,
			postal_code,
			region
		FROM bronze.region;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration '+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
		PRINT '>> -----------------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.shipment';
		TRUNCATE TABLE silver.shipment

		PRINT '>> Inserting Table silver.shipment';
		INSERT INTO silver.shipment (
			order_id,
			order_date,
			ship_date,
			ship_mode
		)
		SELECT
			order_id,
			order_date,
			ship_date,
			ship_mode
		FROM bronze.shipment;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration '+ CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
		PRINT '>> -----------------------------------------------------------------------------------------';
		SET @batch_end_time = GETDATE();
		PRINT '=============================================================================================';
		PRINT 'Loading Bronze Layer is Complated';
		PRINT '- Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time)AS NVARCHAR) + ' seconds';
		PRINT '=============================================================================================';
	END TRY
	BEGIN CATCH 
		PRINT '==============================================================================================';
		PRINT '>> KESALAHAN SELAMA PEMUATAN SILVER LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number'  + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State'   + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==============================================================================================';
	END CATCH
END

