import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:my_projects/shared/bloc_observer.dart';
import 'layout/todo_layout.dart';


void main()
{
  Bloc.observer = MyBlocObserver();

  runApp(MyApp());
}



class MyApp extends StatelessWidget
{


  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeLayout(),
    );
  }
}