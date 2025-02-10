import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'request_details.dart';

class PendingRequestsPage extends StatefulWidget {
  @override
  _PendingRequestsPageState createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  bool _isAdmin = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingUsers = [];

  @override
  void initState() {
    super.initState();
    checkIfUserIsAdmin();
  }

  void checkIfUserIsAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted)
        setState(() => _isLoading = false); //mounted prevent exception
      return;
    }

    String uid = user.uid;

    try {
      DocumentSnapshot adminDoc =
          await FirebaseFirestore.instance.collection('admins').doc(uid).get();
      bool isAdmin = adminDoc.exists && (adminDoc['isAdmin'] ?? false);

      if (isAdmin) fetchPendingUsers();

      if (mounted) {
        setState(() {
          _isAdmin = isAdmin;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error checking admin status: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void fetchPendingUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('isApproved', isEqualTo: false)
          .get();

      List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'email': doc['email'],
          'isApproved': doc['isApproved'],
        };
      }).toList();

      if (mounted) {
        setState(() {
          _pendingUsers = users;
        });
      }

      print("Pending Users Found: ${users.length}");
    } catch (e) {
      print("Error fetching pending users: $e");
    }
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text("Confirm", style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void approveUser(String userId) {
    _showConfirmationDialog(
      title: "Approve User?",
      content: "Are you sure you want to approve this user?",
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'isApproved': true});

          setState(() {
            _pendingUsers.removeWhere((user) => user['id'] == userId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User approved successfully!")),
          );
        } catch (e) {
          print("Error approving user: $e");
        }
      },
    );
  }

  void rejectUser(String userId) {
    _showConfirmationDialog(
      title: "Remove User?",
      content: "Are you sure you want to remove this user?",
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .delete();

          setState(() {
            _pendingUsers.removeWhere((user) => user['id'] == userId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User removed successfully!")),
          );
        } catch (e) {
          print("Error removing user: $e");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.teal.shade50,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Colors.teal,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Pending Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),

              centerTitle: true,
              elevation: 8,
              // shadowColor: Colors.black54,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isAdmin) {
      return Scaffold(
        backgroundColor: Colors.teal.shade50,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
            child: AppBar(
              backgroundColor: Colors.teal,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Access Denied',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 1.2,
                ),
              ),

              centerTitle: true,
              elevation: 8,
              // shadowColor: Colors.black54,
            ),
          ),
        ),
        body: const Center(
            child: Text("You don't have permission to view this page.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: AppBar(
            backgroundColor: Colors.teal,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Pending Requests',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),

            centerTitle: true,
            elevation: 8,
            // shadowColor: Colors.black54,
          ),
        ),
      ),
    
      body: _pendingUsers.isEmpty
          ? const Center(child: Text("No pending requests!"))
          : ListView.builder(
              itemCount: _pendingUsers.length,
              itemBuilder: (context, index) {
                var user = _pendingUsers[index];
                return Card(
                    color: const Color(0xfff5f5f5),
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      title: Text(
                        user['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(user['email'],
                          style: const TextStyle(color: Colors.grey)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => approveUser(user['id']),
                            tooltip: "Approve",
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () => rejectUser(user['id']),
                            tooltip: "Remove",
                          ),
                        ],
                      ),
                      onTap: () async {
                        var user = _pendingUsers[index];
                        String email = user['email'];

                        bool? result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RequestDetailsPage(email: email),
                          ),
                        );

                        if (result == true) {
                          fetchPendingUsers();
                        }
                      },
                    ));
              },
            ),
    );
  }
}
