import 'dart:convert';
import 'dart:io';
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
import 'accent_learning_result_page.dart'; // 새로운 페이지 파일을 임포트합니다.

class AccentLearningPage extends StatefulWidget {
  final int chapterId;

  AccentLearningPage({required this.chapterId});

  @override
  _AccentLearningPageState createState() => _AccentLearningPageState();
}

class _AccentLearningPageState extends State<AccentLearningPage> {

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

  late Future<List<AppSentence>> futureSentences;
  late Future<Chapter> futureChapter;
  int currentIndex = 0;
  late AudioPlayer audioPlayer;
  late stt.SpeechToText _speech;
  bool isListening = false;
  bool isPlaying = false;
  String recognizedText = '';
  int playCount = 0;

  @override
  void initState() {
    super.initState();
    futureSentences = ApiService().fetchSentences(widget.chapterId);
    futureChapter = ApiService().fetchChapter(widget.chapterId);
    audioPlayer = AudioPlayer();
    _speech = stt.SpeechToText();
  }

  Future<void> _checkPermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print('Microphone permission granted');
    } else {
      print('Microphone permission denied');
    }
  }

  Future<void> _playTextToSpeech(String text) async {
    try {
      final audioUrl = await ApiService.fetchAudioUrl(text);

      setState(() {
        isPlaying = true;
      });

      await audioPlayer.play(UrlSource(audioUrl));  // UrlSource로 URL을 직접 재생

      audioPlayer.onPlayerComplete.listen((event) async {
        setState(() {
          isPlaying = false;
        });
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

  Future<void> _saveSentence(int sentenceId) async {
    final response = await http.post(Uri.parse('http://10.0.2.2:8000/api/sentences/$sentenceId/save/'));

    if (response.statusCode == 200) {
      setState(() {
        futureSentences = futureSentences.then((sentences) {
          sentences[currentIndex].isCorrect = true;
          return sentences;
        });
      });
    } else {
      throw Exception('Failed to save sentence');
    }
  }

  Future<void> _updateSentenceIsCalled(int sentenceId) async {
    await ApiService().updateSentenceIsCalled(sentenceId);
  }

  void _nextSentence(List<AppSentence> sentences) async {
    await _updateSentenceIsCalled(sentences[currentIndex].id);
    setState(() {
      if (currentIndex < sentences.length - 1) {
        currentIndex++;
      }
    });
  }

  void _completeLearning() async {
    final sentences = await ApiService().fetchSentences(widget.chapterId);

    for (var sentence in sentences) {
      if (!sentence.isCalled) {
        await ApiService().updateSentenceIsCalled(sentence.id);
      }
    }

    final updatedSentences = await ApiService().fetchSentences(widget.chapterId);
    final progress = updatedSentences.where((sentence) => sentence.isCalled).length / updatedSentences.length * 100;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AccentLearningResultPage(
          progress: progress,
          sentences: updatedSentences,
          chapterId: widget.chapterId,
        ),
      ),
    );
  }

  void _startListening() async {
    await _checkPermissions(); // 권한 확인

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
        listenFor: Duration(seconds: 5),
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
    if (!isListening) return; // 이미 listening 상태가 아니면 return
    setState(() => isListening = false);
    _speech.stop();
  }

  void _evaluateSpeech() {
    futureSentences.then((sentences) {
      final referenceText = sentences[currentIndex].koreanSentence;
      final result = calculateRougeL(referenceText, recognizedText);
      final score = result['f1Score']!;
      final precision = result['precision']!;
      final recall = result['recall']!;
      _showEvaluationPopup(score, precision, recall);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFF3FA),
      appBar: AppBar(
        title: Text('Accent Learning'),
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
            List<AppSentence> sentences = snapshot.data!;
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
                                Image.asset(
                                  'assets/images/${currentSentence.koreanSentence}.png',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey.shade200,
                                      child: Center(
                                        child: Text(
                                          'No Image',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
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
                                  onPressed: () {
                                    if (currentSentence.isCorrect) {
                                      setState(() {
                                        currentSentence.isCorrect = false;
                                      });
                                    } else {
                                      _saveSentence(currentSentence.id);
                                    }
                                  },
                                  child: Text(currentSentence.isCorrect ? '저장됨' : '저장하기', style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentSentence.isCorrect ? Colors.black : Colors.white,
                                    foregroundColor: currentSentence.isCorrect ? Colors.white : Colors.black,
                                    minimumSize: Size(double.infinity, 50),
                                    side: currentSentence.isCorrect ? null : BorderSide(color: Colors.black),
                                  ),
                                ),
                                SizedBox(height: 10),
                                if (currentIndex > 0)
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        currentIndex--;
                                      });
                                    },
                                    child: Text('이전', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                SizedBox(height: 10),
                                if (currentIndex < sentences.length - 1)
                                  ElevatedButton(
                                    onPressed: () {
                                      _nextSentence(sentences);
                                    },
                                    child: Text('다음', style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                if (currentIndex == sentences.length - 1)
                                  ElevatedButton(
                                    onPressed: _completeLearning,
                                    child: Text('완료하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      minimumSize: Size(double.infinity, 50),
                                    ),
                                  ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => _playTextToSpeech(currentSentence.koreanSentence),
                                  child: Text('음성 듣기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => isListening ? _stopListening() : _startListening(),
                                  child: Text(isListening ? '듣기 중지하기' : '직접 말하기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
