import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AccentEvaluationResultPage extends StatelessWidget {
  final int chapterId;

  AccentEvaluationResultPage({required this.chapterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('평가 결과 확인하기'),
        backgroundColor: Color(0xFFDFF3FA),
      ),
      body: FutureBuilder<List<AppSentence>>(
        future: ApiService().fetchEvaluationResults(chapterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching evaluation results: ${snapshot.error}');
            return Center(child: Text('Failed to load results'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No results available');
            return Center(child: Text('No results available'));
          } else {
            final results = snapshot.data!;
            return ListView(
              children: [
                // 전체 성취도를 보여주는 컨테이너입니다.
                Container(
                  width: double.infinity,
                  height: 136,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '전체 성취도 확인하기',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x3F000000),
                              blurRadius: 4,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '진행도',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${(results.length / snapshot.data!.length * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                // 평가한 문장들이 있을 경우, 문장들을 보여주는 컨테이너입니다.
                if (results.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '평가한 문장들',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        // 각 문장을 보여주는 위젯입니다.
                        for (var result in results)
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: Text(
                                      result.isCalled ? '✅' : '❌',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${result.northKoreanSentence} - ${result.koreanSentence}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        softWrap: true,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Recognized: ${result.recognizedText}',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Accuracy: ${(result.accuracy * 100).toStringAsFixed(2)}%',
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }
}
