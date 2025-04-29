import 'package:flutter/material.dart';
import 'package:codify_admin/pages/user.dart';
import 'package:codify_admin/pages/image_service.dart';
import 'package:codify_admin/pages/image.dart';
import 'package:codify_admin/pages/super_admin_service.dart';

class UserDetailPage extends StatefulWidget {
  final UserDetail user;

  UserDetailPage({required this.user});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final ImageService _imageService = ImageService();
  final UserDetailService _userDetailService = UserDetailService();
  late UserDetail _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
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

  Future<bool> _showDeleteConfirmationDialog(String userNameIdentifier) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to permanently delete the user $userNameIdentifier? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
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

          setState(() {
            _currentUser = _currentUser.copyWith(
              isBlacklisted: true,
              blacklistReason: reason,
            );
          });
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

          setState(() {
            _currentUser = _currentUser.copyWith(
              isBlacklisted: false,
              blacklistReason: null,
            );
          });
        }
      } catch (e) {
        if (mounted) {
          await _showInfoDialog('Error', 'Error revoking blacklist: $e');
        }
      }
    }
  }

  Future<void> _performDeleteUser(
      String documentId, String userNameIdentifier) async {
    final confirmed = await _showDeleteConfirmationDialog(userNameIdentifier);
    if (confirmed && mounted) {
      try {
        await _userDetailService.deleteUserDetail(documentId);
        if (mounted) {
          await _showInfoDialog('Success', 'User deleted successfully');

          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          await _showInfoDialog('Error', 'Error deleting user: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBlacklisted = _currentUser.isBlacklisted;
    final statusText = isBlacklisted ? 'Blacklisted' : 'Active';
    final statusColor = isBlacklisted ? Colors.red : Colors.green;
    final userNameIdentifier =
        _currentUser.name ?? _currentUser.userId ?? _currentUser.documentId;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(_currentUser.name ?? 'User Details'),
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 1.0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (!isBlacklisted)
            Tooltip(
              message: 'Add to Blacklist',
              child: IconButton(
                icon: const Icon(Icons.block, color: Colors.orange),
                onPressed: () {
                  _performBlacklist(_currentUser.documentId);
                },
              ),
            ),
          if (isBlacklisted)
            Tooltip(
              message: 'Revoke Blacklist',
              child: IconButton(
                icon:
                    const Icon(Icons.check_circle_outline, color: Colors.green),
                onPressed: () {
                  _performRevokeBlacklist(
                      _currentUser.documentId, userNameIdentifier);
                },
              ),
            ),
          Tooltip(
            message: 'Delete User',
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                _performDeleteUser(_currentUser.documentId, userNameIdentifier);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: FutureBuilder<List<ImageModel>>(
                future:
                    _imageService.getImageByUserId(_currentUser.userId ?? ''),
                builder: (context, imageSnapshot) {
                  Widget imageWidget = Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.grey.shade400,
                  );

                  if (imageSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    imageWidget = const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (imageSnapshot.hasError) {
                    imageWidget = Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.red.shade300,
                    ); // Error icon
                  } else if (imageSnapshot.hasData &&
                      imageSnapshot.data!.isNotEmpty) {
                    final imageUrl = imageSnapshot.data![0].image;
                    imageWidget = ClipOval(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey.shade400,
                          );
                        },
                      ),
                    );
                  }

                  return CircleAvatar(
                    radius: 65,
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: imageWidget,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _currentUser.name ?? 'No Name Provided',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Chip(
                label: Text(statusText),
                backgroundColor: statusColor.withOpacity(0.1),
                labelStyle:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                side: BorderSide(color: statusColor.withOpacity(0.5)),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _buildDetailRow(context, Icons.person_outline, 'Name',
                _currentUser.name ?? 'N/A'),
            _buildDetailRow(context, Icons.credit_card, 'User ID',
                _currentUser.userId ?? 'N/A'),
            _buildDetailRow(context, Icons.fingerprint, 'Document ID',
                _currentUser.documentId),
            if (isBlacklisted) ...[
              const Divider(),
              _buildDetailRow(context, Icons.block, 'Blacklist Reason',
                  _currentUser.blacklistReason ?? 'No reason specified',
                  valueColor: Colors.red),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500, color: valueColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
