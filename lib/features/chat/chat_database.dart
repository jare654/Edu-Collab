import 'package:drift/drift.dart';
import 'connection/connection.dart';

part 'chat_database.g.dart';

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get sender => text()();
  TextColumn get content => text()();
  IntColumn get timeMs => integer()();
  BoolColumn get isMine => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

LazyDatabase _openConnection() => LazyDatabase(openConnection);

@DriftDatabase(tables: [ChatMessages])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Example future migration:
          // if (from < 2) {
          //   await m.addColumn(chatMessages, chatMessages.someNewColumn);
          // }
        },
      );

  Future<List<ChatMessage>> getMessages(String groupId) {
    return (select(chatMessages)
          ..where((tbl) => tbl.groupId.equals(groupId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.timeMs, mode: OrderingMode.asc)]))
        .get();
  }

  Future<void> upsertMessage(ChatMessagesCompanion entry) async {
    await into(chatMessages).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> clearGroup(String groupId) async {
    await (delete(chatMessages)..where((tbl) => tbl.groupId.equals(groupId))).go();
  }
}
