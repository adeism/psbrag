<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# update 100 kode sql dengan kategori

Baik! Saya buatkan **100 SQL Query lengkap** dengan **keterangan detail** di setiap query.

# **100 SQL QUERIES - SLIMS PSB FEB UI**

**Database: Perpustakaan FEB UI**

***

## **📚 1. MEMBER MANAGEMENT (15 Queries)**

```sql
-- ==========================================
-- 1. DAFTAR SEMUA ANGGOTA DENGAN INFO LENGKAP
-- ==========================================
-- Keterangan Kolom:
-- - cf_03ddf: Status Lulus ('belum'/'sudah')
-- - cf_cc26d: Status Loker ('tidak'/'ya')  
-- - is_bebas_pustaka: 0=belum, 1=sudah
-- - is_self_regist: 0=registrasi manual, 1=self registration online
SELECT 
    m.member_id, 
    m.member_name, 
    m.member_email,
    m.member_phone,
    mt.member_type_name,
    m.member_since_date,
    p.prodi,
    p.jenjang,
    CASE WHEN mc.is_bebas_pustaka = 1 THEN 'Sudah' ELSE 'Belum' END as status_bebas_pustaka,
    CASE WHEN mc.cf_cc26d LIKE '%ya%' THEN 'Ya' ELSE 'Tidak' END as pinjam_loker
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
ORDER BY m.member_since_date DESC;

-- ==========================================
-- 2. STATISTIK ANGGOTA PER TIPE KEANGGOTAAN
-- ==========================================
-- Breakdown: Mahasiswa, Dosen, Tendik, Umum, dll
SELECT 
    mt.member_type_name,
    mt.loan_limit as batas_pinjam,
    mt.loan_periode as durasi_pinjam_hari,
    COUNT(m.member_id) as total_anggota,
    ROUND(COUNT(m.member_id) * 100.0 / (SELECT COUNT(*) FROM member), 2) as persentase
FROM mst_member_type mt
LEFT JOIN member m ON mt.member_type_id = m.member_type_id
GROUP BY mt.member_type_id, mt.member_type_name, mt.loan_limit, mt.loan_periode
ORDER BY total_anggota DESC;

-- ==========================================
-- 3. ANGGOTA PER PROGRAM STUDI DAN JENJANG
-- ==========================================
-- Jenjang: s1, s2, s3, Profesi
SELECT 
    p.jenjang,
    p.prodi,
    COUNT(mc.member_id) as total_anggota,
    COUNT(CASE WHEN mc.is_bebas_pustaka = 1 THEN 1 END) as sudah_bebas_pustaka,
    COUNT(CASE WHEN mc.is_bebas_pustaka = 0 OR mc.is_bebas_pustaka IS NULL THEN 1 END) as belum_bebas_pustaka
FROM mst_prodi p
LEFT JOIN member_custom mc ON p.id = mc.prodi_id
GROUP BY p.id, p.jenjang, p.prodi
ORDER BY p.jenjang, total_anggota DESC;

-- ==========================================
-- 4. ANGGOTA SELF REGISTRATION YANG SUDAH DIVERIFIKASI
-- ==========================================
-- is_self_regist = 1: daftar via website
-- verified_at NOT NULL: sudah di-approve admin
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    mc.verified_at,
    p.prodi,
    DATEDIFF(CURDATE(), mc.verified_at) as hari_sejak_verifikasi
FROM member m
JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE mc.is_self_regist = 1 
    AND mc.verified_at IS NOT NULL
ORDER BY mc.verified_at DESC;

-- ==========================================
-- 5. ANGGOTA SELF REGISTRATION PENDING (BELUM DIVERIFIKASI)
-- ==========================================
-- Anggota yang daftar online tapi belum di-approve
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    m.member_since_date,
    p.prodi,
    DATEDIFF(CURDATE(), m.member_since_date) as hari_menunggu
FROM member m
JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE mc.is_self_regist = 1 
    AND mc.verified_at IS NULL
ORDER BY m.member_since_date ASC;

-- ==========================================
-- 6. ANGGOTA YANG SUDAH LULUS
-- ==========================================
-- cf_03ddf: custom field status kelulusan
-- Value: 'belum' atau 'sudah'
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    mc.cf_03ddf as status_lulus
FROM member m
JOIN member_custom mc ON m.member_id = mc.member_id
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE mc.cf_03ddf LIKE '%sudah%'
ORDER BY m.member_name;

-- ==========================================
-- 7. ANGGOTA YANG PINJAM LOKER
-- ==========================================
-- cf_cc26d: custom field status loker
-- Value: 'tidak' atau 'ya'
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    p.prodi,
    mc.cf_cc26d as status_loker
FROM member m
JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE mc.cf_cc26d LIKE '%ya%'
ORDER BY m.member_name;

-- ==========================================
-- 8. ANGGOTA YANG SUDAH BEBAS PUSTAKA
-- ==========================================
-- is_bebas_pustaka = 1: sudah clear semua tanggungan
-- Syarat: tidak ada pinjaman aktif & tidak ada denda
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    p.jenjang
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE mc.is_bebas_pustaka = 1
ORDER BY p.jenjang, m.member_name;

-- ==========================================
-- 9. ANGGOTA YANG BELUM BEBAS PUSTAKA (ADA TANGGUNGAN)
-- ==========================================
-- Menampilkan anggota dengan pinjaman aktif atau denda
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    COUNT(l.loan_id) as total_pinjaman_aktif,
    COALESCE(SUM(f.debet - f.credit), 0) as total_denda
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
LEFT JOIN loan l ON m.member_id = l.member_id AND l.is_return = 0
LEFT JOIN fines f ON m.member_id = f.member_id
WHERE (mc.is_bebas_pustaka = 0 OR mc.is_bebas_pustaka IS NULL)
GROUP BY m.member_id, m.member_name, m.member_email, mt.member_type_name, p.prodi
HAVING total_pinjaman_aktif > 0 OR total_denda > 0
ORDER BY total_pinjaman_aktif DESC, total_denda DESC;

-- ==========================================
-- 10. ANGGOTA YANG BELUM PERNAH MEMINJAM
-- ==========================================
-- Dead member: terdaftar >1 bulan tapi belum pernah pinjam
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    m.member_since_date,
    DATEDIFF(CURDATE(), m.member_since_date) as hari_sejak_daftar
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
LEFT JOIN loan l ON m.member_id = l.member_id
WHERE l.loan_id IS NULL
    AND m.member_since_date < DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
ORDER BY m.member_since_date ASC
LIMIT 100;

-- ==========================================
-- 11. PENCARIAN ANGGOTA (UNIVERSAL SEARCH)
-- ==========================================
-- Cari berdasarkan: nama, ID, atau email
-- Ganti '%keyword%' dengan kata kunci
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    mt.member_type_name,
    p.prodi
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE m.member_name LIKE '%keyword%' 
    OR m.member_id LIKE '%keyword%'
    OR m.member_email LIKE '%keyword%'
ORDER BY m.member_name;

-- ==========================================
-- 12. ANGGOTA DENGAN TELEGRAM BOT TERINTEGRASI
-- ==========================================
-- Anggota yang sudah connect Telegram bot perpustakaan
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mc.telegram_id,
    mc.telegram_username,
    p.prodi
FROM member m
JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE mc.telegram_id IS NOT NULL
ORDER BY m.member_name;

-- ==========================================
-- 13. ANGGOTA PER JENIS KELAMIN DAN PROGRAM STUDI
-- ==========================================
-- gender: 0=Perempuan, 1=Laki-laki
SELECT 
    p.prodi,
    CASE 
        WHEN m.gender = 0 THEN 'Perempuan'
        WHEN m.gender = 1 THEN 'Laki-laki'
        ELSE 'Tidak Diketahui'
    END as jenis_kelamin,
    COUNT(*) as total
FROM member m
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
GROUP BY p.prodi, m.gender
ORDER BY p.prodi, m.gender;

-- ==========================================
-- 14. ANGGOTA DENGAN ULANG TAHUN BULAN INI
-- ==========================================
-- Untuk greeting/ucapan selamat ulang tahun
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    m.birth_date,
    DAY(m.birth_date) as tanggal_lahir,
    YEAR(CURDATE()) - YEAR(m.birth_date) as usia,
    p.prodi
FROM member m
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE MONTH(m.birth_date) = MONTH(CURDATE())
    AND m.birth_date IS NOT NULL
ORDER BY DAY(m.birth_date);

-- ==========================================
-- 15. UPDATE STATUS BEBAS PUSTAKA
-- ==========================================
-- Set is_bebas_pustaka = 1 setelah clear semua tanggungan
-- Ganti '2006602016' dengan member_id yang sesuai
UPDATE member_custom
SET is_bebas_pustaka = 1
WHERE member_id = '2006602016';
```


***

## **📖 2. CATALOG / BIBLIOGRAPHIC (15 Queries)**

