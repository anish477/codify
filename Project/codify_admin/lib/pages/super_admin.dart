import 'package:codify_admin/pages/image.dart';
import 'package:flutter/material.dart';
import 'package:codify_admin/pages/super_admin_service.dart';
import 'package:codify_admin/pages/user.dart';
import 'package:codify_admin/pages/image_service.dart';
import 'package:codify_admin/pages/user_detail_page.dart';

class SuperAdminPage extends StatefulWidget {
  @override
  State<SuperAdminPage> createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> {
  final UserDetailService _userDetailService = UserDetailService();
  late Future<List<UserDetail>> _usersFuture;
  List<UserDetail> _allUsers = [];
  List<UserDetail> _filteredUsers = [];
  final ImageService _imageService = ImageService();
  final TextEditingController _searchController = TextEditingController();

  bool _showBlacklistedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() {
    setState(() {

      _usersFuture = (_showBlacklistedOnly
              ? _userDetailService.getBlacklistedUsers()
              : _userDetailService.getNonBlacklistedUsers())
          .then((users) {
        _allUsers = users;
        _filterUsers();
        return _filteredUsers;
      });
    });
  }


  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_allUsers);
      } else {
        _filteredUsers = _allUsers.where((user) {
          final nameMatches = user.name?.toLowerCase().contains(query) ?? false;
          final userIdMatches =
              user.userId?.toLowerCase().contains(query) ?? false;

          return nameMatches || userIdMatches;
        }).toList();
      }

      _usersFuture = Future.value(_filteredUsers);
    });
  }

  Future<void> _showInfoDialog(String title, String content) async {
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: Text(title),
          content: SingleChildScrollView(

            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showRevokeConfirmationDialog(String userNameIdentifier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Confirm Revoke'),
          content: Text(
              'Are you sure you want to revoke the blacklist status for $userNameIdentifier?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
            ),
            TextButton(
              child:
                  const Text('Revoke', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(ctx).pop(true);
              },
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<String?> _showBlacklistReasonDialog() async {
    final reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Blacklist Reason'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
                hintText: "Enter reason for blacklisting"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Blacklist'),
              onPressed: () {
                if (reasonController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(reasonController.text.trim());
                } else {
                  Navigator.of(context).pop();
                  _showInfoDialog('Input Error', 'Reason cannot be empty.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performBlacklist(String documentId) async {
    final reason = await _showBlacklistReasonDialog();
    if (reason != null && reason.isNotEmpty) {
      try {
        await _userDetailService.addToBlacklist(documentId, reason);
        if (mounted) {
          await _showInfoDialog('Success', 'User blacklisted successfully');
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          await _showInfoDialog('Error', 'Error blacklisting user: $e');
        }
      }
    }
  }

  Future<void> _performRevokeBlacklist(
      String documentId, String userNameIdentifier) async {
    final confirmed = await _showRevokeConfirmationDialog(userNameIdentifier);

    if (confirmed && mounted) {
      try {
        await _userDetailService.revokeBlacklist(documentId);
        if (mounted) {
          await _showInfoDialog(
              'Success', 'User blacklist revoked successfully');
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          await _showInfoDialog('Error', 'Error revoking blacklist: $e');
        }
      }
    }
  }

  Future<void> _deleteUser(String documentId) async {
    try {
      await _userDetailService.deleteUserDetail(documentId);

      if (mounted) {
        await _showInfoDialog('Success', 'User deleted successfully');

        _loadUsers();
      }
    } catch (e) {
      if (mounted) {
        await _showInfoDialog('Error', 'Error deleting user: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appBarTitle =
        _showBlacklistedOnly ? 'Blacklisted Users' : 'Active Users';
    final toggleTooltip =
        _showBlacklistedOnly ? 'Show Active Users' : 'Show Blacklisted Users';
    final toggleIcon =
        _showBlacklistedOnly ? Icons.check_circle_outline : Icons.block;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(appBarTitle),
            backgroundColor: const Color(0xFFFFFFFF),
            floating: true,
            pinned: true,
            elevation: 1.0,
            surfaceTintColor: Colors.transparent,
            actions: [
              Tooltip(
                message: toggleTooltip,
                child: IconButton(
                  icon: Icon(toggleIcon),
                  onPressed: () {
                    setState(() {
                      _showBlacklistedOnly = !_showBlacklistedOnly;
                      _searchController.clear();
                    });
                    _loadUsers();
                  },
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, user ID, or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            ),
          ),
          FutureBuilder<List<UserDetail>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  _filteredUsers.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (_filteredUsers.isEmpty) {
                final noUserText = _showBlacklistedOnly
                    ? 'No blacklisted users found'
                    : 'No active users found';
                final searchText = _searchController.text.isNotEmpty
                    ? ' matching "${_searchController.text}"'
                    : '.';
                return SliverFillRemaining(
                  child: Center(child: Text('$noUserText$searchText')),
                );
              } else {
                final users = _filteredUsers;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = users[index];
                      final isBlacklisted = user.isBlacklisted;
                      final titleColor = isBlacklisted ? Colors.red : null;
                      final subtitleText = isBlacklisted
                          ? 'Blacklisted: ${user.blacklistReason ?? "No reason specified"}'
                          : 'UserID: ${user.userId ?? "N/A"}';
                      final userNameIdentifier =
                          '${user.name ?? 'this user'} (${user.userId ?? user.documentId})';

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDetailPage(user: user),
                            ),
                          ).then((_) => _loadUsers());
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isBlacklisted
                                    ? Colors.red.shade100
                                    : Colors.blue.shade100,
                                child: FutureBuilder<List<ImageModel>>(
                                  future: _imageService
                                      .getImageByUserId(user.userId ?? ''),
                                  builder: (context, imageSnapshot) {
                                    if (imageSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      );
                                    }
                                    if (imageSnapshot.hasError) {
                                      return Icon(Icons.error_outline,
                                          color: Colors.red.shade700);
                                    }
                                    if (imageSnapshot.hasData &&
                                        imageSnapshot.data!.isNotEmpty) {
                                      final imageUrl =
                                          imageSnapshot.data![0].image;
                                      return ClipOval(
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(Icons.person,
                                                color: isBlacklisted
                                                    ? Colors.red.shade900
                                                    : Colors.blue.shade900);
                                          },
                                        ),
                                      );
                                    }
                                    return Icon(Icons.person,
                                        color: isBlacklisted
                                            ? Colors.red.shade900
                                            : Colors.blue.shade900);
                                  },
                                ),
                              ),
                              title: Text(
                                user.name ?? 'No Name',
                                style: TextStyle(color: titleColor),
                              ),
                              subtitle: Text(subtitleText),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: isBlacklisted
                                        ? 'Revoke Blacklist'
                                        : 'Add to Blacklist',
                                    child: IconButton(
                                      icon: Icon(
                                        isBlacklisted
                                            ? Icons.check_circle
                                            : Icons.block,
                                        color: isBlacklisted
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                      onPressed: () {
                                        if (isBlacklisted) {
                                          _performRevokeBlacklist(
                                              user.documentId,
                                              userNameIdentifier);
                                        } else {
                                          _performBlacklist(user.documentId);
                                        }
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: 'Delete User',
                                    child: IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext ctx) {
                                            return AlertDialog(
                                              backgroundColor:
                                                  const Color(0xFFFFFFFF),
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: Text(
                                                  'Are you sure you want to delete $userNameIdentifier?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                ),
                                                TextButton(
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  onPressed: () {
                                                    Navigator.of(ctx).pop();
                                                    _deleteUser(
                                                        user.documentId);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: users.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
