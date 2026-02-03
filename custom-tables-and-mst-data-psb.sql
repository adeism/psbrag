-- Custom data for mst_* tables & some custom tables from plugin
-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 03, 2026 at 01:12 AM
-- Server version: 10.6.18-MariaDB-log
-- PHP Version: 7.4.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `psb_slims`
--

-- --------------------------------------------------------

--
-- Table structure for table `biblio_custom`
--

CREATE TABLE `biblio_custom` (
  `biblio_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='one to one relation with real biblio table';

-- --------------------------------------------------------

--
-- Table structure for table `member_custom`
--

CREATE TABLE `member_custom` (
  `member_id` varchar(20) NOT NULL,
  `telegram_id` varchar(32) DEFAULT NULL,
  `telegram_username` varchar(64) DEFAULT NULL,
  `is_self_regist` int(11) DEFAULT 0,
  `is_bebas_pustaka` int(11) DEFAULT 0,
  `prodi_id` int(11) DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `verify_token` text DEFAULT NULL,
  `cf_03ddf` text DEFAULT NULL COMMENT 'field for Lulus?',
  `cf_cc26d` text DEFAULT NULL COMMENT 'field for Loker'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci COMMENT='one to one relation with real member table';

-- --------------------------------------------------------

--
-- Table structure for table `mst_coll_type`
--

CREATE TABLE `mst_coll_type` (
  `coll_type_id` int(3) NOT NULL,
  `coll_type_name` varchar(30) NOT NULL,
  `input_date` date DEFAULT NULL,
  `last_update` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `mst_coll_type`
--

INSERT INTO `mst_coll_type` (`coll_type_id`, `coll_type_name`, `input_date`, `last_update`) VALUES
(1, 'ADB Repository', '2022-06-23', '2022-06-23'),
(2, 'Artikel Jurnal', NULL, NULL),
(3, 'B. Penunjang', NULL, '2022-11-11'),
(4, 'B. Wajib', NULL, '2022-11-11'),
(5, 'Data Ekonomi & Bisnis', NULL, NULL),
(6, 'Disertasi', NULL, NULL),
(7, 'eBook', NULL, NULL),
(8, 'Laporan Penelitian', NULL, NULL),
(9, 'Majalah', NULL, NULL),
(10, 'Non Buku', NULL, NULL),
(11, 'Skripsi', NULL, NULL),
(12, 'Tesis', NULL, NULL),
(13, 'Cases Harvard', '2023-02-23', '2023-02-23'),
(16, 'Studi Kasus FEB UI', '2025-05-26', '2025-05-26'),
(17, 'Pidato Guru Besar', '2025-07-24', '2025-07-24');

-- --------------------------------------------------------

--
-- Table structure for table `mst_custom_field`
--

CREATE TABLE `mst_custom_field` (
  `field_id` int(11) NOT NULL,
  `primary_table` varchar(100) DEFAULT NULL,
  `dbfield` varchar(50) NOT NULL,
  `label` varchar(80) NOT NULL,
  `type` enum('text','checklist','numeric','dropdown','longtext','choice','date') NOT NULL,
  `default` varchar(80) DEFAULT NULL,
  `max` int(11) DEFAULT NULL,
  `data` text DEFAULT NULL,
  `indexed` tinyint(1) DEFAULT NULL,
  `class` varchar(100) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `width` int(5) DEFAULT 100,
  `note` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `mst_custom_field`
--

INSERT INTO `mst_custom_field` (`field_id`, `primary_table`, `dbfield`, `label`, `type`, `default`, `max`, `data`, `indexed`, `class`, `is_public`, `width`, `note`) VALUES
(5, 'member', 'cf_03ddf', 'Lulus', 'choice', NULL, NULL, 'a:2:{i:0;a:2:{i:0;i:0;i:1;s:5:\"belum\";}i:1;a:2:{i:0;i:1;i:1;s:5:\"sudah\";}}', NULL, '', 1, 100, 'centang jika sudah lulus'),
(6, 'member', 'cf_cc26d', 'Loker', 'choice', NULL, NULL, 'a:2:{i:0;a:2:{i:0;i:0;i:1;s:5:\"tidak\";}i:1;a:2:{i:0;i:1;i:1;s:2:\"ya\";}}', NULL, '', 1, 100, 'Status untuk member yang pinjam loker');

-- --------------------------------------------------------

--
-- Table structure for table `mst_item_status`
--

CREATE TABLE `mst_item_status` (
  `item_status_id` char(3) NOT NULL,
  `item_status_name` varchar(30) NOT NULL,
  `rules` varchar(255) DEFAULT NULL,
  `no_loan` smallint(1) NOT NULL DEFAULT 0,
  `skip_stock_take` smallint(1) NOT NULL DEFAULT 0,
  `input_date` date DEFAULT NULL,
  `last_update` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `mst_item_status`
--

INSERT INTO `mst_item_status` (`item_status_id`, `item_status_name`, `rules`, `no_loan`, `skip_stock_take`, `input_date`, `last_update`) VALUES
('BD', 'Baca di tempat', NULL, 0, 0, '2022-08-25', '2023-02-21'),
('MIS', 'Missing', NULL, 1, 1, '2022-01-05', '2023-02-21'),
('NL', 'No Loan', NULL, 1, 0, '2022-01-05', '2023-02-21'),
('R', 'Repair', NULL, 1, 0, '2022-01-05', '2023-02-21'),
('sc', 'Softcopy', NULL, 1, 1, '2023-03-03', '2023-03-03');

-- --------------------------------------------------------

--
-- Table structure for table `mst_loan_rules`
--

CREATE TABLE `mst_loan_rules` (
  `loan_rules_id` int(11) NOT NULL,
  `member_type_id` int(11) NOT NULL DEFAULT 0,
  `coll_type_id` int(11) DEFAULT 0,
  `gmd_id` int(11) DEFAULT 0,
  `loan_limit` int(3) DEFAULT 0,
  `loan_periode` int(3) DEFAULT 0,
  `reborrow_limit` int(3) DEFAULT 0,
  `fine_each_day` int(3) DEFAULT 0,
  `grace_periode` int(2) DEFAULT 0,
  `input_date` date DEFAULT NULL,
  `last_update` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `mst_loan_rules`
--

INSERT INTO `mst_loan_rules` (`loan_rules_id`, `member_type_id`, `coll_type_id`, `gmd_id`, `loan_limit`, `loan_periode`, `reborrow_limit`, `fine_each_day`, `grace_periode`, `input_date`, `last_update`) VALUES
(1, 1, 9, 0, 1, 0, 0, 0, 0, '2022-07-19', '2022-07-19'),
(2, 1, 3, 0, 5, 14, 3, 1000, 0, '2022-07-19', '2023-04-18'),
(3, 1, 4, 0, 3, 7, 3, 2000, 0, '2022-07-19', '2023-03-24'),
(4, 2, 3, 0, 10, 31, 3, 1000, 0, '2022-07-19', '2025-09-15'),
(5, 2, 4, 0, 10, 31, 3, 2000, 0, '2022-07-19', '2025-09-15'),
(6, 1, 6, 0, 10, 0, 0, 0, 0, '2022-07-19', '2023-03-01'),
(7, 1, 11, 0, 10, 0, 0, 0, 0, '2022-07-19', '2023-03-01'),
(8, 1, 12, 0, 10, 0, 0, 0, 0, '2022-07-19', '2023-03-01'),
(9, 1, 5, 0, 10, 0, 0, 0, 0, '2022-07-19', '2023-03-24'),
(11, 1, 2, 0, 1, 0, 0, 0, 0, '2022-07-19', '2022-07-19'),
(12, 2, 11, 0, 10, 0, 0, 0, 0, '2023-03-01', '2023-03-01'),
(13, 2, 12, 0, 10, 0, 0, 0, 0, '2023-03-01', '2023-03-01'),
(14, 2, 6, 0, 10, 0, 0, 0, 0, '2023-03-01', '2023-03-01'),
(16, 3, 4, 0, 4, 0, 0, 0, 0, '2023-03-16', '2023-03-16'),
(17, 3, 11, 0, 10, 0, 0, 0, 0, '2023-03-16', '2023-03-16'),
(18, 3, 6, 0, 10, 0, 0, 0, 0, '2023-03-16', '2023-03-24'),
(19, 3, 12, 0, 10, 0, 0, 0, 0, '2023-03-16', '2023-03-24'),
(20, 4, 3, 0, 5, 14, 2, 0, 0, '2025-10-24', '2025-10-24'),
(21, 4, 4, 0, 3, 7, 2, 0, 0, '2025-10-24', '2025-10-24');

-- --------------------------------------------------------

--
-- Table structure for table `mst_location`
--

CREATE TABLE `mst_location` (
  `location_id` varchar(3) NOT NULL,
  `location_name` varchar(100) DEFAULT NULL,
  `input_date` date NOT NULL,
  `last_update` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `mst_location`
--

INSERT INTO `mst_location` (`location_id`, `location_name`, `input_date`, `last_update`) VALUES
('adb', 'ADB Repository Online', '2025-08-22', '2025-08-22'),
('bp', 'PSB lt.1 - B. Penunjang', '2022-06-29', '2022-11-11'),
('bw', 'PSB lt.1 - B. Wajib', '2022-06-29', '2023-06-09'),
('cb', 'CELEB FEB UI', '2024-08-01', '2024-08-01'),
('ka', 'PSB lt.2 - Karya Akhir', '2022-06-29', '2022-06-30'),
('pa', 'PSB lt.dasar - Pascasarjana', '2022-06-29', '2022-11-08'),
('pd', 'PSB lt.1 - Pusat Data Ekonomi & Bisnis', '2022-06-29', '2022-07-19'),
('sd', 'PSB lt.1 - R. Prof. Sumitro Djojohadikusumo', '2022-06-29', '2022-07-19');

-- --------------------------------------------------------

--
-- Table structure for table `mst_member_type`
--

CREATE TABLE `mst_member_type` (
  `member_type_id` int(11) NOT NULL,
  `member_type_name` varchar(50) NOT NULL,
  `loan_limit` int(11) NOT NULL,
  `loan_periode` int(11) NOT NULL,
  `enable_reserve` int(1) NOT NULL DEFAULT 0,
  `reserve_limit` int(11) NOT NULL DEFAULT 0,
  `member_periode` int(11) NOT NULL,
  `reborrow_limit` int(11) NOT NULL,
  `fine_each_day` int(11) NOT NULL,
  `grace_periode` int(2) DEFAULT 0,
  `input_date` date NOT NULL,
  `last_update` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `mst_member_type`
--

INSERT INTO `mst_member_type` (`member_type_id`, `member_type_name`, `loan_limit`, `loan_periode`, `enable_reserve`, `reserve_limit`, `member_periode`, `reborrow_limit`, `fine_each_day`, `grace_periode`, `input_date`, `last_update`) VALUES
(1, 'Mahasiswa', 2, 7, 1, 0, 365, 1, 0, 0, '2022-01-05', '2023-03-16'),
(2, 'Dosen', 5, 185, 1, 1, 365, 1, 0, 0, '2022-07-19', '2025-06-21'),
(3, 'Umum/Alumni/Mhs. UI Non-FEB', 5, 0, 0, 0, 1, 0, 0, 0, '2022-07-19', '2025-12-18'),
(4, 'Tendik', 5, 185, 1, 1, 365, 1, 0, 0, '2025-06-21', '2025-06-21'),
(5, 'Asdos (lulus)', 2, 7, 1, 0, 365, 1, 0, 0, '2025-06-21', '2025-06-21');

-- --------------------------------------------------------

--
-- Table structure for table `mst_prodi`
--

CREATE TABLE `mst_prodi` (
  `id` int(11) NOT NULL,
  `jenjang` varchar(10) DEFAULT NULL,
  `prodi` varchar(255) NOT NULL,
  `create_at` datetime NOT NULL,
  `update_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `mst_prodi`
--

INSERT INTO `mst_prodi` (`id`, `jenjang`, `prodi`, `create_at`, `update_at`) VALUES
(1, 's1', 'S1 - Manajemen', '2022-12-18 19:43:23', '2022-12-18 19:43:23'),
(2, 's1', 'S1 - Akuntansi', '2022-12-18 19:43:45', '2022-12-18 19:43:45'),
(3, 's1', 'S1 - Ilmu Ekonomi', '2022-12-18 19:44:03', '2022-12-18 19:44:03'),
(4, 's1', 'S1 - Bisnis Islam', '2023-02-13 15:20:40', '2023-02-13 15:20:40'),
(5, 's1', 'S1 - Ilmu Ekonomi Islam', '2023-02-13 15:21:00', '2023-02-13 15:21:00'),
(6, 's1', 'S1 - KKI/International Program', '2023-02-13 15:23:26', '2023-02-13 15:25:56'),
(7, 's1', 'S1 - Ekstensi', '2023-02-13 15:24:12', '2023-02-13 15:24:12'),
(8, 's2', 'S2 - MAKSI-PPAk.', '2023-02-13 15:24:28', '2023-02-13 15:44:50'),
(9, 's2', 'S2 - PPIA', '2023-02-13 15:24:39', '2023-02-13 15:30:42'),
(10, 's2', 'S2 - MM', '2023-02-13 15:25:07', '2023-02-13 15:42:59'),
(11, 's2', 'S2 - PPIM', '2023-02-13 15:25:17', '2023-02-13 15:40:41'),
(12, 's2', 'S2 - MPKP', '2023-02-13 15:25:38', '2023-02-13 15:30:32'),
(13, 's2', 'S2 - MEKK', '2023-02-13 15:26:09', '2023-02-13 15:30:20'),
(14, 's2', 'S2 - PPIE', '2023-02-13 15:26:20', '2023-02-13 15:30:52'),
(15, 's3', 'S3 - PPIA', '2023-02-13 15:26:31', '2023-02-13 15:31:43'),
(16, 's3', 'S3 - PPIM', '2023-02-13 15:26:41', '2023-02-13 15:32:04'),
(17, 's3', 'S3 - PPIE', '2023-02-13 15:26:54', '2023-02-13 15:31:52'),
(18, 'Profesi', 'Profesi', '2023-06-27 10:05:49', '2023-06-27 13:46:08');

-- --------------------------------------------------------

--
-- Table structure for table `mst_publisher`
--

CREATE TABLE `mst_publisher` (
  `publisher_id` int(11) NOT NULL,
  `publisher_name` varchar(100) NOT NULL,
  `input_date` date DEFAULT NULL,
  `last_update` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;


--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL,
  `room_name` varchar(255) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `status` enum('in use','available','closed') DEFAULT NULL,
  `location` enum('Lt. 3','Basement') NOT NULL DEFAULT 'Lt. 3',
  `facilities` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `room_name`, `capacity`, `status`, `location`, `facilities`) VALUES
(1, 'Discussion  1', 5, 'available', 'Lt. 3', 'whiteboard'),
(2, 'Discussion 2', 5, 'available', 'Lt. 3', 'tv'),
(11, 'Discussion 3', 7, 'available', 'Lt. 3', 'smart TV'),
(12, 'Seminar A ', 1, 'available', 'Lt. 3', 'Proyektor'),
(13, 'Seminar B (open)', 1, 'available', 'Lt. 3', 'Proyektor'),
(14, 'Meeting Room Lt. 1', 1, 'available', 'Lt. 3', 'Proyektor'),
(18, 'Pascasarjana 1', 1, 'available', 'Basement', 'meja'),
(19, 'Pascasarjana 2', 1, 'available', 'Basement', 'meja'),
(20, 'Pascasarjana 3', 1, 'available', 'Basement', 'meja'),
(21, 'Pascasarjana 4', 1, 'available', 'Basement', 'meja'),
(22, 'Pascasarjana 5', 1, 'available', 'Basement', 'meja');

-- --------------------------------------------------------

--
-- Table structure for table `room_report`
--

CREATE TABLE `room_report` (
  `id` int(11) NOT NULL,
  `room_id` int(11) DEFAULT NULL,
  `npm` text DEFAULT NULL,
  `tanggal_pinjam` date DEFAULT NULL,
  `waktu_pinjam` time DEFAULT NULL,
  `waktu_kembali` time DEFAULT NULL,
  `keterangan` text DEFAULT NULL,
  `nomor_telepon` varchar(20) DEFAULT NULL,
  `jumlah_user` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `setting`
--

CREATE TABLE `setting` (
  `setting_id` int(3) NOT NULL,
  `setting_name` varchar(30) NOT NULL,
  `setting_value` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `setting`
--

INSERT INTO `setting` (`setting_id`, `setting_name`, `setting_value`) VALUES
(1, 'library_name', 's:27:\"Pusat Sumber Belajar FEB UI\";'),
(2, 'library_subname', 's:0:\"\";'),
(3, 'template', 'a:2:{s:5:\"theme\";s:5:\"febui\";s:3:\"css\";s:24:\"template/febui/style.css\";}'),
(4, 'admin_template', 'a:2:{s:5:\"theme\";s:7:\"default\";s:3:\"css\";s:32:\"admin_template/default/style.css\";}'),
(5, 'default_lang', 's:5:\"id_ID\";'),
(6, 'opac_result_num', 's:2:\"20\";'),
(7, 'enable_promote_titles', 'a:1:{i:0;s:1:\"1\";}'),
(8, 'quick_return', 'b:0;'),
(9, 'allow_loan_date_change', 'b:1;'),
(10, 'loan_limit_override', 'b:0;'),
(11, 'enable_xml_detail', 'b:0;'),
(12, 'enable_xml_result', 'b:0;'),
(13, 'allow_file_download', 'b:1;'),
(14, 'session_timeout', 's:4:\"7200\";'),
(15, 'circulation_receipt', 'b:0;'),
(16, 'barcode_encoding', 's:7:\"code128\";'),
(17, 'ignore_holidays_fine_calc', 'b:1;'),
(20, 'membercard_print_settings', 'a:68:{s:8:\"template\";s:7:\"classic\";s:11:\"page_margin\";d:0.2;s:12:\"items_margin\";d:0.1;s:13:\"items_per_row\";i:1;s:6:\"factor\";s:12:\"37.795275591\";s:16:\"include_id_label\";i:1;s:18:\"include_name_label\";i:1;s:17:\"include_pin_label\";i:1;s:18:\"include_inst_label\";i:0;s:19:\"include_email_label\";i:0;s:21:\"include_address_label\";i:1;s:21:\"include_barcode_label\";i:1;s:21:\"include_expired_label\";i:1;s:9:\"box_width\";d:8.6;s:10:\"box_height\";d:5.4;s:16:\"front_side_image\";s:17:\"slimsacademy1.jpg\";s:15:\"back_side_image\";s:17:\"slimsacademy2.jpg\";s:4:\"logo\";s:8:\"logo.png\";s:16:\"front_logo_width\";s:0:\"\";s:17:\"front_logo_height\";s:0:\"\";s:15:\"front_logo_left\";s:0:\"\";s:14:\"front_logo_top\";s:0:\"\";s:15:\"back_logo_width\";s:0:\"\";s:16:\"back_logo_height\";s:0:\"\";s:14:\"back_logo_left\";s:0:\"\";s:13:\"back_logo_top\";s:0:\"\";s:10:\"photo_left\";s:0:\"\";s:9:\"photo_top\";s:0:\"\";s:11:\"photo_width\";d:1.5;s:12:\"photo_height\";d:1.8;s:18:\"front_header1_text\";s:19:\"Library Member Card\";s:23:\"front_header1_font_size\";s:2:\"12\";s:18:\"front_header2_text\";s:10:\"My Library\";s:23:\"front_header2_font_size\";s:2:\"12\";s:17:\"back_header1_text\";s:10:\"My Library\";s:22:\"back_header1_font_size\";s:2:\"12\";s:17:\"back_header2_text\";s:35:\"My Library Full Address and Website\";s:22:\"back_header2_font_size\";s:1:\"5\";s:12:\"header_color\";s:7:\"#0066FF\";s:13:\"bio_font_size\";s:2:\"11\";s:15:\"bio_font_weight\";s:4:\"bold\";s:15:\"bio_label_width\";s:3:\"100\";s:4:\"city\";s:9:\"City Name\";s:5:\"title\";s:15:\"Library Manager\";s:9:\"officials\";s:14:\"Librarian Name\";s:12:\"officials_id\";s:12:\"Librarian ID\";s:10:\"stamp_file\";s:9:\"stamp.png\";s:14:\"signature_file\";s:13:\"signature.png\";s:10:\"stamp_left\";s:0:\"\";s:9:\"stamp_top\";s:0:\"\";s:11:\"stamp_width\";s:0:\"\";s:12:\"stamp_height\";s:0:\"\";s:8:\"exp_left\";s:0:\"\";s:7:\"exp_top\";s:0:\"\";s:9:\"exp_width\";s:0:\"\";s:10:\"exp_height\";s:0:\"\";s:13:\"barcode_scale\";i:100;s:12:\"barcode_left\";s:0:\"\";s:11:\"barcode_top\";s:0:\"\";s:13:\"barcode_width\";s:0:\"\";s:14:\"barcode_height\";s:0:\"\";s:5:\"rules\";s:120:\"<ul>\r\n<li>This card is published by Library.</li>\r\n<li>Please return this card to its owner if you found it.</li>\r\n</ul>\";s:15:\"rules_font_size\";s:1:\"8\";s:7:\"address\";s:76:\"My Library<br />website: http://slims.web.id, email : librarian@slims.web.id\";s:17:\"address_font_size\";s:1:\"7\";s:12:\"address_left\";s:0:\"\";s:11:\"address_top\";s:0:\"\";s:3:\"css\";s:0:\"\";}'),
(21, 'enable_visitor_limitation', 's:1:\"0\";'),
(22, 'time_visitor_limitation', 's:3:\"180\";'),
(23, 'logo_image', 's:8:\"logo.png\";'),
(24, 'enable_counter_by_ip', 's:1:\"1\";'),
(25, 'allowed_counter_ip', 'a:1:{i:0;s:0:\"\";}'),
(26, 'reserve_direct_database', 's:1:\"1\";'),
(27, 'reserve_on_loan_only', 's:1:\"0\";'),
(29, 'batch_item_code_pattern', 'a:22:{i:0;s:7:\"P00000S\";i:2;s:8:\"22000000\";i:3;s:6:\"EK0000\";i:4;s:7:\"MA00000\";i:5;s:7:\"EK00000\";i:6;s:7:\"IA00000\";i:7;s:9:\"MEKK00000\";i:8;s:8:\"DMA00000\";i:9;s:8:\"DEK00000\";i:10;s:8:\"DIA00000\";i:11;s:8:\"DEB00000\";i:12;s:6:\"N00000\";i:13;s:6:\"M00000\";i:14;s:6:\"A00000\";i:15;s:6:\"E00000\";i:16;s:6:\"L00000\";i:17;s:7:\"ADB0000\";i:18;s:6:\"W00000\";i:19;s:6:\"P00000\";i:20;s:6:\"S00000\";i:21;s:6:\"D00000\";i:22;s:6:\"T00000\";}'),
(35, 'selfRegistration', 'a:8:{s:22:\"selfRegistrationActive\";s:1:\"1\";s:5:\"title\";s:40:\"Pendaftaran Keanggotaan Online PSB FEBUI\";s:10:\"autoActive\";s:1:\"0\";s:9:\"withImage\";s:1:\"1\";s:13:\"separateTable\";s:1:\"1\";s:12:\"editableData\";s:1:\"0\";s:12:\"useRecaptcha\";s:1:\"0\";s:9:\"regisInfo\";s:16:\"Informasi Kontak\";}'),
(36, 'shortcuts_2', 'a:1:{i:0;s:26:\"Konten|/system/content.php\";}'),
(38, 'shortcuts_3', 'a:6:{i:0;s:26:\"Konten|/system/content.php\";i:1;s:42:\"Daftar Bibliografi|/bibliography/index.php\";i:2;s:61:\"Tambah Bibliografi Baru|/bibliography/index.php?action=detail\";i:3;s:51:\"Mulai Transaksi|/circulation/index.php?action=start\";i:4;s:42:\"Lihat Daftar Anggota|/membership/index.php\";i:5;s:50:\"Tambah Anggota|/membership/index.php?action=detail\";}'),
(41, 'timezone', 's:12:\"Asia/Jakarta\";'),
(42, 'search_engine', 's:39:\"SLiMS\\\\SearchEngine\\\\SearchBiblioEngine\";'),
(44, 'enable_chbox_confirm', 'i:1;'),
(60, 'custom_currency_locale', 'a:3:{s:6:\"enable\";s:1:\"1\";s:6:\"region\";s:5:\"id_ID\";s:6:\"detail\";a:1:{s:9:\"attribute\";a:1:{s:19:\"MAX_FRACTION_DIGITS\";s:1:\"0\";}}}'),
(75, 'dflipConfig', 'a:3:{s:9:\"guestForm\";s:1:\"1\";s:13:\"allowDownload\";s:1:\"0\";s:3:\"tos\";s:290:\"<ol>\r\n	<li>Your ID will be used for internal use.</li>\r\n	<li>You are willing to accept all forms of use of the data that you have submitted and then will not dispute the use of the data even if you consider that the use of the data is not in accordance with your expectations.</li>\r\n</ol>\r\n\";}'),
(92, 'label_print_settings', 'a:10:{s:11:\"page_margin\";s:3:\"0.2\";s:13:\"items_per_row\";s:1:\"4\";s:12:\"items_margin\";s:4:\"0.05\";s:9:\"box_width\";s:1:\"8\";s:10:\"box_height\";s:3:\"3.3\";s:19:\"include_header_text\";s:1:\"1\";s:11:\"header_text\";s:0:\"\";s:5:\"fonts\";s:41:\"Arial, Verdana, Helvetica, \'Trebuchet MS\'\";s:9:\"font_size\";s:2:\"11\";s:11:\"border_size\";s:1:\"1\";}'),
(115, 'webicon', 's:11:\"webicon.png\";'),
(189, 'shortcuts_1', 'a:4:{i:0;s:91:\"Yearly Report|/admin/plugin_container.php?mod=reporting&id=eaab0fe438d116f23ea7ecda27154164\";i:1;s:93:\"Custom Report 1|/admin/plugin_container.php?mod=reporting&id=b90723663f7ecfd57a56f82fc532c5c9\";i:2;s:50:\"Manajemen Komentar|/master_file/detail_comment.php\";i:3;s:91:\"Yearly Report|/admin/plugin_container.php?mod=reporting&id=eaab0fe438d116f23ea7ecda27154164\";}'),
(210, 'barcode_print_settings', 'a:12:{s:19:\"barcode_page_margin\";s:3:\"0.1\";s:21:\"barcode_items_per_row\";s:1:\"3\";s:20:\"barcode_items_margin\";s:4:\"0.15\";s:17:\"barcode_box_width\";s:3:\"3.3\";s:18:\"barcode_box_height\";s:3:\"1.5\";s:27:\"barcode_include_header_text\";s:1:\"0\";s:17:\"barcode_cut_title\";s:1:\"0\";s:19:\"barcode_header_text\";s:0:\"\";s:13:\"barcode_fonts\";s:41:\"Arial, Verdana, Helvetica, \'Trebuchet MS\'\";s:17:\"barcode_font_size\";s:2:\"12\";s:13:\"barcode_scale\";s:2:\"90\";s:19:\"barcode_border_size\";s:1:\"0\";}'),
(211, 'label_barcode_classic', 'a:34:{s:13:\"barcode_fonts\";s:28:\"Arial, Helvetica, sans-serif\";s:17:\"barcode_font_size\";s:2:\"12\";s:19:\"barcode_page_margin\";s:1:\"2\";s:21:\"barcode_items_per_row\";s:1:\"2\";s:20:\"barcode_items_margin\";s:1:\"1\";s:18:\"barcode_box_height\";s:2:\"40\";s:17:\"barcode_box_width\";s:3:\"100\";s:19:\"barcode_border_size\";s:1:\"0\";s:20:\"barcode_border_color\";s:7:\"#000000\";s:16:\"callnumber_align\";s:6:\"center\";s:23:\"callnumber_padding_size\";s:2:\"20\";s:20:\"callnumber_font_size\";s:2:\"13\";s:27:\"barcode_include_header_text\";s:1:\"1\";s:19:\"barcode_header_text\";s:0:\"\";s:16:\"header_font_size\";s:2:\"11\";s:12:\"barcode_type\";s:2:\"qr\";s:16:\"barcode_position\";s:4:\"left\";s:14:\"barcode_rotate\";s:0:\"\";s:16:\"barcode_col_size\";s:2:\"65\";s:13:\"barcode_scale\";s:2:\"75\";s:17:\"barcode_cut_title\";s:2:\"25\";s:12:\"color_header\";s:1:\"0\";s:7:\"class_0\";s:7:\"#e35c5c\";s:7:\"class_1\";s:7:\"#a343dc\";s:7:\"class_2\";s:7:\"#2ee8c9\";s:8:\"class_2x\";s:7:\"#57cc12\";s:7:\"class_3\";s:7:\"#e8d82e\";s:7:\"class_4\";s:7:\"#f5822b\";s:7:\"class_5\";s:7:\"#5069c5\";s:7:\"class_6\";s:7:\"#c775b4\";s:7:\"class_7\";s:7:\"#c3f30e\";s:7:\"class_8\";s:7:\"#caa030\";s:7:\"class_9\";s:7:\"#9d7afa\";s:11:\"class_other\";s:7:\"#ffffff\";}'),
(212, 'spellchecker_enabled', 'b:1;');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `biblio_custom`
--
ALTER TABLE `biblio_custom`
  ADD PRIMARY KEY (`biblio_id`);

--
-- Indexes for table `member_custom`
--
ALTER TABLE `member_custom`
  ADD PRIMARY KEY (`member_id`);

--
-- Indexes for table `mst_coll_type`
--
ALTER TABLE `mst_coll_type`
  ADD PRIMARY KEY (`coll_type_id`),
  ADD UNIQUE KEY `coll_type_name` (`coll_type_name`);

--
-- Indexes for table `mst_custom_field`
--
ALTER TABLE `mst_custom_field`
  ADD PRIMARY KEY (`dbfield`),
  ADD UNIQUE KEY `field_id` (`field_id`);

--
-- Indexes for table `mst_item_status`
--
ALTER TABLE `mst_item_status`
  ADD PRIMARY KEY (`item_status_id`),
  ADD UNIQUE KEY `item_status_name` (`item_status_name`);

--
-- Indexes for table `mst_loan_rules`
--
ALTER TABLE `mst_loan_rules`
  ADD PRIMARY KEY (`loan_rules_id`);

--
-- Indexes for table `mst_location`
--
ALTER TABLE `mst_location`
  ADD PRIMARY KEY (`location_id`),
  ADD UNIQUE KEY `location_name` (`location_name`);

--
-- Indexes for table `mst_member_type`
--
ALTER TABLE `mst_member_type`
  ADD PRIMARY KEY (`member_type_id`),
  ADD UNIQUE KEY `member_type_name` (`member_type_name`);

--
-- Indexes for table `mst_prodi`
--
ALTER TABLE `mst_prodi`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mst_publisher`
--
ALTER TABLE `mst_publisher`
  ADD PRIMARY KEY (`publisher_id`),
  ADD UNIQUE KEY `publisher_name` (`publisher_name`),
  ADD KEY `idx_publisher_name` (`publisher_name`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `room_report`
--
ALTER TABLE `room_report`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room_id` (`room_id`);

--
-- Indexes for table `setting`
--
ALTER TABLE `setting`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `setting_name` (`setting_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `mst_coll_type`
--
ALTER TABLE `mst_coll_type`
  MODIFY `coll_type_id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `mst_custom_field`
--
ALTER TABLE `mst_custom_field`
  MODIFY `field_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `mst_loan_rules`
--
ALTER TABLE `mst_loan_rules`
  MODIFY `loan_rules_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `mst_member_type`
--
ALTER TABLE `mst_member_type`
  MODIFY `member_type_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `mst_prodi`
--
ALTER TABLE `mst_prodi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `mst_publisher`
--
ALTER TABLE `mst_publisher`
  MODIFY `publisher_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11410;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `room_report`
--
ALTER TABLE `room_report`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `setting`
--
ALTER TABLE `setting`
  MODIFY `setting_id` int(3) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=213;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `room_report`
--
ALTER TABLE `room_report`
  ADD CONSTRAINT `room_report_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
