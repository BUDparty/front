// 필요한 패키지들을 임포트합니다.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'evaluation_learning_page.dart';
import 'evaluation_sentence_page.dart';
import 'accent_evaluation_page.dart'; // 억양 평가하기 페이지 추가

// EvaluationPage 클래스는 평가 페이지를 나타내는 StatefulWidget입니다.
class EvaluationPage extends StatefulWidget {
  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

// _EvaluationPageState 클래스는 EvaluationPage의 상태를 관리합니다.
class _EvaluationPageState extends State<EvaluationPage> {
  late Future<List<Chapter>> futureChapters; // 미래의 챕터 리스트를 저장하는 변수입니다.

  @override
  void initState() {
    super.initState();
    futureChapters = ApiService().fetchChapters(); // 챕터 데이터를 가져옵니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('평가하기'), // 앱바의 제목을 설정합니다.
      ),
      body: FutureBuilder<List<Chapter>>(
        future: futureChapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시되는 위젯입니다.
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load chapters')); // 오류가 발생했을 때 표시되는 위젯입니다.
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chapters available')); // 데이터가 없을 때 표시되는 위젯입니다.
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Chapter chapter = snapshot.data![index];
                String imageAsset;
                if (index % 3 == 0) {
                  imageAsset = 'assets/images/hi.png'; // 인덱스에 따라 다른 이미지를 설정합니다.
                } else if (index % 3 == 1) {
                  imageAsset = 'assets/images/exercising.png';
                } else {
                  imageAsset = 'assets/images/food.png';
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('챕터 ${chapter.id} : ${chapter.title}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 챕터 제목을 표시합니다.
                      SizedBox(height: 4),
                      Text('한국의 ${chapter.title}에 대해 배워봅시다.', style: TextStyle(fontSize: 14, color: Colors.grey)), // 챕터 설명을 표시합니다.
                      SizedBox(height: 8),
                      // 단어 평가하기로 이동하는 카드입니다.
                      Card(
                        child: ListTile(
                          leading: Image.asset(imageAsset, width: 50, height: 50), // 카드의 이미지입니다.
                          title: Text('유닛 1. 단어 평가하기'),
                          subtitle: Text('${chapter.title} 기본'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EvaluationLearningPage(chapterId: chapter.id)), // EvaluationLearningPage로 이동합니다.
                            );
                          },
                        ),
                      ),
                      // 문장 평가하기로 이동하는 카드입니다.
                      Card(
                        child: ListTile(
                          leading: Image.asset(imageAsset, width: 50, height: 50),
                          title: Text('유닛 2. 문장 평가하기'),
                          subtitle: Text('${chapter.title} 기본'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EvaluationSentencePage(chapterId: chapter.id)), // EvaluationSentencePage로 이동합니다.
                            );
                          },
                        ),
                      ),
                      // 억양 평가하기로 이동하는 카드입니다.
                      Card(
                        child: ListTile(
                          leading: Image.asset(imageAsset, width: 50, height: 50),
                          title: Text('유닛 3. 억양 평가하기'),
                          subtitle: Text('${chapter.title} 기본'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AccentEvaluationPage(chapterId: chapter.id)), // AccentEvaluationPage로 이동합니다.
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
