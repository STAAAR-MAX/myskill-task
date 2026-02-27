/*
===============================================================================
Eksplorasi Database
===============================================================================
Tujuan:
    - Menelusuri struktur database, termasuk daftar tabel yang tersedia
      beserta skemanya.
    - Memeriksa detail kolom dan metadata dari tabel tertentu.

Tabel Sistem yang Digunakan:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/
SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_product';
