import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openConnectionImpl() async {
  final result = await WasmDatabase.open(
    databaseName: 'chat',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  return result.resolvedExecutor;
}
