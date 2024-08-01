import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_provider.dart';
import 'test_page.dart'; // TestPage import

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('환경 설정'),
      ),
      body: ListView(
        children: <Widget>[
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return SwitchListTile(
                title: Text('다크 모드'),
                value: settingsProvider.isDarkMode,
                onChanged: (bool value) {
                  settingsProvider.toggleDarkMode();
                },
              );
            },
          ),
          ListTile(
            title: Text('버전 정보'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: Text('Test Page'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestPage(// TestPage에 전달할 메시지 목록을 추가합니다.
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
