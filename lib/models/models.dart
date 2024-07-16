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

  Word({
    required this.id,
    required this.chapterId,
    required this.koreanWord,
    required this.northKoreanWord,
    this.isCalled = false,
    this.isCorrect = false,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      chapterId: json['chapter'],
      koreanWord: json['korean_word'],
      northKoreanWord: json['north_korean_word'],
      isCalled: json['is_called'],
      isCorrect: json['is_correct'],
    );
  }
}
