import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';

void main() async {
  // await dotenv.load(fileName: ".env"); // Load environment variables
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
  static const String _localBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _productionBaseUrl = 'http://35.202.241.53/api';

  // Dynamically set the base URL
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

  final List<String> _userMessages = [];
  final List<String> _botMessages = [];
  late String apiKey;
  late stt.SpeechToText _speech;
  bool isListening = false;
  bool isTtsPlaying = false; // TTS 상태 변수 추가
  String recognizedText = '';
  late AudioPlayer audioPlayer;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _listeningController; // 듣는중 애니메이션 컨트롤러
  late Animation<double> _listeningAnimation; // 듣는중 애니메이션
  late AnimationController _ttsController; // TTS 애니메이션 컨트롤러
  late Animation<double> _ttsAnimation; // TTS 애니메이션
  bool isLoading = false; // 로딩 상태 변수 추가
  int messageCount = 0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    audioPlayer = AudioPlayer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);

    _listeningController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true); // 애니메이션 반복
    _listeningAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_listeningController);

    _ttsController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
    _ttsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_ttsController);
    fetchApiKey();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _listeningController.dispose();
    _ttsController.dispose();
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
      _userMessages.add(message);
      isLoading = true; // 로딩 상태 시작
    });

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'system', 'content': '너는 입력된 모든 문장을 표준한국어로 변화하는 작업만 진행하면되. 추가 설명은 필요없어.'},
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      String responseMessage = responseBody['choices'][0]['message']['content'];
      setState(() {
        _botMessages.add(responseMessage);
        isLoading = false; // 로딩 상태 종료
        messageCount++;
        if (messageCount >= 5) {
          _showAllMessages();
        } else {
          _playTextToSpeech(responseMessage);
        }
      });
    } else {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        _botMessages.add('Error: ${responseBody['error']['message']}\nPlease check your quota at: https://platform.openai.com/account/usage');
        isLoading = false; // 로딩 상태 종료
      });
    }
  }

  Future<void> _playTextToSpeech(String text) async {
    String truncatedText = _truncateText(text, 30);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/typecast-speak/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': truncatedText}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        String audioUrl = responseBody['audio_url'];

        setState(() {
          isTtsPlaying = true; // TTS 재생 상태 시작
        });

        await audioPlayer.play(UrlSource(audioUrl));

        audioPlayer.onPlayerComplete.listen((event) {
          setState(() {
            isTtsPlaying = false; // TTS 재생 상태 종료
          });
        });
      } else {
        throw Exception('Failed to fetch audio from Typecast API');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  String _truncateText(String text, int maxWords) {
    List<String> words = text.split(' ');
    if (words.length > maxWords) {
      return words.sublist(0, maxWords).join(' ') + '...';
    }
    return text;
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
            _sendMessage(recognizedText);
            _animationController.reverse();
            isListening = false; // 마이크 버튼 다시 활성화
          }),
          localeId: 'ko_KR',
        );
      } else {
        setState(() => isListening = false);
        _speech.stop();
        _animationController.reverse();
      }
    } else {
      print('Microphone permission denied');
    }
  }

  void _showAllMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConversationSummary(
          userMessages: _userMessages,
          botMessages: _botMessages,
        ),
      ),
    ).then((_) => _resetConversation());
  }

  void _resetConversation() {
    setState(() {
      _userMessages.clear();
      _botMessages.clear();
      messageCount = 0;
    });
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
              child: CircularProgressIndicator(), // 로딩 애니메이션 추가
            ),
          if (isTtsPlaying)
            Center(
              child: RotationTransition(
                turns: _ttsAnimation,
                child: Text(
                  '재생중...',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConversationSummary extends StatelessWidget {
  final List<String> userMessages;
  final List<String> botMessages;

  ConversationSummary({required this.userMessages, required this.botMessages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대화 내용'),
      ),
      body: ListView.builder(
        itemCount: userMessages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User: ${userMessages[index]}', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('AI: ${botMessages[index]}', style: TextStyle(color: Colors.blue)),
                SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}
