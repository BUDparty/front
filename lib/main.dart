import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_page.dart';
import 'screens/chat_page.dart';
import 'screens/word_learning_page.dart';
import 'screens/progress_page.dart';
import 'screens/library_page.dart';
import 'screens/settings_page.dart';
import 'screens/learning_page.dart';
import 'screens/evaluation_page.dart';
import 'screens/evaluation_learning_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';
import 'settings_provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: '온새미로',
          theme: settingsProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: HomePage(),
        );
      },
    );
  }
}