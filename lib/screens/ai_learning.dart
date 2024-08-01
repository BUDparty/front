import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'rouge_l.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiLearningPage extends StatefulWidget {
  @override
  _AiLearningPageState createState() => _AiLearningPageState();
}

class _AiLearningPageState extends State<AiLearningPage> {
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

  List<String> sentences = [];
  int currentIndex = 0;
  late AudioPlayer audioPlayer;
  late stt.SpeechToText _speech;
  bool isListening = false;
  bool isPlaying = false;
  bool isLoading = false;
  String recognizedText = '';
  int playCount = 0;
  late String apiKey;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    _speech = stt.SpeechToText();
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchApiKey();
    _generateNewSentence();
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

  Future<void> _generateNewSentence() async {
    setState(() {
      isLoading = true;
    });

    if (apiKey.isEmpty) {
      await fetchApiKey();
    }

    List<String> situations = [
      '일상 대화',
      '비즈니스 미팅',
      '쇼핑 대화',
      '여행 대화',
      '의료 상담',
      '학교 대화',
      '식당 주문',
      '길 안내',
      '취미 활동',
      '운동 대화'
    ];

    String selectedSituation = situations[Random().nextInt(situations.length)];

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: utf8.encode(jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': '다음 상황에 맞는 자연스러운 한국어 문장을 30자 이내로 하나 생성하세요. 질문이 아닌 대화중 일부를 생성하세요.: $selectedSituation'
          },
        ],
      })),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
      String newSentence = responseBody['choices'][0]['message']['content'].trim();
      setState(() {
        sentences.add(newSentence);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load sentence');
    }
  }

  Future<void> _playTextToSpeech(String text) async {
    try {
      await _checkPermissions();

      // API를 호출하여 음성 URL을 가져옵니다.
      final audioUrl = await ApiService.fetchAudioUrl(text);

      setState(() {
        isPlaying = true;
        playCount = 0;
      });

      await audioPlayer.play(UrlSource(audioUrl));  // UrlSource로 URL을 직접 재생

      audioPlayer.onPlayerComplete.listen((event) async {
        playCount++;
        if (playCount < 1) {
          await audioPlayer.play(UrlSource(audioUrl));  // UrlSource로 URL을 직접 재생
        } else {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            isPlaying = false;
          });
        }
      });
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  Future<void> _stopTextToSpeech() async {
    await audioPlayer.stop();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _checkPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission denied');
    }
  }

  void _startListening() async {
    await _checkPermissions();

    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        setState(() {
          if (val == 'done' || val == 'notListening') {
            isListening = false;
          }
        });
      },
      onError: (val) {
        print('onError: $val');
        setState(() {
          isListening = false;
        });
      },
    );
    if (available) {
      setState(() => isListening = true);
      _speech.listen(
        onResult: (val) {
          print('onResult: ${val.recognizedWords}');
          setState(() {
            recognizedText = val.recognizedWords;
            _evaluateSpeech();
          });
        },
        listenFor: Duration(seconds: 60), // Long duration to allow manual stopping
        pauseFor: Duration(seconds: 3),
        partialResults: false,
        localeId: 'ko_KR',
        onSoundLevelChange: (level) {
          print('Sound level: $level');
        },
      );
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
  }

  void _stopListening() {
    if (!isListening) return;
    setState(() => isListening = false);
    _speech.stop();
  }

  void _evaluateSpeech() {
    final referenceText = sentences[currentIndex];
    final result = calculateRougeL(referenceText, recognizedText);
    final score = result['f1Score']!;
    final precision = result['precision']!;
    final recall = result['recall']!;
    _showEvaluationPopup(score, precision, recall);
  }

  void _showEvaluationPopup(double score, double precision, double recall) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('평가 결과'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('억양 정확도: ${(score * 100).toStringAsFixed(2)}%'),
              SizedBox(height: 10),
              Text('인식된 내용: $recognizedText'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _nextSentence() {
    if (currentIndex < sentences.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _generateNewSentence().then((_) {
        setState(() {
          currentIndex++;
        });
      });
    }
  }

  void _previousSentence() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFF3FA),
      appBar: AppBar(
        title: Text('AI와 학습하기'),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('문장을 생성하고 있습니다!'),
                ],
                isRepeatingAnimation: true,
              ),
            ),
          ],
        ),
      )
          : sentences.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            DefaultTextStyle(
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  WavyAnimatedText('문장을 생성하고 있습니다!'),
                ],
                isRepeatingAnimation: true,
              ),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${currentIndex + 1} 문장', style: TextStyle(fontSize: 14)),
                    SizedBox(height: 10),
                    Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sentences[currentIndex], style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _playTextToSpeech(sentences[currentIndex]),
                      child: Text('음성 듣기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        elevation: 5,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _stopTextToSpeech,
                      child: Text('듣기 중지하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.red,
                        minimumSize: Size(double.infinity, 50),
                        elevation: 5,
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _startListening,
                      child: Text('직접 말하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        elevation: 5,
                      ),
                    ),
                    SizedBox(height: 10),
                    if (currentIndex > 0)
                      ElevatedButton(
                        onPressed: _previousSentence,
                        child: Text('이전', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.black),
                          elevation: 5,
                        ),
                      ),
                    SizedBox(height: 10),
                    if (currentIndex < 9)
                      ElevatedButton(
                        onPressed: _nextSentence,
                        child: Text('다음', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          side: BorderSide(color: Colors.black),
                          elevation: 5,
                        ),
                      ),
                    if (currentIndex == 9)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            currentIndex = 0;
                            sentences.clear();
                            _generateNewSentence();
                          });
                        },
                        child: Text('완료하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          elevation: 5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (isListening)
            Positioned(
              top: 10,
              right: 10,
              child: ElevatedButton(
                onPressed: _stopListening,
                child: Text('말하기 중지', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          if (isListening)
            Column(
              children: [
                Spacer(),
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(1.0),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: AnimatedTextKit(
                      animatedTexts: [
                        WavyAnimatedText(
                          '말하는 중...',
                          textStyle: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                      isRepeatingAnimation: true,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

Map<String, double> calculateRougeL(String reference, String hypothesis) {
  // Implement the ROUGE-L calculation logic here
  return {
    'f1Score': 0.9, // Placeholder
    'precision': 0.85, // Placeholder
    'recall': 0.95, // Placeholder
  };
}
