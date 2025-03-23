
class Question {

  String documentId;
  final String title;
  final String content;
  final String difficulty;
  final int rewards;
  final String feedback;
  final String questionText;
  final List<String> options;
  final int correctOption;
  final String lessonId;

  Question({
  this.documentId = '',
  required this.title,
  required this.content,
  required this.difficulty,
  required this.rewards,
  required this.questionText,
  required this.options,
  required this.correctOption,
  required this.feedback,
  required this.lessonId,
  });

  // Factory constructor to create a Question object from a Map
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(

      documentId: map['documentId'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      difficulty: map['difficulty'] as String,
      rewards: map['rewards'] as int,
      questionText: map['questionText'] as String,
      options: List<String>.from(map['options'] as List<dynamic>),
      correctOption: map['correctOption'] as int,
      feedback: map['feedback'] as String,
      lessonId: map['lessonId'] as String,
    );
  }

  // Method to convert a Question object to a Map
  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'title': title,
      'content': content,
      'difficulty': difficulty,
      'rewards': rewards,
      'questionText': questionText,
      'options': options,
      'correctOption': correctOption,
      'feedback': feedback,
      'lessonId': lessonId,
    };
  }


  Question copyWith({
    String? documentId,
    String? title,
    String? content,
    String? difficulty,
    int? rewards,
    String? questionText,
    List<String>? options,
    int? correctOption,
    String? feedback,
    String? lessonId,
  }) {
    return Question(
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      content: content ?? this.content,
      difficulty: difficulty ?? this.difficulty,
      rewards: rewards ?? this.rewards,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctOption: correctOption ?? this.correctOption,
      feedback: feedback ?? this.feedback,
      lessonId: lessonId ?? this.lessonId,
    );
  }


}