// 필요한 패키지들을 임포트합니다.
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

// 애플리케이션의 진입점입니다.
void main() {
  runApp(MyApp());
}

// MyApp 클래스는 애플리케이션의 루트 위젯입니다.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chatbot', // 애플리케이션의 제목입니다.
      theme: ThemeData(
        primarySwatch: Colors.blue, // 기본 테마 색상을 파란색으로 설정합니다.
      ),
      home: ChatPage(), // 기본 화면으로 ChatPage를 설정합니다.
    );
  }
}

// ChatPage 클래스는 챗봇과의 대화 화면을 나타냅니다.
class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

// _ChatPageState 클래스는 ChatPage의 상태를 관리합니다.
class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController(); // 텍스트 입력 컨트롤러입니다.
  final List<Map<String, String>> _messages = []; // 메시지 목록을 저장합니다.
  final String apiKey = dotenv.env['OPENAI_API_KEY']!; // OpenAI API 키입니다.

  @override
  void initState() {
    super.initState();
    // 초기 메시지를 추가합니다.
    _messages.add({'role': 'bot', 'content': '한국말과 북한말에 대해 궁금한걸 뭐든 물어보세요'});
  }

  // 사용자의 메시지를 전송하는 비동기 함수입니다.
  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'content': message}); // 사용자의 메시지를 추가합니다.
    });

    // OpenAI API에 POST 요청을 보냅니다.
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: utf8.encode(jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are an expert in North and South Korean languages.'},
          {'role': 'user', 'content': message},
        ],
      })),
    );

    if (response.statusCode == 200) {
      // 응답이 성공적일 경우, 응답 메시지를 추가합니다.
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _messages.add({'role': 'bot', 'content': responseBody['choices'][0]['message']['content']});
      });
    } else {
      // 응답이 실패할 경우, 에러 메시지를 추가합니다.
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
        title: Text('AI와 대화하기'), // 앱바의 제목입니다.
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length, // 메시지의 수입니다.
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: message['role'] == 'user' ? Colors.blue[100] : Colors.green[100], // 메시지의 배경 색상입니다.
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: Text(message['content']!), // 메시지의 내용을 표시합니다.
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
                    controller: _controller, // 텍스트 입력 컨트롤러입니다.
                    decoration: InputDecoration(
                      hintText: 'Text message', // 힌트 텍스트입니다.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send), // 전송 버튼 아이콘입니다.
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text); // 메시지를 전송합니다.
                      _controller.clear(); // 입력 필드를 초기화합니다.
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
