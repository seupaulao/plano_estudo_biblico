// usar sqlite para banco de dados
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> openPrepopulatedDatabase() async {
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'my_data.db');

  // Check if the database already exists
  bool exists = await databaseExists(path);

  if (!exists) {
    // Copy from asset
    ByteData data = await rootBundle.load(join('assets', 'my_data.db'));
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await File(path).writeAsBytes(bytes, flush: true);
  }

  return await openDatabase(path);
}

class Biblia {
  final String id;
  final String texto;
  final bool like;
  const Biblia({required this.id, required this.texto, required this.like});
}

Future<String> getTexto(String livro, int cap, int vers) async {
  var chave = "${livro}_${cap}_$vers";

  final dbfut = openPrepopulatedDatabase();
  final db = await dbfut;
  final List<Map<String, dynamic>> resultado = await db.query(
    "biblia",
    where: "id = ?",
    whereArgs: [chave],
  );
  if (resultado.isNotEmpty) {
    return resultado.first['texto'];
  }
  return '';
}
