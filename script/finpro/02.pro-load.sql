-- ===============================================================================================================
-- Script Name      : Bulk Load FinPRO Dataset
-- Deskripsi        :
-- Script ini digunakan untuk memuat data dari beberapa file TXT
-- ke dalam tabel-tabel SQL Server menggunakan perintah BULK INSERT.
--
-- Tujuan Script    :
-- 1. Mengosongkan (TRUNCATE) tabel sebelum proses pemuatan data untuk memastikan
--    tidak ada duplikasi dari load sebelumnya.
-- 2. Memuat ulang data terbaru dari file eksternal (.txt) ke masing-masing tabel.
-- 3. Menggunakan FIRSTROW = 2 untuk mengabaikan header pada file.
-- 4. Menggunakan FIELDTERMINATOR = ',' karena file dipisahkan dengan koma (comma delimited).
-- 5. Menggunakan TABLOCK untuk meningkatkan performa saat proses bulk loading.
--
-- Tabel yang Dimuat :
-- - customer_detail     ← customer_detail.txt
-- - order_detail        ← order_detail.txt
-- - funnel_detail       ← funnel_detail.txt
-- - payment_detail      ← payment_detail.txt
-- - product_detail      ← product_detail.txt
-- - transaction_detail  ← transaction_detail.txt
--
-- Mekanisme Proses :
-- - TRUNCATE TABLE untuk menghapus seluruh data lama.
-- - BULK INSERT untuk memuat data baru dari file eksternal.
-- - Setiap file diasumsikan memiliki baris header sehingga dilewati dengan FIRSTROW = 2.
--
-- Catatan Penting :
-- - Path file harus dapat diakses oleh SQL Server Service.
-- - Struktur kolom pada file harus sesuai dengan struktur tabel tujuan.
-- - Jika terjadi error "Cannot open file", periksa permission dan lokasi file.
--
-- ===============================================================================================================
-- ============================================
-- 1️⃣ LOAD CUSTOMER DETAIL
-- ============================================
TRUNCATE TABLE customer_detail;

BULK INSERT customer_detail
FROM 'D:\belajar\My skill\FinPRO\customer_detail.txt'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );


-- ============================================
-- 2️⃣ LOAD ORDER DETAIL
-- ============================================
TRUNCATE TABLE order_detail;

BULK INSERT order_detail
FROM 'D:\belajar\My skill\FinPRO\order_detail.txt'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );



-- ============================================
-- 3️⃣ LOAD FUNNEL DETAIL
-- ============================================
TRUNCATE TABLE funnel_detail;

BULK INSERT funnel_detail
FROM 'D:\belajar\My skill\FinPRO\funnel_detail.txt'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );



-- ============================================
-- 4️⃣ LOAD PAYMENT DETAIL
-- ============================================
TRUNCATE TABLE payment_detail;

BULK INSERT payment_detail
FROM 'D:\belajar\My skill\FinPRO\payment_detail.txt'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );



-- ============================================
-- 5️⃣ LOAD PRODUCT DETAIL
-- ============================================
TRUNCATE TABLE product_detail;

BULK INSERT product_detail
FROM 'D:\belajar\My skill\FinPRO\product_detail.txt'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );



-- ============================================
-- 6️⃣ LOAD TRANSACTION DETAIL
-- ============================================
TRUNCATE TABLE transaction_detail;

BULK INSERT transaction_detail
FROM 'D:\belajar\My skill\FinPRO\transaction_detail.txt'
WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        TABLOCK
    );
