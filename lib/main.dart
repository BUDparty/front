import 'package:flutter/material.dart';
import 'package:onsaemiro/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/models.dart';
import 'screens/home_page.dart';
import 'settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env"); // 환경 변수를 로드합니다.

  try {
    ApiService apiService = ApiService();
    Chapter nextChapter = await apiService.fetchNextChapter();
    print('Next chapter loaded: ${nextChapter.title}');
  } catch (e) {
    print('Error in main: $e');
  }

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
          title: '시나브로',
          theme: settingsProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          home: HomePage(),
        );
      },
    );
  }
}
