import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'rouge_l.dart';
import 'accent_evaluation_result_page.dart';

class AccentEvaluationPage extends StatefulWidget {
  final int chapterId;

  AccentEvaluationPage({required this.chapterId});

  @override
  _AccentEvaluationPageState createState() => _AccentEvaluationPageState();
}

class _AccentEvaluationPageState extends State<AccentEvaluationPage> {

  static const String _localBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _productionBaseUrl = 'https://your-production-server.com/api';

  // 기본 URL을 동적으로 설정합니다.
  static String get baseUrl {
    if (kIsWeb) {
      return _productionBaseUrl;
    } else if (Platform.isAndroid) {
      return _androidEmulatorBaseUrl;
    } else if (Platform.isIOS) {
      return _localBaseUrl;
    } else {
      return _localBaseUrl;
    }
  }






  late Future<List<AppSentence>> futureSentences;
  late Future<Chapter> futureChapter;
  int currentIndex = 0;
  late stt.SpeechToText _speech;
  bool isListening = false;
  String recognizedText = '';

  List<Map<String, dynamic>> evaluationResults = [];
  List<AppSentence> sentences = [];

  @override
  void initState() {
    super.initState();
    futureSentences = ApiService().fetchSentences(widget.chapterId);
    futureChapter = ApiService().fetchChapter(widget.chapterId);
    _speech = stt.SpeechToText();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> _updateSentenceAccuracyAndText(int sentenceId, double accuracy, String recognizedText) async {
    final String url = '$baseUrl/sentences/$sentenceId/update_accuracy_and_text/';
    final Map<String, dynamic> data = {
      'accuracy': accuracy,
      'recognized_text': recognizedText,
    };

    print('Request URL: $url');
    print('Request body: ${jsonEncode(data)}');

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Update successful');
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to update sentence accuracy and text');
      }
    } catch (e) {
      print('Error updating accuracy and text: $e');
    }
  }



  void _nextSentence() {
    setState(() {
      if (currentIndex < sentences.length - 1) {
        currentIndex++;
      }
    });
  }

  void _prevSentence() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void _completeEvaluation() async {
    try {
      // 서버에서 데이터 업데이트가 완료되도록 잠시 대기
      await Future.delayed(Duration(seconds: 1));

      print('Navigating to evaluation result page');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AccentEvaluationResultPage(
            chapterId: widget.chapterId,
          ),
        ),
      );
    } catch (e) {
      print('Error in _completeEvaluation: $e');
    }
  }


  void _startListening() async {
    await _checkPermissions();

    try {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          setState(() {
            if (val == 'done' || val == 'notListening') {
              isListening = false;
              _evaluateSpeech();
            }
          });
        },
        onError: (val) {
          print('onError: $val');
          setState(() {
            isListening = false;
            _showErrorDialog('Speech recognition error: ${val.errorMsg}');
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
            });
          },
          listenFor: Duration(seconds: 5),
          pauseFor: Duration(seconds: 3),
          partialResults: false,
          localeId: 'ko_KR',
        );
      } else {
        print('Speech recognition not available');
        _showErrorDialog('Speech recognition is not available on this device.');
      }
    } catch (e) {
      print('Speech recognition initialization failed: $e');
      _showErrorDialog('Failed to initialize speech recognition.');
    }
  }

  void _stopListening() {
    if (!isListening) return;
    setState(() => isListening = false);
    _speech.stop();
  }

  void _evaluateSpeech() async {
    final referenceText = sentences[currentIndex].koreanSentence;
    final result = calculateRougeL(referenceText, recognizedText);
    final score = result['f1Score']!;
    _saveEvaluationResult(score);
  }

  void _saveEvaluationResult(double score) async {
    if (score.isNaN || score.isInfinite) {
      print('Invalid score: $score');
      return;
    }
    final sentence = sentences[currentIndex];
    try {
      await _updateSentenceAccuracyAndText(sentence.id, score, recognizedText);
      evaluationResults.add({
        'sentence': sentence.koreanSentence,
        'recognized': recognizedText,
        'score': score,
      });
      if (currentIndex < sentences.length - 1) {
        _nextSentence();
      } else {
        // 평가가 끝난 후에 _completeEvaluation을 호출합니다.
        await Future.delayed(Duration(seconds: 1)); // 서버에서 데이터 업데이트가 완료되도록 잠시 대기
        _completeEvaluation();
      }
    } catch (e) {
      print('Error updating accuracy and text: $e');
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFF3FA),
      appBar: AppBar(
        title: Text('Accent Evaluation'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _completeEvaluation,
          ),
        ],
      ),
      body: FutureBuilder<List<AppSentence>>(
        future: futureSentences,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching sentences: ${snapshot.error}');
            return Center(child: Text('Failed to load sentences'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No sentences available'));
          } else {
            sentences = snapshot.data!;
            AppSentence currentSentence = sentences[currentIndex];
            return FutureBuilder<Chapter>(
              future: futureChapter,
              builder: (context, chapterSnapshot) {
                if (chapterSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (chapterSnapshot.hasError) {
                  print('Error fetching chapter: ${chapterSnapshot.error}');
                  return Center(child: Text('Failed to load chapter'));
                } else if (!chapterSnapshot.hasData) {
                  return Center(child: Text('No chapter available'));
                } else {
                  Chapter chapter = chapterSnapshot.data!;
                  return Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('#${chapter.id} #${chapter.title}', style: TextStyle(fontSize: 14)),
                                SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(currentSentence.koreanSentence, style: TextStyle(fontSize: 24)),
                                        Text(': ${currentSentence.northKoreanSentence}', style: TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text('Greetings', style: TextStyle(fontSize: 16)),
                                SizedBox(height: 5),
                                Text('${sentences.length} sentences', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          Expanded(child: Container()),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => isListening ? _stopListening() : _startListening(),
                                  child: Text(isListening ? '듣기 중지하기' : '직접 말하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (currentIndex > 0)
                                  ElevatedButton(
                                    onPressed: _prevSentence,
                                    child: Text('이전', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                if (currentIndex < sentences.length - 1)
                                  ElevatedButton(
                                    onPressed: _nextSentence,
                                    child: Text('다음', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                if (currentIndex == sentences.length - 1)
                                  ElevatedButton(
                                    onPressed: _completeEvaluation,
                                    child: Text('평가 완료', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
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
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