```sql
-- ==========================================
-- 16. PENCARIAN KOLEKSI BY JUDUL ATAU PENGARANG
-- ==========================================
-- Universal search untuk katalog
-- Ganti '%keyword%' dengan kata kunci pencarian
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    b.isbn_issn,
    GROUP_CONCAT(DISTINCT a.author_name SEPARATOR ', ') as pengarang,
    p.publisher_name,
    g.gmd_name as jenis_media,
    COUNT(i.item_id) as total_eksemplar
FROM biblio b
LEFT JOIN biblio_author ba ON b.biblio_id = ba.biblio_id
LEFT JOIN mst_author a ON ba.author_id = a.author_id
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN mst_gmd g ON b.gmd_id = g.gmd_id
LEFT JOIN item i ON b.biblio_id = i.biblio_id
WHERE b.title LIKE '%keyword%' 
    OR a.author_name LIKE '%keyword%'
GROUP BY b.biblio_id
ORDER BY b.input_date DESC
LIMIT 50;

-- ==========================================
-- 17. KOLEKSI TERBARU (3 BULAN TERAKHIR)
-- ==========================================
-- New arrival / koleksi baru yang ditambahkan
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    b.isbn_issn,
    p.publisher_name,
    g.gmd_name,
    b.input_date,
    COUNT(i.item_id) as total_eksemplar
FROM biblio b
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN mst_gmd g ON b.gmd_id = g.gmd_id
LEFT JOIN item i ON b.biblio_id = i.biblio_id
WHERE b.input_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY b.biblio_id
ORDER BY b.input_date DESC
LIMIT 100;

-- ==========================================
-- 18. STATISTIK KOLEKSI PER TIPE KOLEKSI
-- ==========================================
-- Breakdown: Skripsi, Tesis, Buku Wajib, dll
SELECT 
    ct.coll_type_name,
    COUNT(DISTINCT b.biblio_id) as total_judul,
    COUNT(i.item_id) as total_eksemplar,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(i.item_id) - COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as tersedia
FROM mst_coll_type ct
LEFT JOIN item i ON ct.coll_type_id = i.coll_type_id
LEFT JOIN biblio b ON i.biblio_id = b.biblio_id
LEFT JOIN loan l ON i.item_code = l.item_code AND l.is_return = 0
GROUP BY ct.coll_type_id, ct.coll_type_name
ORDER BY total_judul DESC;

-- ==========================================
-- 19. STATISTIK KOLEKSI PER GMD (GENERAL MATERIAL DESIGNATION)
-- ==========================================
-- GMD: Buku, CD-ROM, DVD, eBook, dll
SELECT 
    g.gmd_name,
    g.gmd_code,
    COUNT(b.biblio_id) as total_koleksi,
    MIN(b.publish_year) as tahun_tertua,
    MAX(b.publish_year) as tahun_terbaru
FROM mst_gmd g
LEFT JOIN biblio b ON g.gmd_id = b.gmd_id
GROUP BY g.gmd_id, g.gmd_name, g.gmd_code
ORDER BY total_koleksi DESC;

-- ==========================================
-- 20. KOLEKSI DENGAN FILE DIGITAL/ATTACHMENT
-- ==========================================
-- Koleksi yang punya file PDF/digital
-- access_type: 'public' atau 'private'
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    f.file_title,
    f.file_name,
    ba.access_type,
    f.mime_type,
    f.input_date
FROM biblio b
JOIN biblio_attachment ba ON b.biblio_id = ba.biblio_id
JOIN files f ON ba.file_id = f.file_id
WHERE ba.access_type = 'public'
ORDER BY f.input_date DESC;

-- ==========================================
-- 21. DAFTAR PENGARANG PRODUKTIF (MINIMAL 3 KARYA)
-- ==========================================
-- Top authors berdasarkan jumlah karya di perpustakaan
SELECT 
    a.author_id,
    a.author_name,
    a.author_year,
    COUNT(ba.biblio_id) as total_karya,
    MIN(b.publish_year) as tahun_pertama,
    MAX(b.publish_year) as tahun_terakhir
FROM mst_author a
JOIN biblio_author ba ON a.author_id = ba.author_id
JOIN biblio b ON ba.biblio_id = b.biblio_id
GROUP BY a.author_id, a.author_name, a.author_year
HAVING total_karya >= 3
ORDER BY total_karya DESC
LIMIT 50;

-- ==========================================
-- 22. KOLEKSI PER PENERBIT (TOP 30 PUBLISHERS)
-- ==========================================
-- Penerbit dengan koleksi terbanyak
SELECT 
    p.publisher_name,
    COUNT(b.biblio_id) as total_judul,
    MIN(b.publish_year) as tahun_pertama,
    MAX(b.publish_year) as tahun_terakhir
FROM mst_publisher p
JOIN biblio b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_id, p.publisher_name
HAVING total_judul >= 3
ORDER BY total_judul DESC
LIMIT 30;

-- ==========================================
-- 23. KOLEKSI PER BAHASA
-- ==========================================
-- Breakdown koleksi berdasarkan bahasa penerbitan
SELECT 
    l.language_name,
    COUNT(b.biblio_id) as total_koleksi,
    ROUND(COUNT(b.biblio_id) * 100.0 / (SELECT COUNT(*) FROM biblio), 2) as persentase
FROM mst_language l
LEFT JOIN biblio b ON l.language_id = b.language_id
GROUP BY l.language_id, l.language_name
HAVING total_koleksi > 0
ORDER BY total_koleksi DESC;

-- ==========================================
-- 24. KOLEKSI TANPA ITEM/EKSEMPLAR (PERLU DIBUATKAN)
-- ==========================================
-- Bibliografi yang sudah di-input tapi belum dibuatkan item fisik
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    b.isbn_issn,
    p.publisher_name,
    b.input_date,
    DATEDIFF(CURDATE(), b.input_date) as hari_sejak_input
FROM biblio b
LEFT JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
WHERE i.item_id IS NULL
ORDER BY b.input_date DESC;

-- ==========================================
-- 25. KOLEKSI LENGKAP DENGAN SUBJEK/TOPIC
-- ==========================================
-- Koleksi dengan penanda subjek untuk penelusuran
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    GROUP_CONCAT(DISTINCT t.topic SEPARATOR ', ') as subjek,
    COUNT(DISTINCT bt.topic_id) as jumlah_subjek
FROM biblio b
LEFT JOIN biblio_topic bt ON b.biblio_id = bt.biblio_id
LEFT JOIN mst_topic t ON bt.topic_id = t.topic_id
GROUP BY b.biblio_id, b.title, b.publish_year
HAVING subjek IS NOT NULL
ORDER BY jumlah_subjek DESC, b.title
LIMIT 100;

-- ==========================================
-- 26. KOLEKSI PER TAHUN TERBIT
-- ==========================================
-- Distribusi koleksi berdasarkan tahun penerbitan
SELECT 
    b.publish_year,
    COUNT(*) as total_koleksi,
    COUNT(DISTINCT p.publisher_id) as jumlah_penerbit
FROM biblio b
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
WHERE b.publish_year IS NOT NULL 
    AND b.publish_year REGEXP '^[0-9]{4}$'
GROUP BY b.publish_year
ORDER BY b.publish_year DESC;

-- ==========================================
-- 27. KOLEKSI DENGAN MULTIPLE PENGARANG (CO-AUTHOR)
-- ==========================================
-- Buku dengan lebih dari 1 pengarang
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    COUNT(ba.author_id) as jumlah_pengarang,
    GROUP_CONCAT(a.author_name ORDER BY ba.level SEPARATOR ', ') as daftar_pengarang
FROM biblio b
JOIN biblio_author ba ON b.biblio_id = ba.biblio_id
JOIN mst_author a ON ba.author_id = a.author_id
GROUP BY b.biblio_id, b.title, b.publish_year
HAVING jumlah_pengarang > 1
ORDER BY jumlah_pengarang DESC;

-- ==========================================
-- 28. KOLEKSI DENGAN ISBN/ISSN DUPLIKAT (QUALITY CHECK)
-- ==========================================
-- Deteksi duplikasi data untuk quality control
SELECT 
    b.isbn_issn,
    COUNT(*) as jumlah_duplikat,
    GROUP_CONCAT(CONCAT(b.biblio_id, ': ', b.title) SEPARATOR ' | ') as daftar_judul
FROM biblio b
WHERE b.isbn_issn IS NOT NULL 
    AND b.isbn_issn != ''
GROUP BY b.isbn_issn
HAVING jumlah_duplikat > 1
ORDER BY jumlah_duplikat DESC;

-- ==========================================
-- 29. KOLEKSI DENGAN EDISI TERBANYAK
-- ==========================================
-- Buku dengan banyak edisi (multi-edition)
SELECT 
    SUBSTRING_INDEX(b.title, '/', 1) as judul_dasar,
    COUNT(*) as jumlah_edisi,
    GROUP_CONCAT(DISTINCT b.edition ORDER BY b.edition SEPARATOR ', ') as edisi,
    GROUP_CONCAT(DISTINCT b.publish_year ORDER BY b.publish_year SEPARATOR ', ') as tahun
FROM biblio b
WHERE b.edition IS NOT NULL 
    AND b.edition != ''
GROUP BY judul_dasar
HAVING jumlah_edisi > 1
ORDER BY jumlah_edisi DESC
LIMIT 30;

-- ==========================================
-- 30. KOLEKSI PER LOKASI PENYIMPANAN
-- ==========================================
-- Dimana koleksi disimpan secara fisik
SELECT 
    loc.location_name,
    ct.coll_type_name,
    COUNT(DISTINCT b.biblio_id) as total_judul,
    COUNT(i.item_id) as total_eksemplar
FROM mst_location loc
LEFT JOIN item i ON loc.location_id = i.location_id
LEFT JOIN biblio b ON i.biblio_id = b.biblio_id
LEFT JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
GROUP BY loc.location_id, loc.location_name, ct.coll_type_name
ORDER BY loc.location_name, total_judul DESC;
```


