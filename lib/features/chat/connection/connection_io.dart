import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<QueryExecutor> openConnectionImpl() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'chat.sqlite'));
  return NativeDatabase(file);
}
