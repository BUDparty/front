// 필요한 패키지들을 임포트합니다.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

// LibraryPage 클래스는 저장된 단어와 문장을 보여주는 StatefulWidget입니다.
class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

// _LibraryPageState 클래스는 LibraryPage의 상태를 관리합니다.
class _LibraryPageState extends State<LibraryPage> {
  late Future<List<Word>> futureWords; // 저장된 단어 리스트를 저장하는 변수입니다.
  late Future<List<AppSentence>> futureSentences; // 저장된 문장 리스트를 저장하는 변수입니다.
  bool _showAllWords = false; // 모든 단어를 표시할지 여부를 나타내는 변수입니다.
  bool _showAllSentences = false; // 모든 문장을 표시할지 여부를 나타내는 변수입니다.

  @override
  void initState() {
    super.initState();
    futureWords = ApiService().fetchSavedWords(); // 저장된 단어 데이터를 가져옵니다.
    futureSentences = ApiService().fetchSavedSentences(); // 저장된 문장 데이터를 가져옵니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('저장된 단어'), // 저장된 단어 섹션 타이틀입니다.
            FutureBuilder<List<Word>>(
              future: futureWords,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시되는 위젯입니다.
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load words')); // 오류가 발생했을 때 표시되는 위젯입니다.
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No words available')); // 데이터가 없을 때 표시되는 위젯입니다.
                } else {
                  List<Word> words = snapshot.data!;
                  return Column(
                    children: [
                      // 저장된 단어들을 카드 형태로 표시합니다.
                      for (int i = 0; i < (_showAllWords ? words.length : (words.length > 3 ? 3 : words.length)); i++)
                        Card(
                          child: ListTile(
                            leading: Image.asset('assets/images/sample1.png', width: 50, height: 50, fit: BoxFit.cover), // 단어 이미지입니다.
                            title: Text(words[i].koreanWord), // 한국어 단어입니다.
                            subtitle: Text(words[i].northKoreanWord), // 북한어 단어입니다.
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllWords = !_showAllWords; // 모든 단어를 표시할지 여부를 토글합니다.
                          });
                        },
                        child: Text(_showAllWords ? '간략히 보기' : '모두 보기'), // 버튼 텍스트입니다.
                      ),
                    ],
                  );
                }
              },
            ),
            _buildSectionTitle('저장된 문장'), // 저장된 문장 섹션 타이틀입니다.
            FutureBuilder<List<AppSentence>>(
              future: futureSentences,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // 로딩 중일 때 표시되는 위젯입니다.
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load sentences')); // 오류가 발생했을 때 표시되는 위젯입니다.
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No sentences available')); // 데이터가 없을 때 표시되는 위젯입니다.
                } else {
                  List<AppSentence> sentences = snapshot.data!;
                  return Column(
                    children: [
                      // 저장된 문장들을 카드 형태로 표시합니다.
                      for (int i = 0; i < (_showAllSentences ? sentences.length : (sentences.length > 3 ? 3 : sentences.length)); i++)
                        Card(
                          child: ListTile(
                            leading: Image.asset('assets/images/sample2.png', width: 50, height: 50, fit: BoxFit.cover), // 문장 이미지입니다.
                            title: Text(sentences[i].koreanSentence), // 한국어 문장입니다.
                            subtitle: Text(sentences[i].northKoreanSentence), // 북한어 문장입니다.
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllSentences = !_showAllSentences; // 모든 문장을 표시할지 여부를 토글합니다.
                          });
                        },
                        child: Text(_showAllSentences ? '간략히 보기' : '모두 보기'), // 버튼 텍스트입니다.
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF0DEF3), // 배경 색상을 설정합니다.
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
}
