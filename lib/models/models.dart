import '../screens/progress_page.dart';

class Chapter {
  final int id;
  final String title;

  Chapter({required this.id, required this.title});

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      title: json['title'],
    );
  }
}

class Word {
  final int id;
  final int chapterId;
  final String koreanWord;
  final String northKoreanWord;
  bool isCalled;
  bool isCorrect;
  bool isCollect;


  Word({
    required this.id,
    required this.chapterId,
    required this.koreanWord,
    required this.northKoreanWord,
    this.isCalled = false,
    this.isCorrect = false,
    this.isCollect = false,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      chapterId: json['chapter'],
      koreanWord: json['korean_word'],
      northKoreanWord: json['north_korean_word'],
      isCalled: json['is_called'],
      isCorrect: json['is_correct'],
      isCollect: json['is_collect'],
    );
  }


}

class ProgressData {
  final List<ChapterProgress> progressData;
  final int completedChapters;
  final double overallProgress;

  ProgressData({
    required this.progressData,
    required this.completedChapters,
    required this.overallProgress,
  });

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    var list = json['progress_data'] as List;
    List<ChapterProgress> progressDataList = list.map((i) => ChapterProgress.fromJson(i)).toList();

    return ProgressData(
      progressData: progressDataList,
      completedChapters: json['completed_chapters'],
      overallProgress: json['overall_progress'],
    );
  }
}

class ChapterProgress {
  final int chapterId;
  final String chapterTitle;
  final double progress;
  final double accuracy;

  ChapterProgress({
    required this.chapterId,
    required this.chapterTitle,
    required this.progress,
    required this.accuracy,
  });

  factory ChapterProgress.fromJson(Map<String, dynamic> json) {
    return ChapterProgress(
      chapterId: json['chapter_id'],
      chapterTitle: json['chapter_title'],
      progress: json['progress'],
      accuracy: json['accuracy'],
    );
  }
}



class AppSentence {
  final int id;
  final int chapterId;
  final String koreanSentence;
  final String northKoreanSentence;
  bool isCalled;
  bool isCorrect;
  bool isCollect;

  AppSentence({
    required this.id,
    required this.chapterId,
    required this.koreanSentence,
    required this.northKoreanSentence,
    this.isCalled = false,
    this.isCorrect = false,
    this.isCollect = false,
  });

  factory AppSentence.fromJson(Map<String, dynamic> json) {
    return AppSentence(
      id: json['id'],
      chapterId: json['chapter'],
      koreanSentence: json['korean_sentence'],
      northKoreanSentence: json['north_korean_sentence'],
      isCalled: json['is_called'],
      isCorrect: json['is_correct'],
      isCollect: json['is_collect'],
    );
  }



}