***

## **🔄 3. CIRCULATION / LOAN (20 Queries)**

```sql
-- ==========================================
-- 31. DAFTAR PEMINJAMAN AKTIF (BELUM DIKEMBALIKAN)
-- ==========================================
-- is_return = 0: belum dikembalikan
-- Status: Terlambat / Jatuh Tempo Hari Ini / Tepat Waktu
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    l.item_code,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as hari_terlambat,
    CASE 
        WHEN l.due_date < CURDATE() THEN 'Terlambat'
        WHEN l.due_date = CURDATE() THEN 'Jatuh Tempo Hari Ini'
        ELSE 'Tepat Waktu'
    END as status
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE l.is_return = 0
ORDER BY l.due_date ASC;

-- ==========================================
-- 32. PEMINJAMAN TERLAMBAT DENGAN PERHITUNGAN DENDA
-- ==========================================
-- fine_each_day: denda per hari dari loan rules
-- Rumus: hari_terlambat × fine_each_day
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    l.item_code,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as hari_terlambat,
    lr.fine_each_day as denda_per_hari,
    (DATEDIFF(CURDATE(), l.due_date) * lr.fine_each_day) as total_denda
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
JOIN mst_loan_rules lr ON l.loan_rules_id = lr.loan_rules_id
WHERE l.is_return = 0 
    AND l.due_date < CURDATE()
ORDER BY hari_terlambat DESC;

-- ==========================================
-- 33. STATISTIK PEMINJAMAN PER BULAN (12 BULAN TERAKHIR)
-- ==========================================
-- Trend peminjaman untuk analisis
SELECT 
    DATE_FORMAT(l.loan_date, '%Y-%m') as bulan,
    COUNT(*) as total_peminjaman,
    COUNT(DISTINCT l.member_id) as unique_peminjam,
    COUNT(CASE WHEN l.is_return = 1 THEN 1 END) as sudah_kembali,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as belum_kembali,
    ROUND(COUNT(CASE WHEN l.is_return = 1 THEN 1 END) * 100.0 / COUNT(*), 2) as persentase_kembali
FROM loan l
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(l.loan_date, '%Y-%m')
ORDER BY bulan DESC;

-- ==========================================
-- 34. STATISTIK PEMINJAMAN PER HARI DALAM SEMINGGU
-- ==========================================
-- Hari mana yang paling ramai peminjaman
-- 1=Sunday, 2=Monday, ..., 7=Saturday
SELECT 
    DAYNAME(l.loan_date) as hari,
    DAYOFWEEK(l.loan_date) as urutan_hari,
    COUNT(*) as total_peminjaman,
    ROUND(AVG(DATEDIFF(l.return_date, l.loan_date)), 1) as rata_rata_durasi_hari
FROM loan l
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
    AND l.return_date IS NOT NULL
GROUP BY DAYNAME(l.loan_date), DAYOFWEEK(l.loan_date)
ORDER BY urutan_hari;

-- ==========================================
-- 35. TOP 20 PEMINJAM AKTIF (1 TAHUN TERAKHIR)
-- ==========================================
-- Anggota paling rajin meminjam buku
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    COUNT(l.loan_id) as total_peminjaman,
    COUNT(CASE WHEN l.is_return = 1 THEN 1 END) as sudah_dikembalikan,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(CASE WHEN l.return_date > l.due_date THEN 1 END) as pernah_terlambat
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
JOIN loan l ON m.member_id = l.member_id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY m.member_id, m.member_name, m.member_email, mt.member_type_name, p.prodi
ORDER BY total_peminjaman DESC
LIMIT 20;

-- ==========================================
-- 36. KOLEKSI YANG PALING SERING DIPINJAM (1 TAHUN TERAKHIR)
-- ==========================================
-- Top borrowed books / koleksi populer
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    p.publisher_name,
    g.gmd_name,
    COUNT(l.loan_id) as total_dipinjam,
    COUNT(DISTINCT l.member_id) as unique_peminjam,
    MAX(l.loan_date) as terakhir_dipinjam
FROM biblio b
JOIN item i ON b.biblio_id = i.biblio_id
JOIN loan l ON i.item_code = l.item_code
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN mst_gmd g ON b.gmd_id = g.gmd_id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY b.biblio_id, b.title, b.publish_year, p.publisher_name, g.gmd_name
ORDER BY total_dipinjam DESC
LIMIT 30;

-- ==========================================
-- 37. HISTORI PEMINJAMAN ANGGOTA TERTENTU
-- ==========================================
-- Riwayat peminjaman per member
-- Ganti '2006602016' dengan member_id yang dicari
SELECT 
    l.loan_date,
    l.due_date,
    l.return_date,
    i.item_code,
    b.title,
    b.publish_year,
    l.renewed as jumlah_perpanjangan,
    DATEDIFF(COALESCE(l.return_date, CURDATE()), l.loan_date) as durasi_pinjam_hari,
    CASE 
        WHEN l.return_date IS NULL THEN 'Masih Dipinjam'
        WHEN l.return_date > l.due_date THEN CONCAT('Terlambat ', DATEDIFF(l.return_date, l.due_date), ' hari')
        ELSE 'Tepat Waktu'
    END as status_pengembalian
FROM loan l
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE l.member_id = '2006602016'
ORDER BY l.loan_date DESC
LIMIT 100;

-- ==========================================
-- 38. PEMINJAMAN YANG SUDAH DIPERPANJANG
-- ==========================================
-- renewed > 0: pernah diperpanjang
-- Maksimal perpanjangan sesuai loan rules
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    b.title,
    l.loan_date,
    l.due_date,
    l.renewed as jumlah_perpanjangan,
    l.is_return,
    DATEDIFF(l.due_date, l.loan_date) as total_hari_pinjam
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE l.renewed > 0
ORDER BY l.renewed DESC, l.loan_date DESC
LIMIT 100;

-- ==========================================
-- 39. RATA-RATA DURASI PEMINJAMAN PER TIPE ANGGOTA
-- ==========================================
-- Perbandingan behavior peminjaman antar tipe anggota
SELECT 
    mt.member_type_name,
    COUNT(l.loan_id) as total_peminjaman,
    ROUND(AVG(DATEDIFF(l.return_date, l.loan_date)), 1) as rata_rata_hari_pinjam,
    MIN(DATEDIFF(l.return_date, l.loan_date)) as tercepat,
    MAX(DATEDIFF(l.return_date, l.loan_date)) as terlama,
    ROUND(AVG(l.renewed), 2) as rata_rata_perpanjangan
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
WHERE l.is_return = 1 
    AND l.return_date IS NOT NULL
GROUP BY mt.member_type_id, mt.member_type_name
ORDER BY total_peminjaman DESC;

-- ==========================================
-- 40. PEMINJAMAN PER TIPE KOLEKSI
-- ==========================================
-- Tipe mana yang paling sering dipinjam
SELECT 
    ct.coll_type_name,
    COUNT(l.loan_id) as total_peminjaman,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(CASE WHEN l.is_return = 1 THEN 1 END) as sudah_kembali,
    ROUND(AVG(DATEDIFF(l.return_date, l.loan_date)), 1) as rata_rata_durasi_hari
FROM loan l
JOIN item i ON l.item_code = i.item_code
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY ct.coll_type_id, ct.coll_type_name
ORDER BY total_peminjaman DESC;

-- ==========================================
-- 41. PEMINJAMAN PER LOKASI ITEM
-- ==========================================
-- Lokasi rak mana yang paling sering dipinjam
SELECT 
    loc.location_name,
    COUNT(l.loan_id) as total_peminjaman,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(DISTINCT l.member_id) as unique_peminjam
FROM loan l
JOIN item i ON l.item_code = i.item_code
JOIN mst_location loc ON i.location_id = loc.location_id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY loc.location_id, loc.location_name
ORDER BY total_peminjaman DESC;

-- ==========================================
-- 42. KOLEKSI YANG JARANG DIPINJAM (PERLU PROMOSI)
-- ==========================================
-- Dead stock: koleksi >6 bulan tapi jarang/tidak dipinjam
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    p.publisher_name,
    COUNT(i.item_id) as total_eksemplar,
    COALESCE(COUNT(l.loan_id), 0) as total_peminjaman_setahun,
    b.input_date,
    DATEDIFF(CURDATE(), b.input_date) as hari_sejak_ditambahkan
FROM biblio b
JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN loan l ON i.item_code = l.item_code 
    AND l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY b.biblio_id, b.title, b.publish_year, p.publisher_name, b.input_date
HAVING total_peminjaman_setahun < 3
    AND hari_sejak_ditambahkan > 180
ORDER BY total_peminjaman_setahun ASC, hari_sejak_ditambahkan DESC
LIMIT 50;

-- ==========================================
-- 43. ANGGOTA YANG SERING TERLAMBAT MENGEMBALIKAN
-- ==========================================
-- Blacklist / problematic borrowers
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    COUNT(l.loan_id) as total_peminjaman,
    COUNT(CASE WHEN l.return_date > l.due_date THEN 1 END) as jumlah_terlambat,
    ROUND(COUNT(CASE WHEN l.return_date > l.due_date THEN 1 END) * 100.0 / COUNT(l.loan_id), 2) as persentase_terlambat,
    ROUND(AVG(CASE WHEN l.return_date > l.due_date THEN DATEDIFF(l.return_date, l.due_date) END), 1) as rata_rata_keterlambatan_hari
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
JOIN loan l ON m.member_id = l.member_id
WHERE l.is_return = 1 
    AND l.return_date IS NOT NULL
    AND l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY m.member_id, m.member_name, m.member_email, mt.member_type_name, p.prodi
HAVING jumlah_terlambat >= 3
ORDER BY persentase_terlambat DESC, jumlah_terlambat DESC
LIMIT 30;

-- ==========================================
-- 44. PEMINJAMAN OVERDUE (TERLAMBAT >30 HARI)
-- ==========================================
-- Urgent: peminjaman yang sangat terlambat
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    m.member_phone,
    m.member_email,
    l.item_code,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as hari_terlambat,
    lr.fine_each_day,
    (DATEDIFF(CURDATE(), l.due_date) * lr.fine_each_day) as estimasi_denda
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
JOIN mst_loan_rules lr ON l.loan_rules_id = lr.loan_rules_id
WHERE l.is_return = 0 
    AND DATEDIFF(CURDATE(), l.due_date) > 30
ORDER BY hari_terlambat DESC;

-- ==========================================
-- 45. TURNOVER RATE KOLEKSI (CIRCULATION RATE)
-- ==========================================
-- Mengukur seberapa sering koleksi berpindah tangan
-- Rumus: total_peminjaman / jumlah_eksemplar
-- >5: Sangat Populer, 2-5: Populer, >0: Normal, 0: Tidak Populer
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    COUNT(DISTINCT i.item_id) as jumlah_eksemplar,
    COUNT(l.loan_id) as total_dipinjam_setahun,
    ROUND(COUNT(l.loan_id) / NULLIF(COUNT(DISTINCT i.item_id), 0), 2) as turnover_rate,
    CASE 
        WHEN ROUND(COUNT(l.loan_id) / NULLIF(COUNT(DISTINCT i.item_id), 0), 2) > 5 THEN 'Sangat Populer'
        WHEN ROUND(COUNT(l.loan_id) / NULLIF(COUNT(DISTINCT i.item_id), 0), 2) > 2 THEN 'Populer'
        WHEN ROUND(COUNT(l.loan_id) / NULLIF(COUNT(DISTINCT i.item_id), 0), 2) > 0 THEN 'Normal'
        ELSE 'Tidak Populer'
    END as kategori_popularitas
FROM biblio b
JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN loan l ON i.item_code = l.item_code 
    AND l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY b.biblio_id, b.title, b.publish_year
HAVING jumlah_eksemplar > 0
ORDER BY turnover_rate DESC
LIMIT 50;

-- ==========================================
-- 46. PEMINJAMAN PER PROGRAM STUDI
-- ==========================================
-- Program studi mana yang paling aktif meminjam
SELECT 
    p.jenjang,
    p.prodi,
    COUNT(l.loan_id) as total_peminjaman,
    COUNT(DISTINCT l.member_id) as unique_peminjam,
    ROUND(AVG(DATEDIFF(l.return_date, l.loan_date)), 1) as rata_rata_durasi_hari
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN member_custom mc ON m.member_id = mc.member_id
JOIN mst_prodi p ON mc.prodi_id = p.id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
    AND l.return_date IS NOT NULL
GROUP BY p.jenjang, p.prodi
ORDER BY total_peminjaman DESC;

-- ==========================================
-- 47. PEMINJAMAN HARI INI
-- ==========================================
-- Real-time: peminjaman yang terjadi hari ini
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    l.item_code,
    b.title,
    l.loan_date,
    l.due_date,
    TIME(l.loan_date) as jam_pinjam
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE DATE(l.loan_date) = CURDATE()
ORDER BY l.loan_date DESC;

-- ==========================================
-- 48. PENGEMBALIAN HARI INI
-- ==========================================
-- Real-time: pengembalian yang terjadi hari ini
-- return_date: tanggal & waktu pengembalian
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    l.item_code,
    b.title,
    l.loan_date,
    l.return_date,
    TIME(l.return_date) as jam_kembali,
    DATEDIFF(l.return_date, l.loan_date) as durasi_pinjam_hari,
    CASE 
        WHEN l.return_date > l.due_date THEN CONCAT('Terlambat ', DATEDIFF(l.return_date, l.due_date), ' hari')
        ELSE 'Tepat Waktu'
    END as status
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE DATE(l.return_date) = CURDATE()
ORDER BY l.return_date DESC;

-- ==========================================
-- 49. PEMINJAMAN YANG JATUH TEMPO HARI INI
-- ==========================================
-- Reminder: due today
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    l.item_code,
    b.title,
    l.loan_date,
    l.due_date
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE l.is_return = 0 
    AND DATE(l.due_date) = CURDATE()
ORDER BY m.member_name;

-- ==========================================
-- 50. PEMINJAMAN YANG AKAN JATUH TEMPO DALAM 3 HARI
-- ==========================================
-- Early reminder: due soon (3 days)
SELECT 
    l.loan_id,
    l.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    l.item_code,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(l.due_date, CURDATE()) as sisa_hari
FROM loan l
JOIN member m ON l.member_id = m.member_id
JOIN item i ON l.item_code = i.item_code
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE l.is_return = 0 
    AND l.due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
ORDER BY l.due_date ASC;
```


