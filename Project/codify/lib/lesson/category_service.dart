import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';

class CategoryService {
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');

  // Get a category_bloc by ID
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
      print('Error getting category_bloc: $e');
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




}