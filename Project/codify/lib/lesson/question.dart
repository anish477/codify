

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
}