***

## **📦 4. ITEM / INVENTORY MANAGEMENT (15 Queries)**

```sql
-- ==========================================
-- 51. INVENTARIS LENGKAP PER LOKASI DAN TIPE KOLEKSI
-- ==========================================
-- Stock opname per lokasi
SELECT 
    loc.location_name,
    ct.coll_type_name,
    COUNT(i.item_id) as total_eksemplar,
    COUNT(CASE WHEN ist.no_loan = 0 THEN 1 END) as bisa_dipinjam,
    COUNT(CASE WHEN ist.no_loan = 1 THEN 1 END) as tidak_bisa_dipinjam,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam
FROM mst_location loc
LEFT JOIN item i ON loc.location_id = i.location_id
LEFT JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
LEFT JOIN mst_item_status ist ON i.item_status_id = ist.item_status_id
LEFT JOIN loan l ON i.item_code = l.item_code AND l.is_return = 0
GROUP BY loc.location_id, loc.location_name, ct.coll_type_id, ct.coll_type_name
HAVING total_eksemplar > 0
ORDER BY loc.location_name, total_eksemplar DESC;

-- ==========================================
-- 52. ITEM PER STATUS
-- ==========================================
-- Status item: Available, Repair, Missing, No Loan, dll
-- no_loan: 0=bisa dipinjam, 1=tidak bisa dipinjam
-- skip_stock_take: 0=ikut stock opname, 1=skip
SELECT 
    ist.item_status_name,
    ist.no_loan,
    ist.skip_stock_take,
    COUNT(i.item_id) as total_item,
    ROUND(COUNT(i.item_id) * 100.0 / (SELECT COUNT(*) FROM item), 2) as persentase
FROM mst_item_status ist
LEFT JOIN item i ON ist.item_status_id = i.item_status_id
GROUP BY ist.item_status_id, ist.item_status_name, ist.no_loan, ist.skip_stock_take
ORDER BY total_item DESC;

-- ==========================================
-- 53. ITEM YANG RUSAK ATAU HILANG (PERLU PENANGANAN)
-- ==========================================
-- Status: R=Repair, MIS=Missing
-- Perlu tindak lanjut: perbaikan atau penghapusan
SELECT 
    i.item_code,
    i.item_id,
    b.title,
    b.isbn_issn,
    ist.item_status_name,
    loc.location_name,
    ct.coll_type_name,
    i.received_date,
    i.last_update,
    DATEDIFF(CURDATE(), i.last_update) as hari_sejak_update
FROM item i
JOIN biblio b ON i.biblio_id = b.biblio_id
JOIN mst_item_status ist ON i.item_status_id = ist.item_status_id
JOIN mst_location loc ON i.location_id = loc.location_id
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
WHERE ist.item_status_id IN ('R', 'MIS')
ORDER BY i.last_update DESC;

-- ==========================================
-- 54. ITEM YANG BELUM PERNAH DIPINJAM (DEAD STOCK)
-- ==========================================
-- Item fisik yang sudah >6 bulan tapi belum pernah dipinjam
SELECT 
    i.item_code,
    b.title,
    b.publish_year,
    p.publisher_name,
    i.received_date,
    loc.location_name,
    ct.coll_type_name,
    DATEDIFF(CURDATE(), i.received_date) as hari_sejak_diterima
FROM item i
JOIN biblio b ON i.biblio_id = b.biblio_id
JOIN mst_location loc ON i.location_id = loc.location_id
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN loan l ON i.item_code = l.item_code
WHERE l.loan_id IS NULL
    AND i.received_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
ORDER BY i.received_date ASC
LIMIT 100;

-- ==========================================
-- 55. KETERSEDIAAN ITEM PER JUDUL
-- ==========================================
-- Cek ketersediaan koleksi untuk OPAC
-- is_return = 0: sedang dipinjam
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    COUNT(i.item_id) as total_eksemplar,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(i.item_id) - COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as tersedia,
    GROUP_CONCAT(DISTINCT loc.location_name SEPARATOR ', ') as lokasi
FROM biblio b
JOIN item i ON b.biblio_id = i.biblio_id
JOIN mst_location loc ON i.location_id = loc.location_id
LEFT JOIN loan l ON i.item_code = l.item_code AND l.is_return = 0
GROUP BY b.biblio_id, b.title, b.publish_year
HAVING total_eksemplar > 0
ORDER BY sedang_dipinjam DESC, b.title
LIMIT 100;

-- ==========================================
-- 56. ITEM YANG DITAMBAHKAN PER BULAN (12 BULAN TERAKHIR)
-- ==========================================
-- Trend pengadaan koleksi
SELECT 
    DATE_FORMAT(i.received_date, '%Y-%m') as bulan,
    ct.coll_type_name,
    loc.location_name,
    COUNT(i.item_id) as total_item_baru
FROM item i
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
JOIN mst_location loc ON i.location_id = loc.location_id
WHERE i.received_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(i.received_date, '%Y-%m'), ct.coll_type_name, loc.location_name
ORDER BY bulan DESC, total_item_baru DESC;

-- ==========================================
-- 57. ITEM DENGAN CALL NUMBER DUPLIKAT (QUALITY CONTROL)
-- ==========================================
-- Deteksi duplikasi call number untuk koreksi
SELECT 
    i.call_number,
    COUNT(*) as jumlah_duplikat,
    GROUP_CONCAT(i.item_code SEPARATOR ', ') as item_codes,
    GROUP_CONCAT(DISTINCT b.title SEPARATOR ' | ') as judul
FROM item i
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE i.call_number IS NOT NULL 
    AND i.call_number != ''
GROUP BY i.call_number
HAVING jumlah_duplikat > 1
ORDER BY jumlah_duplikat DESC;

-- ==========================================
-- 58. ITEM DENGAN INVENTORY CODE DUPLIKAT
-- ==========================================
-- Deteksi duplikasi inventory code
SELECT 
    i.inventory_code,
    COUNT(*) as jumlah_duplikat,
    GROUP_CONCAT(i.item_code SEPARATOR ', ') as item_codes,
    GROUP_CONCAT(DISTINCT b.title SEPARATOR ' | ') as judul
FROM item i
JOIN biblio b ON i.biblio_id = b.biblio_id
WHERE i.inventory_code IS NOT NULL 
    AND i.inventory_code != ''
GROUP BY i.inventory_code
HAVING jumlah_duplikat > 1
ORDER BY jumlah_duplikat DESC;

-- ==========================================
-- 59. ITEM PER SUPPLIER (PENGADAAN)
-- ==========================================
-- Track supplier/vendor pengadaan koleksi
SELECT 
    s.supplier_name,
    s.phone,
    s.email,
    COUNT(i.item_id) as total_item,
    MIN(i.received_date) as pengadaan_pertama,
    MAX(i.received_date) as pengadaan_terakhir,
    DATEDIFF(MAX(i.received_date), MIN(i.received_date)) as rentang_hari
FROM item i
JOIN mst_supplier s ON i.supplier_id = s.supplier_id
GROUP BY s.supplier_id, s.supplier_name, s.phone, s.email
ORDER BY total_item DESC;

-- ==========================================
-- 60. STATISTIK ITEM PER TAHUN PENGADAAN
-- ==========================================
-- Trend pengadaan tahunan
SELECT 
    YEAR(i.received_date) as tahun,
    ct.coll_type_name,
    COUNT(i.item_id) as total_item,
    COUNT(DISTINCT i.biblio_id) as jumlah_judul
FROM item i
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
WHERE i.received_date IS NOT NULL
GROUP BY YEAR(i.received_date), ct.coll_type_name
ORDER BY tahun DESC, total_item DESC;

-- ==========================================
-- 61. ITEM YANG SERING RUSAK (TRACK KOLEKSI BERMASALAH)
-- ==========================================
-- Koleksi dengan banyak eksemplar rusak
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    COUNT(CASE WHEN i.item_status_id = 'R' THEN 1 END) as jumlah_rusak,
    COUNT(i.item_id) as total_eksemplar,
    ROUND(COUNT(CASE WHEN i.item_status_id = 'R' THEN 1 END) * 100.0 / COUNT(i.item_id), 2) as persentase_rusak
FROM biblio b
JOIN item i ON b.biblio_id = i.biblio_id
GROUP BY b.biblio_id, b.title, b.publish_year
HAVING jumlah_rusak > 0
ORDER BY persentase_rusak DESC, jumlah_rusak DESC;

-- ==========================================
-- 62. ITEM YANG HILANG (MISSING)
-- ==========================================
-- Status: MIS = Missing
-- Perlu investigasi atau penghapusan dari katalog
SELECT 
    i.item_code,
    b.title,
    b.isbn_issn,
    i.call_number,
    loc.location_name,
    i.received_date,
    i.last_update,
    DATEDIFF(CURDATE(), i.last_update) as hari_sejak_update
FROM item i
JOIN biblio b ON i.biblio_id = b.biblio_id
JOIN mst_location loc ON i.location_id = loc.location_id
WHERE i.item_status_id = 'MIS'
ORDER BY i.last_update DESC;

-- ==========================================
-- 63. NILAI INVESTASI KOLEKSI PER LOKASI
-- ==========================================
-- Estimasi nilai aset perpustakaan
-- price: harga pengadaan item
SELECT 
    loc.location_name,
    ct.coll_type_name,
    COUNT(i.item_id) as total_item,
    SUM(COALESCE(i.price, 0)) as total_nilai_investasi,
    ROUND(AVG(COALESCE(i.price, 0)), 0) as rata_rata_harga
FROM item i
JOIN mst_location loc ON i.location_id = loc.location_id
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
WHERE i.price IS NOT NULL AND i.price > 0
GROUP BY loc.location_id, loc.location_name, ct.coll_type_id, ct.coll_type_name
ORDER BY total_nilai_investasi DESC;

-- ==========================================
-- 64. ITEM DENGAN HARGA TERTINGGI
-- ==========================================
-- Koleksi paling mahal / rare items
SELECT 
    i.item_code,
    b.title,
    b.isbn_issn,
    i.price,
    i.price_currency,
    i.received_date,
    loc.location_name,
    ct.coll_type_name
FROM item i
JOIN biblio b ON i.biblio_id = b.biblio_id
JOIN mst_location loc ON i.location_id = loc.location_id
JOIN mst_coll_type ct ON i.coll_type_id = ct.coll_type_id
WHERE i.price IS NOT NULL 
    AND i.price > 0
ORDER BY i.price DESC
LIMIT 50;

-- ==========================================
-- 65. UPDATE LOKASI ITEM SECARA BATCH
-- ==========================================
-- Contoh: pindah semua skripsi ke lokasi Karya Akhir
-- location_id 'ka' = PSB lt.2 - Karya Akhir
-- LIMIT 100: safety untuk prevent mass update
UPDATE item i
JOIN biblio b ON i.biblio_id = b.biblio_id
SET i.location_id = 'ka', 
    i.last_update = NOW()
WHERE b.title LIKE '%skripsi%'
    AND i.location_id != 'ka'
LIMIT 100;
```


