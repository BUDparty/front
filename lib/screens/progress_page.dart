// 필요한 패키지들을 임포트합니다.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'evaluation_learning_result_page.dart';
import 'learning_result_page.dart';

// ProgressPage 클래스는 진행도를 보여주는 StatefulWidget입니다.
class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

// _ProgressPageState 클래스는 ProgressPage의 상태를 관리합니다.
class _ProgressPageState extends State<ProgressPage> {
  late Future<ProgressData> futureProgressData; // 진행도 데이터를 저장하는 변수입니다.

  @override
  void initState() {
    super.initState();
    futureProgressData = ApiService().fetchProgressData(); // 진행도 데이터를 가져옵니다.
  }

  // 평가 결과를 보여주는 함수입니다.
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

  // 학습 결과를 보여주는 함수입니다.
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

  // 학습 진행도를 계산하는 함수입니다.
  Future<double> _calculateLearningProgress(int chapterId) async {
    final words = await ApiService().fetchWords(chapterId);
    final sentences = await ApiService().fetchSentences(chapterId);
    final progress = (words.where((word) => word.isCalled).length +
        sentences.where((sentence) => sentence.isCalled).length) /
        (words.length + sentences.length) *
        100;
    return progress;
  }

  // 평가 진행도를 계산하는 함수입니다.
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
        title: Text('진행도'), // 앱바의 제목을 설정합니다.
        backgroundColor: Color(0xFFF0DEF3), // 앱바의 배경 색상입니다.
      ),
      body: FutureBuilder<ProgressData>(
        future: futureProgressData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시되는 위젯입니다.
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load progress data')); // 오류가 발생했을 때 표시되는 위젯입니다.
          } else if (!snapshot.hasData || snapshot.data!.progressData.isEmpty) {
            return Center(child: Text('No progress data available')); // 데이터가 없을 때 표시되는 위젯입니다.
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
                        '진행상황 보기', // 진행상황 보기 섹션 타이틀입니다.
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
                                      '학습한 챕터 수', // 학습한 챕터 수를 나타내는 텍스트입니다.
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${progressData.completedChapters}', // 학습한 챕터 수를 표시합니다.
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
                                      '평가 점수 (100점 기준)', // 평가 점수를 나타내는 텍스트입니다.
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '${progressData.overallProgress.toStringAsFixed(0)}', // 평가 점수를 표시합니다.
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
                        '학습하기', // 학습하기 섹션 타이틀입니다.
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
                                  color: progress >= 75 ? Colors.green : Colors.red, // 진행도에 따라 아이콘 색상이 달라집니다.
                                ),
                                title: Text(chapter.chapterTitle),
                                subtitle: Text('${progress.toStringAsFixed(0)}% 완료했어요!'),
                                onTap: () => _showLearningResult(chapter.chapterId), // 학습 결과를 보여줍니다.
                              ),
                            );
                          },
                        ),
                      SizedBox(height: 8.0),
                      Text(
                        '평가하기', // 평가하기 섹션 타이틀입니다.
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
                                  color: progress >= 75 ? Colors.green : Colors.red, // 진행도에 따라 아이콘 색상이 달라집니다.
                                ),
                                title: Text(chapter.chapterTitle),
                                subtitle: Text('${progress.toStringAsFixed(0)}% 완료했어요!'),
                                onTap: () => _showEvaluationResult(chapter.chapterId), // 평가 결과를 보여줍니다.
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
      backgroundColor: Color(0xFFF0DEF3), // 배경 색상을 설정합니다.
    );
  }
}
