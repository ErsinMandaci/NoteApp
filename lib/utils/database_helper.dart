import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_note_app/models/category.dart';
import 'package:flutter_note_app/models/notes.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }

  DatabaseHelper._internal();

  Future<Database> _getDatabase() async {
    if (_database == null) {
      _database = (await _initializeDatabase())!;
      return _database!;
    } else {
      return _database!;
    }
  }

  Future<Database?> _initializeDatabase() async {
    Database db;

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "category.db");
    debugPrint(databasesPath);

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      debugPrint("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "note.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      debugPrint("Opening existing database");
    }

// open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<List<Category>> getCategoryList() async {
     var getCategoryList = await getCategory();
     var categoryList = <Category>[];
     for (Map<String, dynamic> map in getCategoryList) {
       categoryList.add(Category.fromMap(map));
     }
     return categoryList;

  }

  Future<List<Map<String, dynamic>>> getCategory() async {
    var db = await _getDatabase();
    var result = await db.query('category');

    return result;
  }

  Future<int> addCategory(Category category) async {
    var db = await _getDatabase();

    var result = await db.insert('category', category.toMap());

    return result;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _getDatabase();

    var result = await db.update('category', category.toMap(),
        where: 'categoryID =?', whereArgs: [category.categoryID]);

    return result;
  }

  Future<int> deleteCategory(int categoryID) async {
    var db = await _getDatabase();

    var result = await db
        .delete('category', where: 'categoryID =?', whereArgs: [categoryID]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getNote() async {
    var db = await _getDatabase();
    var result = await db.rawQuery(
        'SELECT * FROM note inner join category on category.categoryID = note.categoryID order by noteID Desc');
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNote();
    var noteList = <Note>[];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<int> addNote(Note note) async {
    var db = await _getDatabase();

    var result = await db.insert('note', note.toMap());

    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await _getDatabase();

    var result = await db.update('note', note.toMap(),
        where: 'noteID =?', whereArgs: [note.noteID]);

    return result;
  }

  Future<int> noteDelete(int noteID) async {
    var db = await _getDatabase();

    var result =
        await db.delete('note', where: 'noteID =?', whereArgs: [noteID]);

    return result;
  }

  String dateFormat(DateTime dt) {
    DateTime today = DateTime.now();
    Duration oneDay = Duration(days: 1);
    Duration twoDay = Duration(days: 2);
    Duration oneWeek = Duration(days: 7);
    String? month;
    switch (dt.month) {
      case 1:
        month = "january";
        break;
      case 2:
        month = "february";
        break;
      case 3:
        month = "march";
        break;
      case 4:
        month = "april";
        break;
      case 5:
        month = "may";
        break;
      case 6:
        month = "june";
        break;
      case 7:
        month = "july";
        break;
      case 8:
        month = "august";
        break;
      case 9:
        month = "september";
        break;
      case 10:
        month = "october";
        break;
      case 11:
        month = "november";
        break;
      case 12:
        month = "december";
        break;
    }

    Duration difference = today.difference(dt);

    if (difference.compareTo(oneDay) < 1) {
      return "today";
    } else if (difference.compareTo(twoDay) < 1) {
      return "yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (dt.weekday) {
        case 1:
          return "monday";
        case 2:
          return "tuesday";
        case 3:
          return "wednesday";
        case 4:
          return "thursday";
        case 5:
          return "friday";
        case 6:
          return "saturday";
        case 7:
          return "sunday";
      }
    } else if (dt.year == today.year) {
      return '${dt.day} $month';
    } else {
      return '${dt.day} $month ${dt.year}';
    }
    return "";
  }
}
