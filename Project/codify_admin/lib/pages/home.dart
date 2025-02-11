import 'package:flutter/material.dart';
import 'package:codify_admin/pages/auth.dart';
import 'package:codify_admin/lesson/topic_list.dart';
import 'package:codify_admin/lesson/add_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codify_admin/lesson/category.dart';
import '../lesson/category_service.dart';
import '../lesson/edit_category.dart';

enum SampleItem { logout }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final CategoryService _categoryService = CategoryService();
  SampleItem? selectedItem;

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCategory(Category category) async {
    final updatedCategory = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(category: category),
      ),
    );

    if (updatedCategory != null) {
      setState(() {});
    }
  }

  Future<void> _confirmDeleteCategory(String documentId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteCategory(documentId);
    }
  }

  Future<void> _deleteCategory(String documentId) async {
    await _categoryService.deleteCategory(documentId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Category Management'),
        actions: [
          PopupMenuButton<SampleItem>(
            initialValue: selectedItem,
            onSelected: (SampleItem item) {
              setState(() {
                selectedItem = item;
                if (item == SampleItem.logout) {
                  _showLogout(context);
                }
              });
            },
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<SampleItem>>[
              const PopupMenuItem<SampleItem>(
                value: SampleItem.logout,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching categories'));
          }
          final categories = snapshot.data!.docs.map((doc) => Category.fromDocument(doc)).toList();
          return ListView.separated(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                title: Text(category.name),
                tileColor: Colors.grey[200], // Add background color here
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicList(category: category),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editCategory(category),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeleteCategory(category.documentId),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCategoryScreen(),
                ),
              );
            },
            heroTag: null,
            child: const Icon(Icons.category),
          ),
        ],
      ),
    );
  }
}