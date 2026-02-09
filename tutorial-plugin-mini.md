## Table of Contents
- [Plugin Structure](#plugin-structure)
- [Main Plugin File](#main-plugin-file)
- [Helper Functions](#helper-functions)
- [Database Migration](#database-migration)
- [Pages & Routing](#pages--routing)
- [Action Handlers](#action-handlers)
- [Plugin Hooks - COMPLETE LIST](#plugin-hooks---complete-list)
- [Security](#security)
- [Quick Reference](#quick-reference)

---

## Plugin Structure

```
nama_plugin/
├── nama_plugin.plugin.php    # Entry point (WAJIB)
├── helper.php                 # Utility functions
├── migration/
│   ├── 1_CreateSchema.php
│   └── 2_AddColumn.php
├── pages/
│   ├── admin/
│   │   ├── index.php         # Router
│   │   ├── list.inc.php
│   │   └── action/
│   │       ├── save.php
│   │       └── delete.php
│   └── opac/
│       └── index.php
└── static/
    ├── css/
    └── js/
```

**Aturan:**
- Nama file plugin = nama folder (snake_case)
- Migration dijalankan otomatis saat aktivasi
- Gunakan `DS` untuk directory separator

---

## Main Plugin File

### Minimal Setup

```php
<?php
/**
 * Plugin Name: Nama Plugin
 * Plugin URI: https://github.com/user/plugin
 * Description: Deskripsi singkat
 * Version: 1.0.0
 * Author: Nama
 */

use SLiMS\DB;
use SLiMS\Plugins;
use SLiMS\Url;
use SLiMS\Table\Schema;

// Constants
define('PLUGIN_DIR', __DIR__);
define('PLUGIN_WEB', (string)Url::getSlimsBaseUri('plugins/' . basename(__DIR__) . '/'));

// Load helper
include_once __DIR__ . DS . 'helper.php';

$plugin = Plugins::getInstance();
```

### Register Menu

```php
// Admin menu
$plugin->registerMenu(
    'membership',           // Module: system|membership|bibliography|circulation|reporting|master_file|stock_take
    'Menu Label',
    __DIR__ . '/pages/admin/index.php'
);

// OPAC menu (public)
if (Schema::hasTable('plugin_table')) {
    $data = DB::getInstance()->query('SELECT name FROM plugin_table WHERE status=1')->fetchObject();
    if ($data) {
        $plugin->registerMenu('opac', $data->name, __DIR__ . '/pages/opac/index.php');
    }
}
```

---

## Helper Functions

### SLiMS-Specific Helpers

```php
<?php
use SLiMS\Url;
use SLiMS\DB;

/**
 * Generate plugin URL with query params
 * SLiMS plugin URL: index.php?mod=xxx&id=plugin&section=yyy
 */
if (!function_exists('pluginUrl')) {
    function pluginUrl(array $data = [], bool $reset = false): string
    {
        if ($reset) {
            return Url::getSelf(fn($s) => "$s?mod={$_GET['mod']}&id={$_GET['id']}");
        }
        return Url::getSelf(fn($s) => $s . '?' . http_build_query(array_merge($_GET, $data)));
    }
}

/**
 * Load action file from action/ folder
 * SLiMS pattern: Separate business logic from presentation
 */
if (!function_exists('action')) {
    function action(string $name, array $vars = []): void
    {
        global $sysconf;
        extract($vars);

        $name = preg_replace('/[^a-z0-9_-]/i', '', $name);
        $trace = debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS, 1);
        $path = pathinfo($trace[0]['file'])['dirname'] . DS . 'action' . DS . "$name.php";

        if (!file_exists($path)) throw new Exception("Action not found", 404);
        include $path;
    }
}

/**
 * Get active data (common pattern in SLiMS plugins)
 */
if (!function_exists('getActiveData')) {
    function getActiveData(string $table): ?object
    {
        $q = DB::getInstance()->prepare("SELECT * FROM {$table} WHERE status=1 LIMIT 1");
        $q->execute();
        return $q->rowCount() ? $q->fetchObject() : null;
    }
}
```

---

## Database Migration

### Migration File Structure

```php
<?php
// migration/1_CreateTable.php

use SLiMS\Migration\Migration;
use SLiMS\DB;

class CreateTable extends Migration
{
    public function up()
    {
        if ($this->schema->hasTable('plugin_table')) return;

        $this->schema->create('plugin_table', function($table) {
            $table->increments('id');
            $table->string('name', 100);
            $table->text('description')->nullable();
            $table->enum('status', ['0', '1'])->default('0');
            $table->timestamps(); // created_at, updated_at

            $table->index('status');
        });

        // Insert default data
        DB::getInstance()->query("INSERT INTO plugin_table (name, status) VALUES ('Default', '1')");
    }

    public function down()
    {
        $this->schema->dropIfExists('plugin_table');
    }
}
```

### Schema Builder Methods

```php
// Column types
$table->increments('id')              // INT AUTO_INCREMENT PRIMARY
$table->string('name', 100)           // VARCHAR(100)
$table->text('desc')->nullable()      // TEXT NULL
$table->integer('count')              // INT
$table->enum('status', ['0','1'])     // ENUM
$table->timestamps()                  // created_at, updated_at
$table->softDeletes()                 // deleted_at

// Indexes
$table->index('column')               // INDEX
$table->unique('email')               // UNIQUE
$table->primary('id')                 // PRIMARY KEY

// Check existence
$this->schema->hasTable('table_name')
$this->schema->hasColumn('table', 'column')
```

---

## Pages & Routing

### Router Pattern

```php
<?php
// pages/admin/index.php

defined('INDEX_AUTH') OR die('Direct access not allowed!');

if (!$can_write) die('Access denied');

require_once __DIR__ . '/../../helper.php';

$section = $_GET['section'] ?? 'list';

// Handle POST action
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    try {
        action($_POST['action'], ['can_write' => $can_write]);
    } catch (Exception $e) {
        toastr($e->getMessage())->error();
    }
    exit;
}

// Route to view
switch ($section) {
    case 'list': include __DIR__ . '/list.inc.php'; break;
    case 'add': include __DIR__ . '/add.inc.php'; break;
    case 'edit': include __DIR__ . '/edit.inc.php'; break;
    default: die('Page not found');
}
```

### List View with DataTable

```php
<?php
// list.inc.php
$data = DB::getInstance()->query('SELECT * FROM plugin_table')->fetchAll(PDO::FETCH_OBJ);
?>

<a href="<?= pluginUrl(['section' => 'add']) ?>" class="btn btn-primary">Add</a>

<table id="dataTable" class="table">
    <thead>
        <tr><th>Name</th><th>Status</th><th>Action</th></tr>
    </thead>
    <tbody>
        <?php foreach ($data as $row): ?>
        <tr>
            <td><?= htmlspecialchars($row->name) ?></td>
            <td><?= $row->status == 1 ? 'Active' : 'Inactive' ?></td>
            <td>
                <a href="<?= pluginUrl(['section' => 'edit', 'id' => $row->id]) ?>">Edit</a>
            </td>
        </tr>
        <?php endforeach; ?>
    </tbody>
</table>

<script>
$('#dataTable').DataTable({
    "language": {"url": "<?= SWB ?>js/jquery.dataTables-Indonesian.json"}
});
</script>
```

---

## Action Handlers

### Save Action

```php
<?php
// pages/admin/action/save.php

defined('INDEX_AUTH') OR die();

if (!$can_write) die('Access denied');

try {
    $name = trim($_POST['name'] ?? '');
    $status = (int)($_POST['status'] ?? 0);

    if (empty($name)) throw new Exception('Name required');

    // Check duplicate
    $check = DB::getInstance()->prepare("SELECT id FROM plugin_table WHERE name=?");
    $check->execute([$name]);
    if ($check->rowCount() > 0) throw new Exception('Name exists');

    // Insert
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_table SET name=?, status=?, created_at=NOW()
    ");
    $stmt->execute([$name, $status]);

    toastr('Saved!')->success();
    header('Location: ' . pluginUrl(['section' => 'list']));

} catch (Exception $e) {
    toastr($e->getMessage())->error();
    header('Location: ' . pluginUrl(['section' => 'add']));
}
exit;
```

---

## Plugin Hooks - COMPLETE LIST

### Hook Categories

#### 1. SYSTEM HOOKS

| Hook Constant | Triggered When | Use Case |
|--------------|----------------|----------|
| `DATABASE_VERSION` | Database version check | Custom DB migration handler |
| `ADMIN_SESSION_AFTER_START` | Admin session dimulai | Log admin login, set custom session |
| `CONTENT_BEFORE_LOAD` | Sebelum content dimuat | Inject custom content, modify data |
| `CONTENT_AFTER_LOAD` | Setelah content dimuat | Post-process content, analytics |
| `MODULE_MAIN_MENU_INIT` | Menu modul di-initialize | Custom menu modification |

#### 2. BIBLIOGRAPHY HOOKS (Katalog/Koleksi)

| Hook Constant | Data Parameter | Use Case |
|--------------|----------------|----------|
| `BIBLIOGRAPHY_INIT` | - | Override halaman bibliography |
| `BIBLIOGRAPHY_BEFORE_SAVE` | `$data` (biblio data) | Validasi sebelum simpan koleksi baru |
| `BIBLIOGRAPHY_AFTER_SAVE` | `$data` (biblio data) | Log, notifikasi, sync ke external |
| `BIBLIOGRAPHY_BEFORE_UPDATE` | `$data` (biblio data) | Validasi sebelum update koleksi |
| `BIBLIOGRAPHY_AFTER_UPDATE` | `$data` (biblio data) | Log perubahan, update cache |
| `BIBLIOGRAPHY_BEFORE_DELETE` | `$biblio_id` | Prevent delete, backup data |
| `BIBLIOGRAPHY_AFTER_DELETE` | `$biblio_id` | Cleanup related data |
| `BIBLIOGRAPHY_CUSTOM_FIELD_DATA` | `$biblio_id` | Inject custom field data |
| `BIBLIOGRAPHY_CUSTOM_FIELD_FORM` | - | Inject custom field form |
| `BIBLIOGRAPHY_BEFORE_DATAGRID_OUTPUT` | `$datagrid_data` | Modify datagrid sebelum output |

#### 3. MEMBERSHIP HOOKS (Keanggotaan)

| Hook Constant | Data Parameter | Use Case |
|--------------|----------------|----------|
| `MEMBERSHIP_INIT` | - | Override halaman membership |
| `MEMBERSHIP_BEFORE_SAVE` | `$data` (member data) | Validasi member baru, cek duplikat |
| `MEMBERSHIP_AFTER_SAVE` | `$data` (member data) | Kirim email welcome, generate kartu |
| `MEMBERSHIP_BEFORE_UPDATE` | `$data` (member data) | Validasi update, backup data lama |
| `MEMBERSHIP_AFTER_UPDATE` | `$data` (member data) | Log perubahan, notifikasi |

#### 4. CIRCULATION HOOKS (Sirkulasi/Peminjaman)

| Hook Constant | Data Parameter | Use Case |
|--------------|----------------|----------|
| `CIRCULATION_BEFORE_CHECKOUT` | `$loan_data` | Validasi peminjaman, cek quota |
| `CIRCULATION_AFTER_CHECKOUT` | `$loan_data` | Kirim notifikasi, log transaksi |
| `CIRCULATION_BEFORE_CHECKIN` | `$loan_data` | Validasi pengembalian, hitung denda |
| `CIRCULATION_AFTER_CHECKIN` | `$loan_data` | Update statistik, notifikasi |
| `CIRCULATION_AFTER_SUCCESSFUL_TRANSACTION` | `$transaction_data` | Log semua transaksi sukses |

#### 5. NOTIFICATION HOOKS

| Hook Constant | Data Parameter | Use Case |
|--------------|----------------|----------|
| `OVERDUE_NOTICE_INIT` | `$overdue_data` | Custom overdue notification |
| `DUEDATE_NOTICE_INIT` | `$duedate_data` | Custom duedate reminder |

#### 6. OAI-PMH HOOKS

| Hook Constant | Data Parameter | Use Case |
|--------------|----------------|----------|
| `OAI2_INIT` | - | Modify OAI-PMH response |

---

### Hook Usage Examples

#### Basic Hook Registration

```php
// Listen to member registration
$plugin->register(Plugins::MEMBERSHIP_AFTER_SAVE, function($data) {
    // $data contains: member_id, member_name, member_email, etc
    error_log("New member: {$data['member_name']} ({$data['member_id']})");

    // Custom action: Save to custom table
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_member_log 
        SET member_id=?, action='register', created_at=NOW()
    ");
    $stmt->execute([$data['member_id']]);
});
```

#### Prevent Operation with Exception

```php
// Prevent update if condition not met
$plugin->register(Plugins::MEMBERSHIP_BEFORE_UPDATE, function($data) {
    if ($data['member_id'] == 1) {
        throw new Exception('Cannot edit admin user!');
    }

    // Check duplicate email
    $check = DB::getInstance()->prepare("
        SELECT member_id FROM member 
        WHERE member_email=? AND member_id!=?
    ");
    $check->execute([$data['member_email'], $data['member_id']]);

    if ($check->rowCount() > 0) {
        throw new Exception('Email already used!');
    }
});
```

#### Bibliography Hooks Example

```php
// Auto-generate call number before save
$plugin->register(Plugins::BIBLIOGRAPHY_BEFORE_SAVE, function($data) {
    if (empty($data['call_number'])) {
        // Generate call number based on classification
        $data['call_number'] = generateCallNumber($data['classification']);
    }
    return $data;
});

// Sync to external system after save
$plugin->register(Plugins::BIBLIOGRAPHY_AFTER_SAVE, function($data) {
    // Send to external catalog
    syncToExternalCatalog($data['biblio_id']);

    // Update search index
    updateSearchIndex($data['biblio_id']);
});

// Add custom field to bibliography form
$plugin->register(Plugins::BIBLIOGRAPHY_CUSTOM_FIELD_FORM, function() {
    echo '<div class="form-group">';
    echo '<label>Custom Field</label>';
    echo '<input type="text" name="custom_field" class="form-control">';
    echo '</div>';
});
```

#### Circulation Hooks Example

```php
// Check member quota before checkout
$plugin->register(Plugins::CIRCULATION_BEFORE_CHECKOUT, function($loan) {
    $member_id = $loan['member_id'];

    // Get current loans count
    $stmt = DB::getInstance()->prepare("
        SELECT COUNT(*) as total FROM loan 
        WHERE member_id=? AND is_return=0
    ");
    $stmt->execute([$member_id]);
    $current = $stmt->fetchObject();

    // Check quota (max 5 books)
    if ($current->total >= 5) {
        throw new Exception('Member has reached maximum loan quota (5 books)');
    }
});

// Send WhatsApp notification after checkout
$plugin->register(Plugins::CIRCULATION_AFTER_CHECKOUT, function($loan) {
    $member = getMemberData($loan['member_id']);
    $book = getBookData($loan['item_code']);

    sendWhatsAppNotification($member['phone'], 
        "Peminjaman berhasil: {$book['title']}. " .
        "Pengembalian: {$loan['due_date']}"
    );
});

// Calculate fine before checkin
$plugin->register(Plugins::CIRCULATION_BEFORE_CHECKIN, function($loan) {
    $overdue_days = calculateOverdueDays($loan['due_date']);

    if ($overdue_days > 0) {
        $fine = $overdue_days * 1000; // Rp 1.000 per hari
        $loan['fine_amount'] = $fine;

        toastr("Denda keterlambatan: Rp " . number_format($fine))->warning();
    }

    return $loan;
});
```

#### Notification Hooks Example

```php
// Custom overdue notice via email
$plugin->register(Plugins::OVERDUE_NOTICE_INIT, function($overdue) {
    foreach ($overdue as $loan) {
        $member = getMemberData($loan['member_id']);

        // Send custom email
        sendEmail($member['email'], 
            'Pengingat Keterlambatan',
            "Buku {$loan['title']} sudah terlambat {$loan['overdue_days']} hari"
        );
    }
});

// Send SMS reminder for due date
$plugin->register(Plugins::DUEDATE_NOTICE_INIT, function($duedate) {
    foreach ($duedate as $loan) {
        $member = getMemberData($loan['member_id']);

        sendSMS($member['phone'],
            "Reminder: Buku {$loan['title']} jatuh tempo besok"
        );
    }
});
```

#### Override Page Hook (DANGEROUS!)

```php
// Override entire membership page
$plugin->register(Plugins::MEMBERSHIP_INIT, function() {
    global $can_read, $can_write, $sysconf, $dbs;

    // Load custom membership page
    include __DIR__ . '/pages/customs/membership/index.php';

    // MUST exit to prevent default page
    exit;
});

// Override bibliography page
$plugin->register(Plugins::BIBLIOGRAPHY_INIT, function() {
    global $can_read, $can_write, $sysconf, $dbs;

    include __DIR__ . '/pages/customs/bibliography/index.php';
    exit;
});
```

#### Session Hook Example

```php
// Set custom session data after admin login
$plugin->register(Plugins::ADMIN_SESSION_AFTER_START, function($session) {
    // Add custom session variable
    $_SESSION['plugin_data'] = 'custom_value';
    $_SESSION['login_time'] = time();

    // Log admin login
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_login_log 
        SET user_id=?, login_at=NOW(), ip=?
    ");
    $stmt->execute([$_SESSION['uid'], $_SERVER['REMOTE_ADDR']]);
});
```

#### Custom Hooks (User-Defined)

```php
// Define custom hooks in plugin
$plugin->register('my_plugin_before_process', function($data) {
    // Other plugins can listen to this
    error_log("Custom hook triggered");
});

$plugin->register('my_plugin_after_process', function($data) {
    // Process completed
});

// Trigger custom hook from action
// In action/save.php:
Plugins::getInstance()->execute('my_plugin_before_process', [
    'data' => $formData,
    'user_id' => $_SESSION['uid']
]);

// Your processing logic here...

Plugins::getInstance()->execute('my_plugin_after_process', [
    'id' => $insertedId,
    'success' => true
]);
```

---

### Hook Data Structure Reference

#### MEMBERSHIP Hook Data Structure
```php
$data = [
    'member_id' => '12345',
    'member_name' => 'John Doe',
    'member_email' => 'john@example.com',
    'gender' => '1',
    'member_type_id' => '2',
    'member_address' => 'Street address',
    'postal_code' => '12345',
    'member_phone' => '08123456789',
    'pin' => 'hashed_pin',
    'member_image' => 'photo.jpg',
    'member_since_date' => '2024-01-01',
    'register_date' => '2024-01-01',
    'expire_date' => '2025-01-01',
    'is_pending' => '0',
    'input_date' => '2024-01-01 10:00:00',
    'last_update' => '2024-01-01 10:00:00'
];
```

#### BIBLIOGRAPHY Hook Data Structure
```php
$data = [
    'biblio_id' => '123',
    'title' => 'Book Title',
    'sor' => 'Statement of Responsibility',
    'edition' => '1st Edition',
    'isbn_issn' => '978-1234567890',
    'publisher_id' => '5',
    'publish_year' => '2024',
    'collation' => 'x, 200 p.',
    'series_title' => 'Series Name',
    'call_number' => '001.234 ABC',
    'language_id' => 'en',
    'source' => 'Purchase',
    'publish_place_id' => '1',
    'classification' => 'DDC',
    'notes' => 'Notes',
    'image' => 'cover.jpg',
    'file_att' => 'document.pdf',
    'opac_hide' => '0',
    'promoted' => '0',
    'labels' => 'label1,label2',
    'input_date' => '2024-01-01 10:00:00',
    'last_update' => '2024-01-01 10:00:00'
];
```

#### CIRCULATION Hook Data Structure
```php
$loan_data = [
    'loan_id' => '456',
    'item_code' => 'B001234',
    'member_id' => 'M12345',
    'loan_date' => '2024-01-01',
    'due_date' => '2024-01-15',
    'return_date' => null,
    'renewed' => '0',
    'loan_rules_id' => '1',
    'is_lent' => '1',
    'is_return' => '0',
    'fine_amount' => '0',
    'input_date' => '2024-01-01 10:00:00',
    'last_update' => '2024-01-01 10:00:00'
];
```

---

## Security

### Essential Security Practices

```php
// 1. Input sanitization
$name = htmlspecialchars(strip_tags(trim($_POST['name'])), ENT_QUOTES, 'UTF-8');

// 2. SQL Injection prevention - ALWAYS use prepared statements
$stmt = DB::getInstance()->prepare("SELECT * FROM table WHERE id=?");
$stmt->execute([$id]);

// 3. CSRF protection - use SLiMS built-in
// In form: <?= getHiddenInput() ?>
// Validation handled by SLiMS

// 4. Authorization check
if (!$can_write) die('Access denied');
if (!isset($_SESSION['uid'])) die('Login required');

// 5. File upload validation
if ($_FILES['file']['error'] !== UPLOAD_ERR_OK) throw new Exception('Upload error');
if ($_FILES['file']['size'] > 2*1024*1024) throw new Exception('Max 2MB');
$ext = strtolower(pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION));
if (!in_array($ext, ['jpg', 'png', 'pdf'])) throw new Exception('Invalid type');

// 6. Whitelist validation
$allowedSections = ['list', 'add', 'edit', 'delete'];
$section = $_GET['section'] ?? 'list';
if (!in_array($section, $allowedSections)) die('Invalid section');
```

---

## Quick Reference

### All Available Hooks (Alphabetical)

```
Plugins::ADMIN_SESSION_AFTER_START
Plugins::BIBLIOGRAPHY_AFTER_DELETE
Plugins::BIBLIOGRAPHY_AFTER_SAVE
Plugins::BIBLIOGRAPHY_AFTER_UPDATE
Plugins::BIBLIOGRAPHY_BEFORE_DATAGRID_OUTPUT
Plugins::BIBLIOGRAPHY_BEFORE_DELETE
Plugins::BIBLIOGRAPHY_BEFORE_SAVE
Plugins::BIBLIOGRAPHY_BEFORE_UPDATE
Plugins::BIBLIOGRAPHY_CUSTOM_FIELD_DATA
Plugins::BIBLIOGRAPHY_CUSTOM_FIELD_FORM
Plugins::BIBLIOGRAPHY_INIT
Plugins::CIRCULATION_AFTER_CHECKIN
Plugins::CIRCULATION_AFTER_CHECKOUT
Plugins::CIRCULATION_AFTER_SUCCESSFUL_TRANSACTION
Plugins::CIRCULATION_BEFORE_CHECKIN
Plugins::CIRCULATION_BEFORE_CHECKOUT
Plugins::CONTENT_AFTER_LOAD
Plugins::CONTENT_BEFORE_LOAD
Plugins::DATABASE_VERSION
Plugins::DUEDATE_NOTICE_INIT
Plugins::MEMBERSHIP_AFTER_SAVE
Plugins::MEMBERSHIP_AFTER_UPDATE
Plugins::MEMBERSHIP_BEFORE_SAVE
Plugins::MEMBERSHIP_BEFORE_UPDATE
Plugins::MEMBERSHIP_INIT
Plugins::MODULE_MAIN_MENU_INIT
Plugins::OAI2_INIT
Plugins::OVERDUE_NOTICE_INIT
```

### SLiMS Global Variables
```php
$dbs           // Database connection
$sysconf       // System configuration array
$can_read      // Read permission (bool)
$can_write     // Write permission (bool)
$_SESSION['uid']      // User ID
$_SESSION['username'] // Username
$_SESSION['realname'] // Real name
```

### SLiMS Constants
```php
DS             // Directory separator (/ or \)
SWB            // SLiMS web base URL
INDEX_AUTH     // Auth check constant
SB             // SLiMS base directory path
```

### Common Patterns

```php
// Check table exists before query
if (Schema::hasTable('table')) { /* query */ }

// Get base URL
Url::getSlimsBaseUri('path/to/file')

// Generate plugin asset URL
PLUGIN_WEB . 'static/css/style.css'

// Include plugin file
PLUGIN_DIR . DS . 'helper.php'

// SLiMS toastr notification
toastr('Message')->success|error|warning|info();

// Flash message
flash('key', 'message');
flash()->includes('key') // Check if exists

// Get config value
$value = $sysconf['key'];

// Database operations
DB::getInstance()->query($sql);
DB::getInstance()->prepare($sql);
DB::getInstance()->lastInsertId();
```

### Hook Registration Patterns

```php
// Basic hook
$plugin->register(Plugins::HOOK_NAME, function($data) {
    // Your logic
});

// Hook with priority (lower = earlier)
$plugin->register(Plugins::HOOK_NAME, function($data) {
    // Your logic
}, 10); // Priority 10

// Hook that modifies data
$plugin->register(Plugins::HOOK_NAME, function($data) {
    $data['new_field'] = 'value';
    return $data; // Return modified data
});

// Hook that prevents operation
$plugin->register(Plugins::HOOK_NAME, function($data) {
    if ($condition) {
        throw new Exception('Operation prevented!');
    }
});

// Hook with multiple parameters
$plugin->register(Plugins::HOOK_NAME, function($data, $context) {
    // Use $data and $context
});
```

---

## Complete Minimal Plugin Example

```php
<?php
/**
 * Plugin Name: Simple Counter
 * Version: 1.0.0
 * Description: Count member registrations
 */

use SLiMS\DB;
use SLiMS\Plugins;

define('COUNTER_DIR', __DIR__);

$plugin = Plugins::getInstance();

// Register menu
$plugin->registerMenu('system', 'Counter', __DIR__ . '/pages/index.php');

// Hook: Count member registrations
$plugin->register(Plugins::MEMBERSHIP_AFTER_SAVE, function($data) {
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_counter 
        SET event='member_register', 
            member_id=?, 
            created_at=NOW()
    ");
    $stmt->execute([$data['member_id']]);
});

// Hook: Log bibliography additions
$plugin->register(Plugins::BIBLIOGRAPHY_AFTER_SAVE, function($data) {
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_counter 
        SET event='book_added', 
            biblio_id=?, 
            created_at=NOW()
    ");
    $stmt->execute([$data['biblio_id']]);
});

// Hook: Track circulation
$plugin->register(Plugins::CIRCULATION_AFTER_CHECKOUT, function($loan) {
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_counter 
        SET event='book_checkout', 
            loan_id=?, 
            created_at=NOW()
    ");
    $stmt->execute([$loan['loan_id']]);
});
```

**Migration:**
```php
<?php
use SLiMS\Migration\Migration;

class CreateCounterTable extends Migration {
    public function up() {
        $this->schema->create('plugin_counter', function($t) {
            $t->increments('id');
            $t->string('event', 50);
            $t->integer('member_id')->nullable();
            $t->integer('biblio_id')->nullable();
            $t->integer('loan_id')->nullable();
            $t->timestamp('created_at');

            $t->index('event');
            $t->index('created_at');
        });
    }

    public function down() {
        $this->schema->dropIfExists('plugin_counter');
    }
}
```

---

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Menu tidak muncul | Cek nama file = nama folder, aktifkan plugin |
| Migration error | Cek tabel belum ada, gunakan `hasTable()` |
| CSRF token invalid | Gunakan `<?= getHiddenInput() ?>` di form |
| Permission denied | Cek `$can_write` atau `$can_read` |
| Hook tidak jalan | Pastikan constant name benar (case-sensitive) |
| URL tidak generate | Pastikan `$_GET['mod']` dan `$_GET['id']` tersedia |
| Hook data kosong | Cek apakah hook dipanggil di tempat yang benar |
| Database error | Pastikan migration sudah dijalankan |
| Plugin tidak aktif | Aktifkan di System > Plugins |

---

## Resources

- **SLiMS API Documentation**: https://slims.web.id/api/SLiMS/Plugins.html
- **SLiMS Official Docs**: https://github.com/slims/SLiMS-9-Documentation
- **GitHub Repository**: https://github.com/slims/slims9_bulian


---

**Version**: 2.1 Complete Hooks Edition  
**Updated**: February 2026  
**Total Hooks**: 28 official hooks + unlimited custom hooks
