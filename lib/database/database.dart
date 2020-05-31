import 'dart:ui';

import 'package:cheon/database/daos/study_dao.dart';
import 'package:cheon/database/daos/subject_dao.dart';
import 'package:cheon/database/daos/teacher_dao.dart';
import 'package:cheon/database/daos/exam_dao.dart';
import 'package:cheon/database/daos/lesson_dao.dart';
import 'package:cheon/database/daos/test_dao.dart';
import 'package:cheon/database/daos/timetable_dao.dart';
import 'package:cheon/database/daos/task_dao.dart';
import 'package:cheon/database/tables.dart';
import 'package:cheon/dependency_injection.dart';
import 'package:cheon/database/converters/uuid_converter.dart';
import 'package:cheon/database/converters/color_converter.dart';
import 'package:moor/moor.dart';

part 'database.g.dart';

@UseMoor(
  // All the tables in the database
  tables: <Type>[
    Subjects,
    Teachers,
    Exams,
    Lessons,
    Timetables,
    Tests,
    Studying,
    LessonTimes,
    Tasks,
    SubTasks,
  ],
  // All the Data Access Objects used to interface with the database
  daos: <Type>[
    ExamDao,
    LessonDao,
    SubjectDao,
    TeacherDao,
    TestDao,
    TimetableDao,
    StudyDao,
    TaskDao,
  ],
)
class Database extends _$Database {
  Database._internal() : super(container<QueryExecutor>());

  /// Always returns the same static instance of [Database]
  static Database get instance => _singleton;

  static final Database _singleton = Database._internal();

  /// Must be updated every time a change to the schema is made. Sometimes a
  /// manual migration is also required.
  @override
  int get schemaVersion => 4;

  // Migrations are required when a change to the database schema is made.
  // They instruct the database to make the required changes for the old and new
  // schema to match.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          Future<void> deleteTables(List<String> tables) async {
            for (String tableName in tables) {
              await m.deleteTable(tableName);
            }
          }

          Future<void> createTables(
            List<TableInfo<Table, DataClass>> tables,
          ) async {
            for (TableInfo<Table, DataClass> table in tables) {
              await m.createTable(table);
            }
          }

          int currentVersion = from;
          while (currentVersion != to) {
            switch (currentVersion) {
              case 1:
                await m.addColumn(exams, exams.priority);
                await m.addColumn(tests, tests.priority);
                break;
              case 2:
                await m.addColumn(studying, studying.examId);
                await m.addColumn(studying, studying.testId);
                await m.addColumn(studying, studying.completed);
                await m.deleteTable('revision');
                break;
              case 3:
                await createTables([tasks, subTasks]);
                await deleteTables([
                  'events',
                  'reminders',
                  'terms',
                  'years',
                  'inset_day',
                  'homework',
                ]);

                break;
              case 4:
                break;
            }
            currentVersion++;
          }
        },
        beforeOpen: (OpeningDetails openingDetails) async {
          // Can be used to run operations e.g. prefill tables at start up
        },
      );
}
