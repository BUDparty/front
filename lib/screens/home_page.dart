// 필요한 패키지들을 임포트합니다.
import 'package:flutter/material.dart';
import 'package:onsaemiro/screens/word_learning_page.dart';
import 'evaluation_learning_page.dart';
import 'sentence_learning_page.dart';
import 'library_page.dart';
import 'progress_page.dart';
import 'settings_page.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'chat_page.dart';
import 'evaluation_sentence_page.dart'; // 문장 평가하기 페이지
import 'evaluation_learning_result_page.dart';
import 'evaluation_page.dart';
import 'learning_page.dart';

// HomePage 클래스는 앱의 홈 화면을 나타내는 StatefulWidget입니다.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// _HomePageState 클래스는 HomePage의 상태를 관리합니다.
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 현재 선택된 하단 네비게이션 바의 인덱스입니다.
  Future<Chapter>? futureNextChapter; // 다음 챕터 데이터를 저장하는 변수입니다.

  @override
  void initState() {
    super.initState();
    futureNextChapter = ApiService().fetchNextChapter(); // 다음 챕터 데이터를 가져옵니다.
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(), // 홈 콘텐츠 위젯
    LibraryPage(), // 보관함 페이지
    ProgressPage(), // 진행도 페이지
    SettingsPage(), // 환경 설정 페이지
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스로 업데이트합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
        title: Text('시나브로'), // 홈 화면의 앱바 제목입니다.
        backgroundColor: Colors.lightBlue[100], // 앱바 배경 색상입니다.
        elevation: 0,
      )
          : null,
      body: _widgetOptions.elementAt(_selectedIndex), // 현재 선택된 페이지를 표시합니다.
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: '보관함',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '진행도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '환경 설정',
          ),
        ],
        currentIndex: _selectedIndex, // 현재 선택된 인덱스를 설정합니다.
        selectedItemColor: Colors.black, // 선택된 아이템 색상입니다.
        unselectedItemColor: Colors.black, // 선택되지 않은 아이템 색상입니다.
        showSelectedLabels: true, // 선택된 아이템의 라벨을 표시합니다.
        showUnselectedLabels: true, // 선택되지 않은 아이템의 라벨을 표시합니다.
        onTap: _onItemTapped, // 아이템 클릭 시 호출되는 함수입니다.
      ),
    );
  }
}

// HomeContent 클래스는 홈 화면의 콘텐츠를 나타내는 StatelessWidget입니다.
class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Chapter>(
      future: ApiService().fetchNextChapter(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시되는 위젯입니다.
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load next chapter')); // 오류가 발생했을 때 표시되는 위젯입니다.
        } else if (!snapshot.hasData) {
          return Center(child: Text('No chapter available')); // 데이터가 없을 때 표시되는 위젯입니다.
        } else {
          Chapter nextChapter = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusCard('학습한 챕터 수', '3'), // 학습한 챕터 수를 나타내는 카드입니다.
                      _buildStatusCard('평가 점수 (100점 기준)', '75'), // 평가 점수를 나타내는 카드입니다.
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatPage()), // ChatPage로 이동합니다.
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'AI와 대화하기',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle('학습하기'), // 학습하기 섹션 타이틀입니다.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SentenceLearningPage(
                                    chapterId: nextChapter.id)), // SentenceLearningPage로 이동합니다.
                          );
                        },
                        child: _buildLearningCard(nextChapter.title, '문장 학습하기',
                            'assets/images/sample1.png'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => WordLearningPage(
                                    chapterId: nextChapter.id)), // WordLearningPage로 이동합니다.
                          );
                        },
                        child: _buildLearningCard(nextChapter.title, '단어 학습하기',
                            'assets/images/sample1.png'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LearningPage()), // LearningPage로 이동합니다.
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '학습하기',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle('평가하기'), // 평가하기 섹션 타이틀입니다.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EvaluationSentencePage(
                                    chapterId: nextChapter.id)), // EvaluationSentencePage로 이동합니다.
                          );
                        },
                        child: _buildLearningCard(nextChapter.title, '문장 평가하기',
                            'assets/images/sample1.png'),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EvaluationLearningPage(
                                    chapterId: nextChapter.id)), // EvaluationLearningPage로 이동합니다.
                          );
                        },
                        child: _buildLearningCard(nextChapter.title, '단어 평가하기',
                            'assets/images/sample1.png'),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EvaluationPage()), // EvaluationPage로 이동합니다.
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '평가하기',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  // 상태 카드를 빌드하는 함수입니다.
  Widget _buildStatusCard(String title, String value) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 섹션 타이틀을 빌드하는 함수입니다.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 학습 카드를 빌드하는 함수입니다.
  Widget _buildLearningCard(String chapter, String title, String imagePath) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            Image.asset(imagePath, width: 120, height: 120, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter, style: TextStyle(fontSize: 14)),
                  SizedBox(height: 4),
                  Text(title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}