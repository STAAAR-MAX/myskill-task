/*
===============================================================================
Eksplorasi Tabel Dimensi
===============================================================================
Tujuan:
    - Meninjau struktur serta isi tabel-tabel dimensi dalam database.

Fungsi SQL yang Digunakan:
    - DISTINCT
    - ORDER BY
===============================================================================
*/
-- Task: eksplore semua segment pelanggan kami
SELECT DISTINCT segment
FROM gold.dim_customer

-- Task: eksplore semua kategori product 'divisi utama'
SELECT DISTINCT
    category
FROM gold.dim_product;

SELECT DISTINCT
    subcategory
FROM gold.dim_product;

-- Task: eksplore ship mode
SELECT DISTINCT ship_mode
FROM gold.dim_shipment




