import 'package:flutter/material.dart';

import '../models/models.dart';

// EvaluationLearningResultPage 클래스는 평가 결과를 보여주는 페이지를 나타내는 StatelessWidget입니다.
class EvaluationLearningResultPage extends StatelessWidget {
  final double progress; // 진행률을 나타내는 변수입니다.
  final List<Word>? words; // 평가한 단어들의 리스트입니다.
  final List<AppSentence>? sentences; // 평가한 문장들의 리스트입니다.
  final int chapterId; // 챕터의 ID입니다.

  // 생성자를 통해 변수를 초기화합니다.
  EvaluationLearningResultPage({
    required this.progress,
    this.words,
    this.sentences,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('평가 결과 확인하기'), // 앱바의 제목을 설정합니다.
        backgroundColor: Color(0xFFDFF3FA), // 앱바의 배경 색상을 설정합니다.
      ),
      body: ListView(
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
                  '전체 성취도 확인하기', // 성취도 확인 텍스트입니다.
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
                        '진행도', // 진행도를 나타내는 텍스트입니다.
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${progress.toStringAsFixed(0)}%', // 진행률을 퍼센트로 표시합니다.
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
          if (sentences != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '평가한 문장들', // 평가한 문장들을 나타내는 텍스트입니다.
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  // 각 문장을 보여주는 위젯입니다.
                  for (var sentence in sentences!)
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
                                sentence.isCollect ? '✅' : '❌', // 문장의 수집 여부를 나타냅니다.
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
                                  '${sentence.northKoreanSentence} - ${sentence.koreanSentence}', // 북한말과 한국말 문장을 표시합니다.
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  softWrap: true,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Recognized: ${sentence.recognizedText}',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                  softWrap: true,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Accuracy: ${(sentence.accuracy * 100).toStringAsFixed(2)}%',
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
      ),
    );
  }
}
