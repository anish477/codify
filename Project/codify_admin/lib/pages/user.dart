import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetail {
  final String documentId;
  final String? userId;
  final String? name;
  final bool isBlacklisted;
  final String? blacklistReason;
  final Timestamp? blacklistTimestamp;
  final String? imageUrl;

  UserDetail({
    required this.documentId,
    this.userId,
    this.name,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.blacklistTimestamp,
    this.imageUrl,
  });

  factory UserDetail.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDetail(
      documentId: doc.id,
      userId: data['userId'] as String?,
      name: data['name'] as String?,
      isBlacklisted: data['isBlacklisted'] ?? false,
      blacklistReason: data['blacklistReason'] as String?,
      blacklistTimestamp: data['blacklistedAt'] as Timestamp? ??
          data['blacklistTimestamp'] as Timestamp?,
    );
  }

  UserDetail copyWithImageUrl(String? newImageUrl) {
    return UserDetail(
      documentId: documentId,
      userId: userId,
      name: name,
      isBlacklisted: isBlacklisted,
      blacklistReason: blacklistReason,
      blacklistTimestamp: blacklistTimestamp,
      imageUrl: newImageUrl,
    );
  }

  UserDetail copyWith({
    String? documentId,
    String? userId,
    String? name,
    String? email,
    String? phone,
    bool? isBlacklisted,
    String? blacklistReason,
  }) {
    return UserDetail(
      documentId: documentId ?? this.documentId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      isBlacklisted: isBlacklisted ?? this.isBlacklisted,
      blacklistReason: isBlacklisted == false
          ? null
          : (blacklistReason ?? this.blacklistReason),
    );
  }
}
