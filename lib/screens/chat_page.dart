import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
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
  static const String _productionBaseUrl = 'http://35.202.241.53/api';

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
  late String apiKey;
  String _threadId = 'thread_y13Gs47cjDtmvkmVqmVmdgCT'; // 이미 생성된 스레드 ID를 사용
  String _response = '';

  @override
  void initState() {
    super.initState();
    fetchApiKey();
    _messages.add({'role': 'bot', 'content': '한국말과 북한말에 대해 궁금한걸 뭐든 물어보세요'});
  }

  Future<void> fetchApiKey() async {
    final response = await http.get(Uri.parse('$baseUrl/get-api-key/'));

    if (response.statusCode == 200) {
      setState(() {
        apiKey = jsonDecode(response.body)['api_key'];
        print('API Key fetched: $apiKey');  // API 키 로그
      });
    } else {
      throw Exception('Failed to load API key');
    }
  }

  Future<void> _sendMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat-with-assistant/'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _messages.add({'role': 'user', 'content': message});
        _messages.add({'role': 'bot', 'content': responseBody['response']});
      });
    } else {
      setState(() {
        _messages.add({'role': 'bot', 'content': 'Error: Unable to send message.'});
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
                      setState(() {
                        _messages.add({'role': 'user', 'content': _controller.text});
                      });
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
