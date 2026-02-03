# PSB RAG - SLiMS 9 Bulian Knowledge Base

This repository contains essential documentation and database schemas for building AI chatbots or RAG (Retrieval-Augmented Generation) systems that interact with **SLiMS 9 Bulian** (Senayan Library Management System). The data is specifically configured for **Pusat Sumber Belajar FEB UI** (FEB UI Learning Resource Center) implementation.

## 📚 Repository Contents

### 1. `SLIMS_ADMIN_EXISTING_FEATURES.md`
**Purpose:** Comprehensive mapping of all existing admin modules and features in SLiMS 9 Bulian.

**What it contains:**
- Complete inventory of 8 core modules: Bibliography, Circulation, Membership, Master File, Reporting, Serial Control, Stock Take, and System
- File-level documentation showing which PHP files handle which features
- Descriptions of CRUD operations, import/export capabilities, and utility functions
- Custom report listings in the `reporting/customs` directory
- Helper files (AJAX handlers, popups, iframes, libraries)

**Use for chatbots:**
- Understanding what features SLiMS already provides
- Identifying correct module paths for feature requests
- Mapping user queries to existing functionality
- Preventing suggestions to build features that already exist

**Key insights:**
- Most modules follow pattern: `index.php` → router → action files
- Features are grouped by functional domains
- Many files are helpers (AJAX, popup, libs) not direct menu items
- Menu visibility requires both file existence + permission configuration

### 2. `custom-tables-and-mst-data-psb.sql`
**Purpose:** Custom database extensions and master data specific to PSB FEB UI implementation.

**What it contains:**

#### Custom Tables (Plugin/Extension):
- **`biblio_custom`** - One-to-one extension for bibliography table
- **`member_custom`** - Extended member data including:
  - Telegram integration (`telegram_id`, `telegram_username`)
  - Self-registration tracking (`is_self_regist`)
  - Graduation status (`is_bebas_pustaka`, `cf_03ddf` for "Lulus")
  - Locker usage (`cf_cc26d`)
  - Study program relationship (`prodi_id`)
  - Email verification (`verified_at`, `verify_token`)
- **`rooms`** - Discussion room booking system with:
  - Room capacity and facilities
  - Location tracking (Lt. 3, Basement)
  - Status management (available, in use, closed)
- **`room_report`** - Room booking transaction records
- **`mst_prodi`** - Academic program master data (S1, S2, S3, Profesi)

#### Master Data Configurations:
- **`mst_coll_type`** - Collection types (17 types including: ADB Repository, B. Wajib, B. Penunjang, Skripsi, Tesis, Disertasi, etc.)
- **`mst_location`** - Physical locations (8 locations: PSB floors, CELEB FEB UI, ADB Repository)
- **`mst_member_type`** - 5 member types with different privileges:
  - Mahasiswa (Students): 2 books, 7 days
  - Dosen (Lecturers): 5 books, 185 days
  - Umum/Alumni: 5 books, read-only
  - Tendik (Staff): 5 books, 185 days
  - Asdos (Teaching Assistants): 2 books, 7 days
- **`mst_loan_rules`** - Complex loan rules matrix combining member types + collection types
- **`mst_item_status`** - 5 item statuses (BD, MIS, NL, R, sc)
- **`mst_custom_field`** - Dynamic custom fields for member table
- **`setting`** - System-wide configurations (212 settings)

**Use for chatbots:**
- Understanding database schema for query generation
- Knowing available collection types and locations
- Calculating loan eligibility based on member type + collection type
- Room booking system queries
- Custom field structure for member data

### 3. `db-slims-972-complete.sql`
**Purpose:** Complete database dump of SLiMS 9.7.2 base schema.

**What it contains:**
- All 69+ core SLiMS tables
- Base structure without custom extensions
- Default data for a fresh SLiMS installation
- Table relationships and foreign keys
- Indexes and constraints

**Use for chatbots:**
- Understanding core SLiMS database architecture
- Reference for standard table structures
- Baseline for comparing with custom implementations
- Schema for SQL query generation

**Key tables to know:**
- `biblio` - Main bibliography/catalog table
- `item` - Physical copies/exemplars
- `member` - Library members
- `loan` - Circulation transactions
- `mst_*` - Master data tables
- `setting` - System configuration
- `user` - Admin/staff users
- `reserve` - Hold/reservation queue
- `fines` - Overdue fine records

