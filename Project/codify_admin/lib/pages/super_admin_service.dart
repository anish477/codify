import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codify_admin/pages/user.dart';

class UserDetailService {
  final CollectionReference _c = FirebaseFirestore.instance.collection('users');

  Future<UserDetail?> getUserDetail(String documentId) async {
    try {
      final doc = await _c.doc(documentId).get();
      if (doc.exists) {
        return UserDetail.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user detail: $e');
      return null;
    }
  }

  Future<List<UserDetail>> getAllUserDetails() async {
    try {
      final querySnapshot = await _c.get();

      return querySnapshot.docs
          .map((doc) => UserDetail.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting all user details: $e');

      return [];
    }
  }

  Future<void> deleteUserDetail(String documentId) async {
    try {
      await _c.doc(documentId).delete();
    } catch (e) {
      print('Error deleting user detail: $e');
      rethrow;
    }
  }

  Future<void> addToBlacklist(String documentId, String reason) async {
    try {
      await _c.doc(documentId).update({
        'isBlacklisted': true,
        'blacklistReason': reason,
        'blacklistedAt': FieldValue.serverTimestamp(),
      });
      print('User $documentId blacklisted successfully.');
    } catch (e) {
      print('Error blacklisting user $documentId: $e');
      rethrow;
    }
  }

  Future<void> revokeBlacklist(String documentId) async {
    try {
      await _c.doc(documentId).update({
        'isBlacklisted': false,
        'blacklistReason': FieldValue.delete(),
        'blacklistedAt': FieldValue.delete(),
      });
      print('User $documentId blacklist revoked successfully.');
    } catch (e) {
      print('Error revoking blacklist for user $documentId: $e');
      rethrow;
    }
  }

  Future<List<UserDetail>> getBlacklistedUsers() async {
    try {
      final querySnapshot =
          await _c.where('isBlacklisted', isEqualTo: true).get();
      return querySnapshot.docs
          .map((doc) => UserDetail.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting blacklisted users: $e');
      return [];
    }
  }

  Future<List<UserDetail>> getNonBlacklistedUsers() async {
    try {
      final querySnapshot =
          await _c.where('isBlacklisted', isNotEqualTo: true).get();
      return querySnapshot.docs
          .map((doc) => UserDetail.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting non-blacklisted users: $e');
      return [];
    }
  }
}
