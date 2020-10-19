import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pract_dos/home/home_page.dart';
import 'package:pract_dos/models/todo_reminder.dart';

void main() async {
  //Inicializa antes de crear la app
  WidgetsFlutterBinding.ensureInitialized();
  //Local Storage
  final _localStorage = await getApplicationSupportDirectory();
  Hive
  ..init(_localStorage.path)
  ..registerAdapter(prac2adapter());
  //Open Box
  await Hive.openBox("ReminderList");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Practica 2',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
       backgroundColor: Colors.black12
      ),
      home: HomePage(),
    );
  }
}