### 4. `update 100 kode sql dengan kategori.md`
**Purpose:** Collection of 100 categorized SQL queries for common operations.

**What it contains:**
- Pre-written SQL queries organized by category
- Common reporting queries
- Data manipulation examples
- Statistics and analytics queries
- Maintenance and cleanup scripts

**Use for chatbots:**
- SQL query templates for common requests
- Examples of correct join patterns
- Reference for complex aggregations
- Query optimization patterns

**Likely categories:**
- Bibliography queries (search, list, statistics)
- Circulation queries (loans, returns, overdues)
- Member queries (registration, status, fines)
- Reporting queries (usage statistics, popular titles)
- System maintenance queries

---

## 🏗️ SLiMS 9 Bulian Architecture Overview

SLiMS (Senayan Library Management System) is an open-source library management system built with PHP using modular MVC-like architecture.

### System Entry Points

**Main Entry Points:**
- [`index.php`](https://github.com/slims/slims9_bulian/blob/main/index.php) - Entry point for OPAC (Online Public Access Catalog)
- [`admin/index.php`](https://github.com/slims/slims9_bulian/blob/main/admin/index.php) - Entry point for administration area
- [`api/`](https://github.com/slims/slims9_bulian/tree/main/api) - REST API endpoints

**Global Configuration:**
- [`sysconfig.inc.php`](https://github.com/slims/slims9_bulian/blob/main/sysconfig.inc.php) - Main system configuration file controlling all global parameters
- [`config/database.php`](https://github.com/slims/slims9_bulian/tree/main/config) - Database connection configuration

### Important Directory Structure

#### Library Core (`lib/`)
| File | Purpose |
|------|---------|
| `lib/autoload.php` | Autoloader for SLiMS classes |
| `lib/Opac.php` | Main OPAC class |
| `lib/Plugins.php` | Plugin system management |
| `lib/DB.php` | Database abstraction layer |
| `lib/Connection.php` | Database connection manager |
| `lib/utility.inc.php` | Helper functions and utilities |
| `lib/helper.inc.php` | Additional helper functions |
| `lib/api.inc.php` | API handler |
| `lib/Config.php` | Configuration management |

#### Search & Indexing
| File | Purpose |
|------|---------|
| [`lib/biblio_list.inc.php`](https://github.com/slims/slims9_bulian/blob/main/lib/biblio_list.inc.php) | Bibliography listing |
| `lib/biblio_list_model.inc.php` | Bibliography data model |
| `lib/SearchEngine/` | Search engine abstractions |
| `lib/biblio_list_elasticsearch.inc.php` | Elasticsearch integration |
| `lib/biblio_list_sphinx.inc.php` | Sphinx search integration |

#### Authentication & Security
| File | Purpose |
|------|---------|
| [`lib/admin_logon.inc.php`](https://github.com/slims/slims9_bulian/blob/main/lib/admin_logon.inc.php) | Admin authentication |
| [`lib/member_logon.inc.php`](https://github.com/slims/slims9_bulian/blob/main/lib/member_logon.inc.php) | Member authentication |
| `lib/member_session.inc.php` | Member session management |
| `lib/Auth/` | Authentication providers |
| `lib/Sanitizer.php` | Input sanitization |

#### Admin Modules (`admin/modules/`)
| Module | Purpose |
|--------|---------|
| `admin/modules/bibliography/` | Collection cataloging |
| `admin/modules/circulation/` | Loan circulation |
| `admin/modules/membership/` | Member management |
| `admin/modules/master_file/` | Master data (publishers, locations, etc.) |
| `admin/modules/reporting/` | Reports and statistics |
| `admin/modules/serial_control/` | Serial publication control |
| `admin/modules/stock_take/` | Stock opname/inventory |
| `admin/modules/system/` | System configuration |

#### Modern Architecture (`src/`)
- `src/Slims/Opac/` - Modern OPAC implementation
- Namespace: `SLiMS\`

### System Workflow

#### 1. Bootstrap Process (from `index.php`)
```
index.php
  → require sysconfig.inc.php (global config)
  → $sanitizer->cleanUp() (input sanitization)
  → require member_session.inc.php (member session)
  → new Opac() (OPAC instance)
  → hookBeforeContent() (plugin hooks)
  → handle('p')->orWelcome() (routing)
  → hookAfterContent() (plugin hooks)
  → parseToTemplate() (template rendering)
```

#### 2. System Configuration (`sysconfig.inc.php`)
- Sets system constants (paths, versions, etc.)
- Loads environment config from `config/env.php`
- Initializes database connection via `\SLiMS\DB::getInstance()`
- Loads settings from database via `utility::loadSettings()`
- Initializes plugins via `\SLiMS\Plugins::getInstance()`
- Sets up localization/language via `\SLiMS\Polyglot\Memory`

#### 3. Database Layer
- MySQLi connection through `\SLiMS\DB` class
- Query builder via `\SLiMS\Query` class
- Connection pooling via `\SLiMS\Connection`

#### 4. Plugin System
- Path: [`plugins/`](https://github.com/slims/slims9_bulian/tree/main/plugins)
- Available hooks: `CONTENT_BEFORE_LOAD`, `CONTENT_AFTER_LOAD`
- Plugin loader: `lib/Plugins.php`

### Critical Files for Chatbot Understanding

#### Understanding Data Structure:
1. `admin/modules/bibliography/biblio.inc.php` - Bibliography data model
2. `admin/modules/membership/member.inc.php` - Member data model
3. `admin/modules/circulation/loan.inc.php` - Loan data model
4. `lib/contents/` - Content page handlers

#### Understanding Business Logic:
5. [`lib/circulation_api.inc.php`](https://github.com/slims/slims9_bulian/blob/main/lib/circulation_api.inc.php) - Circulation API
6. [`lib/member_api.inc.php`](https://github.com/slims/slims9_bulian/blob/main/lib/member_api.inc.php) - Member API
7. `lib/detail.inc.php` - Detail record handler
8. `lib/comment.inc.php` - Comment system

#### Understanding Templates & UI:
9. [`template/`](https://github.com/slims/slims9_bulian/tree/main/template) - OPAC templates
10. [`admin/admin_template/`](https://github.com/slims/slims9_bulian/tree/main/admin/admin_template) - Admin area templates

#### Understanding Routing:
11. [`lib/router.inc.php`](https://github.com/slims/slims9_bulian/blob/main/lib/router.inc.php) - URL routing
12. `lib/AltoRouter.php` - Modern router implementation

### Technology Stack & Dependencies

#### Core Technologies:
- PHP 8.1+
- MySQL 5.7+ / MariaDB 10.3+
- Composer for dependency management

#### Key Libraries (from `lib/`):
| Library | Purpose |
|---------|---------|
| `PHPMailer/` | Email handling |
| `phpoffice/` | Excel/Office file handling |
| `guzzlehttp/` | HTTP client |
| `nesbot/` (Carbon) | Date/time handling |
| `league/` | Various utilities |
| `phpbarcode/` | Barcode generation |
| `Zend/` | Zend Barcode |

### Core Features Managed

1. **Bibliography Management** - Library collection cataloging
2. **Circulation** - Lending and returning materials
3. **Membership** - Library member management
4. **Master File** - Master data (publishers, authors, locations, etc.)
5. **Serial Control** - Serial publication management
6. **Stock Take** - Collection inventory
7. **Reporting** - Reports and statistics
8. **OPAC** - Online catalog for users

### Development Tips for Chatbots

- **Architecture Pattern:** SLiMS uses legacy PHP mixed with modern namespace patterns
- **Module Structure:** All admin modules follow: `index.php` → router → action files
- **Plugin System:** Allows extending functionality without modifying core
- **Database Schema:** Stored in [`install/`](https://github.com/slims/slims9_bulian/tree/main/install) directory
- **API Documentation:** Available in [`api/`](https://github.com/slims/slims9_bulian/tree/main/api) folder

---

## 🤖 How Chatbots Should Use These Files

### For Understanding SLiMS Features:
1. **First check** `SLIMS_ADMIN_EXISTING_FEATURES.md` to see if feature already exists
2. **Reference** module paths and file names for accurate guidance
3. **Identify** the correct module for user's functional domain
4. **Understand** the bootstrap process and workflow from the architecture overview

### For Database Operations:
1. **Use** `custom-tables-and-mst-data-psb.sql` for PSB-specific schema
2. **Reference** `db-slims-972-complete.sql` for core tables
3. **Check** master data values before generating queries
4. **Validate** foreign key relationships
5. **Understand** database layer abstraction (`\SLiMS\DB`, `\SLiMS\Query`)

### For Query Generation:
1. **Start with** `update 100 kode sql dengan kategori.md` templates
2. **Adapt** queries to custom tables when needed
3. **Consider** loan rules matrix for circulation queries
4. **Include** proper JOINs for related tables
5. **Use** prepared statements through SLiMS DB layer

### For Feature Requests:
1. **Identify** if it's a modification of existing feature or new feature
2. **Know** which module directory to target (`admin/modules/{module}/`)
3. **Understand** permission requirements (module privileges)
4. **Consider** plugin system for custom features
5. **Reference** the correct API files (`lib/*_api.inc.php`)

### For Understanding Code Flow:
1. **Follow** the bootstrap process from `index.php` or `admin/index.php`
2. **Trace** routing through `lib/router.inc.php` or `lib/AltoRouter.php`
3. **Check** plugin hooks: `CONTENT_BEFORE_LOAD`, `CONTENT_AFTER_LOAD`
4. **Understand** template rendering via `parseToTemplate()`
5. **Reference** authentication flow in `lib/admin_logon.inc.php` or `lib/member_logon.inc.php`

## 🎯 Key SLiMS Concepts for AI Understanding

### Architecture Patterns:
- **MVC-like structure:** Controllers in `admin/modules/`, Models in `lib/`, Views in templates
- **Plugin system:** Extend without modifying core via `plugins/` directory
- **Hook system:** CONTENT_BEFORE_LOAD, CONTENT_AFTER_LOAD
- **Bootstrap flow:** `index.php` → `sysconfig.inc.php` → module routing → template rendering
- **Namespace usage:** Modern classes use `SLiMS\` namespace, legacy code uses procedural PHP

### Module Structure:
```
admin/modules/{module_name}/
├── index.php          (main entry, listing)
├── {feature}.php      (specific features)
├── submenu.php        (menu definitions)
├── iframe_*.php       (popup content)
├── pop_*.php          (popup windows)
└── *_lib.inc.php      (libraries)
```

### Database Relationships:
- **Bibliography:** `biblio` (1) → (n) `item` (physical copies)
- **Loan:** `member` (1) → (n) `loan` (n) ← (1) `item`
- **Rules:** `mst_member_type` + `mst_coll_type` → `mst_loan_rules`
- **Custom:** Core tables (1) ← (1) Custom tables (`biblio_custom`, `member_custom`)

### Permission System:
- Users belong to groups (`user_group`)
- Groups have module privileges
- Privileges control access to admin features
- Three permission types: read, write, execute

### Circulation Business Logic:
```
Loan eligibility = 
  mst_loan_rules.WHERE(
    member_type_id = member.member_type_id
    AND coll_type_id = biblio.coll_type_id
  )
```

### Configuration Management:
- **Global config:** `sysconfig.inc.php` (constants and base settings)
- **Environment:** `config/env.php` (development/production mode)
- **Database:** `config/database.php` (connection parameters)
- **Settings table:** Runtime settings stored in database (serialized PHP)
- **Class-based:** `\SLiMS\Config` for modern configuration access

## 📋 Common Chatbot Queries & Reference Guide

### "How do I add a new book?"
→ **Check:** `SLIMS_ADMIN_EXISTING_FEATURES.md` → Bibliography → `bibliography/index.php?action=detail`  
→ **Flow:** Entry via `admin/index.php` → route to `bibliography/index.php` → action handler

### "What member types are available?"
→ **Query:** `custom-tables-and-mst-data-psb.sql` → `mst_member_type` table  
→ **Code reference:** `admin/modules/membership/member_type.php`

### "How many days can a student borrow?"
→ **Query:** `mst_loan_rules` JOIN `mst_member_type` WHERE member_type_name='Mahasiswa'  
→ **Code reference:** `admin/modules/circulation/loan_rules.php`  
→ **API:** `lib/circulation_api.inc.php`

### "Show me all items in location X"
→ **Query:** `item` JOIN `biblio` WHERE location_id='X'  
→ **Reference:** `mst_location` for valid location codes  
→ **Code:** `admin/modules/bibliography/item.php`

### "What are the overdue books?"
→ **Template:** `update 100 kode sql dengan kategori.md` → Circulation category  
→ **Report:** `admin/modules/reporting/customs/overdued_list.php`

### "How to enable room booking?"
→ **Schema:** `rooms` and `room_report` tables already exist  
→ **Need:** Custom plugin or module to expose UI  
→ **Plugin path:** `plugins/{your_room_booking_plugin}/`

### "How does authentication work?"
→ **Admin:** `lib/admin_logon.inc.php` → session via `COOKIES_NAME`  
→ **Member:** `lib/member_logon.inc.php` → session via `MEMBER_COOKIES_NAME`  
→ **Security:** `lib/Sanitizer.php` for input validation

### "How to create a custom report?"
→ **Location:** `admin/modules/reporting/customs/`  
→ **Registry:** `customs_report_list.inc.php` to register new report  
→ **Examples:** Check existing custom reports in same directory

## 🔧 Database Schema Quick Reference

### Core Tables (from base SLiMS):
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `biblio` | Bibliography records | biblio_id, title, author, isbn |
| `item` | Physical items | item_id, item_code, biblio_id, location_id |
| `member` | Library members | member_id, member_name, member_type_id |
| `loan` | Active loans | loan_id, item_id, member_id, loan_date, due_date |
| `setting` | System config | setting_name, setting_value (serialized) |
| `user` | Admin users | user_id, username, user_type, groups |
| `reserve` | Hold requests | reserve_id, item_code, member_id |
| `fines` | Overdue fines | fines_id, member_id, fines_date, debet, credit |

### Custom Tables (PSB-specific):
| Table | Purpose | Key Fields |
|-------|---------|------------|
| `member_custom` | Extended member data | telegram_id, prodi_id, is_bebas_pustaka |
| `mst_prodi` | Study programs | id, jenjang, prodi |
| `rooms` | Discussion rooms | id, room_name, capacity, status, location |
| `room_report` | Room bookings | id, room_id, npm, tanggal_pinjam |

## 🚀 Integration Tips

### For SQL Query Generation:
- Always use prepared statements/parameterized queries
- Check `mst_*` tables for valid foreign key values
- Consider timezone: Database uses 'Asia/Jakarta'
- Character set: utf8mb3/utf8mb4
- Use `\SLiMS\DB` class methods, not direct MySQLi

### For Feature Development:
- Don't modify core files - use plugin system
- Follow naming conventions: `{module}_{feature}.php`
- Register new menus via System → Module privileges
- Use SLiMS classes: `\SLiMS\DB`, `\SLiMS\Config`, `\SLiMS\Plugins`
- Study existing modules in `admin/modules/` for patterns

### For Data Validation:
- Cross-reference with master tables before INSERT
- Respect loan rules matrix
- Check item status before loan operations
- Validate member eligibility (expiry date, fines)
- Use `lib/Sanitizer.php` for input cleaning

### For Plugin Development:
- Place plugins in `plugins/` directory
- Implement required hooks: `CONTENT_BEFORE_LOAD`, `CONTENT_AFTER_LOAD`
- Register via `\SLiMS\Plugins` system
- Don't override core functionality
- Follow plugin naming: `{vendor}_{plugin_name}`

## 📖 Additional Resources

- **SLiMS Official:** https://slims.web.id
- **SLiMS 9 Bulian Repo:** https://github.com/slims/slims9_bulian
- **Base SLiMS Documentation:** Use `SLIMS_ADMIN_EXISTING_FEATURES.md` as navigation map
- **System Requirements:** PHP 7.4 or 8.1+, MySQL 5.7+/MariaDB 10.3+, PHP extensions: GD, gettext, mbstring

## ⚠️ Important Notes

1. **Master Data is Critical:** Always validate against `mst_*` tables before operations
2. **Custom Fields are Dynamic:** Check `mst_custom_field` for current field definitions
3. **Loan Rules are Complex:** Use the matrix, not simple lookups
4. **Setting Table Uses Serialization:** PHP serialize/unserialize format
5. **Room System is Custom:** Not part of standard SLiMS
6. **Legacy + Modern Code:** Mix of procedural PHP and namespaced classes
7. **Plugin Hooks:** Use for extending, not core modification
8. **Bootstrap Sequence Matters:** Follow `index.php` → `sysconfig.inc.php` flow
