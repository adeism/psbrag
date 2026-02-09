## Table of Contents
- [Plugin Structure](#plugin-structure)
- [Main Plugin File](#main-plugin-file)
- [Helper Functions](#helper-functions)
- [Database Migration](#database-migration)
- [Pages & Routing](#pages--routing)
- [Action Handlers](#action-handlers)
- [Plugin Hooks](#plugin-hooks)
- [Security](#security)

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

### Register Hooks

```php
// After member saved
$plugin->register(Plugins::MEMBERSHIP_AFTER_SAVE, function($data) {
    // $data contains: member_id, member_name, member_email, etc
    error_log("New member: " . $data['member_name']);
});

// Before member update (can throw Exception to prevent)
$plugin->register(Plugins::MEMBERSHIP_BEFORE_UPDATE, function($data) {
    if (empty($data['member_email'])) {
        throw new Exception('Email required!');
    }
});

// Custom hooks
$plugin->register('plugin_custom_event', function($data) {
    // Your logic
});

// Trigger custom hook
Plugins::getInstance()->execute('plugin_custom_event', ['key' => 'value']);
```

**Available Hooks:**
- `MEMBERSHIP_INIT|BEFORE_SAVE|AFTER_SAVE|BEFORE_UPDATE|AFTER_UPDATE`
- `BIBLIOGRAPHY_INIT|BEFORE_SAVE|AFTER_SAVE|BEFORE_UPDATE|AFTER_UPDATE`
- `CIRCULATION_BEFORE_CHECKOUT|AFTER_CHECKOUT|BEFORE_CHECKIN|AFTER_CHECKIN`

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
        $path = pathinfo($trace['file'])['dirname'] . DS . 'action' . DS . "$name.php";
        
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

/**
 * CSRF helpers (use SLiMS built-in)
 */
// Generate: <?= getHiddenInput() ?> in form
// Validate: Use SLiMS built-in validation
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

### Delete Action

```php
<?php
// action/delete.php

defined('INDEX_AUTH') OR die();

try {
    $id = (int)($_POST['id'] ?? 0);
    if ($id <= 0) throw new Exception('Invalid ID');
    
    $stmt = DB::getInstance()->prepare("DELETE FROM plugin_table WHERE id=?");
    $stmt->execute([$id]);
    
    echo json_encode(['success' => true]);
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
```

---

## Plugin Hooks

### Hook Usage Examples

```php
// Listen to SLiMS events
$plugin->register(Plugins::MEMBERSHIP_AFTER_SAVE, function($data) {
    // Log new member
    $stmt = DB::getInstance()->prepare("
        INSERT INTO plugin_log SET member_id=?, action='register', created_at=NOW()
    ");
    $stmt->execute([$data['member_id']]);
});

// Prevent operation with Exception
$plugin->register(Plugins::MEMBERSHIP_BEFORE_UPDATE, function($data) {
    if ($data['member_id'] == 1) {
        throw new Exception('Cannot edit admin user!');
    }
});

// Override page (DANGEROUS - use carefully)
$plugin->register(Plugins::MEMBERSHIP_INIT, function() {
    global $can_read, $can_write, $sysconf, $dbs;
    include __DIR__ . '/pages/customs/membership/index.php';
    exit; // MUST exit to prevent default page
});
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

### SLiMS Global Variables
```php
$dbs           // Database connection
$sysconf       // System configuration
$can_read      // Read permission
$can_write     // Write permission
$_SESSION['uid']      // User ID
$_SESSION['username'] // Username
```

### SLiMS Constants
```php
DS             // Directory separator (/ or \)
SWB            // SLiMS web base URL
INDEX_AUTH     // Auth check constant
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
```

---

## Complete Minimal Plugin Example

```php
<?php
/**
 * Plugin Name: Simple Counter
 * Version: 1.0.0
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
        INSERT INTO plugin_counter SET event='member_register', created_at=NOW()
    ");
    $stmt->execute();
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
            $t->timestamp('created_at');
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