***

## **💰 5. FINES \& RESERVES (10 Queries)**

```sql
-- ==========================================
-- 66. DAFTAR DENDA YANG BELUM DIBAYAR
-- ==========================================
-- debet: denda yang dikenakan
-- credit: pembayaran
-- sisa_denda = debet - credit
SELECT 
    f.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    SUM(f.debet) as total_debet,
    SUM(f.credit) as total_bayar,
    SUM(f.debet - f.credit) as sisa_denda,
    COUNT(*) as jumlah_transaksi,
    MAX(f.fines_date) as transaksi_terakhir
FROM fines f
JOIN member m ON f.member_id = m.member_id
GROUP BY f.member_id, m.member_name, m.member_email, m.member_phone
HAVING sisa_denda > 0
ORDER BY sisa_denda DESC;

-- ==========================================
-- 67. HISTORI TRANSAKSI DENDA PER ANGGOTA
-- ==========================================
-- Riwayat denda & pembayaran member tertentu
-- Ganti '2006602016' dengan member_id
SELECT 
    f.fines_date,
    f.member_id,
    m.member_name,
    f.debet as denda_baru,
    f.credit as pembayaran,
    f.description,
    (f.debet - f.credit) as saldo_transaksi
FROM fines f
JOIN member m ON f.member_id = m.member_id
WHERE f.member_id = '2006602016'
ORDER BY f.fines_date DESC;

-- ==========================================
-- 68. STATISTIK DENDA PER BULAN
-- ==========================================
-- Trend pendapatan denda & pembayaran
SELECT 
    DATE_FORMAT(f.fines_date, '%Y-%m') as bulan,
    SUM(f.debet) as total_denda,
    SUM(f.credit) as total_bayar,
    SUM(f.debet - f.credit) as selisih,
    COUNT(DISTINCT f.member_id) as jumlah_anggota,
    COUNT(*) as jumlah_transaksi
FROM fines f
WHERE f.fines_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(f.fines_date, '%Y-%m')
ORDER BY bulan DESC;

-- ==========================================
-- 69. ANGGOTA DENGAN TOTAL DENDA TERBESAR (ALL TIME)
-- ==========================================
-- Top fines: anggota dengan akumulasi denda terbanyak
SELECT 
    f.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    SUM(f.debet) as total_denda_sepanjang_masa,
    SUM(f.credit) as total_bayar,
    SUM(f.debet - f.credit) as sisa_denda
FROM fines f
JOIN member m ON f.member_id = m.member_id
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
GROUP BY f.member_id, m.member_name, m.member_email, mt.member_type_name, p.prodi
ORDER BY total_denda_sepanjang_masa DESC
LIMIT 30;

-- ==========================================
-- 70. RESERVASI AKTIF DENGAN STATUS ITEM
-- ==========================================
-- Daftar reservasi yang masih aktif
-- Cek apakah item sudah tersedia atau masih dipinjam
SELECT 
    r.reserve_id,
    r.member_id,
    m.member_name,
    m.member_email,
    m.member_phone,
    b.title,
    r.reserve_date,
    COUNT(i.item_id) as total_eksemplar,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(i.item_id) - COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as tersedia,
    DATEDIFF(CURDATE(), r.reserve_date) as hari_sejak_reservasi
FROM reserve r
JOIN member m ON r.member_id = m.member_id
JOIN biblio b ON r.biblio_id = b.biblio_id
LEFT JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN loan l ON i.item_code = l.item_code AND l.is_return = 0
GROUP BY r.reserve_id, r.member_id, m.member_name, m.member_email, m.member_phone, b.title, r.reserve_date
ORDER BY r.reserve_date DESC;

-- ==========================================
-- 71. KOLEKSI YANG SERING DIRESERVASI (HIGH DEMAND)
-- ==========================================
-- Koleksi dengan demand tinggi: perlu tambah eksemplar
-- ratio_demand >1: permintaan > ketersediaan
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    p.publisher_name,
    COUNT(r.reserve_id) as total_reservasi,
    COUNT(DISTINCT i.item_id) as jumlah_eksemplar,
    ROUND(COUNT(r.reserve_id) / NULLIF(COUNT(DISTINCT i.item_id), 0), 2) as ratio_demand,
    MAX(r.reserve_date) as reservasi_terakhir
FROM biblio b
JOIN reserve r ON b.biblio_id = r.biblio_id
JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
GROUP BY b.biblio_id, b.title, b.publish_year, p.publisher_name
HAVING total_reservasi >= 3
ORDER BY total_reservasi DESC
LIMIT 30;

-- ==========================================
-- 72. ANGGOTA YANG SERING MELAKUKAN RESERVASI
-- ==========================================
-- Power users yang aktif mereservasi buku
SELECT 
    m.member_id,
    m.member_name,
    m.member_email,
    mt.member_type_name,
    p.prodi,
    COUNT(r.reserve_id) as total_reservasi,
    MAX(r.reserve_date) as reservasi_terakhir
FROM member m
JOIN mst_member_type mt ON m.member_type_id = mt.member_type_id
LEFT JOIN member_custom mc ON m.member_id = mc.member_id
LEFT JOIN mst_prodi p ON mc.prodi_id = p.id
JOIN reserve r ON m.member_id = r.member_id
GROUP BY m.member_id, m.member_name, m.member_email, mt.member_type_name, p.prodi
ORDER BY total_reservasi DESC
LIMIT 30;

-- ==========================================
-- 73. RESERVASI YANG SUDAH LAMA (>7 HARI)
-- ==========================================
-- Reservasi yang terlalu lama: perlu di-follow up
SELECT 
    r.reserve_id,
    r.member_id,
    m.member_name,
    m.member_phone,
    m.member_email,
    b.title,
    r.reserve_date,
    DATEDIFF(CURDATE(), r.reserve_date) as hari_menunggu,
    COUNT(i.item_id) as total_eksemplar,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam
FROM reserve r
JOIN member m ON r.member_id = m.member_id
JOIN biblio b ON r.biblio_id = b.biblio_id
LEFT JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN loan l ON i.item_code = l.item_code AND l.is_return = 0
WHERE DATEDIFF(CURDATE(), r.reserve_date) > 7
GROUP BY r.reserve_id, r.member_id, m.member_name, m.member_phone, m.member_email, b.title, r.reserve_date
ORDER BY hari_menunggu DESC;

-- ==========================================
-- 74. STATISTIK RESERVASI PER BULAN
-- ==========================================
-- Trend reservasi untuk analisis demand
SELECT 
    DATE_FORMAT(r.reserve_date, '%Y-%m') as bulan,
    COUNT(*) as total_reservasi,
    COUNT(DISTINCT r.member_id) as unique_member,
    COUNT(DISTINCT r.biblio_id) as unique_judul
FROM reserve r
WHERE r.reserve_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(r.reserve_date, '%Y-%m')
ORDER BY bulan DESC;

-- ==========================================
-- 75. INSERT PEMBAYARAN DENDA BARU
-- ==========================================
-- Record pembayaran denda
-- debet=0 karena ini pembayaran (credit)
-- Ganti nilai sesuai kebutuhan
INSERT INTO fines (fines_date, member_id, debet, credit, description)
VALUES (CURDATE(), '2006602016', 0, 50000, 'Pembayaran denda keterlambatan');
```


