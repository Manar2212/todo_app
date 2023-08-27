import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../shared/components/constants.dart';
import 'package:buildcondition/buildcondition.dart';
import '../shared/components/components.dart';
import '../shared/cubit/cubit.dart';
import '../shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  //1- create database
  //2- create tables
  //3- open database
  //4- insert to database
  //5- get from database
  //6- update in database
  //7- delete from database

  var scaffoldkey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (BuildContext context, AppStates state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, AppStates state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: scaffoldkey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.Currentindex]),
            ),
            body: BuildCondition(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) => cubit.Screens[cubit.Currentindex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (cubit.isBottomSheetShown) {
                  if (formkey.currentState!.validate()) {
                    cubit.insertToDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text);
                  }
                } else {
                  scaffoldkey.currentState!
                      .showBottomSheet((context) => Form(
                            key: formkey,
                            child: Container(
                              padding: EdgeInsets.all(20.0),
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  defaultTextFormField(
                                      controller: titleController,
                                      inputType: TextInputType.text,
                                      text: 'Title Task',
                                      prefix: Icons.title,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'title must be not empty';
                                        } else {
                                          return null;
                                        }
                                      }),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  defaultTextFormField(
                                    controller: timeController,
                                    inputType: TextInputType.datetime,
                                    text: 'Time Task',
                                    prefix: Icons.watch_later_outlined,
                                    validate: (value) {
                                      if (value!.isEmpty) {
                                        return 'time must be not empty';
                                      } else {
                                        return null;
                                      }
                                    },
                                    ontap: () {
                                      showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now())
                                          .then((value) {
                                        timeController.text =
                                            value!.format(context);
                                        print(value.format(context));
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  defaultTextFormField(
                                      controller: dateController,
                                      inputType: TextInputType.datetime,
                                      text: 'Date Task',
                                      prefix: Icons.calendar_today,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'Date must be not empty';
                                        } else {
                                          return null;
                                        }
                                      },
                                      ontap: () {
                                        showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.parse(
                                                    '2023-03-06'))
                                            .then((value) {
                                          dateController.text =
                                              DateFormat.yMMMMd()
                                                  .format(value!);
                                          print(
                                              DateFormat.yMMMd().format(value));
                                        });
                                      })
                                ],
                              ),
                            ),
                          ))
                      .closed
                      .then((value) {
                    cubit.ChangeBottomSheetState(
                        isShow: false, icon: Icons.edit);
                  });
                  cubit.ChangeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: cubit.Currentindex,
              onTap: (index) {
                cubit.ChangeIndex(index);
              },
              items: [
                BottomNavigationBarItem(label: 'Tasks', icon: Icon(Icons.menu)),
                BottomNavigationBarItem(
                    label: 'Done', icon: Icon(Icons.check_circle_outline)),
                BottomNavigationBarItem(
                    label: 'Archived', icon: Icon(Icons.archive)),
              ],
            ),
          );
        },
      ),
    );
  }
}
