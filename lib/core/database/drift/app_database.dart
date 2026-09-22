import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../features/crm/contacts/domain/contact_model.dart';
import '../../../features/crm/invoices/domain/invoice_model.dart';
import '../../../features/crm/leads/domain/lead_model.dart';
import '../../../features/farm/farms/domain/farm_model.dart';
import '../../../features/farm/crops/domain/crop_model.dart';
import '../../../features/farm/livestock/domain/livestock_model.dart';
import '../../../features/farm/equipment/domain/equipment_model.dart';
import '../../../features/farm/finances/domain/finance_model.dart';

class AppDatabase {
  static Database? _db;

  /// Call once in main() before runApp.
  static Future<void> init() async {
    _db = await _openDatabase();
  }

  static Future<Database> get database async {
    _db ??= await _openDatabase();
    return _db!;
  }

  static Future<Database> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'meadowbrook_erp.db');
    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS farms (
          id          TEXT PRIMARY KEY,
          name        TEXT NOT NULL,
          county      TEXT DEFAULT 'Nairobi',
          acreage     REAL DEFAULT 0.0,
          description TEXT DEFAULT '',
          createdAt   TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS crops (
          id              TEXT PRIMARY KEY,
          farmId          TEXT NOT NULL,
          name            TEXT NOT NULL,
          variety         TEXT DEFAULT '',
          plantingDate    TEXT DEFAULT '',
          expectedHarvest TEXT DEFAULT '',
          status          TEXT DEFAULT 'Growing',
          notes           TEXT DEFAULT '',
          createdAt       TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS livestock (
          id        TEXT PRIMARY KEY,
          farmId    TEXT NOT NULL,
          type      TEXT NOT NULL,
          name      TEXT DEFAULT '',
          count     INTEGER DEFAULT 0,
          notes     TEXT DEFAULT '',
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS equipment (
          id        TEXT PRIMARY KEY,
          farmId    TEXT NOT NULL,
          name      TEXT NOT NULL,
          type      TEXT DEFAULT '',
          condition TEXT DEFAULT 'Good',
          notes     TEXT DEFAULT '',
          createdAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS farm_finances (
          id        TEXT PRIMARY KEY,
          farmId    TEXT NOT NULL,
          type      TEXT NOT NULL,
          category  TEXT DEFAULT '',
          amount    REAL DEFAULT 0.0,
          date      TEXT NOT NULL,
          notes     TEXT DEFAULT '',
          createdAt TEXT NOT NULL
        )
      ''');
    }
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contacts (
        id       TEXT PRIMARY KEY,
        name     TEXT NOT NULL,
        phone    TEXT DEFAULT '',
        email    TEXT DEFAULT '',
        type     TEXT DEFAULT 'Farmer',
        county   TEXT DEFAULT 'Nairobi',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE leads (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        contactName TEXT DEFAULT '',
        phone       TEXT DEFAULT '',
        status      TEXT DEFAULT 'New',
        value       REAL DEFAULT 0.0,
        notes       TEXT DEFAULT '',
        createdAt   TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE invoices (
        id            TEXT PRIMARY KEY,
        invoiceNumber TEXT NOT NULL,
        clientName    TEXT DEFAULT '',
        clientPhone   TEXT DEFAULT '',
        amount        REAL DEFAULT 0.0,
        amountPaid    REAL DEFAULT 0.0,
        status        TEXT DEFAULT 'Unpaid',
        dueDate       TEXT DEFAULT '',
        notes         TEXT DEFAULT '',
        createdAt     TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE farms (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        county      TEXT DEFAULT 'Nairobi',
        acreage     REAL DEFAULT 0.0,
        description TEXT DEFAULT '',
        createdAt   TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE crops (
        id              TEXT PRIMARY KEY,
        farmId          TEXT NOT NULL,
        name            TEXT NOT NULL,
        variety         TEXT DEFAULT '',
        plantingDate    TEXT DEFAULT '',
        expectedHarvest TEXT DEFAULT '',
        status          TEXT DEFAULT 'Growing',
        notes           TEXT DEFAULT '',
        createdAt       TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE livestock (
        id        TEXT PRIMARY KEY,
        farmId    TEXT NOT NULL,
        type      TEXT NOT NULL,
        name      TEXT DEFAULT '',
        count     INTEGER DEFAULT 0,
        notes     TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE equipment (
        id        TEXT PRIMARY KEY,
        farmId    TEXT NOT NULL,
        name      TEXT NOT NULL,
        type      TEXT DEFAULT '',
        condition TEXT DEFAULT 'Good',
        notes     TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE farm_finances (
        id        TEXT PRIMARY KEY,
        farmId    TEXT NOT NULL,
        type      TEXT NOT NULL,
        category  TEXT DEFAULT '',
        amount    REAL DEFAULT 0.0,
        date      TEXT NOT NULL,
        notes     TEXT DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');
    await _insertSampleData(db);
  }

  static Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now().toIso8601String();

    for (final c in _sampleContacts(now)) {
      await db.insert('contacts', c);
    }
    for (final l in _sampleLeads(now)) {
      await db.insert('leads', l);
    }
    for (final inv in _sampleInvoices(now)) {
      await db.insert('invoices', inv);
    }
  }

  // ─── CONTACTS ────────────────────────────────────────────────────────────

  static Future<List<ContactModel>> getContacts() async {
    final db = await database;
    final rows = await db.query('contacts', orderBy: 'name ASC');
    return rows.map(ContactModel.fromMap).toList();
  }

  static Future<void> insertContact(ContactModel contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateContact(ContactModel contact) async {
    final db = await database;
    await db.update('contacts', contact.toMap(),
        where: 'id = ?', whereArgs: [contact.id]);
  }

  static Future<void> deleteContact(String id) async {
    final db = await database;
    await db.delete('contacts', where: 'id = ?', whereArgs: [id]);
  }

  /// Insert or replace — used during XML import.
  static Future<void> upsertContact(ContactModel contact) async {
    final db = await database;
    await db.insert('contacts', contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── LEADS ───────────────────────────────────────────────────────────────

  static Future<List<LeadModel>> getLeads() async {
    final db = await database;
    final rows = await db.query('leads', orderBy: 'createdAt DESC');
    return rows.map(LeadModel.fromMap).toList();
  }

  static Future<void> insertLead(LeadModel lead) async {
    final db = await database;
    await db.insert('leads', lead.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateLead(LeadModel lead) async {
    final db = await database;
    await db.update('leads', lead.toMap(),
        where: 'id = ?', whereArgs: [lead.id]);
  }

  static Future<void> deleteLead(String id) async {
    final db = await database;
    await db.delete('leads', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> upsertLead(LeadModel lead) async {
    final db = await database;
    await db.insert('leads', lead.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── INVOICES ────────────────────────────────────────────────────────────

  static Future<List<InvoiceModel>> getInvoices() async {
    final db = await database;
    final rows = await db.query('invoices', orderBy: 'createdAt DESC');
    return rows.map(InvoiceModel.fromMap).toList();
  }

  static Future<void> insertInvoice(InvoiceModel invoice) async {
    final db = await database;
    await db.insert('invoices', invoice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateInvoice(InvoiceModel invoice) async {
    final db = await database;
    await db.update('invoices', invoice.toMap(),
        where: 'id = ?', whereArgs: [invoice.id]);
  }

  static Future<void> deleteInvoice(String id) async {
    final db = await database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> upsertInvoice(InvoiceModel invoice) async {
    final db = await database;
    await db.insert('invoices', invoice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── FARMS ───────────────────────────────────────────────────────────────

  static Future<List<FarmModel>> getFarms() async {
    final db = await database;
    final rows = await db.query('farms', orderBy: 'name ASC');
    return rows.map(FarmModel.fromMap).toList();
  }

  static Future<void> insertFarm(FarmModel farm) async {
    final db = await database;
    await db.insert('farms', farm.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateFarm(FarmModel farm) async {
    final db = await database;
    await db.update('farms', farm.toMap(),
        where: 'id = ?', whereArgs: [farm.id]);
  }

  static Future<void> deleteFarm(String id) async {
    final db = await database;
    await db.delete('farms', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> upsertFarm(FarmModel farm) async {
    final db = await database;
    await db.insert('farms', farm.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ─── CROPS ───────────────────────────────────────────────────────────────

  static Future<List<CropModel>> getCrops(String farmId) async {
    final db = await database;
    final rows = await db.query('crops',
        where: 'farmId = ?', whereArgs: [farmId], orderBy: 'createdAt DESC');
    return rows.map(CropModel.fromMap).toList();
  }

  static Future<void> insertCrop(CropModel crop) async {
    final db = await database;
    await db.insert('crops', crop.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateCrop(CropModel crop) async {
    final db = await database;
    await db.update('crops', crop.toMap(),
        where: 'id = ?', whereArgs: [crop.id]);
  }

  static Future<void> deleteCrop(String id) async {
    final db = await database;
    await db.delete('crops', where: 'id = ?', whereArgs: [id]);
  }

  // ─── LIVESTOCK ────────────────────────────────────────────────────────────

  static Future<List<LivestockModel>> getLivestock(String farmId) async {
    final db = await database;
    final rows = await db.query('livestock',
        where: 'farmId = ?', whereArgs: [farmId], orderBy: 'createdAt DESC');
    return rows.map(LivestockModel.fromMap).toList();
  }

  static Future<void> insertLivestock(LivestockModel item) async {
    final db = await database;
    await db.insert('livestock', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateLivestock(LivestockModel item) async {
    final db = await database;
    await db.update('livestock', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<void> deleteLivestock(String id) async {
    final db = await database;
    await db.delete('livestock', where: 'id = ?', whereArgs: [id]);
  }

  // ─── EQUIPMENT ────────────────────────────────────────────────────────────

  static Future<List<EquipmentModel>> getEquipment(String farmId) async {
    final db = await database;
    final rows = await db.query('equipment',
        where: 'farmId = ?', whereArgs: [farmId], orderBy: 'createdAt DESC');
    return rows.map(EquipmentModel.fromMap).toList();
  }

  static Future<void> insertEquipment(EquipmentModel item) async {
    final db = await database;
    await db.insert('equipment', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateEquipment(EquipmentModel item) async {
    final db = await database;
    await db.update('equipment', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<void> deleteEquipment(String id) async {
    final db = await database;
    await db.delete('equipment', where: 'id = ?', whereArgs: [id]);
  }

  // ─── FARM FINANCES ────────────────────────────────────────────────────────

  static Future<List<FinanceModel>> getFarmFinances(String farmId) async {
    final db = await database;
    final rows = await db.query('farm_finances',
        where: 'farmId = ?', whereArgs: [farmId], orderBy: 'date DESC');
    return rows.map(FinanceModel.fromMap).toList();
  }

  static Future<void> insertFarmFinance(FinanceModel item) async {
    final db = await database;
    await db.insert('farm_finances', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> updateFarmFinance(FinanceModel item) async {
    final db = await database;
    await db.update('farm_finances', item.toMap(),
        where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<void> deleteFarmFinance(String id) async {
    final db = await database;
    await db.delete('farm_finances', where: 'id = ?', whereArgs: [id]);
  }

  // ─── SAMPLE DATA ─────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> _sampleContacts(String now) => [
        {
          'id': '1', 'name': 'James Kamau',
          'phone': '+254 712 345 678', 'email': 'james@email.com',
          'type': 'Farmer', 'county': 'Nakuru', 'createdAt': now,
        },
        {
          'id': '2', 'name': 'Mary Wanjiku',
          'phone': '+254 723 456 789', 'email': 'mary@email.com',
          'type': 'Buyer', 'county': 'Nairobi', 'createdAt': now,
        },
        {
          'id': '3', 'name': 'Peter Ochieng',
          'phone': '+254 734 567 890', 'email': 'peter@email.com',
          'type': 'Supplier', 'county': 'Kisumu', 'createdAt': now,
        },
        {
          'id': '4', 'name': 'Grace Muthoni',
          'phone': '+254 745 678 901', 'email': 'grace@email.com',
          'type': 'Farmer', 'county': 'Nyeri', 'createdAt': now,
        },
        {
          'id': '5', 'name': 'David Kipchoge',
          'phone': '+254 756 789 012', 'email': 'david@email.com',
          'type': 'Partner', 'county': 'Uasin Gishu', 'createdAt': now,
        },
      ];

  static List<Map<String, dynamic>> _sampleLeads(String now) => [
        {
          'id': '1', 'title': 'Maize Supply Contract',
          'contactName': 'James Kamau', 'phone': '+254 712 345 678',
          'status': 'Qualified', 'value': 150000.0,
          'notes': 'Interested in bulk maize supply for next season',
          'createdAt': now,
        },
        {
          'id': '2', 'title': 'Tea Export Deal',
          'contactName': 'Mary Wanjiku', 'phone': '+254 723 456 789',
          'status': 'Proposal', 'value': 450000.0,
          'notes': 'Exporting to UK market, needs certification',
          'createdAt': now,
        },
        {
          'id': '3', 'title': 'Fertilizer Partnership',
          'contactName': 'Peter Ochieng', 'phone': '+254 734 567 890',
          'status': 'New', 'value': 80000.0,
          'notes': 'New supplier partnership inquiry', 'createdAt': now,
        },
        {
          'id': '4', 'title': 'Dairy Products Distribution',
          'contactName': 'Grace Muthoni', 'phone': '+254 745 678 901',
          'status': 'Won', 'value': 220000.0,
          'notes': 'Signed contract for milk distribution', 'createdAt': now,
        },
        {
          'id': '5', 'title': 'Avocado Export',
          'contactName': 'David Kipchoge', 'phone': '+254 756 789 012',
          'status': 'Contacted', 'value': 320000.0,
          'notes': 'Exploring export options to Middle East', 'createdAt': now,
        },
      ];

  static List<Map<String, dynamic>> _sampleInvoices(String now) => [
        {
          'id': '1', 'invoiceNumber': 'INV-001',
          'clientName': 'James Kamau', 'clientPhone': '+254 712 345 678',
          'amount': 150000.0, 'amountPaid': 150000.0, 'status': 'Paid',
          'dueDate': '2024-03-15', 'notes': 'Maize supply payment',
          'createdAt': now,
        },
        {
          'id': '2', 'invoiceNumber': 'INV-002',
          'clientName': 'Mary Wanjiku', 'clientPhone': '+254 723 456 789',
          'amount': 450000.0, 'amountPaid': 225000.0, 'status': 'Partial',
          'dueDate': '2024-03-30', 'notes': 'Tea export advance payment',
          'createdAt': now,
        },
        {
          'id': '3', 'invoiceNumber': 'INV-003',
          'clientName': 'Peter Ochieng', 'clientPhone': '+254 734 567 890',
          'amount': 80000.0, 'amountPaid': 0.0, 'status': 'Unpaid',
          'dueDate': '2024-04-05', 'notes': 'Fertilizer order',
          'createdAt': now,
        },
        {
          'id': '4', 'invoiceNumber': 'INV-004',
          'clientName': 'Grace Muthoni', 'clientPhone': '+254 745 678 901',
          'amount': 220000.0, 'amountPaid': 0.0, 'status': 'Overdue',
          'dueDate': '2024-02-28', 'notes': 'Dairy products delivery',
          'createdAt': now,
        },
        {
          'id': '5', 'invoiceNumber': 'INV-005',
          'clientName': 'David Kipchoge', 'clientPhone': '+254 756 789 012',
          'amount': 320000.0, 'amountPaid': 320000.0, 'status': 'Paid',
          'dueDate': '2024-03-10', 'notes': 'Avocado export batch 1',
          'createdAt': now,
        },
      ];
}
