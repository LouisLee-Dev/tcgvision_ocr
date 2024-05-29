import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:tcgvision/models/AppConst.dart';
import 'CardModel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DatabaseModel with ChangeNotifier{
  Database db;
  final String tableName = "scan_cards";
  final String dbName = "tcg_vision_history_1.db";
  final String columnId = "id";
  final String columnType = "type";
  final String columnName = "name";
  final String columnSetCode = "set_code";
  final String columnSetRarity = "set_rarity";
  final String columnEdition = "edition";
  final String columnCondition = "condition";
  final String columnDate = "scan_date";
  final String columnPrice = "price";
  List<TCGCard> scanHistories = [];

  DatabaseModel(){
    getAllCardsFromSql();
  }

  Future open(String path) async {
    try{
      Directory directory = await getApplicationDocumentsDirectory();
      String databasePath = p.join(directory.toString(), path);
      db = await openDatabase(databasePath, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
            create table $tableName ( 
              $columnId integer primary key,
              $columnType text not null,
              $columnName text not null,
              $columnSetCode text not null,
              $columnSetRarity text not null,
              $columnEdition text,
              $columnCondition text not null,
              $columnDate text not null,
              $columnPrice text
              )
            ''');
        },
      );
    }catch(e){
      print("[DatabaseModel.open] $e");
      notifyListeners();
    }
  }

  saveCardToSQLite(TCGCard card) async {
    try{
      Directory directory = await getApplicationDocumentsDirectory();
      String databasePath = p.join(directory.toString(), dbName);
      Database sqlDB = await openDatabase(databasePath);
      await sqlDB.execute('''
          REPLACE INTO $tableName 
          ($columnId, $columnType, $columnName, $columnSetCode, $columnSetRarity, $columnEdition, $columnCondition, $columnDate, $columnPrice)  VALUES 
          (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ''',
          [card.id, card.type, card.name, card.setCode, card.setRarity,
            card.edition, card.condition, DateTime.now().toString(), buyMode?"${isLowestPrice?"Lowest":"Market"} Price \$${card.getPrice().toStringAsFixed(2)} $appCurrency":null]
      );
      await sqlDB.close();
    }catch(e){
      print("[DatabaseModel.saveCardToSQLite] $e");
    }
  }

  getAllCardsFromSql()async{
    try{
      await open(dbName);
      List<Map> maps = await db.query(tableName);
      print("[DatabaseModel.getAllCardsFromSql] ${maps.length}");
      scanHistories.clear();
      for(var map in maps){
        TCGCard card = TCGCard.fromHistoryJson(map);
        scanHistories.add(card);
      }
      await db.close();
    }catch(e){
      print("[DatabaseModel.getAllCardsFromSql] $e");
    }
    notifyListeners();
  }

  Future close() async => db.close();
}