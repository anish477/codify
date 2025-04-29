import 'package:flutter/material.dart';
import '../lesson/category_service.dart';
import '../lesson/category.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;

  List<Category> _categories = [];
  bool _loading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  CategoryProvider({CategoryService? categoryService})
      : _categoryService = categoryService ?? CategoryService() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _categoryService.getAllCategories();
    } catch (e) {
      _error = 'Failed to load categories: ${e.toString()}';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
