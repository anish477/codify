import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  String? documentId;
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final List<String>? tags;
  final Map<String, String>? additionalResources;
  final String? category; // Added category field

  Lesson({
    this.documentId,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.tags,
    this.additionalResources,
    this.category, // Added category parameter
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'tags': tags,
      'additionalResources': additionalResources,
      'category': category, // Added category to map
    };
  }

  factory Lesson.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Lesson(
      documentId: doc.id,
      title: data['title'],
      description: data['description'],
      content: data['content'],
      imageUrl: data['imageUrl'],
      videoUrl: data['videoUrl'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      additionalResources: data['additionalResources'] != null
          ? Map<String, String>.from(data['additionalResources'])
          : null,
      category: data['category'], // Added category to fromDocument
    );
  }
}