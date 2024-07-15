import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
          } else if (!snapshot.hasData) {
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
                        Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.book,
                              color: chapter.progress >= 75 ? Colors.green : Colors.red,
                            ),
                            title: Text(chapter.chapterTitle),
                            subtitle: Text('${chapter.progress.toStringAsFixed(0)}% 완료했어요!'),
                          ),
                        ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Color(0xFF9714AF),
                        ),
                        child: Text('평가하기'),
                      ),
                      SizedBox(height: 16.0),
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
                        Card(
                          child: ListTile(
                            leading: Icon(
                              Icons.book,
                              color: chapter.progress >= 75 ? Colors.green : Colors.red,
                            ),
                            title: Text(chapter.chapterTitle),
                            subtitle: Text('${chapter.progress.toStringAsFixed(0)}% 완료했어요!'),
                          ),
                        ),
                      SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Color(0xFF9714AF),
                        ),
                        child: Text('평가하기'),
                      ),
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

class ProgressData {
  final List<ChapterProgress> progressData;
  final int completedChapters;
  final double overallProgress;

  ProgressData({
    required this.progressData,
    required this.completedChapters,
    required this.overallProgress,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    var list = json['progress_data'] as List;
    List<ChapterProgress> progressList =
    list.map((i) => ChapterProgress.fromJson(i)).toList();

    return ProgressData(
      progressData: progressList,
      completedChapters: json['completed_chapters'],
      overallProgress: json['overall_progress'],
    );
  }
}

class ChapterProgress {
  final int chapterId;
  final String chapterTitle;
  final double progress;
  final int totalWords;
  final int calledWords;

  ChapterProgress({
    required this.chapterId,
    required this.chapterTitle,
    required this.progress,
    required this.totalWords,
    required this.calledWords,
  });

  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      chapterId: json['chapter_id'],
      chapterTitle: json['chapter_title'],
      progress: json['progress'],
      totalWords: json['total_words'],
      calledWords: json['called_words'],
    );
  }
}
