import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'gestionImmo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertTestData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('client', 'technicien', 'admin'))
      )
    ''');

    await db.execute('''
      CREATE TABLE immeubles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        adresse TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE maisons (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_immeuble INTEGER NOT NULL,
        numero TEXT NOT NULL,
        nombre_pieces INTEGER NOT NULL,
        FOREIGN KEY (id_immeuble) REFERENCES immeubles (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE pieces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_maison INTEGER NOT NULL,
        nom TEXT NOT NULL,
        FOREIGN KEY (id_maison) REFERENCES maisons (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE equipements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_piece INTEGER NOT NULL,
        code TEXT NOT NULL,
        quantite INTEGER NOT NULL,
        nom TEXT NOT NULL,
        FOREIGN KEY (id_piece) REFERENCES pieces (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reclamations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_client INTEGER NOT NULL,
        id_equipement INTEGER NOT NULL,
        description TEXT NOT NULL,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        statut TEXT NOT NULL,
        FOREIGN KEY (id_client) REFERENCES users (id),
        FOREIGN KEY (id_equipement) REFERENCES equipements (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE pannes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_reclamation INTEGER NOT NULL,
        id_technicien INTEGER,
        description TEXT NOT NULL,
        date_detection DATETIME DEFAULT CURRENT_TIMESTAMP,
        date_resolution DATETIME,
        statut TEXT NOT NULL,
        FOREIGN KEY (id_reclamation) REFERENCES reclamations (id),
        FOREIGN KEY (id_technicien) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE rapports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_panne INTEGER NOT NULL,
        id_technicien INTEGER NOT NULL,
        description TEXT NOT NULL,
        date_intervention DATETIME DEFAULT CURRENT_TIMESTAMP,
        duree INTEGER NOT NULL,
        cout REAL NOT NULL,
        statut TEXT NOT NULL,
        FOREIGN KEY (id_panne) REFERENCES pannes (id),
        FOREIGN KEY (id_technicien) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE paiements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_rapport INTEGER NOT NULL,
        id_client INTEGER NOT NULL,
        montant REAL NOT NULL,
        date_paiement DATETIME DEFAULT CURRENT_TIMESTAMP,
        mode_paiement TEXT NOT NULL,
        statut TEXT NOT NULL,
        FOREIGN KEY (id_rapport) REFERENCES rapports (id),
        FOREIGN KEY (id_client) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE avis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_client INTEGER NOT NULL,
        id_technicien INTEGER NOT NULL,
        id_intervention INTEGER NOT NULL,
        note INTEGER NOT NULL CHECK (note BETWEEN 1 AND 5),
        commentaire TEXT,
        date_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_client) REFERENCES users (id),
        FOREIGN KEY (id_technicien) REFERENCES users (id),
        FOREIGN KEY (id_intervention) REFERENCES rapports (id)
      )
    ''');
  }

  Future<void> _insertTestData(Database db) async {
    await db.insert('immeubles', {
      'nom': 'Résidence Les Oliviers',
      'adresse': '123 Avenue de la République',
      'type': 'Résidentiel'
    });

    await db.insert('maisons', {
      'id_immeuble': 1,
      'numero': 'A101',
      'nombre_pieces': 4
    });

    await db.insert('pieces', {
      'id_maison': 1,
      'nom': 'Salon'
    });

    await db.insert('equipements', {
      'id_piece': 1,
      'code': 'CLIM001',
      'quantite': 1,
      'nom': 'Climatiseur'
    });

    await db.insert('users', {
      'name': 'Client Test',
      'email': 'client@test.com',
      'password': '123456',
      'role': 'client'
    });

    await db.insert('users', {
      'name': 'Technicien Test',
      'email': 'tech@test.com',
      'password': '123456',
      'role': 'technicien'
    });

    await db.insert('users', {
      'name': 'Admin Test',
      'email': 'admin@test.com',
      'password': '123456',
      'role': 'admin'
    });
  }
}
