import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env"); // 환경 변수를 로드합니다.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {


  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const String _localBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _productionBaseUrl = 'http://35.202.241.53/api';

  // 기본 URL을 동적으로 설정합니다.
  static String get baseUrl {
    if (kIsWeb) {
      return _productionBaseUrl;
    } else if (Platform.isAndroid) {
      return _productionBaseUrl;
    } else if (Platform.isIOS) {
      return _productionBaseUrl;
    } else {
      return _productionBaseUrl;
    }
  }


  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  late final String apiKey;

  @override
  void initState() {
    super.initState();

    //apiKey = dotenv.env['API_KEY']!;
    _messages.add({'role': 'bot', 'content': '한국말과 북한말에 대해 궁금한걸 뭐든 물어보세요'});
  }

  Future<void> fetchApiKey() async {
    final response = await http.get(Uri.parse('$baseUrl/get-api-key/'));

    if (response.statusCode == 200) {
      setState(() {
        apiKey = jsonDecode(response.body)['api_key'];
      });
    } else {
      throw Exception('Failed to load API key');
    }
  }


  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'content': message});
    });

    fetchApiKey();
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: utf8.encode(jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {'role': 'system', 'content': '너는 한국말과 북한말에 대한 전문가야. 물어보는 질문에 한국말로 대답해줘.'},
          {'role': 'user', 'content': message},
        ],
      })),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _messages.add({'role': 'bot', 'content': responseBody['choices'][0]['message']['content']});
      });
    } else {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _messages.add({
          'role': 'bot',
          'content': 'Error: ${responseBody['error']['message']}\nPlease check your quota at: https://platform.openai.com/account/usage'
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI와 대화하기'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: message['role'] == 'user' ? Colors.blue[100] : Colors.green[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(message['content']!),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Text message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
