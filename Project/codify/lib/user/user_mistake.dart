class UserMistake{
  final String mistake;
  final String documentId;
  final String userId;

  UserMistake({
    this.mistake = '',
    this.documentId = '',
    this.userId = '',
  });

  factory UserMistake.fromMap(Map<String, dynamic> map) {
    return UserMistake(
      mistake: map['mistake'] as String,
      documentId: map['documentId'] as String,
      userId: map['userId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mistake': mistake,
      'documentId': documentId,
      'userId': userId,
    };
  }

}