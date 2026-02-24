-- ===============================================================================================================
-- Stored Procedure  : bronze.load_Tokopaedi
-- Deskripsi        :
-- Stored procedure ini digunakan untuk memuat data mentah (raw data) ke dalam schema bronze
-- yang bersumber dari beberapa file CSV dataset Tokopaedi (orders, customer, product, 
-- region, dan shipment).
--
-- Script Purpose   :
-- 1. Mengosongkan (TRUNCATE) seluruh tabel pada bronze layer sebelum proses pemuatan data.
-- 2. Memuat data mentah (raw data) dari file CSV ke tabel bronze menggunakan perintah BULK INSERT.
-- 3. Mencatat durasi waktu proses loading untuk setiap tabel.
-- 4. Mencatat total durasi proses loading dalam satu batch eksekusi.
-- 5. Menyediakan error handling menggunakan TRY...CATCH untuk menangkap dan menampilkan
--    pesan kesalahan apabila terjadi kegagalan saat proses loading.
--
-- Tabel yang Dimuat :
-- - bronze.orders   (Sumber: orders.csv)
-- - bronze.customer (Sumber: customer.csv)
-- - bronze.product  (Sumber: product.csv)
-- - bronze.region   (Sumber: region.csv)
-- - bronze.shipment (Sumber: shipment.csv)
--
-- Mekanisme Proses  :
-- - Set waktu awal batch
-- - Untuk setiap tabel:
--     a. TRUNCATE TABLE
--     b. BULK INSERT dari file CSV (skip header dengan FIRSTROW = 2)
--     c. Hitung durasi loading per tabel
-- - Hitung total durasi loading seluruh tabel
-- - Jika terjadi error, tampilkan ERROR_MESSAGE(), ERROR_NUMBER(), dan ERROR_STATE()
--
-- Parameter        :
-- Tidak memiliki parameter input.
-- Stored procedure ini tidak mengembalikan nilai parameter apa pun.
--
-- Contoh Penggunaan:
-- EXEC bronze.load_Tokopaedi;
-- ===============================================================================================================
EXEC bronze.load_Tokopaedi;

CREATE OR ALTER PROCEDURE bronze.load_Tokopaedi AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=========================================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=========================================================================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.orders';
		TRUNCATE TABLE bronze.orders;

		PRINT '>> Inserting Table bronze.orders';
		BULK INSERT bronze.orders
		FROM 'D:/belajar/My skill/datasets/orders.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -----------------------------------------------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.customer';
		TRUNCATE TABLE bronze.customer;

		PRINT '>> Inserting Table bronze.customer';
		BULK INSERT bronze.customer
		FROM 'D:\belajar\My skill\datasets\customer.csv'
		WITH (
			  FIRSTROW = 2,
			  FIELDTERMINATOR = ',',
			  TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -----------------------------------------------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.product';
		TRUNCATE TABLE bronze.product;

		PRINT '>> Inserting Table bronze.product';
		BULK INSERT bronze.product
		FROM 'D:\belajar\My skill\datasets\product.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR =',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -----------------------------------------------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.region';
		TRUNCATE TABLE bronze.region;

		PRINT '>> Inserting Table bronze.region';
		BULK INSERT bronze.region
		FROM 'D:\belajar\My skill\datasets\region.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -----------------------------------------------------------------------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table bronze.shipment';
		TRUNCATE TABLE bronze.shipment 

		PRINT '>> Inserting Table bronze.shipment';
		BULK INSERT bronze.shipment
		FROM 'D:\belajar\My skill\datasets\shipment.csv'
		WITH (
				FIRSTROW = 2,
				FIELDTERMINATOR = ',',
				TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '>> -----------------------------------------------------------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '=============================================================================================';
		PRINT 'Loading Bronze Layer is Complated';
		PRINT '- Total Load Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time)AS NVARCHAR) + ' seconds';
		PRINT '=============================================================================================';
	END TRY
	BEGIN CATCH
		PRINT '==============================================================================================';
		PRINT 'KESALAHAN SELAMA PEMUATAN BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER()AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE()AS NVARCHAR);
		PRINT '==============================================================================================';
	END CATCH
END
