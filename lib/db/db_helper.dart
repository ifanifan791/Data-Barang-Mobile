import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:part1/model/barang.dart';
import 'package:part1/model/category.dart';
import 'package:part1/model/history_stok.dart';

class DatabaseHelper {
  static Database? _database;

  // Fungsi untuk mendapatkan instance database
  Future<Database> get database async {
    if (_database != null) return _database!;

    // Hapus database lama jika ada
    await deleteDatabaseIfNeeded();

    _database = await _initDb();
    return _database!;
  }

  // Fungsi untuk menghapus database lama
  Future<void> deleteDatabaseIfNeeded() async {
    final dbPath = await getDatabasesPath();
    await deleteDatabase(join(dbPath, 'inventory.db'));
  }

  // Inisialisasi database dan tabel
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'inventory.db'),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            category TEXT NOT NULL,
            imagePath TEXT NOT NULL
          )
        ''');
        db.execute('''CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )''');
        db.execute('''CREATE TABLE history_stok(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER,
        jenis TEXT,
        jumlah INTEGER,
        tanggal TEXT,
        FOREIGN KEY(item_id) REFERENCES items(id)
      )''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('''ALTER TABLE items ADD COLUMN stock INTEGER;''');
        }
        if (oldVersion < 3) {
          db.execute('''CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )''');
        }
        if (oldVersion < 4) {
          db.execute('''CREATE TABLE history_stok(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          item_id INTEGER,
          jenis TEXT,
          jumlah INTEGER,
          tanggal TEXT,
          FOREIGN KEY(item_id) REFERENCES items(id)
        )''');
        }
      },
      version: 4, // Increment the version number
    );
  }

  // Fungsi untuk menambahkan item ke database
  Future<void> addItem(Barang item) async {
    final db = await database;
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Fungsi untuk mendapatkan daftar item dari database
  Future<List<Barang>> getItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return Barang.fromMap(maps[i]);
    });
  }

// Fungsi untuk mendapatkan item berdasarkan ID
  Future<Barang?> getItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('items', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Barang.fromMap(maps.first);
    }
    return null;
  }

  Future<int> getLastItemId() async {
    final db = await database; 
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT MAX(id) as maxId FROM items');
    return result.isNotEmpty && result[0]['maxId'] != null
        ? result[0]['maxId']
        : 0;
  }

// Fungsi untuk menghapus item dari database
  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Fungsi untuk menambahkan kategori ke database
  Future<void> addCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

// Fungsi untuk mendapatkan daftar kategori dari database
  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<int> getLastCategoryId() async {
    final db = await database; 
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT MAX(id) as maxId FROM categories');
    return result.isNotEmpty && result[0]['maxId'] != null
        ? result[0]['maxId']
        : 0;
  }

  Future<void> updateStock(int itemId, int stock) async {
    final db = await database;
    await db.update(
      'items',
      {'stock': stock},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> addHistoryStok(HistoryStok historyStok) async {
    final db = await database;
    await db.insert(
      'history_stok',
      historyStok.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryStok>> getHistoryStokByItemId(int itemId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query('history_stok', where: 'item_id = ?', whereArgs: [itemId]);
    return List.generate(maps.length, (i) {
      return HistoryStok.fromMap(maps[i]);
    });
  }

  Future<List<HistoryStok>> getAllHistoryStok() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('history_stok');

    return List.generate(maps.length, (i) {
      return HistoryStok.fromMap(maps[i]);
    });
  }
}
