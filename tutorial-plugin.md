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
- [Testing Plugin](#testing-plugin)
- [Deployment Checklist](#deployment-checklist)

---

## Pengenalan Struktur Plugin

### Struktur Folder Plugin (Best Practice)

```
nama_plugin/
├── .gitignore                          # Git ignore file
├── README.md                           # Dokumentasi plugin untuk pengguna
├── CHANGELOG.md                        # History perubahan versi
├── LICENSE                             # File lisensi
├── composer.json                       # Dependency management (opsional)
├── helper.php                          # Fungsi-fungsi pembantu/utility
├── nama_plugin.plugin.php             # File utama plugin (WAJIB)
├── migration/                          # Folder untuk migrasi database
│   ├── 1_CreateSchema.php             # Migration pertama: buat tabel
│   ├── 2_AddColumnEmail.php           # Migration kedua: tambah kolom
│   └── 3_CreateIndexes.php            # Migration ketiga: buat index
├── pages/                              # Folder untuk halaman-halaman
│   ├── customs/                        # Override halaman SLiMS (hati-hati!)
│   │   └── membership/
│   │       └── index.php              # Override halaman membership
│   ├── admin/                          # Halaman admin (backend)
│   │   ├── index.php                  # Router utama admin
│   │   ├── list.inc.php               # Halaman list data
│   │   ├── add.inc.php                # Form tambah data
│   │   ├── edit.inc.php               # Form edit data
│   │   ├── detail.inc.php             # Detail data
│   │   └── action/                    # Folder untuk proses form
│   │       ├── save.php               # Proses simpan data baru
│   │       ├── update.php             # Proses update data
│   │       ├── delete.php             # Proses hapus data
│   │       └── export.php             # Proses export data
│   └── opac/                           # Halaman publik (frontend)
│       ├── index.php                  # Halaman utama OPAC
│       └── action/
│           └── save.php               # Proses data dari publik
├── static/                             # Asset statis (opsional)
│   ├── css/
│   │   └── style.css
│   ├── js/
│   │   └── script.js
│   └── images/
│       └── icon.png
└── tests/                              # Unit tests (opsional tapi recommended)
    └── PluginTest.php
```

**Catatan Penting:**
- File `nama_plugin.plugin.php` adalah **WAJIB** dan harus sama dengan nama folder
- Nama folder dan file plugin harus lowercase dengan underscore (snake_case)
- Folder `migration/` akan dijalankan otomatis saat plugin diaktifkan
- Folder `pages/` berisi semua halaman plugin
- Folder `customs/` untuk override halaman SLiMS (gunakan dengan hati-hati)

---

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
 * Plugin URI: https://github.com/username/nama_plugin
 * Description: Plugin untuk mengelola data tertentu dengan fitur X, Y, Z
 * Version: 1.0.0
 * Author: Nama Anda
 * Author URI: https://yourwebsite.com
 */

/**
 * ====================================================================
 * IMPORT NAMESPACE SLiMS
 * ====================================================================
 */

use SLiMS\DB;              // Class untuk koneksi database dan query
use SLiMS\Plugins;         // Class untuk manajemen plugin
use SLiMS\Url;             // Class untuk generate dan manipulasi URL
use SLiMS\Table\Schema;   // Class untuk operasi DDL database

/**
 * ====================================================================
 * KONSTANTA PLUGIN
 * ====================================================================
 */

// Path absolut ke folder plugin
define('NAMA_PLUGIN_DIR', __DIR__);

// URL web ke folder plugin
define('NAMA_PLUGIN_WEB', (string)Url::getSlimsBaseUri('plugins/' . basename(__DIR__) . '/'));

/**
 * CONTOH PENGGUNAAN KONSTANTA:
 * 
 * // Include file PHP:
 * include NAMA_PLUGIN_DIR . DS . 'helper.php';
 * 
 * // Load asset CSS/JS/Image:
 * <link rel="stylesheet" href="<?= NAMA_PLUGIN_WEB ?>static/css/style.css">
 */

/**
 * ====================================================================
 * LOAD HELPER FUNCTIONS
 * ====================================================================
 */
if (file_exists(__DIR__ . DS . 'helper.php')) {
    include_once __DIR__ . DS . 'helper.php';
}

/**
 * ====================================================================
 * INISIALISASI PLUGIN INSTANCE
 * ====================================================================
 */
$plugin = Plugins::getInstance();

/**
 * ====================================================================
 * REGISTRASI MENU PLUGIN DI ADMIN AREA
 * ====================================================================
 * Menu akan muncul di sidebar admin sesuai modul yang dipilih
 * 
 * Pilihan modul yang tersedia:
 * - 'system'        : Menu muncul di System
 * - 'membership'    : Menu muncul di Membership
 * - 'bibliography'  : Menu muncul di Bibliography
 * - 'circulation'   : Menu muncul di Circulation
 * - 'reporting'     : Menu muncul di Reporting
 * - 'master_file'   : Menu muncul di Master File
 * - 'stock_take'    : Menu muncul di Stock Take
 */

$plugin->registerMenu(
    'membership',                                    // Modul
    'Nama Menu Plugin',                              // Label menu
    __DIR__ . '/pages/admin/index.php'              // Path file
);

// Bisa register multiple menu di modul berbeda:
// $plugin->registerMenu('system', 'Settings', __DIR__ . '/pages/settings/index.php');
// $plugin->registerMenu('reporting', 'Report', __DIR__ . '/pages/report/index.php');

/**
 * ====================================================================
 * REGISTRASI MENU PLUGIN DI OPAC (Area Publik)
 * ====================================================================
 */

// Cek tabel sudah ada (mencegah error saat migration belum jalan)
if (Schema::hasTable('nama_table_plugin')) {

    // Query data aktif untuk menu dinamis
    $activeData = DB::getInstance()->query('
        SELECT id, name 
        FROM nama_table_plugin 
        WHERE status = 1 
        LIMIT 1
    ');

    if ($activeData->rowCount()) {
        $data = $activeData->fetchObject();

        // Register menu OPAC dengan nama dinamis
        $plugin->registerMenu(
            'opac',                                  // Modul khusus OPAC
            $data->name,                            // Judul dari database
            __DIR__ . DS . 'pages' . DS . 'opac' . DS . 'index.php'
        );
    }
}

// Atau menu OPAC dengan nama statis:
// $plugin->registerMenu('opac', 'Menu Publik', __DIR__ . '/pages/opac/index.php');

/**
 * ====================================================================
 * REGISTRASI PLUGIN HOOKS (Event System)
 * ====================================================================
 */

/**
 * HOOK: MEMBERSHIP_AFTER_SAVE
 * Dijalankan SETELAH member baru berhasil disimpan ke database
 * 
 * Use case:
 * - Kirim email welcome
 * - Log activity
 * - Sync ke sistem eksternal
 * - Generate barcode/kartu member
 */
$plugin->register(Plugins::MEMBERSHIP_AFTER_SAVE, function($data) {

    // Log activity
    error_log("New member registered: " . $data['member_name']);

    // Simpan ke tabel custom plugin
    $db = DB::getInstance();
    $stmt = $db->prepare("
        INSERT INTO plugin_member_log 
        SET member_id = ?, 
            action = 'registered', 
            created_at = NOW()
    ");
    $stmt->execute([$data['member_id']]);

    // Kirim email (jika sudah dikonfigurasi)
    /*
    if (!empty($data['member_email'])) {
        mail(
            $data['member_email'],
            'Selamat Datang',
            "Halo " . $data['member_name'] . ", terima kasih telah mendaftar."
        );
    }
    */
});

/**
 * HOOK: MEMBERSHIP_BEFORE_UPDATE
 * Dijalankan SEBELUM data member diupdate
 * 
 * Use case:
 * - Validasi custom
 * - Backup data lama
 * - Prevent update dengan throw Exception
 */
$plugin->register(Plugins::MEMBERSHIP_BEFORE_UPDATE, function($data) {

    // Validasi custom
    if (empty($data['member_email'])) {
        throw new Exception('Email member tidak boleh kosong!');
    }

    // Cek duplikat email
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
});

/**
 * HOOK: MEMBERSHIP_AFTER_UPDATE
 * Dijalankan SETELAH data member berhasil diupdate
 */
$plugin->register(Plugins::MEMBERSHIP_AFTER_UPDATE, function($data) {
    error_log("Member updated: " . $data['member_id']);
});

/**
 * HOOK: MEMBERSHIP_INIT (Override Halaman)
 * HATI-HATI: Hook ini akan REPLACE seluruh halaman membership default!
 * 
 * Hanya gunakan jika benar-benar perlu customize total halaman
 */
/*
$plugin->register(Plugins::MEMBERSHIP_INIT, function() {
    global $member_custom_fields, $can_read, $can_write, $sysconf, $dbs;

    // Load halaman custom
    include __DIR__ . '/pages/customs/membership/index.php';

    // WAJIB exit untuk stop eksekusi halaman default
    exit;
});
*/

/**
 * ====================================================================
 * CUSTOM HOOKS (Buat Hook Sendiri)
 * ====================================================================
 */

// Define custom hooks untuk plugin
$plugin->register('nama_plugin_before_process', function($data) {
    // Plugin lain bisa listen hook ini
});

$plugin->register('nama_plugin_after_process', function($data) {
    // Plugin lain bisa listen hook ini
});

/**
 * Cara trigger custom hook (di action/save.php):
 * 
 * Plugins::getInstance()->execute('nama_plugin_before_process', [
 *     'data' => $formData,
 *     'user_id' => $_SESSION['uid']
 * ]);
 */

/**
 * ====================================================================
 * DAFTAR LENGKAP HOOKS BAWAAN SLiMS
 * ====================================================================
 * 
 * MEMBERSHIP HOOKS:
 * - Plugins::MEMBERSHIP_INIT
 * - Plugins::MEMBERSHIP_BEFORE_SAVE
 * - Plugins::MEMBERSHIP_AFTER_SAVE
 * - Plugins::MEMBERSHIP_BEFORE_UPDATE
 * - Plugins::MEMBERSHIP_AFTER_UPDATE
 * 
 * BIBLIOGRAPHY HOOKS:
 * - Plugins::BIBLIOGRAPHY_INIT
 * - Plugins::BIBLIOGRAPHY_BEFORE_SAVE
 * - Plugins::BIBLIOGRAPHY_AFTER_SAVE
 * - Plugins::BIBLIOGRAPHY_BEFORE_UPDATE
 * - Plugins::BIBLIOGRAPHY_AFTER_UPDATE
 * 
 * CIRCULATION HOOKS:
 * - Plugins::CIRCULATION_BEFORE_CHECKOUT
 * - Plugins::CIRCULATION_AFTER_CHECKOUT
 * - Plugins::CIRCULATION_BEFORE_CHECKIN
 * - Plugins::CIRCULATION_AFTER_CHECKIN
 */
```

---

## Helper Functions

### 2. File `helper.php` - Fungsi-Fungsi Utility

```php
<?php
/**
 * ====================================================================
 * FILE HELPER - KUMPULAN FUNGSI PEMBANTU
 * ====================================================================
 * 
 * BEST PRACTICES:
 * - Setiap fungsi dibungkus if(!function_exists())
 * - Gunakan type hinting untuk parameter dan return value
 * - Beri komentar lengkap
 * - Gunakan nama fungsi yang deskriptif
 */

use SLiMS\Url;
use SLiMS\DB;

/**
 * ====================================================================
 * FUNGSI: getActiveData()
 * ====================================================================
 * Mengambil satu data yang aktif dari database
 * 
 * @param string $table Nama tabel
 * @param string $statusColumn Nama kolom status (default: 'status')
 * @return object|null Object data jika ada, null jika tidak ada
 */
if (!function_exists('getActiveData')) {
    function getActiveData(string $table, string $statusColumn = 'status'): ?object
    {
        try {
            $query = DB::getInstance()->prepare("
                SELECT * 
                FROM {$table} 
                WHERE {$statusColumn} = 1 
                LIMIT 1
            ");
            $query->execute();

            return $query->rowCount() ? $query->fetchObject() : null;
        } catch (Exception $e) {
            error_log("getActiveData Error: " . $e->getMessage());
            return null;
        }
    }
}

/**
 * ====================================================================
 * FUNGSI: getAllData()
 * ====================================================================
 * Mengambil semua data dari tabel
 * 
 * @param string $table Nama tabel
 * @param string $orderBy Kolom untuk sorting (default: 'id')
 * @param string $order Arah sorting ASC/DESC (default: 'DESC')
 * @return array Array of objects
 */
if (!function_exists('getAllData')) {
    function getAllData(
        string $table, 
        string $orderBy = 'id', 
        string $order = 'DESC'
    ): array {
        try {
            $order = strtoupper($order) === 'ASC' ? 'ASC' : 'DESC';

            $query = DB::getInstance()->query("
                SELECT * 
                FROM {$table} 
                ORDER BY {$orderBy} {$order}
            ");

            return $query->fetchAll(PDO::FETCH_OBJ);
        } catch (Exception $e) {
            error_log("getAllData Error: " . $e->getMessage());
            return [];
        }
    }
}

/**
 * ====================================================================
 * FUNGSI: getDataById()
 * ====================================================================
 * Mengambil data berdasarkan ID
 * 
 * @param string $table Nama tabel
 * @param int $id ID data
 * @param string $idColumn Nama kolom ID (default: 'id')
 * @return object|null
 */
if (!function_exists('getDataById')) {
    function getDataById(
        string $table, 
        int $id, 
        string $idColumn = 'id'
    ): ?object {
        try {
            $stmt = DB::getInstance()->prepare("
                SELECT * 
                FROM {$table} 
                WHERE {$idColumn} = ?
            ");
            $stmt->execute([$id]);

            return $stmt->rowCount() ? $stmt->fetchObject() : null;
        } catch (Exception $e) {
            error_log("getDataById Error: " . $e->getMessage());
            return null;
        }
    }
}

/**
 * ====================================================================
 * FUNGSI: action()
 * ====================================================================
 * Memuat file action dari folder action/ secara otomatis
 * Pattern MVC: Memisahkan presentation dari business logic
 * 
 * @param string $actionName Nama file action tanpa .php
 * @param array $attribute Data tambahan untuk di-extract
 * @throws Exception Jika file tidak ditemukan
 */
if (!function_exists('action')) {
    function action(string $actionName, array $attribute = []): void
    {
        global $sysconf;

        // Sanitize action name untuk security
        $actionName = preg_replace('/[^a-z0-9_-]/i', '', $actionName);

        // Extract array menjadi variabel
        extract($attribute);

        // Dapatkan info file pemanggil
        $trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 1);
        $info = pathinfo($trace[0]['file']);

        // Bangun path ke file action
        $path = $info['dirname'] . DS . 'action' . DS . $actionName . '.php';

        // Resolve realpath untuk prevent directory traversal
        $realPath = realpath($path);

        // Security check: pastikan file dalam folder action
        if ($realPath && strpos($realPath, $info['dirname'] . DS . 'action') === 0) {
            include $realPath;
        } else {
            throw new Exception('Action "' . $actionName . '" not found!', 404);
        }
    }
}

/**
 * ====================================================================
 * FUNGSI: pluginUrl()
 * ====================================================================
 * Generate URL untuk plugin dengan query string otomatis
 * 
 * @param array $data Array key-value untuk query string
 * @param bool $reset Hapus semua query kecuali mod & id
 * @return string URL lengkap dengan query string
 * 
 * CONTOH:
 * pluginUrl(['section' => 'edit', 'id' => 5])
 * // Result: index.php?mod=membership&id=plugin&section=edit&id=5
 * 
 * pluginUrl(reset: true)
 * // Result: index.php?mod=membership&id=plugin
 */
if (!function_exists('pluginUrl')) {
    function pluginUrl(array $data = [], bool $reset = false): string
    {
        if ($reset) {
            return Url::getSelf(fn($self) => 
                $self . '?mod=' . ($_GET['mod'] ?? '') . '&id=' . ($_GET['id'] ?? '')
            );
        }

        return Url::getSelf(function($self) use($data) {
            $merged = array_merge($_GET, $data);
            return $self . '?' . http_build_query($merged);
        });
    }
}

/**
 * ====================================================================
 * FUNGSI: textColor()
 * ====================================================================
 * Menghitung warna teks terbaik (hitam/putih) untuk background tertentu
 * Menggunakan formula W3C untuk perceived brightness
 * 
 * @param string $hexCode Kode warna HEX tanpa # (6 karakter)
 * @return string '000000' untuk hitam, 'ffffff' untuk putih
 * 
 * CONTOH:
 * $textColor = textColor('FF0000');  // Return: 'ffffff' (putih)
 * echo '<div style="background:#FF0000; color:#'.$textColor.'">Text</div>';
 */
if (!function_exists('textColor')) {
    function textColor(string $hexCode): string
    {
        // Validasi input
        if (strlen($hexCode) !== 6 || !ctype_xdigit($hexCode)) {
            return '000000'; // Default hitam jika input invalid
        }

        // Pisahkan RGB
        $r = hexdec(substr($hexCode, 0, 2)) / 255;
        $g = hexdec(substr($hexCode, 2, 2)) / 255;
        $b = hexdec(substr($hexCode, 4, 2)) / 255;

        // Hitung perceived brightness (formula W3C)
        $brightness = (($r * 299) + ($g * 587) + ($b * 114)) / 1000;

        // Threshold 0.5 (50%)
        return $brightness > 0.5 ? '000000' : 'ffffff';
    }
}

/**
 * ====================================================================
 * FUNGSI: sanitizeInput()
 * ====================================================================
 * Sanitize input untuk mencegah XSS
 * 
 * @param mixed $data Data yang akan disanitize
 * @return mixed Data yang sudah bersih
 */
if (!function_exists('sanitizeInput')) {
    function sanitizeInput($data)
    {
        if (is_array($data)) {
            return array_map('sanitizeInput', $data);
        }

        return htmlspecialchars(strip_tags(trim($data)), ENT_QUOTES, 'UTF-8');
    }
}

/**
 * ====================================================================
 * FUNGSI: validateCSRF()
 * ====================================================================
 * Validasi CSRF token
 * 
 * @return bool True jika valid, false jika tidak
 */
if (!function_exists('validateCSRF')) {
    function validateCSRF(): bool
    {
        if (!isset($_POST['csrf_token']) || !isset($_SESSION['csrf_token'])) {
            return false;
        }

        return hash_equals($_SESSION['csrf_token'], $_POST['csrf_token']);
    }
}

/**
 * ====================================================================
 * FUNGSI: generateCSRFToken()
 * ====================================================================
 * Generate CSRF token baru
 * 
 * @return string CSRF token
 */
if (!function_exists('generateCSRFToken')) {
    function generateCSRFToken(): string
    {
        if (!isset($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }

        return $_SESSION['csrf_token'];
    }
}
```

---

## Database Migration

### 3. Membuat File Migration

Migration adalah cara terstruktur untuk mengelola perubahan skema database. SLiMS akan menjalankan migration secara otomatis saat plugin diaktifkan.

#### Aturan Penamaan Migration
- Format: `{nomor}_{NamaClass}.php`
- Nomor urut dimulai dari 1
- Nama class menggunakan PascalCase
- Contoh: `1_CreatePluginTable.php`, `2_AddEmailColumn.php`

#### Migration #1: Create Table

```php
<?php
/**
 * File: migration/1_CreatePluginTable.php
 * Membuat tabel utama plugin
 */

use SLiMS\Migration\Migration;
use SLiMS\DB;

class CreatePluginTable extends Migration
{
    /**
     * Method up() dijalankan saat plugin diaktifkan
     */
    public function up()
    {
        // Cek apakah tabel sudah ada
        if ($this->schema->hasTable('plugin_data')) {
            return; // Skip jika sudah ada
        }

        // Buat tabel dengan schema builder
        $this->schema->create('plugin_data', function($table) {
            $table->increments('id');                          // INT AUTO_INCREMENT PRIMARY KEY
            $table->string('name', 100);                       // VARCHAR(100)
            $table->text('description')->nullable();           // TEXT NULL
            $table->integer('user_id');                        // INT
            $table->enum('status', ['0', '1'])->default('0'); // ENUM default '0'
            $table->timestamps();                              // created_at, updated_at

            // Index
            $table->index('user_id');                          // INDEX
            $table->index('status');
        });

        // Insert data default (opsional)
        DB::getInstance()->query("
            INSERT INTO plugin_data (name, description, status, created_at) 
            VALUES ('Default', 'Data default plugin', '1', NOW())
        ");
    }

    /**
     * Method down() dijalankan saat plugin di-uninstall
     */
    public function down()
    {
        $this->schema->dropIfExists('plugin_data');
    }
}
```

#### Migration #2: Add Column

```php
<?php
/**
 * File: migration/2_AddEmailColumn.php
 * Menambah kolom email ke tabel
 */

use SLiMS\Migration\Migration;

class AddEmailColumn extends Migration
{
    public function up()
    {
        // Cek apakah kolom sudah ada
        if ($this->schema->hasColumn('plugin_data', 'email')) {
            return;
        }

        // Tambah kolom
        $this->schema->table('plugin_data', function($table) {
            $table->string('email', 100)->nullable()->after('name');
            $table->index('email');
        });
    }

    public function down()
    {
        $this->schema->table('plugin_data', function($table) {
            $table->dropColumn('email');
        });
    }
}
```

#### Migration #3: Create Indexes

```php
<?php
/**
 * File: migration/3_CreateIndexes.php
 * Membuat index untuk optimasi query
 */

use SLiMS\Migration\Migration;
use SLiMS\DB;

class CreateIndexes extends Migration
{
    public function up()
    {
        $db = DB::getInstance();

        // Cek apakah index sudah ada
        $result = $db->query("
            SHOW INDEX FROM plugin_data 
            WHERE Key_name = 'idx_name_status'
        ");

        if ($result->rowCount() == 0) {
            // Buat composite index
            $db->query("
                CREATE INDEX idx_name_status 
                ON plugin_data (name, status)
            ");
        }

        // Buat fulltext index (untuk pencarian)
        $result = $db->query("
            SHOW INDEX FROM plugin_data 
            WHERE Key_name = 'ft_description'
        ");

        if ($result->rowCount() == 0) {
            $db->query("
                CREATE FULLTEXT INDEX ft_description 
                ON plugin_data (description)
            ");
        }
    }

    public function down()
    {
        $db = DB::getInstance();
        $db->query("DROP INDEX idx_name_status ON plugin_data");
        $db->query("DROP INDEX ft_description ON plugin_data");
    }
}
```

#### Migration Best Practices

1. **Selalu cek keberadaan** sebelum create/alter
2. **Gunakan transactions** untuk operasi kompleks
3. **Test migration** di development dulu
4. **Backup database** sebelum migration
5. **Implement down()** untuk rollback

```php
// Contoh migration dengan transaction
public function up()
{
    $db = DB::getInstance();

    try {
        $db->beginTransaction();

        // Multiple operations
        $db->query("CREATE TABLE...");
        $db->query("INSERT INTO...");
        $db->query("CREATE INDEX...");

        $db->commit();
    } catch (Exception $e) {
        $db->rollBack();
        throw $e;
    }
}
```

---

## Pages dan Routing

### 4. Struktur Pages

#### File Router Utama: `pages/admin/index.php`

```php
<?php
/**
 * ====================================================================
 * ROUTER UTAMA ADMIN
 * ====================================================================
 * File ini mengatur routing dan load halaman sesuai section
 */

// Security check: pastikan diakses dari dalam SLiMS
defined('INDEX_AUTH') OR die('Direct access not allowed!');

// Check permission
if (!$can_write) {
    die('<div class="alert alert-danger">Anda tidak punya akses!</div>');
}

// Load helper
require_once __DIR__ . '/../../helper.php';

// Get section dari query string
$section = $_GET['section'] ?? 'list';

// Handle POST action
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    try {
        // Validate CSRF
        if (!validateCSRF()) {
            throw new Exception('Invalid CSRF token!');
        }

        // Load action handler
        action($_POST['action'], [
            'can_write' => $can_write,
            'user_id' => $_SESSION['uid'] ?? 0
        ]);

    } catch (Exception $e) {
        if ($e->getCode() == 404) {
            toastr('Action tidak ditemukan')->error();
        } else {
            toastr($e->getMessage())->error();
        }
    }
    exit;
}

// Routing berdasarkan section
switch ($section) {
    case 'list':
        include __DIR__ . '/list.inc.php';
        break;

    case 'add':
        include __DIR__ . '/add.inc.php';
        break;

    case 'edit':
        if (!isset($_GET['id'])) {
            die('ID tidak valid');
        }
        include __DIR__ . '/edit.inc.php';
        break;

    case 'detail':
        if (!isset($_GET['id'])) {
            die('ID tidak valid');
        }
        include __DIR__ . '/detail.inc.php';
        break;

    default:
        die('Halaman tidak ditemukan');
}
```

#### File List: `pages/admin/list.inc.php`

```php
<?php
/**
 * Halaman list data dengan datatable
 */

defined('INDEX_AUTH') OR die('Direct access not allowed!');

// Load data
$data = getAllData('plugin_data', 'created_at', 'DESC');
?>

<div class="menuBox">
    <div class="menuBoxInner printHide">
        <div class="per_title">
            <h2>Plugin Data Management</h2>
        </div>
        <div class="infoBox">
            Kelola data plugin
        </div>
    </div>
</div>

<!-- Toolbar -->
<div class="mb-3">
    <a href="<?= pluginUrl(['section' => 'add']) ?>" class="btn btn-primary">
        <i class="fas fa-plus"></i> Tambah Data
    </a>
    <a href="<?= pluginUrl(['section' => 'export']) ?>" class="btn btn-success">
        <i class="fas fa-file-excel"></i> Export Excel
    </a>
</div>

<!-- DataTable -->
<table id="dataTable" class="table table-bordered table-striped">
    <thead>
        <tr>
            <th width="5%">No</th>
            <th width="20%">Nama</th>
            <th width="30%">Deskripsi</th>
            <th width="15%">User</th>
            <th width="10%">Status</th>
            <th width="10%">Created</th>
            <th width="10%">Aksi</th>
        </tr>
    </thead>
    <tbody>
        <?php if (empty($data)): ?>
        <tr>
            <td colspan="7" class="text-center">Tidak ada data</td>
        </tr>
        <?php else: ?>
        <?php $no = 1; foreach ($data as $row): ?>
        <tr>
            <td><?= $no++ ?></td>
            <td><?= htmlspecialchars($row->name) ?></td>
            <td><?= htmlspecialchars(substr($row->description ?? '', 0, 100)) ?>...</td>
            <td><?= $row->user_id ?></td>
            <td>
                <?php if ($row->status == 1): ?>
                <span class="badge badge-success">Aktif</span>
                <?php else: ?>
                <span class="badge badge-secondary">Nonaktif</span>
                <?php endif; ?>
            </td>
            <td><?= date('d/m/Y', strtotime($row->created_at)) ?></td>
            <td>
                <a href="<?= pluginUrl(['section' => 'detail', 'id' => $row->id]) ?>" 
                   class="btn btn-sm btn-info" title="Detail">
                    <i class="fas fa-eye"></i>
                </a>
                <a href="<?= pluginUrl(['section' => 'edit', 'id' => $row->id]) ?>" 
                   class="btn btn-sm btn-warning" title="Edit">
                    <i class="fas fa-edit"></i>
                </a>
                <a href="#" 
                   onclick="deleteData(<?= $row->id ?>, '<?= htmlspecialchars($row->name) ?>')" 
                   class="btn btn-sm btn-danger" title="Hapus">
                    <i class="fas fa-trash"></i>
                </a>
            </td>
        </tr>
        <?php endforeach; ?>
        <?php endif; ?>
    </tbody>
</table>

<!-- JavaScript -->
<script>
$(document).ready(function() {
    $('#dataTable').DataTable({
        "language": {
            "url": "<?= SWB ?>js/jquery.dataTables-Indonesian.json"
        }
    });
});

function deleteData(id, name) {
    if (!confirm('Hapus data "' + name + '"?')) {
        return;
    }

    $.ajax({
        url: '<?= pluginUrl() ?>',
        method: 'POST',
        data: {
            action: 'delete',
            id: id,
            csrf_token: '<?= generateCSRFToken() ?>'
        },
        success: function(response) {
            location.reload();
        },
        error: function() {
            alert('Gagal menghapus data');
        }
    });
}
</script>
```

#### File Add: `pages/admin/add.inc.php`

```php
<?php
defined('INDEX_AUTH') OR die('Direct access not allowed!');
?>

<div class="menuBox">
    <div class="menuBoxInner printHide">
        <div class="per_title">
            <h2>Tambah Data</h2>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <form method="POST" action="<?= pluginUrl() ?>">
            <?= getHiddenInput() // CSRF token ?>
            <input type="hidden" name="action" value="save">

            <div class="form-group">
                <label>Nama <span class="text-danger">*</span></label>
                <input type="text" 
                       name="name" 
                       class="form-control" 
                       required 
                       maxlength="100">
            </div>

            <div class="form-group">
                <label>Deskripsi</label>
                <textarea name="description" 
                          class="form-control" 
                          rows="5"></textarea>
            </div>

            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="0">Nonaktif</option>
                    <option value="1">Aktif</option>
                </select>
            </div>

            <div class="form-group">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Simpan
                </button>
                <a href="<?= pluginUrl(['section' => 'list']) ?>" 
                   class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Kembali
                </a>
            </div>
        </form>
    </div>
</div>
```

#### File Edit: `pages/admin/edit.inc.php`

```php
<?php
defined('INDEX_AUTH') OR die('Direct access not allowed!');

$id = (int)$_GET['id'];
$data = getDataById('plugin_data', $id);

if (!$data) {
    die('<div class="alert alert-danger">Data tidak ditemukan!</div>');
}
?>

<div class="menuBox">
    <div class="menuBoxInner printHide">
        <div class="per_title">
            <h2>Edit Data</h2>
        </div>
    </div>
</div>

<div class="card">
    <div class="card-body">
        <form method="POST" action="<?= pluginUrl() ?>">
            <?= getHiddenInput() ?>
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" value="<?= $data->id ?>">

            <div class="form-group">
                <label>Nama <span class="text-danger">*</span></label>
                <input type="text" 
                       name="name" 
                       class="form-control" 
                       required 
                       maxlength="100"
                       value="<?= htmlspecialchars($data->name) ?>">
            </div>

            <div class="form-group">
                <label>Deskripsi</label>
                <textarea name="description" 
                          class="form-control" 
                          rows="5"><?= htmlspecialchars($data->description ?? '') ?></textarea>
            </div>

            <div class="form-group">
                <label>Status</label>
                <select name="status" class="form-control">
                    <option value="0" <?= $data->status == 0 ? 'selected' : '' ?>>Nonaktif</option>
                    <option value="1" <?= $data->status == 1 ? 'selected' : '' ?>>Aktif</option>
                </select>
            </div>

            <div class="form-group">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-save"></i> Update
                </button>
                <a href="<?= pluginUrl(['section' => 'list']) ?>" 
                   class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Kembali
                </a>
            </div>
        </form>
    </div>
</div>
```

---

## Action Handlers

### 5. File Action untuk CRUD Operations

#### Action Save: `pages/admin/action/save.php`

```php
<?php
/**
 * Action handler untuk save data baru
 */

defined('INDEX_AUTH') OR die('Direct access not allowed!');

// Check permission
if (!$can_write) {
    toastr('Anda tidak punya akses!')->error();
    exit;
}

try {
    // Sanitize input
    $name = sanitizeInput($_POST['name'] ?? '');
    $description = sanitizeInput($_POST['description'] ?? '');
    $status = (int)($_POST['status'] ?? 0);
    $userId = $_SESSION['uid'] ?? 0;

    // Validasi
    if (empty($name)) {
        throw new Exception('Nama tidak boleh kosong!');
    }

    if (strlen($name) > 100) {
        throw new Exception('Nama maksimal 100 karakter!');
    }

    // Cek duplikat nama
    $check = DB::getInstance()->prepare("
        SELECT id FROM plugin_data WHERE name = ?
    ");
    $check->execute([$name]);

    if ($check->rowCount() > 0) {
        throw new Exception('Nama sudah digunakan!');
    }

    // Insert ke database
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_data 
        SET name = ?,
            description = ?,
            user_id = ?,
            status = ?,
            created_at = NOW(),
            updated_at = NOW()
    ");

    $stmt->execute([$name, $description, $userId, $status]);
    $insertId = DB::getInstance()->lastInsertId();

    // Trigger custom hook
    Plugins::getInstance()->execute('nama_plugin_after_save', [
        'id' => $insertId,
        'name' => $name,
        'user_id' => $userId
    ]);

    // Success message
    toastr('Data berhasil disimpan!')->success();

    // Redirect
    header('Location: ' . pluginUrl(['section' => 'list']));
    exit;

} catch (Exception $e) {
    toastr($e->getMessage())->error();

    // Redirect kembali ke form
    header('Location: ' . pluginUrl(['section' => 'add']));
    exit;
}
```

#### Action Update: `pages/admin/action/update.php`

```php
<?php
defined('INDEX_AUTH') OR die('Direct access not allowed!');

if (!$can_write) {
    toastr('Anda tidak punya akses!')->error();
    exit;
}

try {
    $id = (int)($_POST['id'] ?? 0);
    $name = sanitizeInput($_POST['name'] ?? '');
    $description = sanitizeInput($_POST['description'] ?? '');
    $status = (int)($_POST['status'] ?? 0);

    // Validasi
    if ($id <= 0) {
        throw new Exception('ID tidak valid!');
    }

    if (empty($name)) {
        throw new Exception('Nama tidak boleh kosong!');
    }

    // Cek data exist
    $check = DB::getInstance()->prepare("SELECT id FROM plugin_data WHERE id = ?");
    $check->execute([$id]);

    if ($check->rowCount() == 0) {
        throw new Exception('Data tidak ditemukan!');
    }

    // Cek duplikat nama (kecuali data sendiri)
    $check = DB::getInstance()->prepare("
        SELECT id FROM plugin_data 
        WHERE name = ? AND id != ?
    ");
    $check->execute([$name, $id]);

    if ($check->rowCount() > 0) {
        throw new Exception('Nama sudah digunakan!');
    }

    // Update database
    $stmt = DB::getInstance()->prepare("
        UPDATE plugin_data 
        SET name = ?,
            description = ?,
            status = ?,
            updated_at = NOW()
        WHERE id = ?
    ");

    $stmt->execute([$name, $description, $status, $id]);

    // Trigger hook
    Plugins::getInstance()->execute('nama_plugin_after_update', [
        'id' => $id,
        'name' => $name
    ]);

    toastr('Data berhasil diupdate!')->success();
    header('Location: ' . pluginUrl(['section' => 'list']));
    exit;

} catch (Exception $e) {
    toastr($e->getMessage())->error();
    header('Location: ' . pluginUrl(['section' => 'edit', 'id' => $id ?? 0]));
    exit;
}
```

#### Action Delete: `pages/admin/action/delete.php`

```php
<?php
defined('INDEX_AUTH') OR die('Direct access not allowed!');

if (!$can_write) {
    echo json_encode(['success' => false, 'message' => 'Tidak punya akses']);
    exit;
}

try {
    $id = (int)($_POST['id'] ?? 0);

    if ($id <= 0) {
        throw new Exception('ID tidak valid!');
    }

    // Cek data exist
    $check = DB::getInstance()->prepare("SELECT name FROM plugin_data WHERE id = ?");
    $check->execute([$id]);
    $data = $check->fetch(PDO::FETCH_OBJ);

    if (!$data) {
        throw new Exception('Data tidak ditemukan!');
    }

    // Delete
    $stmt = DB::getInstance()->prepare("DELETE FROM plugin_data WHERE id = ?");
    $stmt->execute([$id]);

    // Trigger hook
    Plugins::getInstance()->execute('nama_plugin_after_delete', [
        'id' => $id,
        'name' => $data->name
    ]);

    echo json_encode([
        'success' => true, 
        'message' => 'Data berhasil dihapus'
    ]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false, 
        'message' => $e->getMessage()
    ]);
}
```

---

## Security Best Practices

### 6. Keamanan Plugin

#### 1. Input Validation & Sanitization

```php
// SALAH - Langsung pakai input
$name = $_POST['name'];
$query = "INSERT INTO table SET name = '$name'"; // SQL Injection!

// BENAR - Sanitize dan gunakan prepared statement
$name = sanitizeInput($_POST['name']);

// Validasi tipe data
$id = filter_var($_POST['id'], FILTER_VALIDATE_INT);
if ($id === false) {
    throw new Exception('ID harus angka!');
}

// Validasi email
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
if ($email === false) {
    throw new Exception('Format email salah!');
}

// Prepared statement
$stmt = DB::getInstance()->prepare("INSERT INTO table SET name = ?");
$stmt->execute([$name]);
```

#### 2. SQL Injection Prevention

```php
// SALAH
$table = $_GET['table'];
$query = "SELECT * FROM $table"; // Bisa dimanipulasi!

// BENAR - Whitelist table name
$allowedTables = ['plugin_data', 'plugin_log'];
$table = $_GET['table'] ?? '';

if (!in_array($table, $allowedTables)) {
    throw new Exception('Invalid table!');
}

$query = "SELECT * FROM $table";
```

#### 3. XSS Prevention

```php
// SALAH - Langsung output
echo $_GET['message']; // XSS!

// BENAR - Escape output
echo htmlspecialchars($_GET['message'], ENT_QUOTES, 'UTF-8');

// Atau gunakan helper
echo sanitizeInput($_GET['message']);
```

#### 4. CSRF Protection

```php
// Di form (HTML)
<form method="POST">
    <?= getHiddenInput() // Generate CSRF token ?>
    <!-- form fields -->
</form>

// Di action handler (PHP)
if (!validateCSRF()) {
    throw new Exception('Invalid CSRF token!');
}
```

#### 5. Authorization Check

```php
// Cek permission
if (!$can_write) {
    die('Anda tidak punya akses!');
}

// Cek user yang login saja
if (!isset($_SESSION['uid'])) {
    die('Silakan login terlebih dahulu!');
}

// Cek role spesifik
$userRole = $_SESSION['role'] ?? '';
$allowedRoles = ['admin', 'librarian'];

if (!in_array($userRole, $allowedRoles)) {
    die('Akses ditolak!');
}
```

#### 6. File Upload Security

```php
// Validasi file upload
function validateFileUpload($file, $allowedTypes = ['jpg', 'png', 'pdf'])
{
    // Cek error
    if ($file['error'] !== UPLOAD_ERR_OK) {
        throw new Exception('Upload error: ' . $file['error']);
    }

    // Cek ukuran (max 2MB)
    $maxSize = 2 * 1024 * 1024;
    if ($file['size'] > $maxSize) {
        throw new Exception('File terlalu besar! Maksimal 2MB');
    }

    // Cek extension
    $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($ext, $allowedTypes)) {
        throw new Exception('Tipe file tidak diizinkan!');
    }

    // Cek MIME type (double check)
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mimeType = finfo_file($finfo, $file['tmp_name']);
    finfo_close($finfo);

    $allowedMimes = [
        'jpg' => 'image/jpeg',
        'png' => 'image/png',
        'pdf' => 'application/pdf'
    ];

    if (!isset($allowedMimes[$ext]) || $mimeType !== $allowedMimes[$ext]) {
        throw new Exception('File type mismatch!');
    }

    return true;
}

// Penggunaan
try {
    validateFileUpload($_FILES['document'], ['pdf', 'doc', 'docx']);

    // Generate unique filename
    $newName = uniqid() . '_' . basename($_FILES['document']['name']);
    $destination = __DIR__ . '/uploads/' . $newName;

    move_uploaded_file($_FILES['document']['tmp_name'], $destination);

} catch (Exception $e) {
    die('Upload gagal: ' . $e->getMessage());
}
```

#### 7. Directory Traversal Prevention

```php
// SALAH
$file = $_GET['file'];
include $file; // Bisa: ../../../../etc/passwd

// BENAR - Whitelist atau realpath check
$file = basename($_GET['file']); // Hapus path
$allowedFiles = ['page1.php', 'page2.php'];

if (!in_array($file, $allowedFiles)) {
    die('File not allowed!');
}

include __DIR__ . '/pages/' . $file;

// Atau gunakan realpath
$requestedPath = realpath(__DIR__ . '/pages/' . $_GET['file']);
$basePath = realpath(__DIR__ . '/pages/');

if (strpos($requestedPath, $basePath) !== 0) {
    die('Directory traversal detected!');
}
```

#### 8. Rate Limiting

```php
// Simple rate limiting untuk prevent brute force
function checkRateLimit($action, $maxAttempts = 5, $timeWindow = 60)
{
    $key = 'rate_limit_' . $action . '_' . $_SERVER['REMOTE_ADDR'];

    if (!isset($_SESSION[$key])) {
        $_SESSION[$key] = ['count' => 0, 'start' => time()];
    }

    $rateData = $_SESSION[$key];

    // Reset jika sudah lewat time window
    if (time() - $rateData['start'] > $timeWindow) {
        $_SESSION[$key] = ['count' => 1, 'start' => time()];
        return true;
    }

    // Increment counter
    $_SESSION[$key]['count']++;

    // Cek limit
    if ($_SESSION[$key]['count'] > $maxAttempts) {
        throw new Exception('Terlalu banyak percobaan! Coba lagi nanti.');
    }

    return true;
}

// Penggunaan di action
try {
    checkRateLimit('login', 5, 300); // 5 attempts dalam 5 menit

    // Proses login...

} catch (Exception $e) {
    die($e->getMessage());
}
```

---

## Testing Plugin

### 7. Unit Testing dengan PHPUnit

#### Setup Testing

```bash
# Install PHPUnit via composer
composer require --dev phpunit/phpunit ^9.0

# Buat file phpunit.xml
```

#### File `phpunit.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<phpunit bootstrap="tests/bootstrap.php"
         colors="true"
         verbose="true">
    <testsuites>
        <testsuite name="Plugin Test Suite">
            <directory>tests</directory>
        </testsuite>
    </testsuites>
</phpunit>
```

#### File `tests/bootstrap.php`

```php
<?php
// Bootstrap untuk testing

// Load SLiMS constants
define('DS', DIRECTORY_SEPARATOR);
define('INDEX_AUTH', 1);

// Mock session untuk testing
if (!isset($_SESSION)) {
    $_SESSION = [
        'uid' => 1,
        'username' => 'admin',
        'role' => 'admin'
    ];
}

// Mock $_GET dan $_POST
if (!isset($_GET)) $_GET = [];
if (!isset($_POST)) $_POST = [];

// Load plugin files
require_once __DIR__ . '/../helper.php';
```

#### File `tests/HelperTest.php`

```php
<?php

use PHPUnit\Framework\TestCase;

class HelperTest extends TestCase
{
    /**
     * Test fungsi sanitizeInput
     */
    public function testSanitizeInput()
    {
        $input = '<script>alert("XSS")</script>';
        $result = sanitizeInput($input);

        $this->assertStringNotContainsString('<script>', $result);
        $this->assertStringNotContainsString('</script>', $result);
    }

    /**
     * Test sanitizeInput dengan array
     */
    public function testSanitizeInputArray()
    {
        $input = [
            'name' => '<b>Test</b>',
            'email' => 'test@email.com'
        ];

        $result = sanitizeInput($input);

        $this->assertIsArray($result);
        $this->assertStringNotContainsString('<b>', $result['name']);
    }

    /**
     * Test fungsi textColor
     */
    public function testTextColorWhiteBackground()
    {
        $result = textColor('FFFFFF'); // White background
        $this->assertEquals('000000', $result); // Should return black
    }

    public function testTextColorBlackBackground()
    {
        $result = textColor('000000'); // Black background
        $this->assertEquals('ffffff', $result); // Should return white
    }

    public function testTextColorRedBackground()
    {
        $result = textColor('FF0000'); // Red background
        $this->assertEquals('ffffff', $result); // Should return white
    }

    /**
     * Test fungsi pluginUrl
     */
    public function testPluginUrlWithParams()
    {
        $_GET = [
            'mod' => 'membership',
            'id' => 'test_plugin'
        ];

        $result = pluginUrl(['section' => 'add']);

        $this->assertStringContainsString('mod=membership', $result);
        $this->assertStringContainsString('id=test_plugin', $result);
        $this->assertStringContainsString('section=add', $result);
    }

    public function testPluginUrlReset()
    {
        $_GET = [
            'mod' => 'membership',
            'id' => 'test_plugin',
            'section' => 'list',
            'page' => '2'
        ];

        $result = pluginUrl(reset: true);

        $this->assertStringContainsString('mod=membership', $result);
        $this->assertStringContainsString('id=test_plugin', $result);
        $this->assertStringNotContainsString('section=', $result);
        $this->assertStringNotContainsString('page=', $result);
    }

    /**
     * Test CSRF token generation
     */
    public function testGenerateCSRFToken()
    {
        $token1 = generateCSRFToken();
        $token2 = generateCSRFToken();

        // Token harus sama jika dipanggil berulang dalam session yang sama
        $this->assertEquals($token1, $token2);
        $this->assertEquals(64, strlen($token1)); // Token length should be 64 chars
    }

    /**
     * Test CSRF validation
     */
    public function testValidateCSRFSuccess()
    {
        $token = generateCSRFToken();
        $_POST['csrf_token'] = $token;
        $_SESSION['csrf_token'] = $token;

        $this->assertTrue(validateCSRF());
    }

    public function testValidateCSRFFailed()
    {
        $_POST['csrf_token'] = 'invalid_token';
        $_SESSION['csrf_token'] = 'valid_token';

        $this->assertFalse(validateCSRF());
    }
}
```

#### File `tests/DatabaseTest.php`

```php
<?php

use PHPUnit\Framework\TestCase;

class DatabaseTest extends TestCase
{
    /**
     * Test fungsi getDataById
     */
    public function testGetDataById()
    {
        // Mock: pastikan ada data dengan id=1
        $result = getDataById('plugin_data', 1);

        if ($result) {
            $this->assertIsObject($result);
            $this->assertEquals(1, $result->id);
        } else {
            // Skip test jika data tidak ada
            $this->markTestSkipped('No data with id=1 in database');
        }
    }

    /**
     * Test fungsi getAllData
     */
    public function testGetAllData()
    {
        $result = getAllData('plugin_data');

        $this->assertIsArray($result);

        if (count($result) > 0) {
            $this->assertIsObject($result[0]);
        }
    }

    /**
     * Test getActiveData
     */
    public function testGetActiveData()
    {
        $result = getActiveData('plugin_data');

        if ($result) {
            $this->assertIsObject($result);
            $this->assertEquals(1, $result->status);
        }
    }
}
```

#### Menjalankan Testing

```bash
# Run all tests
./vendor/bin/phpunit

# Run specific test file
./vendor/bin/phpunit tests/HelperTest.php

# Run dengan coverage report
./vendor/bin/phpunit --coverage-html coverage/
```

#### Manual Testing Checklist

```markdown
## Testing Checklist

### Instalasi
- [ ] Plugin muncul di list plugins
- [ ] Migration berjalan tanpa error
- [ ] Tabel database terbuat dengan benar
- [ ] Data default terinsert

### Menu
- [ ] Menu muncul di modul yang tepat
- [ ] Menu bisa diklik dan load halaman
- [ ] Permission check berfungsi

### CRUD Operations
- [ ] List data tampil dengan benar
- [ ] Add data berhasil
- [ ] Edit data berhasil
- [ ] Delete data berhasil
- [ ] Validasi form berfungsi
- [ ] Error handling berfungsi

### Security
- [ ] CSRF protection aktif
- [ ] SQL injection tidak berhasil
- [ ] XSS tidak berhasil
- [ ] File upload validation berfungsi
- [ ] Authorization check berfungsi

### Performance
- [ ] Query tidak lambat (< 0.1s)
- [ ] Tidak ada N+1 query
- [ ] Pagination berfungsi

### Compatibility
- [ ] Test di SLiMS 9.x
- [ ] Test di SLiMS 10.x (Mulawarman)
- [ ] Test di PHP 7.4
- [ ] Test di PHP 8.x

### Browser Testing
- [ ] Chrome/Edge
- [ ] Firefox
- [ ] Safari
- [ ] Mobile responsive
```

---

## Deployment Checklist

### 8. Checklist Sebelum Deploy ke Production

```markdown
## Pre-Deployment Checklist

### Code Quality
- [ ] Semua function punya docblock comment
- [ ] Tidak ada debug code (var_dump, print_r, die)
- [ ] Tidak ada console.log di JavaScript
- [ ] Error handling lengkap
- [ ] Code sudah di-review

### Security
- [ ] Input validation di semua form
- [ ] Output escaping di semua view
- [ ] CSRF protection aktif
- [ ] SQL prepared statements digunakan
- [ ] File upload validation lengkap
- [ ] Authorization check di semua action
- [ ] Rate limiting untuk sensitive actions

### Database
- [ ] Migration tested dan bisa rollback
- [ ] Index database sudah optimal
- [ ] Backup database tersedia
- [ ] Migration tidak menghapus data existing

### Testing
- [ ] Unit test passed
- [ ] Manual testing completed
- [ ] Test di development environment
- [ ] Test di staging environment
- [ ] Load testing (jika perlu)

### Documentation
- [ ] README.md lengkap
- [ ] CHANGELOG.md updated
- [ ] User manual tersedia
- [ ] API documentation (jika ada)
- [ ] Installation guide

### Version Control
- [ ] Git tag untuk release version
- [ ] Changelog commit
- [ ] README updated

### Performance
- [ ] Query optimization done
- [ ] Asset minification (CSS/JS)
- [ ] Image optimization
- [ ] Caching implemented (jika perlu)

### Compatibility
- [ ] Test di SLiMS target version
- [ ] Test di different PHP versions
- [ ] Test di different databases (MySQL/MariaDB)
- [ ] Browser compatibility checked

### Rollback Plan
- [ ] Backup plugin lama
- [ ] Backup database
- [ ] Rollback procedure documented
- [ ] Emergency contact prepared
```

---

## Appendix: Best Practices Summary

### Coding Standards

1. **Naming Conventions**
   - Plugin folder: `snake_case`
   - Class names: `PascalCase`
   - Function names: `camelCase`
   - Constants: `UPPER_CASE`

2. **File Structure**
   - Satu class per file
   - Grouping by feature, bukan by type
   - Pisahkan business logic dari presentation

3. **Comments**
   - Docblock untuk semua function
   - Inline comment untuk logic kompleks
   - TODO/FIXME untuk improvement

4. **Error Handling**
   - Gunakan try-catch
   - Log error ke file
   - User-friendly error messages
   - Never expose sensitive info

5. **Database**
   - Selalu gunakan prepared statements
   - Transaction untuk multiple operations
   - Index untuk kolom yang sering di-query
   - Normalisasi database

6. **Security First**
   - Validate input
   - Escape output
   - Use CSRF tokens
   - Check permissions
   - Rate limiting

7. **Performance**
   - Lazy loading data
   - Pagination untuk list besar
   - Cache hasil query (jika perlu)
   - Optimize database queries

8. **Maintainability**
   - DRY (Don't Repeat Yourself)
   - KISS (Keep It Simple, Stupid)
   - SOLID principles
   - Consistent code style

---

## Referensi & Resources

### Official Documentation
- [SLiMS Official Site](https://slims.web.id)
- [SLiMS GitHub](https://github.com/slims/slims9_bulian)
- [SLiMS Documentation](https://docs.slims.web.id)

### PHP Resources
- [PHP Official Documentation](https://www.php.net/docs.php)
- [PSR Standards](https://www.php-fig.org/psr/)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)

### Security
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [PHP Security Guide](https://phptherightway.com/#security)

### Tools
- Composer: Dependency management
- PHPUnit: Unit testing
- PHPStan: Static analysis
- PHP_CodeSniffer: Code style checker

---
