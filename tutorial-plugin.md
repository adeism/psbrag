## Daftar Isi
- [Pengenalan Struktur Plugin](#pengenalan-struktur-plugin)
- [File Utama Plugin](#file-utama-plugin)
- [Helper Functions](#helper-functions)
- [Database Migration](#database-migration)
- [Pages dan Routing](#pages-dan-routing)
- [Action Handlers](#action-handlers)
- [Form Management](#form-management)
- [Custom Override Pages](#custom-override-pages)
- [Plugin Hooks](#plugin-hooks)
- [Security Best Practices](#security-best-practices)

***

## Pengenalan Struktur Plugin

### Struktur Folder Plugin (Sesuai Template)

```
nama_plugin/
├── README.md                           # Dokumentasi plugin untuk pengguna
├── helper.php                          # Fungsi-fungsi pembantu/utility
├── nama_plugin.plugin.php             # File utama plugin (WAJIB)
├── migration/                          # Folder untuk migrasi database
│   ├── 1_CreateSchema.php             # Migration pertama: buat tabel
│   ├── 2_AddColumnEmail.php           # Migration kedua: tambah kolom (contoh)
│   └── 3_CreateIndexes.php            # Migration ketiga: buat index (contoh)
├── pages/                              # Folder untuk halaman-halaman
│   ├── customs/                        # Override halaman SLiMS default (opsional)
│   │   └── membership/
│   │       └── index.php              # Override halaman membership SLiMS
│   ├── membership/                     # Halaman admin (backend)
│   │   ├── index.php                  # Router utama admin
│   │   ├── list.inc.php               # Halaman list data
│   │   ├── add_schema.inc.php         # Form tambah data
│   │   ├── form_config.inc.php        # Halaman konfigurasi
│   │   ├── form_preview.inc.php       # Preview form
│   │   ├── view_detail.inc.php        # Detail data
│   │   └── action/                    # Folder untuk proses form
│   │       ├── save.php               # Proses simpan data baru
│   │       ├── update.php             # Proses update data
│   │       ├── delete.php             # Proses hapus data
│   │       ├── create_schema.php      # Proses buat schema
│   │       └── active_schema.php      # Proses aktifkan schema
│   └── opac/                           # Halaman publik (frontend)
│       ├── index.php                  # Halaman utama OPAC
│       └── action/
│           └── save.php               # Proses data dari publik
└── static/                             # Asset statis (opsional)
    ├── css/
    │   └── style.css
    ├── js/
    │   └── script.js
    └── images/
        └── icon.png
```

**Catatan Penting:**
- File `nama_plugin.plugin.php` adalah **WAJIB** dan namanya harus sesuai dengan nama folder plugin
- Folder `migration/` akan dijalankan otomatis saat plugin diaktifkan
- Folder `pages/` berisi semua halaman plugin
- Folder `customs/` untuk override halaman SLiMS default (hati-hati menggunakannya)

***

## File Utama Plugin

### 1. File `nama_plugin.plugin.php` - Entry Point Plugin

```php
<?php
/**
 * ====================================================================
 * HEADER PLUGIN - Meta Information (WAJIB)
 * ====================================================================
 * Format header ini mengikuti standar WordPress Plugin Header
 * SLiMS akan membaca informasi ini untuk ditampilkan di halaman plugin
 */

/**
 * Plugin Name: Nama Plugin Anda
 * Nama yang akan muncul di daftar plugin di menu System > Plugins
 * Contoh: Member Self Registration, Book Reservation, Online Payment
 * 
 * Plugin URI: https://github.com/username/nama_plugin
 * URL repository atau website plugin (untuk link "Visit plugin site")
 * 
 * Description: Plugin untuk mengelola data tertentu dengan fitur X, Y, Z
 * Deskripsi singkat yang menjelaskan fungsi plugin (1-2 kalimat)
 * Akan ditampilkan di bawah nama plugin
 * 
 * Version: 1.0.0
 * Versi plugin mengikuti semantic versioning:
 * - Major.Minor.Patch (contoh: 2.1.3)
 * - Major: Perubahan breaking changes
 * - Minor: Fitur baru tanpa breaking changes  
 * - Patch: Bug fixes
 * 
 * Author: Nama Anda
 * Nama pembuat/developer plugin
 * 
 * Author URI: https://yourwebsite.com
 * Website, GitHub, atau profil pembuat plugin
 */

/**
 * ====================================================================
 * IMPORT NAMESPACE SLiMS
 * ====================================================================
 * Mengimpor class-class framework SLiMS yang diperlukan
 * Gunakan 'use' statement untuk memudahkan pemanggilan class
 */

use SLiMS\DB;              // Class untuk koneksi database dan query
                           // Menggantikan mysqli/PDO manual
                           // Contoh: DB::getInstance()->query()

use SLiMS\Plugins;         // Class untuk manajemen plugin
                           // Register menu, hooks, dan event
                           // Contoh: Plugins::getInstance()

use SLiMS\Url;            // Class untuk generate dan manipulasi URL
                          // Menghasilkan URL SLiMS yang benar
                          // Contoh: Url::getSlimsBaseUri()

use SLiMS\Table\Schema;   // Class untuk operasi DDL database
                          // Create table, drop table, check table exists
                          // Contoh: Schema::hasTable(), Schema::create()

/**
 * ====================================================================
 * KONSTANTA PLUGIN
 * ====================================================================
 * Define konstanta untuk path dan URL plugin
 * Ini memudahkan akses file dan asset plugin
 */

// Konstanta untuk PATH absolut ke folder plugin di server
// __DIR__ adalah magic constant PHP yang berisi path file saat ini
// Contoh hasil: /var/www/html/slims/plugins/nama_plugin
define('NAMA_PLUGIN_DIR', __DIR__);

// Alternatif penamaan (lihat contoh di member_self_registration):
// define('MSLR', __DIR__);  // Singkatan dari Member Self-Registration

// Konstanta untuk URL web ke folder plugin
// Digunakan untuk load CSS, JavaScript, atau gambar dari folder plugin
// basename(__DIR__) mengambil nama folder plugin
// Contoh hasil: http://localhost/slims/plugins/nama_plugin/
define('NAMA_PLUGIN_WEB', (string)Url::getSlimsBaseUri('plugins/' . basename(__DIR__) . '/'));

// Alternatif penamaan:
// define('MSWB', (string)Url::getSlimsBaseUri('plugins/' . basename(__DIR__) . '/'));

/**
 * PENGGUNAAN KONSTANTA:
 * 
 * Untuk include file PHP:
 * include NAMA_PLUGIN_DIR . DS . 'helper.php';
 * include NAMA_PLUGIN_DIR . DS . 'pages' . DS . 'admin' . DS . 'index.php';
 * 
 * Untuk load asset (CSS/JS/Image):
 * <link rel="stylesheet" href="<?= NAMA_PLUGIN_WEB ?>static/css/style.css">
 * <script src="<?= NAMA_PLUGIN_WEB ?>static/js/script.js"></script>
 * <img src="<?= NAMA_PLUGIN_WEB ?>static/images/icon.png">
 * 
 * DS adalah konstanta SLiMS untuk DIRECTORY_SEPARATOR:
 * - Di Linux/Mac: DS = '/'
 * - Di Windows: DS = '\'
 */

/**
 * ====================================================================
 * LOAD HELPER FUNCTIONS
 * ====================================================================
 * Include file helper.php yang berisi fungsi-fungsi utility
 */
include_once __DIR__ . DS . 'helper.php';

// include_once vs include vs require vs require_once:
// - include: Load file, warning jika tidak ada (lanjut eksekusi)
// - include_once: Load file sekali saja, skip jika sudah di-load
// - require: Load file, fatal error jika tidak ada (stop eksekusi)
// - require_once: Load file sekali saja, fatal error jika tidak ada

/**
 * ====================================================================
 * INISIALISASI PLUGIN INSTANCE
 * ====================================================================
 * Ambil singleton instance dari Plugin Manager
 */
$plugin = Plugins::getInstance();

// Plugins::getInstance() mengembalikan object singleton
// Artinya selalu return object yang sama di seluruh aplikasi
// Object ini punya method untuk:
// - registerMenu(): Daftar menu plugin
// - register(): Daftar hook/event
// - execute(): Trigger hook

/**
 * ====================================================================
 * REGISTRASI MENU PLUGIN DI ADMIN AREA
 * ====================================================================
 * Menu akan muncul di sidebar admin sesuai modul yang dipilih
 */

/**
 * Method: registerMenu()
 * 
 * @param string $module - Modul SLiMS tempat menu akan muncul
 * @param string $label - Label/teks menu yang ditampilkan
 * @param string $path - Path ke file PHP yang akan di-load
 * 
 * Pilihan $module yang tersedia:
 * - 'system'        : Menu muncul di System (bersama Plugins, Modules)
 * - 'membership'    : Menu muncul di Membership
 * - 'bibliography'  : Menu muncul di Bibliography
 * - 'circulation'   : Menu muncul di Circulation
 * - 'reporting'     : Menu muncul di Reporting
 * - 'master_file'   : Menu muncul di Master File
 * - 'stock_take'    : Menu muncul di Stock Take
 * 
 * Contoh dari member_self_registration:
 * Menu "Daftar Online" muncul di modul Membership
 */
$plugin->registerMenu('membership', 'Daftar Online', __DIR__ . '/pages/membership/index.php');

// Bisa register multiple menu di modul berbeda:
// $plugin->registerMenu('system', 'Settings Plugin', __DIR__ . '/pages/settings/index.php');
// $plugin->registerMenu('reporting', 'Report Plugin', __DIR__ . '/pages/report/index.php');

/**
 * ====================================================================
 * REGISTRASI MENU PLUGIN DI OPAC (Area Publik)
 * ====================================================================
 * Menu akan muncul di sidebar OPAC untuk pengunjung/member
 */

/**
 * PENTING: Cek dulu apakah tabel sudah ada
 * Ini mencegah error saat plugin baru diinstall/migration belum jalan
 * 
 * Schema::hasTable() untuk cek keberadaan tabel
 * Return true jika tabel ada, false jika tidak
 */
if (Schema::hasTable('nama_table_anda')) {
    
    /**
     * Ambil data aktif dari database untuk judul menu dinamis
     * Contoh: Menu registrasi dengan nama yang bisa diubah admin
     */
    $activeData = DB::getInstance()->query('SELECT id, name FROM nama_table_anda WHERE status = 1');
    
    // Cek apakah ada data yang aktif
    if ($activeData->rowCount()) {
        // fetchObject() mengambil 1 row sebagai object
        // Akses kolom dengan $data->nama_kolom
        $data = $activeData->fetchObject();
        
        /**
         * Register menu OPAC dengan nama dinamis dari database
         * 
         * @param string 'opac' - Modul khusus untuk area publik
         * @param string $data->name - Judul menu dari database
         * @param string $path - Path ke file halaman OPAC
         * 
         * Contoh hasil: Menu "Pendaftaran Member Online" di sidebar OPAC
         */
        $plugin->registerMenu('opac', $data->name, __DIR__ . DS . 'pages' . DS . 'opac' . DS . 'index.php');
    }
}

// Menu OPAC dengan nama statis:
// $plugin->registerMenu('opac', 'Daftar Member Baru', __DIR__ . '/pages/opac/index.php');

/**
 * ====================================================================
 * REGISTRASI PLUGIN HOOKS (Event System)
 * ====================================================================
 * Hooks memungkinkan plugin merespons event tertentu di SLiMS
 * Mirip dengan WordPress hooks atau Laravel events
 */

/**
 * HOOK: MEMBERSHIP_AFTER_SAVE
 * ============================================================
 * Dijalankan SETELAH member baru berhasil disimpan ke database
 * 
 * Use case:
 * - Kirim email welcome ke member baru
 * - Log activity untuk audit
 * - Sync data ke sistem eksternal
 * - Generate barcode/kartu member otomatis
 * - Buat folder personal member
 * 
 * @param array $data - Array berisi data member yang baru disimpan
 *                      Keys: member_id, member_name, member_email, dst
 */
$plugin->register(Plugins::MEMBERSHIP_AFTER_SAVE, function($data) {
    
    // Contoh 1: Log activity
    error_log("Member baru: " . $data['member_name'] . " (" . $data['member_id'] . ")");
    
    // Contoh 2: Simpan ke tabel custom plugin
    $db = DB::getInstance();
    $stmt = $db->prepare("
        INSERT INTO plugin_member_log 
        SET member_id = ?, 
            action = 'registered', 
            created_at = NOW()
    ");
    $stmt->execute([$data['member_id']]);
    
    // Contoh 3: Kirim email welcome (jika mail sudah dikonfigurasi)
    /*
    if (!empty($data['member_email'])) {
        $to = $data['member_email'];
        $subject = 'Selamat Datang di Perpustakaan';
        $message = "Halo " . $data['member_name'] . ",\n\n";
        $message .= "Terima kasih telah mendaftar.\n";
        $message .= "Member ID Anda: " . $data['member_id'];
        
        mail($to, $subject, $message);
    }
    */
});

/**
 * HOOK: MEMBERSHIP_BEFORE_UPDATE
 * ============================================================
 * Dijalankan SEBELUM data member diupdate
 * 
 * Use case:
 * - Validasi custom sebelum update
 * - Backup data lama sebelum diubah
 * - Prevent update berdasarkan kondisi tertentu
 * - Transform data sebelum disimpan
 * 
 * @param array $data - Array berisi data member yang akan diupdate
 * 
 * CATATAN: Bisa throw Exception untuk batalkan update
 */
$plugin->register(Plugins::MEMBERSHIP_BEFORE_UPDATE, function($data) {
    
    // Contoh 1: Validasi custom
    if (empty($data['member_email'])) {
        throw new Exception('Email member tidak boleh kosong!');
    }
    
    // Contoh 2: Cek duplikat email
    $db = DB::getInstance();
    $check = $db->prepare("
        SELECT member_id 
        FROM member 
        WHERE member_email = ? 
          AND member_id != ?
    ");
    $check->execute([$data['member_email'], $data['member_id']]);
    
    if ($check->rowCount() > 0) {
        throw new Exception('Email sudah digunakan member lain!');
    }
    
    // Contoh 3: Backup data lama
    $old = $db->prepare("SELECT * FROM member WHERE member_id = ?");
    $old->execute([$data['member_id']]);
    $oldData = $old->fetch(PDO::FETCH_ASSOC);
    
    // Simpan backup
    $backup = $db->prepare("
        INSERT INTO member_backup 
        SET member_id = ?, 
            data = ?, 
            backup_date = NOW()
    ");
    $backup->execute([
        $data['member_id'], 
        json_encode($oldData)
    ]);
});

/**
 * HOOK: MEMBERSHIP_AFTER_UPDATE
 * ============================================================
 * Dijalankan SETELAH data member berhasil diupdate
 * 
 * Use case:
 * - Log perubahan data
 * - Notifikasi admin/member tentang perubahan
 * - Sync ke sistem lain
 * - Clear cache
 */
$plugin->register(Plugins::MEMBERSHIP_AFTER_UPDATE, function($data) {
    // Log perubahan
    error_log("Member updated: " . $data['member_id']);
});

/**
 * HOOK: MEMBERSHIP_INIT (Override Halaman)
 * ============================================================
 * HATI-HATI: Hook ini akan REPLACE seluruh halaman membership default!
 * 
 * Use case:
 * - Customize total halaman membership
 * - Tambah fitur yang tidak bisa dilakukan dengan hook biasa
 * - Integrasi deep dengan sistem membership
 * 
 * PENTING:
 * - Harus include file custom yang lengkap
 * - Wajib exit() di akhir untuk stop eksekusi halaman default
 * - Jika ada error, halaman membership tidak bisa diakses
 * 
 * Contoh dari member_self_registration:
 * Plugin ini override halaman membership untuk menambah
 * field custom dari form generator
 */
$plugin->register(Plugins::MEMBERSHIP_INIT, function() use($plugin) {
    // Akses variabel global SLiMS yang diperlukan
    global $member_custom_fields, $can_read, $can_write, $sysconf, $dbs;
    
    // Load halaman custom yang menggantikan membership default
    include __DIR__ . '/pages/customs/membership/index.php';
    
    // WAJIB exit untuk stop eksekusi halaman default
    exit;
});

/**
 * ====================================================================
 * CUSTOM HOOKS (Buat Hook Sendiri)
 * ====================================================================
 * Selain menggunakan hook bawaan SLiMS, kita bisa buat hook custom
 * untuk plugin kita sendiri atau untuk digunakan plugin lain
 */

/**
 * Contoh: Hook custom untuk plugin kita
 * Plugin lain bisa mendengarkan hook ini
 */
$plugin->register('nama_plugin_before_process', function($data) {
    // Plugin lain bisa inject logic di sini
});

$plugin->register('nama_plugin_after_process', function($data) {
    // Plugin lain bisa inject logic di sini
});

/**
 * Cara trigger custom hook (di action/save.php misalnya):
 * 
 * // Sebelum proses
 * Plugins::getInstance()->execute('nama_plugin_before_process', [
 *     'data' => $formData,
 *     'user_id' => $_SESSION['uid']
 * ]);
 * 
 * // Proses data...
 * 
 * // Setelah proses
 * Plugins::getInstance()->execute('nama_plugin_after_process', [
 *     'id' => $insertedId,
 *     'data' => $formData
 * ]);
 */

/**
 * ====================================================================
 * DAFTAR LENGKAP HOOKS BAWAAN SLiMS
 * ====================================================================
 * 
 * MEMBERSHIP HOOKS:
 * -----------------
 * Plugins::MEMBERSHIP_INIT             → Saat modul membership dimuat
 * Plugins::MEMBERSHIP_BEFORE_SAVE      → Sebelum member baru disimpan
 * Plugins::MEMBERSHIP_AFTER_SAVE       → Setelah member baru disimpan
 * Plugins::MEMBERSHIP_BEFORE_UPDATE    → Sebelum member diupdate
 * Plugins::MEMBERSHIP_AFTER_UPDATE     → Setelah member diupdate
 * 
 * BIBLIOGRAPHY HOOKS:
 * -------------------
 * Plugins::BIBLIOGRAPHY_INIT           → Saat modul bibliografi dimuat
 * Plugins::BIBLIOGRAPHY_BEFORE_SAVE    → Sebelum buku baru disimpan
 * Plugins::BIBLIOGRAPHY_AFTER_SAVE     → Setelah buku baru disimpan
 * Plugins::BIBLIOGRAPHY_BEFORE_UPDATE  → Sebelum data buku diupdate
 * Plugins::BIBLIOGRAPHY_AFTER_UPDATE   → Setelah data buku diupdate
 * 
 * CIRCULATION HOOKS:
 * ------------------
 * Plugins::CIRCULATION_BEFORE_CHECKOUT → Sebelum peminjaman diproses
 * Plugins::CIRCULATION_AFTER_CHECKOUT  → Setelah peminjaman sukses
 * Plugins::CIRCULATION_BEFORE_CHECKIN  → Sebelum pengembalian diproses
 * Plugins::CIRCULATION_AFTER_CHECKIN   → Setelah pengembalian sukses
 * 
 * CUSTOM HOOKS:
 * -------------
 * Hook dengan nama string bebas untuk kebutuhan plugin custom
 * Contoh: 'plugin_name_custom_event'
 */
```

***

## Helper Functions

### 2. File `helper.php` - Fungsi-Fungsi Utility

```php
<?php
/**
 * ====================================================================
 * FILE HELPER - KUMPULAN FUNGSI PEMBANTU
 * ====================================================================
 * File ini berisi fungsi-fungsi utility yang sering digunakan
 * di seluruh plugin untuk menghindari code duplication
 * 
 * BEST PRACTICES:
 * - Setiap fungsi dibungkus if(!function_exists()) 
 *   untuk hindari konflik dengan fungsi lain
 * - Gunakan type hinting untuk parameter dan return value (PHP 7+)
 * - Beri komentar lengkap untuk setiap fungsi
 * - Gunakan nama fungsi yang deskriptif
 */

/**
 * Import namespace yang diperlukan
 */
use SLiMS\Url;      // Untuk manipulasi URL
use SLiMS\DB;       // Untuk operasi database
use SLiMS\Captcha\Factory as Captcha; // Untuk captcha
use SLiMS\Filesystems\Storage;  // Untuk operasi file/upload

/**
 * ====================================================================
 * FUNGSI: getActiveSchemaData()
 * ====================================================================
 * Mengambil satu data schema yang aktif dari database
 * Pattern ini umum untuk plugin yang punya konsep aktif/nonaktif
 * 
 * Contoh penggunaan dari member_self_registration:
 * Plugin ini bisa punya banyak schema form pendaftaran,
 * tapi hanya 1 yang aktif di OPAC pada satu waktu
 * 
 * @return object|null - Object data jika ada, null jika tidak ada
 * 
 * CONTOH PENGGUNAAN:
 * 
 * $schema = getActiveSchemaData();
 * if ($schema) {
 *     echo $schema->name;        // Akses property
 *     echo $schema->structure;
 * } else {
 *     echo "Tidak ada schema aktif";
 * }
 */
if (!function_exists('getActiveSchemaData')) {
    function getActiveSchemaData()
    {
        // Query data dengan status = 1 (aktif)
        // Menggunakan DB::getInstance() untuk akses database
        $state = \SLiMS\DB::getInstance()->query('
            SELECT * 
            FROM self_registration_schemas 
            WHERE status = 1
        ');
        
        // Cek apakah ada row yang ditemukan
        // rowCount() return jumlah row hasil query
        // fetchObject() return row sebagai object
        // Jika tidak ada data, return null
        return $state->rowCount() ? $state->fetchObject() : null;
    }
}

/**
 * VARIASI FUNGSI GET DATA:
 * 
 * Get all data:
 * function getAllData($table) {
 *     $query = DB::getInstance()->query("SELECT * FROM {$table}");
 *     return $query->fetchAll(PDO::FETCH_OBJ);
 * }
 * 
 * Get by ID:
 * function getDataById($table, $id) {
 *     $stmt = DB::getInstance()->prepare("SELECT * FROM {$table} WHERE id = ?");
 *     $stmt->execute([$id]);
 *     return $stmt->fetch(PDO::FETCH_OBJ);
 * }
 */

/**
 * ====================================================================
 * FUNGSI: action()
 * ====================================================================
 * Memuat file action dari folder action/ secara otomatis
 * Pattern ini memisahkan presentation (view) dari business logic (action)
 * Mirip dengan konsep MVC (Model-View-Controller)
 * 
 * STRUKTUR FOLDER YANG EXPECTED:
 * pages/admin/
 * ├── index.php          ← File ini memanggil action()
 * └── action/
 *     ├── save.php       ← action('save') load file ini
 *     ├── update.php     ← action('update') load file ini
 *     └── delete.php     ← action('delete') load file ini
 * 
 * @param string $actionName - Nama file action tanpa ekstensi .php
 *                             Contoh: 'save', 'update', 'delete', 'create_schema'
 * 
 * @param array $attribute - Data tambahan yang dikirim ke file action
 *                          Array ini akan di-extract jadi variabel
 *                          Contoh: ['user' => $user] → $user tersedia di action
 * 
 * @throws Exception - Jika file action tidak ditemukan (404)
 * 
 * CONTOH PENGGUNAAN DI index.php:
 * 
 * if (isset($_POST['action'])) {
 *     // Load action berdasarkan POST
 *     action($_POST['action'], [
 *         'db' => $database,
 *         'user' => $userData
 *     ]);
 *     exit;
 * }
 * 
 * CONTOH DI FILE action/save.php:
 * // Variabel $db dan $user sudah tersedia di sini
 * // karena di-extract dari $attribute
 */
if (!function_exists('action')) {
    function action(string $actionName, array $attribute = [])
    {
        // Akses variabel global SLiMS (jika diperlukan di action)
        global $sysconf;
        
        // Extract array menjadi variabel
        // Contoh: ['db' => $x, 'user' => $y]
        // Menjadi: $db = $x; $user = $y;
        extract($attribute);
        
        // debug_backtrace() untuk mendapatkan info file pemanggil
        // limit: 1 artinya hanya ambil 1 level trace (untuk performa)
        $trace = debug_backtrace(limit: 1);
        
        // pathinfo() untuk parse path file
        // Mendapatkan dirname, basename, extension, dll
        $info = pathinfo(array_pop($trace)['file']);
        
        // Bangun path ke file action
        // DS = DIRECTORY_SEPARATOR (/ atau \)
        // basename() untuk security: prevent directory traversal
        $path = $info['dirname'] . DS . 'action' . DS . basename($actionName) . '.php';
        
        // Cek apakah file action exist
        if (file_exists($path)) {
            // Include file action
            // Variable extract di atas sudah tersedia di file ini
            include $path;
        } else {
            // Throw exception dengan error code 404
            // Exception ini bisa di-catch di caller
            throw new Exception('Action ' . $actionName . ' is not found!', 404);
        }
    }
}

/**
 * CONTOH ACTION ROUTING ADVANCED:
 * 
 * // Di index.php
 * if (isset($_POST['action'])) {
 *     try {
 *         action($_POST['action'], [
 *             'can_write' => $can_write,
 *             'user_id' => $_SESSION['uid']
 *         ]);
 *     } catch (Exception $e) {
 *         if ($e->getCode() == 404) {
 *             toastr('Action tidak ditemukan')->error();
 *         } else {
 *             toastr($e->getMessage())->error();
 *         }
 *     }
 *     exit;
 * }
 */

/**
 * ====================================================================
 * FUNGSI: pluginUrl()
 * ====================================================================
 * Generate URL untuk plugin dengan query string otomatis
 * Fungsi ini SANGAT PENTING untuk navigasi dalam plugin
 * 
 * URL plugin SLiMS selalu punya format:
 * index.php?mod=module_name&id=plugin_name&section=xxx&param=yyy
 * 
 * mod: Modul SLiMS (membership, bibliography, dll)
 * id: Nama plugin
 * section: Halaman dalam plugin
 * param lain: Custom parameter
 * 
 * @param array $data - Array key-value untuk query string tambahan
 *                      Key yang sama akan override query yang ada
 *                      Contoh: ['section' => 'edit', 'item_id' => 5]
 * 
 * @param bool $reset - Jika true, hapus semua query kecuali mod & id
 *                      Berguna untuk kembali ke halaman utama plugin
 * 
 * @return string - URL lengkap dengan query string
 * 
 * CONTOH PENGGUNAAN:
 * 
 * // URL saat ini: index.php?mod=membership&id=plugin&section=list&page=2
 * 
 * pluginUrl(['section' => 'add'])
 * // Hasil: index.php?mod=membership&id=plugin&section=add&page=2
 * // Query 'section' di-override, 'page' tetap ada
 * 
 * pluginUrl(['section' => 'edit', 'item_id' => 123])
 * // Hasil: index.php?mod=membership&id=plugin&section=edit&item_id=123&page=2
 * 
 * pluginUrl(reset: true)
 * // Hasil: index.php?mod=membership&id=plugin
 * // Semua query lain dihapus, kembali ke halaman utama
 * 
 * DI VIEW/TEMPLATE:
 * <a href="<?= pluginUrl(['section' => 'edit', 'id' => $item->id]) ?>">Edit</a>
 * <a href="<?= pluginUrl(reset: true) ?>">Kembali ke List</a>
 */
if (!function_exists('pluginUrl')) {
    function pluginUrl(array $data = [], bool $reset = false): string
    {
        // Jika reset = true, return URL base plugin saja
        // Hanya preserve mod dan id dari query string
        if ($reset) {
            return Url::getSelf(fn($self) => 
                $self . '?mod=' . $_GET['mod'] . '&id=' . $_GET['id']
            );
        }
        
        // Gabungkan query string existing dengan data baru
        return Url::getSelf(function($self) use($data) {
            // array_merge: Gabungkan array, key yang sama di-override
            // $_GET: Query string yang sudah ada
            // $data: Query string baru
            // http_build_query: Ubah array jadi string query
            return $self . '?' . http_build_query(array_merge($_GET, $data));
        });
    }
}

/**
 * ====================================================================
 * FUNGSI: textColor()
 * ====================================================================
 * Menghitung warna teks terbaik (hitam/putih) untuk background tertentu
 * Berdasarkan algoritma persepsi kecerahan mata manusia
 * 
 * Mata manusia lebih sensitif terhadap warna hijau, lalu merah, lalu biru
 * Formula: brightness = (R * 299 + G * 587 + B * 114) / 1000
 * 
 * @param string $hexCode - Kode warna HEX tanpa # (6 karakter)
 *                          Contoh: 'FF0000' (merah), '00FF00' (hijau), '0000FF' (biru)
 * 
 * @return string - '000000' untuk teks hitam, 'ffffff' untuk teks putih
 * 
 * CONTOH PENGGUNAAN:
 * 
 * $bgColor = 'FF0000';  // Background merah
 * $textColor = textColor($bgColor);  // Return 'ffffff' (putih)
 * echo '<div style="background:#'.$bgColor.'; color:#'.$textColor.'">Teks Readable</div>';
 * 
 * $bgColor2 = 'FFFF00';  // Background kuning
 * $textColor2 = textColor($bgColor2);  // Return '000000' (hitam)
 * 
 * USE CASE REAL:
 * Plugin punya fitur label/tag dengan warna custom
 * Perlu warna teks yang selalu readable di setiap background
 */
if (!function_exists('textColor')) {
    function textColor($hexCode) {
        // Pisahkan hex code jadi 3 komponen RGB
        // Setiap warna 2 karakter hex (00-FF)
        $redHex = substr($hexCode, 0, 2);      // 2 karakter pertama
        $greenHex = substr($hexCode, 2, 2);    // 2 karakter tengah
        $blueHex = substr($hexCode, 4, 2);     // 2 karakter terakhir
    
        // Convert hex ke decimal, lalu normalize ke range 0-1
        // hexdec() convert hex string ke integer
        // Dibagi 255 untuk normalize (range: 0-1)
        $r = (hexdec($redHex)) / 255;
        $g = (hexdec($greenHex)) / 255;
        $b = (hexdec($blueHex)) / 255;
    
        // Hitung perceived brightness dengan formula W3C
        // Formula berdasarkan sensitivitas mata manusia:
        // - 29.9% Red
        // - 58.7% Green (mata paling sensitif ke hijau)
        // - 11.4% Blue
        $brightness = (($r * 299) + ($g * 587) + ($b * 114)) / 1000;
        
        // Threshold: 0.6 (60%)
        // Jika brightness > 60%: background terang → teks hitam
        // Jika brightness ≤ 60%: background gelap → teks putih
        if ($brightness > .6) {
            return '000000';  // Teks hitam
        } else {
            return 'ffffff';  // Teks putih
        }
    }
}

/**
 * CONTOH PENGGUNAAN DENGAN LOOP:
 * 
 * $categories = [
 *     ['name' => 'Urgent', 'color' => 'FF0000'],
 *     ['name' => 'Normal', 'color' => '00FF00'],
 *     ['name' => 'Low', 'color' => '0000FF']
 * ];
 * 
 * foreach ($categories as $cat) {
 *     $textColor = textColor($cat['color']);
 *     echo '<span style="background:#'.$cat['color'].'; color:#'.$textColor.'; padding:5px">';
 *     echo $cat['name'];
 *     echo '</span>';
 * }
 */

/**
 * ====================================================================
 * FUNGSI: formGenerator()
 * ====================================================================
 * Generate form HTML secara dinamis berdasarkan schema JSON
 * Ini adalah fungsi PENTING dari plugin member_self_registration
 * 
 * Fungsi ini sangat kompleks karena:
 * - Generate berbagai tipe input (text, select, radio, checkbox, file, dll)
 * - Handle validation (required fields)
 * - Support custom fields advance
 * - Support captcha
 * - Support file upload
 * - Support agreement checkbox
 * - Generate JavaScript validation
 * 
 * @param object $data - Object schema dari database yang berisi:
 *                       - structure: JSON array field yang akan ditampilkan
 *                       - option: JSON opsi form (captcha, agreement, image)
 *                       - info: JSON info form (title, description, position)
 * 
 * @param array $record - Data existing untuk edit mode (default: empty array)
 *                        Jika ada, form akan terisi dengan data ini
 * 
 * @param string $actionUrl - URL tujuan submit form
 *                            Jika kosong, form hanya preview (tidak bisa submit)
 * 
 * @param object|null $opac - Object OPAC untuk set page title (hanya di OPAC)
 * 
 * @return string - HTML form lengkap dengan JavaScript
 * 
 * STRUKTUR $data->structure (JSON):
 * [
 *     {
 *         "name": "Nama Lengkap",
 *         "field": "member_name",
 *         "is_required": true,
 *         "advfield": "",
 *         "advfieldtype": ""
 *     },
 *     {
 *         "name": "Jenis Kelamin",
 *         "field": "gender",
 *         "is_required": true
 *     },
 *     {
 *         "name": "Hobi",
 *         "field": "advance",
 *         "is_required": false,
 *         "advfield": "hobi,Membaca|Menulis|Olahraga",
 *         "advfieldtype": "text_multiple"
 *     }
 * ]
 * 
 * STRUKTUR $data->option (JSON):
 * {
 *     "captcha": true,
 *     "image": true,
 *     "with_agreement": true
 * }
 * 
 * STRUKTUR $data->info (JSON):
 * {
 *     "title": "Form Pendaftaran Member",
 *     "desc": "<p>Silakan isi form berikut...</p>",
 *     "position": "top"
 * }
 * 
 * CONTOH PENGGUNAAN:
 * 
 * // Get schema dari database
 * $schema = getActiveSchemaData();
 * 
 * // Generate form kosong (untuk registrasi baru di OPAC)
 * echo formGenerator($schema, [], 'action/save.php', $opac);
 * 
 * // Generate form terisi (untuk edit di admin)
 * $member = ['member_name' => 'John', 'member_email' => 'john@mail.com'];
 * echo formGenerator($schema, $member, 'action/update.php');
 * 
 * // Generate form preview (tanpa action)
 * echo formGenerator($schema);
 */
if (!function_exists('formGenerator')) {
    function formGenerator($data, $record = [], $actionUrl = '', $opac = null)
    {
        // Parse JSON dari database
        $structure = json_decode($data->structure, true);  // Array field form
        $option = json_decode($data->option ?? '');        // Object opsi
        $info = json_decode($data->info);                  // Object info
        
        // Start output buffering
        // Semua echo akan disimpan di buffer, tidak langsung output
        ob_start();
        
        // Variable untuk kumpulkan JavaScript validation
        $js = '';
        
        // Variable untuk attribute form (jika ada upload)
        $withUpload = '';
        if (($option?->image ?? false)) {
            $withUpload = 'enctype="multipart/form-data"';
        }
        
        /**
         * ============================================================
         * BUKA TAG FORM
         * ============================================================
         */
        echo '<form id="self_member" method="POST" action="' . $actionUrl . '" ' . $withUpload . '>';
        
        /**
         * ============================================================
         * TAMPILKAN ERROR (jika ada)
         * ============================================================
         * flash() adalah session flash message di SLiMS
         * includes() cek apakah ada flash dengan key tertentu
         */
        if ($key = flash()->includes('self_regis_error')) {
            flash()->danger($key);  // Tampilkan error message
        }
        
        /**
         * ============================================================
         * JUDUL FORM
         * ============================================================
         * Jika actionUrl kosong atau berisi 'admin', ini mode preview/admin
         * Jika actionUrl OPAC, set page title dan tampilkan deskripsi
         */
        if ($actionUrl === '' || stripos($actionUrl, 'admin') !== false) {
            // Mode preview atau admin
            if ($actionUrl === '') {
                echo '<h3>Pratinjau</h3>';
                echo '<h5>Skema ' . $data->name . '</h5>';
            } else {
                echo '<h3>Pratinjau Data</h3>';
                echo '<h5>Calon anggota ' . $record['member_name'] . '</h5>';
            }
        } else {
            // Mode OPAC (publik)
            if ($opac !== null) {
                $opac->page_title = $info->title;
            }
            
            // Deskripsi form dengan HTML terbatas (untuk security)
            // strip_tags() dengan whitelist tag yang diizinkan
            $descInfo = '<div class="alert alert-info p-3">' . 
                       strip_tags($info->desc, '<p><a><i><em><h1><h2><h3><ul><ol><li>') . 
                       '</div>';
        }
        
        /**
         * ============================================================
         * TAMPILKAN DESKRIPSI DI ATAS (jika position = top)
         * ============================================================
         */
        if ($info->position == 'top' && isset($descInfo)) {
            echo $descInfo;
        }
        
        /**
         * ============================================================
         * LOOP GENERATE FIELD FORM
         * ============================================================
         * Loop setiap field di structure dan generate HTML input yang sesuai
         */
        foreach ($structure as $key => $column) {
            
            /**
             * Convert key untuk field name
             * Jika mode admin dan ada advfield, gunakan advfield[0]
             */
            if (strpos($actionUrl, 'admin') == true) {
                if (empty($column['advfield'])) {
                    $key = $column['field'];
                } else {
                    $advfield = explode(',', $column['advfield']);
                    $key = $advfield[0];
                }
            }
            
            /**
             * Tentukan apakah field required
             */
            $is_required = $column['is_required'] === true ? ' required' : '';
            
            /**
             * Label dengan tanda required (*)
             */
            $required_mark = $is_required ? '<em class="text-danger">*</em>' : '';
            echo <<<HTML
            <div class="my-3">
                <label class="form-label"><strong>{$column['name']} {$required_mark}</strong></label>
            HTML;
            
            /**
             * Ambil default value dari $record (untuk edit mode)
             * Null coalescing operator (??) untuk handle jika tidak ada
             */
            $defaultValue = $record[$column['field']] ?? $record[$column['advfield']] ?? '';
            
            /**
             * Kondisi khusus untuk field tipe tertentu
             */
            if (in_array($column['advfieldtype'], ['enum', 'enum_radio', 'text_multiple'])) {
                list($name, $detail) = explode(',', $column['advfield']);
                $defaultValue = $record[$name] ?? '';
            }
            
            /**
             * ========================================================
             * GENERATE INPUT BERDASARKAN TIPE FIELD
             * ========================================================
             * Switch case untuk handle berbagai jenis field
             */
            switch ($column['field']) {
                
                /**
                 * FIELD: PASSWORD
                 * ------------------------------------------------
                 * Special handling untuk password:
                 * - Input password
                 * - Input konfirmasi password
                 * - Jika edit mode, password optional (tidak required)
                 */
                case 'mpasswd':
                    // Jika ada actionUrl (bukan preview), password optional
                    if ($actionUrl !== '') {
                        $is_required = '';
                    }
                    
                    echo <<<HTML
                    <br>
                    <small>Tulis password Anda</small>
                    <input type="password" 
                           placeholder="Masukan {$column['name']} anda" 
                           name="form[{$key}]" 
                           id="pass1" 
                           class="form-control" 
                           {$is_required}>
                    <small>Konfirmasi ulang password</small>
                    <input type="password" 
                           name="confirm_password" 
                           placeholder="Masukan ulang {$column['name']} anda" 
                           id="pass2" 
                           class="form-control" 
                           {$is_required}>
                    HTML;
                    break;
                
                /**
                 * FIELD: GENDER (Jenis Kelamin)
                 * ------------------------------------------------
                 * Select dropdown dengan 2 opsi: Laki-laki / Perempuan
                 */
                case 'gender':
                    // Set selected berdasarkan $defaultValue
                    $man = $defaultValue != 1 ? '' : 'selected';
                    $woman = $defaultValue != 0 ? '' : 'selected';
                    
                    echo <<<HTML
                    <select name="form[{$key}]" class="form-control" {$is_required}>
                        <option>Pilih</option>
                        <option value="1" {$man}>Laki-Laki</option>
                        <option value="0" {$woman}>Perempuan</option>
                    </select>
                    HTML;
                    break;
                
                /**
                 * FIELD: TEXTAREA (Alamat)
                 * ------------------------------------------------
                 */
                case 'member_address':
                    echo <<<HTML
                    <textarea name="form[{$key}]" 
                              placeholder="Masukan {$column['name']} anda" 
                              class="form-control" 
                              {$is_required}>{$defaultValue}</textarea>
                    HTML;
                    break;
                
                /**
                 * FIELD: MEMBER TYPE (Tipe Keanggotaan)
                 * ------------------------------------------------
                 * Select dropdown yang diisi dari database
                 */
                case 'member_type_id':
                    // Query member type dari database
                    $memberType = \SLiMS\DB::getInstance()->query('
                        SELECT member_type_id, member_type_name 
                        FROM mst_member_type
                    ');
                    
                    echo '<select class="form-control" name="form[' . $key . ']" ' . $is_required . '>';
                    echo '<option value="0">Pilih</option>';
                    
                    // Loop hasil query dan buat option
                    while ($result = $memberType->fetch(PDO::FETCH_NUM)) {
                        $selected = ($defaultValue != $result[0]) ? '' : 'selected';
                        echo '<option value="' . $result[0] . '" ' . $selected . '>' . $result [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/9060597/5005ddc1-7400-4719-9d92-528061dddf0f/drajathasan-member_self_registration.md) . '</option>';
                    }
                    
                    echo '</select>';
                    break;
                
                /**
                 * FIELD: ADVANCE (Custom Field)
                 * ------------------------------------------------
                 * Field yang tidak ada di tabel member default
                 * Disimpan di tabel member_custom
                 * Tipe bisa: varchar, int, text, enum, enum_radio, text_multiple
                 */
                case 'advance':
                    switch ($column['advfieldtype']) {
                        
                        /**
                         * ADVANCE: VARCHAR (Short Text)
                         * INT (Number)
                         */
                        case 'varchar':
                        case 'int':
                            $types = ['varchar' => 'text', 'int' => 'number'];
                            $type = $types[$column['advfieldtype']];
                            
                            echo <<<HTML
                            <input type="{$type}" 
                                   name="form[{$key}]" 
                                   value="{$defaultValue}" 
                                   placeholder="Masukan {$column['name']} anda" 
                                   class="form-control" 
                                   {$is_required}/>
                            HTML;
                            break;
                        
                        /**
                         * ADVANCE: TEXT (Long Text / Textarea)
                         */
                        case 'text':
                            echo <<<HTML
                            <textarea name="form[{$key}]" 
                                      placeholder="Masukan {$column['name']} anda" 
                                      class="form-control" 
                                      {$is_required}>{$defaultValue}</textarea>
                            HTML;
                            break;
                        
                        /**
                         * ADVANCE: ENUM (Select Dropdown)
                         * ----------------------------------------
                         * Format advfield: "field_name,Option1|Option2|Option3"
                         */
                        case 'enum':
                            list($field, $list) = explode(',', $column['advfield']);
                            
                            echo '<select name="form[' . $key . ']" class="form-control">';
                            echo '<option value="">Pilih</option>';
                            
                            $selected = '';
                            foreach (explode('|', $list) as $item) {
                                if ($defaultValue == $item) $selected = 'selected';
                                echo '<option value="'.$item.'" '.$selected.'>' . $item . '</option>';
                                $selected = '';
                            }
                            
                            echo '</select>';
                            break;
                        
                        /**
                         * ADVANCE: ENUM_RADIO (Radio Button)
                         * ----------------------------------------
                         * Format advfield: "field_name,Option1|Option2|Option3"
                         */
                        case 'enum_radio':
                            $field = explode(',', $column['advfield']);
                            $uniqueId = md5($field[0]);  // Unique ID untuk JavaScript
                            $checked = '';
                            
                            // Jika required, tambahkan validasi JavaScript
                            if ($is_required) {
                                $js .= <<<HTML
                                if ($('.radio{$uniqueId}:checked').length < 1) {
                                    evt.preventDefault();
                                    alert('Pilih salah satu dari isian {$column['name']}');
                                    return;
                                }
                                HTML;
                            }
                            
                            echo '<div class="d-flex flex-column">';
                            foreach (explode('|', trim($field [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/9060597/5005ddc1-7400-4719-9d92-528061dddf0f/drajathasan-member_self_registration.md))) as $optionKey => $value) {
                                if (empty($value)) continue;
                                if ($defaultValue == $value) $checked = 'checked';
                                
                                echo '<div>
                                    <input class="radio'.$uniqueId.'" 
                                           id="radio' . $uniqueId . '-' . $optionKey . '" 
                                           type="radio" 
                                           name="form[' . $key . ']" 
                                           value="' . $value . '" 
                                           ' . $checked . '/>
                                    <label for="radio' . $uniqueId . '-' . $optionKey . '" 
                                           style="cursor: pointer">' . $value . '</label>
                                </div>';
                                
                                $checked = '';
                            }
                            echo '</div>';
                            break;
                        
                        /**
                         * ADVANCE: TEXT_MULTIPLE (Checkbox Multiple)
                         * ----------------------------------------
                         * Format advfield: "field_name,Option1|Option2|Option3"
                         * Data disimpan sebagai JSON array
                         */
                        case 'text_multiple':
                            $field = explode(',', $column['advfield']);
                            $uniqueId = md5($field[0]);
                            $defaultValue = json_decode(trim($defaultValue), true);
                            $checked = '';
                            
                            // Jika required, tambahkan validasi JavaScript
                            if ($is_required) {
                                $js .= <<<HTML
                                if ($('.checkbox{$uniqueId}:checked').length < 1) {
                                    evt.preventDefault();
                                    alert('Pilih salah satu dari isian {$column['name']}');
                                    return;
                                }
                                HTML;
                            }
                            
                            echo '<div class="d-flex flex-column">';
                            foreach (explode('|', trim($field [ppl-ai-file-upload.s3.amazonaws](https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/9060597/5005ddc1-7400-4719-9d92-528061dddf0f/drajathasan-member_self_registration.md))) as $optionKey => $value) {
                                if (empty($value)) continue;
                                if (in_array($value, $defaultValue ?? [])) $checked = 'checked';
                                
                                echo '<div class="mx-3">
                                    <input class="checkbox'.$uniqueId.'" 
                                           id="checkbox' . $uniqueId . '-' . $optionKey . '" 
                                           type="checkbox" 
                                           name="form[' . $key . '][]" 
                                           value="' . $value . '" 
                                           ' . $checked . '/>
                                    <label for="checkbox' . $uniqueId . '-' . $optionKey . '" 
                                           style="cursor: pointer">' . $value . '</label>
                                </div>';
                                
                                $checked = '';
                            }
                            echo '</div>';
                            break;
                    }
                    break;
                
                /**
                 * FIELD: MEMBER_IMAGE (Upload Foto)
                 * ------------------------------------------------
                 * Hanya muncul jika opsi image diaktifkan
                 */
                case 'member_image':
                    if (($option?->image ?? null) === null) {
                        echo '<div class="alert alert-info font-weight-bold">Anda belum mengatur ruas ini pada "Pengaturan Form"</div>';
                    } else {
                        if (!isset($record['member_image'])) {
                            // Mode upload baru
                            echo <<<HTML
                            <input type="file" 
                                   name="member_image" 
                                   class="form-control d-block" 
                                   {$is_required}/>
                            <small>Maksimal ukuran file foto adalah 2MB</small>
                            HTML;
                        } else {
                            // Mode edit: tampilkan foto existing
                            $image = Storage::images()->isExists('persons/' . $record['member_image']) 
                                   ? $record['member_image'] 
                                   : 'avatar.jpg';
                            
                            echo '<img class="d-block" src="' . SWB . 'lib/minigalnano/createthumb.php?filename=images/persons/' . $image . '&width=120"/>';
                        }
                    }
                    break;
                
                /**
                 * FIELD: DEFAULT (Text, Date, Email)
                 * ------------------------------------------------
                 * Field standard lainnya
                 */
                default:
                    $types = [
                        'birth_date' => 'date', 
                        'member_email' => 'email'
                    ];
                    $type = isset($types[$column['field']]) ? $types[$column['field']] : 'text';
                    
                    echo <<<HTML
                    <input type="{$type}" 
                           name="form[{$key}]" 
                           value="{$defaultValue}" 
                           placeholder="Masukan {$column['name']} anda" 
                           class="form-control" 
                           {$is_required}/>
                    HTML;
                    break;
            }
            
            // Tutup div field
            echo '</div>';
        }
        
        /**
         * ============================================================
         * TAMPILKAN DESKRIPSI DI BAWAH (jika position = bottom)
         * ============================================================
         */
        if ($info->position == 'bottom' && isset($descInfo)) {
            echo $descInfo;
        }
        
        /**
         * ============================================================
         * CHECKBOX AGREEMENT (jika aktif)
         * ============================================================
         */
        if (($option?->with_agreement ?? false) && strpos($actionUrl, 'admin') === false) {
            echo <<<HTML
            <div>
                <input type="checkbox" id="iAgree"/>
                <label for="iAgree" style="cursor: pointer">Saya menyetujui prasyarat diatas</label>
            </div>
            HTML;
        }
        
        /**
         * ============================================================
         * FORM ACTION (Submit Button)
         * ============================================================
         */
        if ($actionUrl !== '') {
            // Initialize captcha
            $captcha = Captcha::section('memberarea');
            
            // Jika public area (OPAC)
            if (strpos($actionUrl, 'admin') === false) {
                
                // Tampilkan captcha (jika aktif)
                if (($option?->captcha ?? false) && $captcha->isSectionActive() && config('captcha', false)) {
                    echo '<div class="captchaMember my-2">';
                    echo $captcha->getCaptcha();
                    echo '</div>';
                }
                
                // CSRF Token untuk security
                echo \Volnix\CSRF\CSRF::getHiddenInputString();
                
                // Disable button jika agreement belum dicentang
                $disableBeforeAgree = '';
                if ($option?->with_agreement ?? false) {
                    $disableBeforeAgree = 'disabled';
                }
                
                // Button submit dan reset
                echo '<div class="form-group">
                    <input type="hidden" name="action" value="save"/>
                    <button class="btn btn-primary" 
                            type="submit" 
                            name="save" 
                            '.$disableBeforeAgree.' 
                            ' . (empty($disableBeforeAgree) ? '' : 'title="Klik \'Saya menyetujui prasyarat diatas\'"') . '>
                        Daftar
                    </button>
                    <button class="btn btn-outline-secondary" type="reset">Batal</button>
                </div>';
            } else {
                // Admin area: button approve dan delete
                echo '<div class="form-group">
                    <input type="hidden" name="action" value="acc"/>
                    <button class="btn btn-success" type="submit" name="acc">Setujui</button>
                    <a class="btn btn-danger" href="' . pluginUrl(['section' => 'view_detail', 'member_id' => $_GET['member_id'] ?? 0, 'headless' => 'yes', 'action' => 'delete_reg']) . '">Hapus</a>
                </div>';
            }
            
            // Keterangan required
            if (strpos($actionUrl, 'admin') === false) {
                echo '<strong><em class="text-danger">*</em> ) wajib diisi</strong>';
            }
        }
        
        // Tutup form tag
        echo '</form>';
        
        /**
         * ============================================================
         * JAVASCRIPT VALIDATION & INTERACTIVITY
         * ============================================================
         */
        if (strpos($actionUrl, 'admin') === false) {
            // JavaScript untuk agreement checkbox
            $agreeJs = '';
            if ($option?->with_agreement ?? false) {
                $agreeJs = <<<HTML
                $('#iAgree').click(function() {
                    if ($('#iAgree:checked').length < 1) { 
                        $('button[name="save"]').prop('disabled', true);
                        $('button[name="save"]').prop('title', 'Klik \'Saya menyetujui prasyarat diatas\'');
                    } else {
                        $('button[name="save"]').prop('title', 'Klik untuk menyimpan data');
                        $('button[name="save"]').prop('disabled', false);
                    }
                });
                HTML;
            }
            
            // Output JavaScript
            echo <<<HTML
            <script>
                $(document).ready(function() {
                    {$agreeJs}
                    
                    // Form submit validation
                    $('#self_member').submit(function(evt) {
                        {$js}
                    });
                });
            </script>
            HTML;
        }
        
        // Return buffered content sebagai string
        return ob_get_clean();
    }
}

/**
 * CATATAN PENGGUNAAN ob_start() dan ob_get_clean():
 * 
 * ob_start()    : Mulai output buffering (simpan output di memory)
 * echo "text"   : Text tidak langsung ke browser, disimpan di buffer
 * ob_get_clean(): Ambil isi buffer sebagai string dan kosongkan buffer
 * 
 * Ini berguna untuk:
 * - Generate HTML sebagai string (bukan langsung output)
 * - Dapat di-assign ke variabel
 * - Dapat di-manipulasi sebelum di-output
 * - Dapat di-return dari fungsi
 */
```
