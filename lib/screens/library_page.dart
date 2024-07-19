import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class LibraryPage extends StatefulWidget {
  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List<Word>> futureWords;
  bool _showAllWords = false;

  @override
  void initState() {
    super.initState();
    futureWords = ApiService().fetchSavedWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSectionTitle('저장된 단어'),
            FutureBuilder<List<Word>>(
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
                  return Column(
                    children: [
                      for (int i = 0; i < (_showAllWords ? words.length : (words.length > 3 ? 3 : words.length)); i++)
                        Card(
                          child: ListTile(
                            leading: Image.asset('assets/images/sample1.png', width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(words[i].koreanWord),
                            subtitle: Text(words[i].northKoreanWord),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllWords = !_showAllWords;
                          });
                        },
                        child: Text(_showAllWords ? '간략히 보기' : '모두 보기'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF0DEF3),
    );
  }

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
