import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/models.dart';
import 'evaluation_result_page.dart';

class EvaluationLearningPage extends StatefulWidget {
  final int chapterId;

  EvaluationLearningPage({required this.chapterId});

  @override
  _EvaluationLearningPageState createState() => _EvaluationLearningPageState();
}

class _EvaluationLearningPageState extends State<EvaluationLearningPage> {
  late Future<List<Word>> futureWords;
  late Future<Chapter> futureChapter;
  int currentIndex = 0;
  bool showPopup = false;
  String popupMessage = "";
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    futureWords = ApiService().fetchWords(widget.chapterId);
    futureChapter = ApiService().fetchChapter(widget.chapterId);
  }

  void _showPopup(String message, bool correct) {
    setState(() {
      popupMessage = message;
      isCorrectAnswer = correct;
      showPopup = true;
    });
  }

  void _evaluateAnswer(String selectedWord) {
    futureWords.then((words) {
      if (selectedWord == words[currentIndex].koreanWord) {
        _updateWordIsCorrect(words[currentIndex].id, true, true);
        _showPopup("정답입니다!", true);
      } else {
        _updateWordIsCorrect(words[currentIndex].id, false, false);
        _showPopup("오답입니다!", false);
      }
    });
  }

  Future<void> _updateWordIsCorrect(int wordId, bool isCorrect, bool isCollect) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/words/$wordId/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_correct': isCorrect, 'is_collect': isCollect}),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureWords = futureWords.then((words) {
          words[currentIndex].isCorrect = isCorrect;
          words[currentIndex].isCollect = isCollect;
          return words;
        });
      });
    } else {
      throw Exception('Failed to save word');
    }
  }

  void _nextWord(List<Word> words) async {
    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        showPopup = false;
      });
    } else {
      // 마지막 단어일 때만 결과 페이지로 이동
      final chapterId = widget.chapterId;

      // 모든 단어의 is_called를 true로 업데이트
      for (var word in words) {
        if (!word.isCalled) {
          await ApiService().updateWordIsCalled(word.id);
        }
      }

      // 업데이트된 단어 리스트 다시 불러오기
      final updatedWords = await ApiService().fetchWords(chapterId);
      final progress = updatedWords.where((word) => word.isCalled).length / updatedWords.length * 100;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluationLearningResultPage(
            progress: progress,
            words: updatedWords,
            chapterId: chapterId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('단어 평가하기'),
      ),
      body: FutureBuilder<List<Word>>(
        future: futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load words'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No words available'));
          } else {
            List<Word> words = snapshot.data!;
            Word currentWord = words[currentIndex];
            return FutureBuilder<Chapter>(
              future: futureChapter,
              builder: (context, chapterSnapshot) {
                if (chapterSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (chapterSnapshot.hasError) {
                  return Center(child: Text('Failed to load chapter'));
                } else if (!chapterSnapshot.hasData) {
                  return Center(child: Text('No chapter available'));
                } else {
                  Chapter chapter = chapterSnapshot.data!;
                  List<String> options = [
                    currentWord.koreanWord,
                    "오답 1",
                    "오답 2"
                  ];
                  options.shuffle();
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
                                  'assets/images/${currentWord.koreanWord}.png',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text('Error loading image', style: TextStyle(color: Colors.red));
                                  },
                                ),
                                SizedBox(height: 10),
                                Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(currentWord.koreanWord, style: TextStyle(fontSize: 24)),
                                        Text(': ${currentWord.northKoreanWord}', style: TextStyle(fontSize: 18)),
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
                              children: options.map((option) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: ElevatedButton(
                                    onPressed: () => _evaluateAnswer(option),
                                    child: Text(option, style: TextStyle(fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black, backgroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, 50),
                                      side: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      if (showPopup)
                        Column(
                          children: [
                            Spacer(),
                            if (!isCorrectAnswer)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      showPopup = false;
                                    });
                                  },
                                  child: Text('다시 해보기', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize: Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () => _nextWord(words),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  minimumSize: Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text('다음으로', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height / 3,
                              decoration: BoxDecoration(
                                color: isCorrectAnswer ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Center(
                                child: AnimatedTextKit(
                                  animatedTexts: [
                                    WavyAnimatedText(
                                      popupMessage,
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