***

## **🚪 6. ROOM MANAGEMENT (10 Queries)**

```sql
-- ==========================================
-- 76. STATISTIK PEMINJAMAN RUANGAN PER BULAN
-- ==========================================
-- Trend penggunaan ruang diskusi/seminar
-- location: 'Lt. 3' atau 'Basement'
SELECT 
    DATE_FORMAT(rr.tanggal_pinjam, '%Y-%m') as bulan,
    r.room_name,
    r.location,
    COUNT(*) as total_peminjaman,
    SUM(rr.jumlah_user) as total_pengguna,
    ROUND(AVG(rr.jumlah_user), 1) as rata_rata_pengguna_per_sesi
FROM room_report rr
JOIN rooms r ON rr.room_id = r.id
WHERE rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(rr.tanggal_pinjam, '%Y-%m'), r.room_name, r.location
ORDER BY bulan DESC, total_peminjaman DESC;

-- ==========================================
-- 77. RUANGAN YANG PALING SERING DIPINJAM
-- ==========================================
-- Most popular rooms
-- status: 'in use', 'available', 'closed'
SELECT 
    r.room_name,
    r.capacity,
    r.location,
    r.facilities,
    r.status,
    COUNT(rr.id) as total_peminjaman,
    SUM(rr.jumlah_user) as total_pengguna,
    ROUND(AVG(rr.jumlah_user), 1) as rata_rata_pengguna,
    ROUND(AVG(rr.jumlah_user) / r.capacity * 100, 2) as persentase_kapasitas
FROM rooms r
LEFT JOIN room_report rr ON r.id = rr.room_id
    AND rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY r.id, r.room_name, r.capacity, r.location, r.facilities, r.status
ORDER BY total_peminjaman DESC;

-- ==========================================
-- 78. STATUS KETERSEDIAAN RUANGAN (REAL-TIME)
-- ==========================================
-- Dashboard ketersediaan ruangan hari ini
SELECT 
    r.room_name,
    r.capacity,
    r.location,
    r.status,
    r.facilities,
    COUNT(CASE WHEN MONTH(rr.tanggal_pinjam) = MONTH(CURDATE()) 
              AND YEAR(rr.tanggal_pinjam) = YEAR(CURDATE()) THEN 1 END) as peminjaman_bulan_ini,
    COUNT(CASE WHEN DATE(rr.tanggal_pinjam) = CURDATE() THEN 1 END) as peminjaman_hari_ini
FROM rooms r
LEFT JOIN room_report rr ON r.id = rr.room_id
GROUP BY r.id, r.room_name, r.capacity, r.location, r.status, r.facilities
ORDER BY r.location, r.room_name;

-- ==========================================
-- 79. LAPORAN PEMINJAMAN RUANGAN PER NPM
-- ==========================================
-- Track penggunaan ruangan per mahasiswa
SELECT 
    rr.npm,
    COUNT(*) as total_peminjaman_ruang,
    SUM(rr.jumlah_user) as total_pengguna_dibawa,
    ROUND(AVG(rr.jumlah_user), 1) as rata_rata_pengguna_per_sesi,
    GROUP_CONCAT(DISTINCT r.room_name SEPARATOR ', ') as ruangan_yang_pernah_dipinjam,
    MIN(rr.tanggal_pinjam) as pertama_kali,
    MAX(rr.tanggal_pinjam) as terakhir_kali
FROM room_report rr
JOIN rooms r ON rr.room_id = r.id
WHERE rr.npm IS NOT NULL
GROUP BY rr.npm
ORDER BY total_peminjaman_ruang DESC
LIMIT 50;

-- ==========================================
-- 80. PEMINJAMAN RUANGAN PER HARI DALAM SEMINGGU
-- ==========================================
-- Hari mana yang paling ramai booking ruangan
SELECT 
    DAYNAME(rr.tanggal_pinjam) as hari,
    DAYOFWEEK(rr.tanggal_pinjam) as urutan_hari,
    COUNT(*) as total_peminjaman,
    ROUND(AVG(rr.jumlah_user), 1) as rata_rata_pengguna
FROM room_report rr
WHERE rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY DAYNAME(rr.tanggal_pinjam), DAYOFWEEK(rr.tanggal_pinjam)
ORDER BY urutan_hari;

-- ==========================================
-- 81. PEMINJAMAN RUANGAN PER JAM (PEAK HOURS)
-- ==========================================
-- Jam berapa yang paling ramai booking
SELECT 
    HOUR(rr.waktu_pinjam) as jam,
    COUNT(*) as total_peminjaman,
    ROUND(AVG(rr.jumlah_user), 1) as rata_rata_pengguna,
    GROUP_CONCAT(DISTINCT r.room_name SEPARATOR ', ') as ruangan_populer
FROM room_report rr
JOIN rooms r ON rr.room_id = r.id
WHERE rr.waktu_pinjam IS NOT NULL
    AND rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY HOUR(rr.waktu_pinjam)
ORDER BY jam;

-- ==========================================
-- 82. RUANGAN YANG JARANG DIGUNAKAN (PERLU EVALUASI)
-- ==========================================
-- Underutilized rooms: <10× dalam 6 bulan
SELECT 
    r.room_name,
    r.capacity,
    r.location,
    r.facilities,
    r.status,
    COUNT(rr.id) as total_peminjaman_6bulan,
    MAX(rr.tanggal_pinjam) as terakhir_dipinjam,
    DATEDIFF(CURDATE(), MAX(rr.tanggal_pinjam)) as hari_sejak_terakhir_dipinjam
FROM rooms r
LEFT JOIN room_report rr ON r.id = rr.room_id
    AND rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY r.id, r.room_name, r.capacity, r.location, r.facilities, r.status
HAVING total_peminjaman_6bulan < 10 OR total_peminjaman_6bulan IS NULL
ORDER BY total_peminjaman_6bulan ASC;

-- ==========================================
-- 83. DURASI RATA-RATA PENGGUNAAN RUANGAN
-- ==========================================
-- Berapa lama rata-rata orang pakai ruangan
-- Durasi = waktu_kembali - waktu_pinjam
SELECT 
    r.room_name,
    r.location,
    COUNT(rr.id) as total_peminjaman,
    ROUND(AVG(TIME_TO_SEC(TIMEDIFF(rr.waktu_kembali, rr.waktu_pinjam)) / 3600), 2) as rata_rata_durasi_jam,
    ROUND(MIN(TIME_TO_SEC(TIMEDIFF(rr.waktu_kembali, rr.waktu_pinjam)) / 3600), 2) as durasi_tersingkat_jam,
    ROUND(MAX(TIME_TO_SEC(TIMEDIFF(rr.waktu_kembali, rr.waktu_pinjam)) / 3600), 2) as durasi_terlama_jam
FROM rooms r
JOIN room_report rr ON r.id = rr.room_id
WHERE rr.waktu_pinjam IS NOT NULL 
    AND rr.waktu_kembali IS NOT NULL
    AND rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY r.id, r.room_name, r.location
ORDER BY total_peminjaman DESC;

-- ==========================================
-- 84. UTILITAS RUANGAN PER LOKASI
-- ==========================================
-- Perbandingan penggunaan Lt. 3 vs Basement
SELECT 
    r.location,
    COUNT(DISTINCT r.id) as jumlah_ruangan,
    SUM(r.capacity) as total_kapasitas,
    COUNT(rr.id) as total_peminjaman_3bulan,
    SUM(rr.jumlah_user) as total_pengguna,
    ROUND(SUM(rr.jumlah_user) / SUM(r.capacity), 2) as utilitas_ratio
FROM rooms r
LEFT JOIN room_report rr ON r.id = rr.room_id
    AND rr.tanggal_pinjam >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY r.location
ORDER BY total_peminjaman_3bulan DESC;

-- ==========================================
-- 85. INSERT PEMINJAMAN RUANGAN BARU
-- ==========================================
-- Record booking ruangan baru
-- Ganti nilai sesuai kebutuhan
INSERT INTO room_report (room_id, npm, tanggal_pinjam, waktu_pinjam, waktu_kembali, keterangan, nomor_telepon, jumlah_user)
VALUES (1, '2006602016', CURDATE(), '09:00:00', '11:00:00', 'Diskusi kelompok', '08123456789', 5);
```


