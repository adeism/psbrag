# SLiMS Admin — Existing Menus & Features (SLiMS 9 Bulian)

Dokumen ini memetakan menu/fitur yang **sudah ada** di SLiMS admin, berdasarkan struktur modul di `admin/modules/` pada repo SLiMS 9 Bulian. [cite:15]

> Scope: hanya modul berikut: `bibliography`, `circulation`, `membership`, `master_file`, `reporting` (termasuk `reporting/customs`), `serial_control`, `stock_take`, `system`. [cite:15]

---

## 1) Bibliography (`admin/modules/bibliography/`)

Tujuan: manajemen bibliografi/katalog, eksemplar (item/copy), import/export, copy cataloging, dan utilitas cetak/barcode. [cite:2]

### Fitur inti
- Bibliography CRUD & utilities (mis. `index.php`, `biblio.inc.php`, `biblio_utils.inc.php`). [cite:2]
- Item/copy management (mis. `item.php`, `iframe_item_list.php`). [cite:2]
- Relasi bibliografi (mis. `iframe_biblio_rel.php`, `pop_biblio_rel.php`). [cite:2]
- Author & Topic lookup/popup (mis. `iframe_author.php`, `pop_author.php`, `iframe_topic.php`, `pop_topic.php`). [cite:2]
- Attachments (mis. `iframe_attach.php`, `pop_attach.php`). [cite:2]

### Import/Export
- Bibliography import (CSV) (`import.php`, `import_preview.php`). [cite:2]
- Bibliography export (`export.php`). [cite:2]
- Item import/export (`item_import.php`, `item_export.php`). [cite:2]
- MARC import/export (`marcimport.php`, `marcexport.php`). [cite:2]

### Copy cataloging / Interop
- Z39.50 (`z3950.php`). [cite:2]
- Z39.50 + SRU (`z3950sru.php`). [cite:2]
- MARC SRU (`marcsru.php`). [cite:2]
- P2P (peer-to-peer) (`p2p.php`, `pop_p2p.php`). [cite:2]

### Barcode & printing
- Item barcode generator (`item_barcode_generator.php`). [cite:2]
- Print settings & printing outputs (`print_settings.php`, `pop_print_settings.php`, `printed_card.php`, `dl_print.php`). [cite:2]
- Barcode reader helper (`barcode_reader.php`). [cite:2]

### Lain-lain
- Checkout item helper (`checkout_item.php`). [cite:2]
- Scrape image/cover helper (`scrape_image.php`). [cite:2]
- UCS upload/update (Union Catalog System) (`ucs_upload.php`, `ucs_update.php`, `ucs_upload.sh.php`). [cite:2]
- Submenu definition (`submenu.php`). [cite:2]

---

## 2) Circulation (`admin/modules/circulation/`)

Tujuan: transaksi sirkulasi (pinjam/kembali), aturan peminjaman, reservasi, denda, dan laporan/list operasional. [cite:3]

### Fitur inti transaksi
- Circulation main (`index.php`, `circulation_action.php`). [cite:3]
- Library circulation base (`circulation_base_lib.inc.php`). [cite:3]
- AJAX action handler (`ajax_action.php`). [cite:3]
- Barcode reader helper (`barcode_reader.php`). [cite:3]

### Operasional peminjaman
- Loan (form/flow) (`loan.php`). [cite:3]
- Loan list (`loan_list.php`). [cite:3]
- Member loan history (`member_loan_hist.php`). [cite:3]
- Loan history maintenance (`loan_history_maintenance.php`). [cite:3]
- Loan date AJAX change (`loan_date_AJAX_change.php`). [cite:3]
- Item AJAX lookup (`item_AJAX_lookup_handler.php`). [cite:3]

### Reservasi & denda
- Reserve list (`reserve_list.php`). [cite:3]
- Fines list (`fines_list.php`). [cite:3]

### Aturan & output
- Loan rules (`loan_rules.php`). [cite:3]
- Loan receipt popup (`pop_loan_receipt.php`). [cite:3]
- Quick return (`quick_return.php`). [cite:3]
- Submenu definition (`submenu.php`). [cite:3]

