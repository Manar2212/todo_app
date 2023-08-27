// Todo application

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_projects/shared/cubit/states.dart';
import 'package:sqflite/sqflite.dart';
import '../../modules/archived_tasks/archived_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';


class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitailState());

  static AppCubit get(context) =>
      BlocProvider.of(context); // function return object from AppCubit

  int Currentindex = 0;
  List<Widget> Screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void ChangeIndex(index) {
    Currentindex = index;
    emit(AppChangeBottomNavBarState());
  }

  Database? database;

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];

  void createDatabase() {
    openDatabase('todo.db', version: 1,

        // id integer
        //title string
        //date string
        //time string
        //status string

        onCreate: (database, version) async {
          print('database created');
          await database
              .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT, date TEXT,time TEXT,status TEXT) ')
              .then((value) {
            print('tables created');
          }).catchError((error) {
            print('Error while creating tables ${error.toString()}');
          });
        }, onOpen: (database) {
          getDataFromDataase(database);
          print('database opened');
        }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    @required String? title,
    @required String? time,
    @required String? date,
  }) async {
    await database!.transaction((txn) {
      txn
          .rawInsert(
          'INSERT INTO tasks(title,date,time,status) VALUES ("$title","$date","$time","new")')
          .then((value) {
        print('$value Inserted Sucessfuly');
        emit(AppInsertDatabaseState());

        getDataFromDataase(database);
      }).catchError((error) {
        print('Error while inserting a new record ${error.toString()}');
      });

      return Future(() => null);
    });
  }

  void getDataFromDataase(database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());
    await database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else {
          archivedTasks.add(element);
        }
      });

      emit(AppGetDatabaseState());
    });
    ;
  }

  bool isBottomSheetShown = false;

  IconData fabIcon = Icons.edit;

  void ChangeBottomSheetState({
    @required bool? isShow,
    @required IconData? icon,
  }) {
    isBottomSheetShown = isShow!;
    fabIcon = icon!;
    emit(AppChangeBottomSheetState());
  }

  void UpdateDatabase({
    @required String? status,
    @required int? id,
  }) async {
    await database!.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {
      getDataFromDataase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void DeleteDatabase({@required int? id}) async {
    await database!
        .rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getDataFromDataase(database);
      emit(AppDeleteDatabaseState());
    });
  }
}


