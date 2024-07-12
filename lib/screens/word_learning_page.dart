import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;

class WordLearningPage extends StatefulWidget {
  final int chapterId;

  WordLearningPage({required this.chapterId});

  @override
  _WordLearningPageState createState() => _WordLearningPageState();
}

class _WordLearningPageState extends State<WordLearningPage> {
  late Future<List<Word>> futureWords;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureWords = ApiService().fetchWords(widget.chapterId);
  }

  Future<void> _saveWord(int wordId) async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/words/$wordId/save/'));

    if (response.statusCode == 200) {
      setState(() {
        // Update the word in the current list
        futureWords = futureWords.then((words) {
          words[currentIndex].isCorrect = true;
          return words;
        });
      });
    } else {
      throw Exception('Failed to save word');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Learning'),
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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Featured Words', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: Text('${currentWord.koreanWord} : ${currentWord.northKoreanWord}', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text('Greetings', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 5),
                      Text('${words.length} words', style: TextStyle(fontSize: 14)),
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
                          if (currentWord.isCorrect) {
                            setState(() {
                              currentWord.isCorrect = false;
                            });
                          } else {
                            _saveWord(currentWord.id);
                          }
                        },
                        child: Text(currentWord.isCorrect ? '저장됨' : '저장하기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentWord.isCorrect ? Colors.black : Colors.white,
                          foregroundColor: currentWord.isCorrect ? Colors.white : Colors.black,
                          minimumSize: Size(double.infinity, 50),
                          side: currentWord.isCorrect ? null : BorderSide(color: Colors.black),
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
                          child: Text('이전'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                      SizedBox(height: 10),
                      if (currentIndex < words.length - 1)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentIndex++;
                            });
                          },
                          child: Text('다음'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black, backgroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            side: BorderSide(color: Colors.black),
                          ),
                        ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('음성 듣기'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}