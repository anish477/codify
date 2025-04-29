import 'package:codify_admin/pages/super_admin.dart';
import 'package:flutter/material.dart';
import 'package:codify_admin/pages/auth.dart';
import 'package:codify_admin/lesson/topic_list.dart';
import 'package:codify_admin/lesson/add_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codify_admin/lesson/category.dart';
import '../lesson/category_service.dart';
import '../lesson/edit_category.dart';
import 'package:flutter/services.dart';

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
          backgroundColor: const Color(0xFFFFFFFFF),
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
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFFF),
          automaticallyImplyLeading: false,
          title: const Text('Category Management'),
          actions: [
            Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: const PopupMenuThemeData(
                  color: Color(0xFFFFFFFFF),
                ),
              ),
              child: PopupMenuButton<SampleItem>(
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
                  PopupMenuItem<SampleItem>(
                    value: SampleItem.logout,
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('categories').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching categories'));
            }
            final categories = snapshot.data!.docs
                .map((doc) => Category.fromDocument(doc))
                .toList();
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 5,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(category.name),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => _editCategory(category),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _confirmDeleteCategory(category.documentId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'addCategory',
              backgroundColor: Color(0xFFFFFFFF),
              tooltip: 'Add Category',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddCategoryScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.category,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'manageUsers',
              backgroundColor: Color(0xFFFFFFFF),
              tooltip: 'Manage Users',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuperAdminPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.people,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
