import 'package:flutter/material.dart';
import 'package:codify_admin/pages/auth.dart';
import 'package:codify_admin/lesson/topic_list.dart';
import 'package:codify_admin/lesson/add_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codify_admin/lesson/category.dart';
import '../lesson/category_service.dart';

enum SampleItem { logout }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
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
                      builder: (context) => TopicList(lesson: null, category: category),
                    ),
                  );
                },
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