// usar sqlite para banco de dados
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<Database> openPrepopulatedDatabase() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa FFI para desktop - remover ao tentar usar mobile
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final database = await openDatabase(
    join(await getDatabasesPath(), 'banco.db'),
  );
  return database;
}

class Biblia {
  final String id;
  final String texto;
  final int gostei;
  const Biblia({required this.id, required this.texto, required this.gostei});
}

class Livros {
  final String id;
  final String nome;
  final int capitulos;
  const Livros({required this.id, required this.nome, required this.capitulos});
}

Future<String> getNomeLivro(String chave) async {
  final db = await openPrepopulatedDatabase();
  final List<Map<String, dynamic>> resultado = await db.query(
    "livros",
    where: "id = ?",
    whereArgs: [chave],
  );
  if (resultado.isNotEmpty) {
    return resultado.first['nome'];
  }
  return '';
}

Future<int> getQuantidadeCapitulos(String chave) async {
  final db = await openPrepopulatedDatabase();
  final List<Map<String, dynamic>> resultado = await db.query(
    "livros",
    where: "id = ?",
    whereArgs: [chave],
  );
  if (resultado.isNotEmpty) {
    return resultado.first['capitulos'];
  }
  return -1;
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
