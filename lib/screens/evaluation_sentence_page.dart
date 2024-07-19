import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/models.dart';
import 'evaluation_learning_result_page.dart';

class EvaluationSentencePage extends StatefulWidget {
  final int chapterId;

  EvaluationSentencePage({required this.chapterId});

  @override
  _EvaluationSentencePageState createState() => _EvaluationSentencePageState();
}

class _EvaluationSentencePageState extends State<EvaluationSentencePage> {
  late Future<List<AppSentence>> futureSentence;
  late Future<Chapter> futureChapter;
  int currentIndex = 0;
  bool showPopup = false;
  String popupMessage = "";
  bool isCorrectAnswer = false;

  @override
  void initState() {
    super.initState();
    futureSentence = ApiService().fetchSentences(widget.chapterId);
    futureChapter = ApiService().fetchChapter(widget.chapterId);
  }

  void _showPopup(String message, bool correct) {
    setState(() {
      popupMessage = message;
      isCorrectAnswer = correct;
      showPopup = true;
    });
  }

  void _evaluateAnswer(String selectedSentence) {
    futureSentence.then((sentence) {
      if (selectedSentence == sentence[currentIndex].koreanSentence) {
        _updateSentenceIsCollect(sentence[currentIndex].id, true, true);
        _showPopup("정답입니다!", true);
      } else {
        _updateSentenceIsCollect(sentence[currentIndex].id, false, false);
        _showPopup("오답입니다!", false);
      }
    });
  }

  Future<void> _updateSentenceIsCollect(int sentenceId, bool isCorrect, bool isCollect) async {
    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/api/sentences/$sentenceId/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_correct': isCorrect, 'is_collect': isCollect}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sentence');
    }
  }

  void _nextSentence(List<AppSentence> sentence) async {
    if (currentIndex < sentence.length - 1) {
      setState(() {
        currentIndex++;
        showPopup = false;
      });
    } else {
      final chapterId = widget.chapterId;

      for (var sentence in sentence) {
        if (!sentence.isCalled) {
          await ApiService().updateSentenceIsCalled(sentence.id);
        }
      }

      final updatedSentences = await ApiService().fetchSentences(chapterId);
      final progress = updatedSentences.where((sentence) => sentence.isCalled).length / updatedSentences.length * 100;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluationLearningResultPage(
            progress: progress,
            sentences: updatedSentences,
            words: [],
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
        title: Text('문장 평가하기'),
      ),
      body: FutureBuilder<List<AppSentence>>(
        future: futureSentence,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
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
                  return Center(child: Text('Failed to load chapter'));
                } else if (!chapterSnapshot.hasData) {
                  return Center(child: Text('No chapter available'));
                } else {
                  Chapter chapter = chapterSnapshot.data!;
                  List<String> options = [
                    currentSentence.koreanSentence,
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
                                  'assets/images/${currentSentence.koreanSentence}.png',
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
                                        Text(currentSentence.koreanSentence, style: TextStyle(fontSize: 24)),
                                        Text(': ${currentSentence.northKoreanSentence}', style: TextStyle(fontSize: 18)),
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
                                onPressed: () => _nextSentence(sentences),
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
