import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/models.dart';




class ApiService {
  static const String _localBaseUrl = 'http://127.0.0.1:8000/api';
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000/api';
  static const String _productionBaseUrl = 'http://35.202.241.53/api';

  // 기본 URL을 동적으로 설정합니다.
  static String get baseUrl {
    if (kIsWeb) {
      return _productionBaseUrl;
    } else if (Platform.isAndroid) {
      return _productionBaseUrl;
    } else if (Platform.isIOS) {
      return _productionBaseUrl;
    } else {
      return _productionBaseUrl;
    }
  }

  Future<void> updateSentenceAccuracyAndText(int sentenceId, double accuracy, String recognizedText) async {
    final url = Uri.parse('$baseUrl/sentences/$sentenceId/update_accuracy_and_text/');
    final body = jsonEncode(<String, dynamic>{
      'accuracy': accuracy,
      'recognized_text': recognizedText,
    });

    print('Request URL: $url');
    print('Request body: $body');

    final response = await http.put(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update sentence accuracy and text');
    }

    print('Update successful');
  }

  Future<void> updateSentenceAccuracy(int sentenceId, double accuracy, String recognizedText) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sentences/$sentenceId/update_accuracy/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'accuracy': accuracy,
        'recognized_text': recognizedText,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sentence accuracy and text');
    }
  }

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

  Future<Chapter> fetchChapter(int chapterId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chapters/$chapterId/'),
      headers: {"Content-Type": "application/json; charset=UTF-8"},
    );

    if (response.statusCode == 200) {
      return Chapter.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load chapter');
    }
  }

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

  Future<List<Word>> fetchWords(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId/words/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Word.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load words');
    }
  }

  Future<void> saveWord(int wordId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/words/$wordId/save/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save word');
    }
  }

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

  Future<List<AppSentence>> fetchSentences(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId/sentences/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print('Fetched sentences successfully: ${data.length} sentences');
      return data.map((item) => AppSentence.fromJson(item)).toList();
    } else {
      print('Failed to load sentences: ${response.statusCode} ${response.body}');
      throw Exception('Failed to load sentences');
    }
  }

  Future<void> saveSentence(int sentenceId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/sentences/$sentenceId/save/'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save sentence');
    }
  }

  Future<void> updateSentenceIsCollect(int sentenceId, bool isCorrect, bool isCollect) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/sentences/$sentenceId/update/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'is_correct': isCorrect, 'is_collect': isCollect}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sentence');
    }
  }

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

  Future<void> updateSentenceIsCalled(int sentenceId) async {
    final response = await http.post(Uri.parse('$baseUrl/sentences/$sentenceId/mark_called/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to update sentence');
    }
  }

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

  Future<Chapter> fetchNextChapter() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/next_chapter/'));
      if (response.statusCode == 200) {
        return Chapter.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        print('Failed to load next chapter: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load next chapter');
      }
    } catch (e) {
      print('Error fetching next chapter: $e');
      throw Exception('Failed to load next chapter');
    }
  }

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

  Future<List<AppSentence>> fetchEvaluationResults(int chapterId) async {
    final response = await http.get(Uri.parse('$baseUrl/chapters/$chapterId/evaluation_results/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print('Fetched evaluation results: $data');  // 로그 추가
      return data.map((item) => AppSentence.fromJson(item)).toList();
    } else {
      print('Failed to load evaluation results: ${response.statusCode} ${response.body}');  // 로그 추가
      throw Exception('Failed to load evaluation results');
    }
  }

  static Future<String> fetchAudioUrl(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/typecast-speak/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['audio_url'];
    } else {
      throw Exception('Failed to fetch audio URL');
    }
  }


}