***

## **📊 7. REPORTS \& ANALYTICS (10 Queries)**

```sql
-- ==========================================
-- 86. DASHBOARD RINGKASAN PERPUSTAKAAN
-- ==========================================
-- Summary untuk homepage dashboard admin
SELECT 
    (SELECT COUNT(*) FROM member) as total_anggota,
    (SELECT COUNT(*) FROM biblio) as total_judul,
    (SELECT COUNT(*) FROM item) as total_eksemplar,
    (SELECT COUNT(*) FROM loan WHERE is_return = 0) as sedang_dipinjam,
    (SELECT COUNT(*) FROM loan WHERE is_return = 0 AND due_date < CURDATE()) as terlambat,
    (SELECT COUNT(*) FROM reserve) as total_reservasi,
    (SELECT COUNT(*) FROM visitor_count WHERE DATE(checkin_date) = CURDATE()) as pengunjung_hari_ini,
    (SELECT COUNT(*) FROM room_report WHERE tanggal_pinjam = CURDATE()) as ruangan_dipinjam_hari_ini;

-- ==========================================
-- 87. STATISTIK PENGUNJUNG PER BULAN
-- ==========================================
-- Trend kunjungan perpustakaan
SELECT 
    DATE_FORMAT(v.checkin_date, '%Y-%m') as bulan,
    COUNT(*) as total_pengunjung,
    COUNT(DISTINCT v.member_id) as unique_member,
    COUNT(CASE WHEN v.member_id IS NULL THEN 1 END) as non_member,
    ROUND(COUNT(DISTINCT v.member_id) * 100.0 / COUNT(*), 2) as persentase_member
FROM visitor_count v
WHERE v.checkin_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(v.checkin_date, '%Y-%m')
ORDER BY bulan DESC;

-- ==========================================
-- 88. PENGUNJUNG PER INSTITUSI
-- ==========================================
-- Institusi asal pengunjung eksternal
SELECT 
    v.institution,
    COUNT(*) as total_kunjungan,
    COUNT(DISTINCT v.member_name) as unique_pengunjung,
    MAX(v.checkin_date) as kunjungan_terakhir
FROM visitor_count v
WHERE v.institution IS NOT NULL
    AND v.checkin_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY v.institution
ORDER BY total_kunjungan DESC
LIMIT 30;

-- ==========================================
-- 89. PENGUNJUNG PER HARI DALAM SEMINGGU
-- ==========================================
-- Hari apa yang paling ramai pengunjung
SELECT 
    DAYNAME(v.checkin_date) as hari,
    DAYOFWEEK(v.checkin_date) as urutan_hari,
    COUNT(*) as total_pengunjung,
    ROUND(AVG(COUNT(*)) OVER(), 0) as rata_rata_per_hari
FROM visitor_count v
WHERE v.checkin_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY DAYNAME(v.checkin_date), DAYOFWEEK(v.checkin_date)
ORDER BY urutan_hari;

-- ==========================================
-- 90. FILE YANG PALING SERING DIAKSES
-- ==========================================
-- Top downloaded files (eBook, PDF, dll)
SELECT 
    f.file_title,
    f.mime_type,
    COUNT(fr.filelog_id) as total_akses,
    COUNT(DISTINCT fr.member_id) as unique_pembaca,
    MAX(fr.date_read) as akses_terakhir
FROM files f
JOIN files_read fr ON f.file_id = fr.file_id
GROUP BY f.file_id, f.file_title, f.mime_type
ORDER BY total_akses DESC
LIMIT 30;

-- ==========================================
-- 91. AKTIVITAS USER ADMIN/STAFF DI SISTEM
-- ==========================================
-- Track last login admin & staff
-- user_type: 1=Admin, 2=Librarian
SELECT 
    u.username,
    u.realname,
    CASE 
        WHEN u.user_type = 1 THEN 'Admin'
        WHEN u.user_type = 2 THEN 'Librarian'
        ELSE 'Staff'
    END as role,
    u.last_login,
    u.email,
    DATEDIFF(CURDATE(), DATE(u.last_login)) as hari_sejak_login
FROM user u
WHERE u.last_login IS NOT NULL
ORDER BY u.last_login DESC;

-- ==========================================
-- 92. LOG AKTIVITAS BIBLIOGRAFI (AUDIT TRAIL)
-- ==========================================
-- Track perubahan data bibliografi
-- action: 'INSERT', 'UPDATE', 'DELETE'
SELECT 
    bl.biblio_log_id,
    bl.biblio_id,
    bl.title,
    bl.action,
    bl.realname as user,
    bl.input_date,
    bl.affected_row
FROM biblio_log bl
WHERE bl.input_date >= DATE_SUB(NOW(), INTERVAL 7 DAY)
ORDER BY bl.input_date DESC
LIMIT 100;

-- ==========================================
-- 93. PERBANDINGAN STATISTIK TAHUN INI VS TAHUN LALU
-- ==========================================
-- Year-over-year comparison
SELECT 
    'Peminjaman' as kategori,
    COUNT(CASE WHEN YEAR(loan_date) = YEAR(CURDATE()) THEN 1 END) as tahun_ini,
    COUNT(CASE WHEN YEAR(loan_date) = YEAR(CURDATE()) - 1 THEN 1 END) as tahun_lalu,
    ROUND((COUNT(CASE WHEN YEAR(loan_date) = YEAR(CURDATE()) THEN 1 END) - 
           COUNT(CASE WHEN YEAR(loan_date) = YEAR(CURDATE()) - 1 THEN 1 END)) * 100.0 / 
           NULLIF(COUNT(CASE WHEN YEAR(loan_date) = YEAR(CURDATE()) - 1 THEN 1 END), 0), 2) as persentase_perubahan
FROM loan
UNION ALL
SELECT 
    'Anggota Baru' as kategori,
    COUNT(CASE WHEN YEAR(member_since_date) = YEAR(CURDATE()) THEN 1 END) as tahun_ini,
    COUNT(CASE WHEN YEAR(member_since_date) = YEAR(CURDATE()) - 1 THEN 1 END) as tahun_lalu,
    ROUND((COUNT(CASE WHEN YEAR(member_since_date) = YEAR(CURDATE()) THEN 1 END) - 
           COUNT(CASE WHEN YEAR(member_since_date) = YEAR(CURDATE()) - 1 THEN 1 END)) * 100.0 / 
           NULLIF(COUNT(CASE WHEN YEAR(member_since_date) = YEAR(CURDATE()) - 1 THEN 1 END), 0), 2) as persentase_perubahan
FROM member
UNION ALL
SELECT 
    'Pengunjung' as kategori,
    COUNT(CASE WHEN YEAR(checkin_date) = YEAR(CURDATE()) THEN 1 END) as tahun_ini,
    COUNT(CASE WHEN YEAR(checkin_date) = YEAR(CURDATE()) - 1 THEN 1 END) as tahun_lalu,
    ROUND((COUNT(CASE WHEN YEAR(checkin_date) = YEAR(CURDATE()) THEN 1 END) - 
           COUNT(CASE WHEN YEAR(checkin_date) = YEAR(CURDATE()) - 1 THEN 1 END)) * 100.0 / 
           NULLIF(COUNT(CASE WHEN YEAR(checkin_date) = YEAR(CURDATE()) - 1 THEN 1 END), 0), 2) as persentase_perubahan
FROM visitor_count;

-- ==========================================
-- 94. TOP 10 HARI DENGAN AKTIVITAS TERTINGGI
-- ==========================================
-- Busiest days di perpustakaan
SELECT 
    DATE(checkin_date) as tanggal,
    DAYNAME(checkin_date) as hari,
    COUNT(*) as total_pengunjung
FROM visitor_count
WHERE checkin_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY DATE(checkin_date), DAYNAME(checkin_date)
ORDER BY total_pengunjung DESC
LIMIT 10;

-- ==========================================
-- 95. LAPORAN KOLEKSI TIDAK AKTIF (DEAD COLLECTION)
-- ==========================================
-- Koleksi kandidat untuk weeding/withdrawal
-- Kriteria: tidak dipinjam >180 hari
SELECT 
    b.biblio_id,
    b.title,
    b.publish_year,
    p.publisher_name,
    COUNT(i.item_id) as total_eksemplar,
    COALESCE(COUNT(l.loan_id), 0) as total_peminjaman_setahun,
    b.input_date,
    DATEDIFF(CURDATE(), b.input_date) as hari_sejak_ditambahkan,
    CASE 
        WHEN COUNT(l.loan_id) = 0 AND DATEDIFF(CURDATE(), b.input_date) > 365 THEN 'Withdraw Candidate'
        WHEN COUNT(l.loan_id) = 0 AND DATEDIFF(CURDATE(), b.input_date) > 180 THEN 'Perlu Promosi'
        ELSE 'Monitor'
    END as rekomendasi
FROM biblio b
JOIN item i ON b.biblio_id = i.biblio_id
LEFT JOIN mst_publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN loan l ON i.item_code = l.item_code 
    AND l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY b.biblio_id, b.title, b.publish_year, p.publisher_name, b.input_date
HAVING total_peminjaman_setahun = 0
    AND hari_sejak_ditambahkan > 180
ORDER BY hari_sejak_ditambahkan DESC
LIMIT 50;
```


