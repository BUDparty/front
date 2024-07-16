import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../screens/progress_page.dart';

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

// 홈페이지 다음 챕터 가져오기
Future<Chapter> fetchNextChapter() async {
final response = await http.get(Uri.parse('$baseUrl/next_chapter/'));

if (response.statusCode == 200) {
return Chapter.fromJson(json.decode(utf8.decode(response.bodyBytes)));
} else {
throw Exception('Failed to load next chapter');
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
    final response = await http.post(Uri.parse('${baseUrl}/words/$wordId/save/'));

    if (response.statusCode != 200) {
      throw Exception('Failed to save word');
    }
  }

// 저장된 단어 가져오기
  Future<List<Word>> fetchSavedWords() async {
    final response = await http.get(Uri.parse('$baseUrl/saved_words/'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((item) => Word.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load saved words');
    }
  }


// 진행도 데이터 가져오기
Future<ProgressData> fetchProgressData() async {
final response = await http.get(Uri.parse('$baseUrl/get_progress/'));

if (response.statusCode == 200) {
return ProgressData.fromJson(jsonDecode(response.body));
} else {
throw Exception('Failed to load progress data');
}
}
}
