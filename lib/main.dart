import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/chat_page.dart';
import 'screens/word_learning_page.dart';
import 'screens/progress_page.dart';
import 'screens/library_page.dart';
import 'screens/settings_page.dart';
import 'screens/learning_page.dart';
import 'screens/evaluation_page.dart';
import 'screens/evaluation_learning_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '온새미로',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}