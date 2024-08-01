import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with TickerProviderStateMixin {
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

  late stt.SpeechToText _speech;
  late AudioPlayer _audioPlayer;
  bool isListening = false;
  bool isLoading = false;
  String recognizedText = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<Map<String, String>> _conversations = [];
  late String apiKey;
  int conversationCount = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
    fetchApiKey();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> fetchApiKey() async {
    final response = await http.get(Uri.parse('$baseUrl/get-api-key/'));

    if (response.statusCode == 200) {
      setState(() {
        apiKey = jsonDecode(utf8.decode(response.bodyBytes))['api_key'];
      });
    } else {
      throw Exception('Failed to load API key');
    }
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: utf8.encode(jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': '너는 입력된 모든 문장을 표준한국어로 변환하는 작업만 진행하면 되. 추가 설명은 필요없어.'},
          {'role': 'user', 'content': message},
        ],
      })),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      String standardText = responseBody['choices'][0]['message']['content'];
      setState(() {
        _conversations.add({
          'original': message,
          'standard': standardText
        });
        isLoading = false;
        conversationCount++;
      });
      _playTextToSpeech(standardText);
      if (conversationCount >= 5) {
        _showSummaryAndExit();
      }
    } else {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _conversations.add({
          'original': message,
          'standard': 'Error: ${responseBody['error']['message']}\nPlease check your quota at: https://platform.openai.com/account/usage'
        });
        isLoading = false;
      });
    }
  }

  Future<void> _playTextToSpeech(String text) async {
    try {
      final audioUrl = await fetchAudioUrl(text);
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  static Future<String> fetchAudioUrl(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/typecast-speak/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['audio_url'];
    } else {
      throw Exception('Failed to fetch audio URL');
    }
  }

  void _showSummaryAndExit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationSummary(conversations: _conversations),
      ),
    ).then((_) {
      Future.delayed(Duration(seconds: 5), () {
        Navigator.of(context).pop();
      });
    });
  }

  void _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => isListening = true);
        _animationController.forward();
        _speech.listen(
          onResult: (val) => setState(() {
            recognizedText = val.recognizedWords;
          }),
          listenFor: Duration(seconds: 5),
          localeId: 'ko_KR',
        );
        await Future.delayed(Duration(seconds: 5));
        _speech.stop();
        _animationController.reverse();
        setState(() => isListening = false);
        _sendMessage(recognizedText);
      } else {
        setState(() => isListening = false);
        _speech.stop();
        _animationController.reverse();
      }
    } else {
      print('Microphone permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI와 대화하기'),
      ),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: isListening ? null : _startListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: isListening ? Colors.grey : Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: ScaleTransition(
                scale: _animation,
                child: Text(
                  isListening ? '듣는중...' : '말하기 시작',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

class ConversationSummary extends StatelessWidget {
  final List<Map<String, String>> conversations;

  ConversationSummary({required this.conversations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대화 요약'),
      ),
      body: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('내가 말한 것:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(conversation['original']!, style: TextStyle(color: Colors.black)),
                SizedBox(height: 5),
                Text('표준말로 변환된 것:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(conversation['standard']!, style: TextStyle(color: Colors.blue)),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
