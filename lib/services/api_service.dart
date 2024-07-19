import 'dart:convert';
import 'package:googleapis/language/v1.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // 챕터 가져오기
  Future<List<Chapter>> fetchChapters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chapters/'),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((chapter) => Chapter.fromJson(chapter)).toList();
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  // 단일 챕터 가져오기
  Future<Chapter> fetchChapter(int chapterId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId'));
      if (response.statusCode == 200) {
        return Chapter.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        print('Failed to load chapter: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load chapter');
      }
    } catch (e) {
      print('Error fetching chapter: $e');
      throw Exception('Failed to load chapter');
    }
  }

  // 챕터 정확도 가져오기
  Future<double> fetchChapterAccuracy(int chapterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chapters/$chapterId/accuracy/'),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['accuracy'];
    } else {
      throw Exception('Failed to load chapter accuracy');
    }
  }

  // 단어 가져오기
  Future<List<Word>> fetchWords(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId/words/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Word.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load words');
    }
  }

  // 단어 저장하기
  Future<void> saveWord(int wordId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/words/$wordId/save/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save word');
    }
  }

  // 저장된 단어 가져오기
  Future<List<Word>> fetchSavedWords() async {
    final response = await http.get(
      Uri.parse('$baseUrl/saved_words/'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Word.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load saved words');
    }
  }

  // 문장 가져오기
  Future<List<AppSentence>> fetchSentences(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId/sentences/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => AppSentence.fromJson(item)).toList();
    } else {
      print('Failed to load sentences: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load sentences');
    }
  }

  // 문장 저장하기
  Future<void> saveSentence(int sentenceId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/sentences/$sentenceId/save/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save sentence');
    }
  }


  // 문장의 is_collect 값 업데이트하기
  Future<void> updateSentenceIsCollect(int sentenceId, bool isCollect) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}/sentences/$sentenceId/update/'),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({'is_collect': isCollect ? 1 : 0}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sentence is_collect');
    }
  }



  // 저장된 문장 가져오기
  Future<List<AppSentence>> fetchSavedSentences() async {
    final response = await http.get(
      Uri.parse('$baseUrl/saved_sentences/'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => AppSentence.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load saved sentences');
    }
  }

  // 문장의 is_called 값 업데이트하기
  Future<void> updateSentenceIsCalled(int sentenceId) async {
    final response = await http.post(Uri.parse('$baseUrl/sentences/$sentenceId/mark_called/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to update sentence');
    }
  }



  // 진행도 데이터 가져오기
  Future<ProgressData> fetchProgressData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_progress/'),
    );

    if (response.statusCode == 200) {
      return ProgressData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load progress data');
    }
  }

  // 단어의 is_collect 값 업데이트하기
  Future<void> updateWordIsCollect(int wordId, bool isCollect) async {
    final response = await http.patch(
      Uri.parse('${baseUrl}/words/$wordId/update/'),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
      body: jsonEncode({'is_collect': isCollect ? 1 : 0}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update word is_collect');
    }
  }
  // 홈페이지 다음 챕터 가져오기
  Future<Chapter> fetchNextChapter() async {
    final response = await http.get(Uri.parse('$baseUrl/next_chapter/'));

    if (response.statusCode == 200) {
      return Chapter.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load next chapter');
    }
  }

// 틀린 단어 목록 가져오기
  Future<List<Word>> fetchIncollectWords(int chapterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chapters/$chapterId/incollect_words/'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Word.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load incollect words');
    }
  }

  Future<void> updateWordIsCalled(int wordId) async {
    final response = await http.post(Uri.parse('$baseUrl/words/$wordId/mark_called/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to update word');
    }
  }

  Future<Map<String, dynamic>> fetchLearningProgress(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId/learning_progress/'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load learning progress');
    }
  }



}


