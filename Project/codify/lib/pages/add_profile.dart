import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:codify/provider/add_profile_provider.dart';

class AddProfile extends StatelessWidget {
  const AddProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddProfileProvider()..fetchUserData(),
      child: Consumer<AddProfileProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(
                provider.isEditing ? 'Edit Profile' : 'Add Profile',
                style: const TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: GlobalKey<FormState>(),
                    child: Builder(builder: (BuildContext formContext) {
                      return Column(
                        children: [
                          provider.isLoading
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                      height: 56,
                                      width: double.infinity,
                                      color: Colors.white))
                              : TextFormField(
                                  controller: provider.nameController,
                                  decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder()),
                                  validator: (v) => (v?.isEmpty ?? true)
                                      ? 'Please enter your name'
                                      : null,
                                ),
                          const SizedBox(height: 16),
                          provider.isLoading
                              ? Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                      height: 56,
                                      width: double.infinity,
                                      color: Colors.white))
                              : TextFormField(
                                  controller: provider.ageController,
                                  decoration: const InputDecoration(
                                      labelText: 'Age',
                                      border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please enter your age';
                                    }
                                    if (int.tryParse(v) == null ||
                                        int.parse(v) <= 0) {
                                      return 'Please enter a valid age';
                                    }
                                    return null;
                                  },
                                ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: provider.isSaving
                                ? null
                                : () async {
                                    final form = Form.of(formContext);
                                    if (form.validate()) {
                                      final success =
                                          await provider.saveProfile(context);
                                      if (success && context.mounted) {
                                        Navigator.of(context).pop(true);
                                      } else if (context.mounted)
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Failed to save user data')));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: provider.isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Save'),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
