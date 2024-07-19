import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'evaluation_learning_page.dart';
import 'evaluation_sentence_page.dart';

class EvaluationPage extends StatefulWidget {
  @override
  _EvaluationPageState createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  late Future<List<Chapter>> futureChapters;

  @override
  void initState() {
    super.initState();
    futureChapters = ApiService().fetchChapters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('평가하기'),
      ),
      body: FutureBuilder<List<Chapter>>(
        future: futureChapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load chapters'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No chapters available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Chapter chapter = snapshot.data![index];
                String imageAsset;
                if (index % 3 == 0) {
                  imageAsset = 'assets/images/hi.png';
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
                      Text('챕터 ${chapter.id} : ${chapter.title}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('한국의 ${chapter.title}에 대해 배워봅시다.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: Image.asset(imageAsset, width: 50, height: 50),
                          title: Text('유닛 1. 단어 평가하기'),
                          subtitle: Text('${chapter.title}  기본'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EvaluationLearningPage(chapterId: chapter.id)),
                            );
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Image.asset(imageAsset, width: 50, height: 50),
                          title: Text('유닛 2. 문장 평가하기'),
                          subtitle: Text('${chapter.title}  기본'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EvaluationSentencePage(chapterId: chapter.id)),
                            );
                          },
                        ),
                      ),
                      Card(
                        child: ListTile(
                          leading: Image.asset(imageAsset, width: 50, height: 50),
                          title: Text('유닛 3. 억양 평가하기'),
                          subtitle: Text('${chapter.title}  기본'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => EvaluationLearningPage(chapterId: chapter.id)),
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