---

## 3) Membership (`admin/modules/membership/`)

Tujuan: manajemen anggota, tipe anggota, import/export, generator kartu anggota, dan email notifikasi jatuh tempo/terlambat. [cite:10]

### Fitur inti
- Membership CRUD (`index.php`, `member_base_lib.inc.php`). [cite:10]
- Member type management (`member_type.php`). [cite:10]
- Member custom fields (`member_custom_fields.inc.php`). [cite:10]
- Member AJAX response (`member_AJAX_response.php`). [cite:10]

### Import/Export
- Import members (`import.php`). [cite:10]
- Export members (`export.php`). [cite:10]

### Member card
- Member card generator (`member_card_generator.php`). [cite:10]

### Email notification
- Due date mail (`duedate_mail.php`). [cite:10]
- Overdue mail (`overdue_mail.php`, helper shell `overdues_mail.sh`). [cite:10]

### Menu
- Submenu definition (`submenu.php`). [cite:10]

---

## 4) Master File (`admin/modules/master_file/`)

Tujuan: master data/authority yang dipakai bibliografi, sirkulasi, serial, visitor, dsb. [cite:11]

### Authority & bibliographic masters
- Author (`author.php`). [cite:11]
- Topic/subject (`topic.php`). [cite:11]
- Publisher (`publisher.php`). [cite:11]
- Place (`place.php`). [cite:11]
- Document language (`doc_language.php`). [cite:11]
- Cross reference (`cross_reference.php`). [cite:11]

### Collection/item masters
- Collection type (`coll_type.php`). [cite:11]
- Location (`location.php`). [cite:11]
- Item status (`item_status.php`). [cite:11]
- Label (`label.php`). [cite:11]
- Item code pattern (`item_code_pattern.php`). [cite:11]

### Serial-related masters
- Frequency (`frequency.php`). [cite:11]

### Vocabulary control helpers
- Vocabulary control popups/iframes (`iframe_vocabolary_control.php`, `pop_vocabolary_control.php`, `pop_scope_vocabolary.php`). [cite:11]

### P2P / visitor
- P2P servers (`p2pservers.php`). [cite:11]
- Visitor room (`visitor_room.php`). [cite:11]

### RDA helper
- RDA CMC (`rda_cmc.php`). [cite:11]

### Menu
- Index & submenu (`index.php`, `submenu.php`). [cite:11]

---

## 5) Reporting (`admin/modules/reporting/`)

Tujuan: laporan peminjaman & anggota, output spreadsheet, grafik/statistik, serta custom reports (folder `customs`). [cite:5][cite:6]

### Reporting core
- Reporting index (`index.php`). [cite:5]
- Loan report (`loan_report.php`). [cite:5]
- Member report (`member_report.php`). [cite:5]
- Charts report & chart popup (`charts_report.php`, `pop_chart.php`). [cite:5]
- Spreadsheet/export helpers (`spreadsheet.php`, `xlsoutput.php`, `report_dbgrid.inc.php`). [cite:5]
- Submenu definition (`submenu.php`). [cite:5]

### Custom reports (`admin/modules/reporting/customs/`)
- Registry/list custom report (`customs_report_list.inc.php`). [cite:6]

#### Custom reports — files (existing)
- `class_recap.php` [cite:6]
- `dl_counter.php` [cite:6]
- `dl_detail.php` [cite:6]
- `due_date_warning.php` [cite:6]
- `fines_report.php` [cite:6]
- `item_titles_list.php` [cite:6]
- `item_usage.php` [cite:6]
- `loan_by_class.php` [cite:6]
- `loan_history.php` [cite:6]
- `member_fines_list.php` [cite:6]
- `member_fines_list.csv.php` [cite:6]
- `member_list.php` [cite:6]
- `member_loan_list.php` [cite:6]
- `overdued_list.php` [cite:6]
- `pop_procurement_list.php` [cite:6]
- `procurement_report.php` [cite:6]
- `reserve_list.php` [cite:6]
- `staff_act.php` [cite:6]
- `titles_list.php` [cite:6]
- `visitor_list.php` [cite:6]
- `visitor_report.php` [cite:6]
- `visitor_report_day.php` [cite:6]

