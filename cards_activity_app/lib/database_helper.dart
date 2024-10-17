import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "card_organizer.db";
  static final _databaseVersion = 1;

  static final tableFolders = 'folders';
  static final tableCards = 'cards';

  static final columnId = 'id';
  static final columnFolderName = 'name';
  static final columnTimestamp = 'timestamp';
  static final columnCardName = 'name';
  static final columnSuit = 'suit';
  static final columnImageUrl = 'imageUrl';
  static final columnFolderId = 'folderId';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFolders (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnFolderName TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $tableCards (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCardName TEXT NOT NULL,
        $columnSuit TEXT NOT NULL,
        $columnImageUrl TEXT NOT NULL,
        $columnFolderId INTEGER NOT NULL,
        FOREIGN KEY ($columnFolderId) REFERENCES $tableFolders ($columnId)
      )
    ''');

    // Prepopulate the folders
    await db.insert(tableFolders, {
      columnFolderName: 'Hearts',
      columnTimestamp: DateTime.now().toString(),
    });
    await db.insert(tableFolders, {
      columnFolderName: 'Spades',
      columnTimestamp: DateTime.now().toString(),
    });
    await db.insert(tableFolders, {
      columnFolderName: 'Diamonds',
      columnTimestamp: DateTime.now().toString(),
    });
    await db.insert(tableFolders, {
      columnFolderName: 'Clubs',
      columnTimestamp: DateTime.now().toString(),
    });
  }

  // CRUD for folders
  Future<List<Map<String, dynamic>>> getFolders() async {
    Database db = await instance.database;
    return await db.query(tableFolders);
  }

  // CRUD for cards
  Future<List<Map<String, dynamic>>> getCards(int folderId) async {
    Database db = await instance.database;
    return await db
        .query(tableCards, where: '$columnFolderId = ?', whereArgs: [folderId]);
  }

  Future<int> insertCard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(tableCards, row);
  }

  Future<int> deleteCard(int id) async {
    Database db = await instance.database;
    return await db.delete(tableCards, where: '$columnId = ?', whereArgs: [id]);
  }

  // Helper method to generate card image URL
  String getCardImageUrl(String cardName, String suit) {
    String formattedCardName = cardName.toLowerCase().replaceAll(' ', '-');
    String formattedSuit = suit.toLowerCase();
    return 'https://example.com/cards/$formattedCardName-of-$formattedSuit.png'; // Placeholder URL format
  }

  // Insert a card with a dynamically generated image URL
  Future<int> insertCardWithImageUrl(
      String cardName, String suit, int folderId) async {
    String imageUrl = getCardImageUrl(cardName, suit);

    Map<String, dynamic> card = {
      columnCardName: '$cardName of $suit',
      columnSuit: suit,
      columnImageUrl: imageUrl,
      columnFolderId: folderId,
    };

    return await insertCard(card);
  }
}
