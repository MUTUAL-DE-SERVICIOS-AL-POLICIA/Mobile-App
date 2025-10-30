import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/database/notification_model.dart';
import 'package:muserpol_pvt/database/affiliate_model.dart';
export 'package:muserpol_pvt/database/notification_model.dart';
export 'package:muserpol_pvt/database/affiliate_model.dart';
import 'package:path_provider/path_provider.dart';

import 'package:sqflite/sqflite.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'muserpolpvt1.db');
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
              await db.execute('''
            CREATE TABLE affiliate(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idAffiliate INTEGER
            )
          ''');
      await db.execute('''
            CREATE TABLE notification(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idAffiliate INTEGER,
              title TEXT,
              content TEXT,
              read TEXT,
              date DATETIME
            )
          ''');
    });
  }
  //GUARDAR INFO AFFILIADO
  Future<int> newAffiliateModel(AffiliateModel data) async {
    final db = await database;
    await db.execute('''
        DROP TABLE affiliate
    ''');
    await db.execute('''
            CREATE TABLE affiliate(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              idAffiliate INTEGER
            )
          ''');
    var noti = data.toJson();
    final res = await db.insert('affiliate', noti);
    return res;
  }
  //GUARDAR INFO NOTIFICACION
  Future<int> newNotificationModel(NotificationModel data) async {
    final db = await database;
    var noti = data.toJson();
    noti['read'] = noti['read'].toString();
    final res = await db.insert('notification', noti);
    return res;
  }

  //OBTENER DATOS SEGUN EL ID
  Future<NotificationModel> getNotificationModelById(int id) async {
    final db = await database;
    final res =
        await db.query('notification', where: 'id = ?', whereArgs: [id]);
    return NotificationModel.fromJson(res.first);
  }
  //OBTENER DATOS DEL AFILIADO SEGUN EL ID
  Future<int> getAffiliateModelById() async {
    final db = await database;
    final res = await db.query('affiliate');
    return AffiliateModel.fromJson(res.first).idAffiliate;
  }
  //OBTENER TODOS LOS DATOS
  Future<List<NotificationModel>> getAllNotificationModel() async {
    final db = await database;
    final res = await db.query('notification');
    return res.isNotEmpty
        ? res.map((c) => NotificationModel.fromJson(c)).toList()
        : [];
  }
  Future<List<AffiliateModel>> getAllAffiliateModel() async {
    final db = await database;
    final res = await db.query('affiliate');
    return res.isNotEmpty
        ? res.map((c) => AffiliateModel.fromJson(c)).toList()
        : [];
  }
  //ACTUALIZAR DATOS SEGUN EL ID
  Future<int> updateNotificationModel(NotificationModel data) async {
    final db = await database;
    final res = await db.update('notification', data.toJson(),
        where: 'id = ?', whereArgs: [data.id]);
    return res;
  }

  //ELIMINAR DATOS SEGUN EL ID
  Future<int> deleteNotificationModelById(int id) async {
    final db = await database;
    final res =
        await db.delete('notification', where: 'id = ?', whereArgs: [id]);
    return res;
  }

//obtengo el registro segun el content y registro true a read
  Future<int> updateNotificationModelByContent(String content) async {
    final db = await database;
    final noti = await db
        .query('notification', where: 'content = ?', whereArgs: [content]);
    if (noti.isNotEmpty) {
      debugPrint('noti ${noti[0]}');
      final newNoti = Map.of(noti[0]);
      newNoti['read'] = 'true';
      final res = await db.update('notification', newNoti,
          where: 'id = ?', whereArgs: [newNoti['id']]);
      return res;
    } else {
      return 0;
    }
  }
}