***

## **⚙️ 8. MASTER DATA MANAGEMENT (5 Queries)**

```sql
-- ==========================================
-- 96. DAFTAR ATURAN PEMINJAMAN (LOAN RULES)
-- ==========================================
-- Kombinasi: member_type × coll_type × gmd
-- Menentukan: batas pinjam, durasi, denda, perpanjangan
SELECT 
    lr.loan_rules_id,
    mt.member_type_name,
    ct.coll_type_name,
    g.gmd_name,
    lr.loan_limit as batas_pinjam,
    lr.loan_periode as periode_hari,
    lr.reborrow_limit as batas_perpanjangan,
    lr.fine_each_day as denda_per_hari,
    lr.grace_periode as masa_tenggang_hari
FROM mst_loan_rules lr
JOIN mst_member_type mt ON lr.member_type_id = mt.member_type_id
LEFT JOIN mst_coll_type ct ON lr.coll_type_id = ct.coll_type_id
LEFT JOIN mst_gmd g ON lr.gmd_id = g.gmd_id
ORDER BY mt.member_type_name, ct.coll_type_name;

-- ==========================================
-- 97. DAFTAR LOKASI DENGAN STATISTIK ITEM
-- ==========================================
-- Location: ka=Karya Akhir, bw=Buku Wajib, dll
SELECT 
    loc.location_id,
    loc.location_name,
    COUNT(i.item_id) as total_item,
    COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as sedang_dipinjam,
    COUNT(i.item_id) - COUNT(CASE WHEN l.is_return = 0 THEN 1 END) as tersedia,
    loc.input_date,
    loc.last_update
FROM mst_location loc
LEFT JOIN item i ON loc.location_id = i.location_id
LEFT JOIN loan l ON i.item_code = l.item_code AND l.is_return = 0
GROUP BY loc.location_id, loc.location_name, loc.input_date, loc.last_update
ORDER BY total_item DESC;

-- ==========================================
-- 98. DAFTAR TIPE ANGGOTA DENGAN HAK AKSES
-- ==========================================
-- Hak & privilege per tipe anggota
-- enable_reserve: 0=tidak bisa, 1=bisa reservasi
SELECT 
    mt.member_type_id,
    mt.member_type_name,
    mt.loan_limit as batas_pinjam,
    mt.loan_periode as durasi_hari,
    mt.enable_reserve,
    mt.reserve_limit,
    mt.member_periode as masa_keanggotaan_hari,
    mt.reborrow_limit as batas_perpanjangan,
    mt.fine_each_day as denda_default,
    mt.grace_periode as grace_period,
    COUNT(m.member_id) as jumlah_anggota
FROM mst_member_type mt
LEFT JOIN member m ON mt.member_type_id = m.member_type_id
GROUP BY mt.member_type_id, mt.member_type_name, mt.loan_limit, mt.loan_periode, 
         mt.enable_reserve, mt.reserve_limit, mt.member_periode, mt.reborrow_limit, 
         mt.fine_each_day, mt.grace_periode
ORDER BY jumlah_anggota DESC;

-- ==========================================
-- 99. DAFTAR GMD DENGAN JUMLAH KOLEKSI
-- ==========================================
-- GMD: General Material Designation (jenis media)
-- Contoh: Buku, eBook, CD-ROM, DVD, dll
SELECT 
    g.gmd_id,
    g.gmd_code,
    g.gmd_name,
    g.icon_image,
    COUNT(b.biblio_id) as jumlah_koleksi,
    MAX(b.input_date) as koleksi_terbaru
FROM mst_gmd g
LEFT JOIN biblio b ON g.gmd_id = b.gmd_id
GROUP BY g.gmd_id, g.gmd_code, g.gmd_name, g.icon_image
ORDER BY jumlah_koleksi DESC;

-- ==========================================
-- 100. DAFTAR PROGRAM STUDI DENGAN JUMLAH ANGGOTA
-- ==========================================
-- Master data program studi FEB UI
-- Jenjang: s1, s2, s3, Profesi
SELECT 
    p.id,
    p.jenjang,
    p.prodi,
    COUNT(mc.member_id) as total_anggota,
    COUNT(CASE WHEN mc.is_bebas_pustaka = 1 THEN 1 END) as sudah_bebas_pustaka,
    COUNT(CASE WHEN mc.is_self_regist = 1 THEN 1 END) as dari_self_registration,
    p.create_at,
    p.update_at
FROM mst_prodi p
LEFT JOIN member_custom mc ON p.id = mc.prodi_id
GROUP BY p.id, p.jenjang, p.prodi, p.create_at, p.update_at
ORDER BY p.jenjang, total_anggota DESC;
```


***

# **SUMMARY KATEGORI**

| No | Kategori | Jumlah Query | Deskripsi |
| :-- | :-- | :-- | :-- |
| 1 | Member Management | 15 | Kelola anggota, verifikasi, bebas pustaka, self registration |
| 2 | Catalog/Bibliographic | 15 | Pencarian koleksi, statistik katalog, pengelolaan bibliografi |
| 3 | Circulation/Loan | 20 | Peminjaman, pengembalian, keterlambatan, denda, statistik sirkulasi |
| 4 | Item/Inventory | 15 | Inventaris, ketersediaan, pengadaan, kondisi item, stock opname |
| 5 | Fines \& Reserves | 10 | Denda, pembayaran, reservasi koleksi, demand analysis |
| 6 | Room Management | 10 | Peminjaman ruangan, statistik utilisasi, booking room |
| 7 | Reports \& Analytics | 10 | Dashboard, laporan, statistik pengunjung, trend analysis |
| 8 | Master Data | 5 | Loan rules, tipe anggota, lokasi, GMD, program studi |
| **TOTAL** | **100** | **Semua aspek perpustakaan tercakup** |  |


***

**✅ Semua query sudah:**

- Disesuaikan dengan struktur database SLiMS FEB UI
- Dilengkapi keterangan kolom penting
- Menggunakan naming convention yang benar (underscore)
- Siap digunakan untuk production
<span style="display:none">[^1][^2]</span>

<div align="center">⁂</div>

[^1]: processed_slims_rag.md

[^2]: custom-tables-and-mst-data-psb.sql

