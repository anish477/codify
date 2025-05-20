import 'package:cloud_firestore/cloud_firestore.dart';
import 'badge.dart';

class BadgeService {
  final CollectionReference _badgeCollection =
      FirebaseFirestore.instance.collection('badges');

  Future<List<Badge>> getBadgesForUser(String userId) async {
    final snapshot =
        await _badgeCollection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => Badge.fromDocument(doc)).toList();
  }

  Future<bool> _badgeExists(
      String userId, String topicId, String badgeType) async {
    final snapshot = await _badgeCollection
        .where('userId', isEqualTo: userId)
        .where('topicId', isEqualTo: topicId)
        .where('badgeType', isEqualTo: badgeType)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<bool> awardBadge(
      {required String userId,
      required String topicId,
      required String badgeType,
      required String name,
      required String description}) async {
    bool exists = await _badgeExists(userId, topicId, badgeType);
    if (exists) return false;

    final badge = Badge(
      id: '',
      userId: userId,
      topicId: topicId,
      badgeType: badgeType,
      name: name,
      description: description,
      dateAwarded: DateTime.now(),
    );

    await _badgeCollection.add(badge.toMap());
    return true;
  }

  Future<bool> awardFirstLessonBadge(String userId, String topicId) async {
    return await awardBadge(
      userId: userId,
      topicId: topicId,
      badgeType: 'first_lesson',
      name: 'First Lesson Completed',
      description: 'Completed your first lesson in this topic',
    );
  }

  Future<bool> awardTopicMasteryBadge(String userId, String topicId) async {
    return await awardBadge(
      userId: userId,
      topicId: topicId,
      badgeType: 'topic_mastery',
      name: 'Topic Mastery',
      description: 'Answered all questions in this topic',
    );
  }
}