---

## 6) Serial Control (`admin/modules/serial_control/`)

Tujuan: manajemen terbitan berkala (serial), langganan, dan kardex. [cite:12]

- Serial control index (`index.php`). [cite:12]
- Subscription management (`subscription.php`). [cite:12]
- Kardex (`kardex.php`). [cite:12]
- Serial base library (`serial_base_lib.inc.php`). [cite:12]
- Submenu definition (`submenu.php`). [cite:12]

---

## 7) Stock Take (`admin/modules/stock_take/`)

Tujuan: stock opname/inventory, upload hasil scan, laporan, log, serta utilitas resync. [cite:13]

### Flow stock take
- Init (`init.php`). [cite:13]
- Current (running) (`current.php`). [cite:13]
- Action handler (`stock_take_action.php`). [cite:13]
- Upload (`st_upload.php`). [cite:13]
- Finish (`finish.php`). [cite:13]

### Reporting & log
- Report (`st_report.php`). [cite:13]
- Report detail (`st_report_detail.php`). [cite:13]
- Lost item list (`lost_item_list.php`). [cite:13]
- Log (`st_log.php`). [cite:13]
- Report reader helper (`report_reader.php`). [cite:13]

### Utilities
- Resync (`resync.php`). [cite:13]

### Menu
- Index & submenu (`index.php`, `submenu.php`). [cite:13]

---

## 8) System (`admin/modules/system/`)

Tujuan: konfigurasi sistem, user & permission, module & plugin, backup, indexing, content/theme, email/captcha, log, holiday, dll. [cite:14]

### Users & access control
- App user management (`app_user.php`). [cite:14]
- User group/roles (`user_group.php`). [cite:14]
- Module privilege forms (`module_priv_form.inc.php`, `module_priv_form_adv.inc.php`). [cite:14]

### Modules & plugins
- Module management (`module.php`). [cite:14]
- Plugins listing/action (`plugins.php`, `plugin_action.php`). [cite:14]

### Backup & maintenance
- Backup UI/proc (`backup.php`, `backup_proc.php`). [cite:14]
- Backup config (`backup_config.php`). [cite:14]
- System log (`sys_log.php`). [cite:14]
- Register site (`register_site.php`). [cite:14]

### Indexing / search infra
- Bibliography indexer (`biblio_indexer.inc.php`). [cite:14]
- Bibliography indexes UI & script (`biblio_indexes.php`, `biblio_indexes.sh`). [cite:14]
- Elasticsearch indexer variant (`biblio_indexer_es.inc.php`, `biblio_indexes_es.php`). [cite:14]

### System settings
- Environment info/settings (`envinfo.php`, `envsetting.php`). [cite:14]
- Captcha setting (`captchasetting.php`). [cite:14]
- Currency setting (`currencysetting.php`). [cite:14]
- Mail setting (`mailsetting.php`). [cite:14]
- Holiday setting (`holiday.php`). [cite:14]
- UC setting (`ucsetting.php`). [cite:14]
- Custom field (system-level) (`custom_field.php`). [cite:14]

### UI/content utilities
- Content management (`content.php`). [cite:14]
- Theme management (`theme.php`). [cite:14]
- Membercard theme (`membercard_theme.php`). [cite:14]
- Shortcut management (`shortcut.php`). [cite:14]
- Barcode generator (`barcode_generator.php`). [cite:14]

### Menu
- System index & submenu (`index.php`, `submenu.php`). [cite:14]

---

## Notes for AI Agents

- Daftar ini berbasis **file/folder yang ada**, bukan jaminan semua file muncul sebagai menu UI; beberapa adalah helper (AJAX, popup, libs, scripts). [cite:2][cite:3][cite:10][cite:11][cite:5][cite:12][cite:13][cite:14]
- Untuk menambah menu baru secara “native”, biasanya perlu menambah entry submenu + permission di System (module privileges), bukan hanya menambah file PHP. [cite:14]
