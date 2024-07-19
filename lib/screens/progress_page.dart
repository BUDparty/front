import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'evaluation_learning_result_page.dart';
import 'learning_result_page.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late Future<ProgressData> futureProgressData;

  @override
  void initState() {
    super.initState();
    futureProgressData = ApiService().fetchProgressData();
  }

  void _showEvaluationResult(int chapterId) async {
    try {
      final words = await ApiService().fetchWords(chapterId);
      final sentences = await ApiService().fetchSentences(chapterId);
      final progress = (words.where((word) => word.isCollect).length +
          sentences.where((sentence) => sentence.isCollect).length) /
          (words.length + sentences.length) *
          100;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EvaluationLearningResultPage(
            progress: progress,
            words: words,
            sentences: sentences,
            chapterId: chapterId,
          ),
        ),
      );
    } catch (e) {
      print('Error loading evaluation result: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load evaluation result')),
      );
    }
  }

  void _showLearningResult(int chapterId) async {
    try {
      final words = await ApiService().fetchWords(chapterId);
      final sentences = await ApiService().fetchSentences(chapterId);
      final progress = (words.where((word) => word.isCalled).length +
          sentences.where((sentence) => sentence.isCalled).length) /
          (words.length + sentences.length) *
          100;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LearningResultPage(
            progress: progress,
            words: words,
            sentences: sentences,
            chapterId: chapterId,
          ),
        ),
      );
    } catch (e) {
      print('Error loading learning result: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load learning result')),
      );
    }
  }

  Future<double> _calculateLearningProgress(int chapterId) async {
    final words = await ApiService().fetchWords(chapterId);
    final sentences = await ApiService().fetchSentences(chapterId);
    final progress = (words.where((word) => word.isCalled).length +
        sentences.where((sentence) => sentence.isCalled).length) /
        (words.length + sentences.length) *
        100;
    return progress;
  }

  Future<double> _calculateEvaluationProgress(int chapterId) async {
    final words = await ApiService().fetchWords(chapterId);
    final sentences = await ApiService().fetchSentences(chapterId);
    final progress = (words.where((word) => word.isCollect).length +
        sentences.where((sentence) => sentence.isCollect).length) /
        (words.length + sentences.length) *
        100;
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('진행도'),
        backgroundColor: Color(0xFFF0DEF3),
      ),
      body: FutureBuilder<ProgressData>(
        future: futureProgressData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load progress data'));
          } else if (!snapshot.hasData || snapshot.data!.progressData.isEmpty) {
            return Center(child: Text('No progress data available'));
          } else {
            ProgressData progressData = snapshot.data!;
            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0DEF3),
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '진행상황 보기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '학습한 챕터 수',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${progressData.completedChapters}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '평가 점수 (100점 기준)',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${progressData.overallProgress.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        '학습하기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      for (var chapter in progressData.progressData)
                        FutureBuilder<double>(
                          future: _calculateLearningProgress(chapter.chapterId),
                          builder: (context, snapshot) {
                            double progress = snapshot.data ?? 0;
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  Icons.book,
                                  color: progress >= 75 ? Colors.green : Colors.red,
                                ),
                                title: Text(chapter.chapterTitle),
                                subtitle: Text('${progress.toStringAsFixed(0)}% 완료했어요!'),
                                onTap: () => _showLearningResult(chapter.chapterId),
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 8.0),
                      Text(
                        '평가하기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      for (var chapter in progressData.progressData)
                        FutureBuilder<double>(
                          future: _calculateEvaluationProgress(chapter.chapterId),
                          builder: (context, snapshot) {
                            double progress = snapshot.data ?? 0;
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  Icons.book,
                                  color: progress >= 75 ? Colors.green : Colors.red,
                                ),
                                title: Text(chapter.chapterTitle),
                                subtitle: Text('${progress.toStringAsFixed(0)}% 완료했어요!'),
                                onTap: () => _showEvaluationResult(chapter.chapterId),
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
      backgroundColor: Color(0xFFF0DEF3),
    );
  }
}
