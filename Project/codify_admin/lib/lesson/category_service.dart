import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';

class CategoryService {
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');

  // Create a new category
  Future<Category?> createCategory(Category category) async {
    try {
      final docRef = await _categoriesCollection.add(category.toMap());
      final docSnapshot = await docRef.get();
      return Category.fromDocument(docSnapshot);
    } catch (e) {
      print('Error creating category: $e');
      return null;
    }
  }

  // Get a category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final docSnapshot = await _categoriesCollection.doc(categoryId).get();
      if (docSnapshot.exists) {
        return Category.fromDocument(docSnapshot);
      } else {
        print('Category not found');
        return null;
      }
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final querySnapshot = await _categoriesCollection.get();
      return querySnapshot.docs
          .map((doc) => Category.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }

  // Update a category
  Future<Category?> updateCategory(Category category) async {
    try {
      final docRef = _categoriesCollection.doc(category.documentId);
      await docRef.update(category.toMap());
      final docSnapshot = await docRef.get();
      return Category.fromDocument(docSnapshot);
    } catch (e) {
      print('Error updating category: $e');
      return null;
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  // Add a lesson to a category
  Future<void> addLessonToCategory(String categoryId, String lessonId) async {
    try {
      final categoryDoc = await _categoriesCollection.doc(categoryId).get();
      if (categoryDoc.exists) {
        final category = Category.fromDocument(categoryDoc);
        category.lessonIds.add(lessonId);
        await _categoriesCollection.doc(categoryId).update({'lessonIds': category.lessonIds});
      } else {
        print('Category not found');
      }
    } catch (e) {
      print('Error adding lesson to category: $e');
    }
  }
}