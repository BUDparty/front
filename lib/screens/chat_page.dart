import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
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
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = "sk-proj-bOtVoAbqkiIn7YBQZPHRT3BlbkFJHPpKkijp3MLaxoloxcwr";

  @override
  void initState() {
    super.initState();
    _messages.add({'role': 'bot', 'content': '한국말과 북한말에 대해 궁금한걸 뭐든 물어보세요'});
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'content': message});
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: utf8.encode(jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
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
