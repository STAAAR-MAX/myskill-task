-- ===============================================================================================================
-- Stored Procedure  : gold.load_Tokopaedi
-- Deskripsi        :
-- Stored procedure ini digunakan untuk memuat dan membentuk data dari silver layer ke dalam schema gold 
-- sebagai bagian dari tahap penyajian data siap analisis (data mart / star schema) Tokopaedi.
--
-- Script Purpose   :
-- 1. Menghapus sementara seluruh foreign key pada tabel fact untuk menghindari konflik saat proses reload.
-- 2. Mengosongkan (TRUNCATE) tabel dimensi dan fakta pada gold layer sebelum proses pemuatan dimulai.
-- 3. Memuat data dari silver ke gold melalui proses INSERT SELECT.
-- 4. Membentuk struktur dimensional model yang terdiri dari:
--      - Dimensi Produk
--      - Dimensi Shipment
--      - Dimensi Customer
--      - Fakta Orders
-- 5. Melakukan proses deduplikasi pada dim_customer menggunakan ROW_NUMBER().
-- 6. Menghubungkan fact_orders dengan tabel dimensi menggunakan surrogate key.
-- 7. Mengembalikan kembali foreign key setelah proses loading selesai.
-- 8. Menghitung durasi waktu loading untuk setiap tabel.
-- 9. Menghitung total durasi proses loading seluruh tabel dalam satu batch eksekusi.
-- 10. Menyediakan mekanisme error handling untuk menampilkan ERROR_MESSAGE(), ERROR_NUMBER(), 
--     dan ERROR_STATE() apabila terjadi kegagalan selama proses loading gold layer.
--
-- Tabel yang Dimuat :
-- - gold.dim_product   (Sumber: silver.product)
-- - gold.dim_shipment  (Sumber: silver.shipment)
-- - gold.dim_customer  (Sumber: silver.orders, silver.customer, silver.region)
-- - gold.fact_orders   (Sumber: silver.orders + seluruh dimensi gold)
--
-- Mekanisme Proses  :
-- - Set waktu mulai batch proses
-- - Drop foreign key pada fact table
-- - Untuk setiap tabel:
--     a. TRUNCATE TABLE pada tabel gold
--     b. INSERT SELECT dari silver ke gold
--     c. Lakukan deduplikasi customer
--     d. Mapping surrogate key ke fact table
--     e. Hitung durasi loading setiap tabel
-- - Recreate foreign key pada fact table
-- - Set waktu selesai batch proses
-- - Tampilkan total durasi loading
-- - Jika terjadi error, tampilkan detail error menggunakan fungsi:
--       ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_STATE()
--
-- Parameter        :
-- Tidak memiliki parameter input dan tidak mengembalikan nilai return parameter.
--
-- Contoh Penggunaan:
-- EXEC gold.load_Tokopaedi;
-- ===============================================================================================================
CREATE OR ALTER PROCEDURE gold.load_Tokopaedi AS
BEGIN
    BEGIN TRY
        DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
        SET @batch_start_time = GETDATE();
        PRINT '=========================================================================================';
        PRINT 'Loading Gold Layer';
        PRINT '=========================================================================================';

        PRINT '>> ----------------------------------------------------------------------------------------';
        PRINT '>> Drop Foreign Keys';
        PRINT '>> -----------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_fact_orders_customer')
            ALTER TABLE gold.fact_orders DROP CONSTRAINT FK_fact_orders_customer;

        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_fact_orders_product')
            ALTER TABLE gold.fact_orders DROP CONSTRAINT FK_fact_orders_product;

        IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_fact_orders_shipment')
            ALTER TABLE gold.fact_orders DROP CONSTRAINT FK_fact_orders_shipment;
    
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
        PRINT '>> -----------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating gold.dim_product';
        TRUNCATE TABLE gold.dim_product;

        PRINT '>> Inserting gold.dim_product';
        INSERT INTO gold.dim_product (
            product_id,
            category,
            subcategory,
            product_name
        )
        SELECT 
            product_id,
            category,
            subcategory,
            product_name
        FROM silver.product;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
        PRINT '>> -----------------------------------------------------------------------------------------';

        SET @start_time =GETDATE();
        PRINT '>> Truncating gold.dim_shipment';
        TRUNCATE TABLE gold.dim_shipment;

        PRINT '>> Inserting gold.dim_shipment';
        INSERT INTO gold.dim_shipment (order_id, ship_mode)
        SELECT 
            order_id,
            ship_mode
        FROM silver.shipment
        ORDER BY order_date;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
        PRINT '>> -----------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
        PRINT '>> Truncating gold.dim_customer';
        TRUNCATE TABLE gold.dim_customer;

        PRINT '>> Inserting gold.dim_customer';
        INSERT INTO gold.dim_customer (
            customer_id,
            postal_code,
            customer_name,
            segment,
            country,
            city,
            state,
            region
        )
        SELECT
            customer_id,
            postal_code,
            customer_name,
            segment,
            country,
            city,
            state,
            region
        FROM (
            SELECT 
                c.customer_id,
                r.postal_code,
                c.customer_name,
                c.segment,
                r.country,
                r.city,
                r.state,
                r.region,
                ROW_NUMBER() OVER(PARTITION BY c.customer_id ORDER BY c.customer_id) nr
            FROM silver.orders o
            FULL JOIN silver.customer c
                ON o.customer_id = c.customer_id
            FULL JOIN silver.region r
                ON o.postal_code = r.postal_code
        ) t
        WHERE nr = 1;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
        PRINT '>> -----------------------------------------------------------------------------------------';

        SET @start_time =GETDATE();
        PRINT '>> Truncating gold.fact_orders';
        TRUNCATE TABLE gold.fact_orders;

        PRINT '>> Inserting gold.fact_orders';
        INSERT INTO gold.fact_orders (
            order_id,
            customer_key,
            product_key,
            shipment_key,
            order_date,
            ship_date,
            quantity,
            sales,
            discount,
            profit
        )
        SELECT 
            o.order_id,
            c.customer_key,
            p.product_key,
            s.shipment_key,
            o.order_date,
            o.ship_date,
            o.quantity,
            o.sales,
            o.discount,
            o.profit
        FROM silver.orders o
        LEFT JOIN gold.dim_customer c ON o.customer_id = c.customer_id
        LEFT JOIN gold.dim_product p ON o.product_id = p.product_id
        LEFT JOIN gold.dim_shipment s ON o.order_id = s.order_id
        ORDER BY o.order_date ASC;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';

        PRINT '>> -----------------------------------------------------------------------------------------';
        PRINT '>> Recreating Foreign Keys';
        PRINT '>> -----------------------------------------------------------------------------------------';

        SET @start_time = GETDATE();
	    ALTER TABLE gold.fact_orders
	    ADD CONSTRAINT FK_fact_orders_customer
	    FOREIGN KEY (customer_key)
	    REFERENCES gold.dim_customer(customer_key);

	    ALTER TABLE gold.fact_orders
	    ADD CONSTRAINT FK_fact_orders_product
	    FOREIGN KEY (product_key)
	    REFERENCES gold.dim_product(product_key);

	    ALTER TABLE gold.fact_orders
	    ADD CONSTRAINT FK_fact_orders_shipment
	    FOREIGN KEY (shipment_key)
	    REFERENCES gold.dim_shipment(shipment_key);
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR) + ' second';
        PRINT '>> -------------------------------------------------------------------------------------'
        SET @batch_end_time = GETDATE();
	    PRINT '=============================================================================================';
        PRINT 'Loading Gold Layer is Complated';
        PRINT '- Total Duration ' + CAST(DATEDIFF(second, @batch_start_time,@batch_end_time) AS NVARCHAR) + ' seconds';
	    PRINT '=============================================================================================';
    END TRY
    BEGIN CATCH
	    PRINT '=============================================================================================';
        PRINT ' KESALAHAN SELAMA PEMUATAN GOLD LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Number' + CAST(ERROR_NUMBER()AS NVARCHAR);
        PRINT 'Error State' + CAST(ERROR_STATE()AS NVARCHAR);
	    PRINT '=============================================================================================';
    END CATCH
END;


EXEC gold.load_Tokopaedi;
