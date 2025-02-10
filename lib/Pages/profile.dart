

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_user.dart';
import 'landing.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String profilePic;

  const ProfilePage({Key? key, required this.userId, required this.profilePic})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> userData;

  @override
  void initState() {
    super.initState();
    userData = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('User not found in Firebase');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  void _editAccount(BuildContext context, Map<String, dynamic> document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserDocumentPage(
          document: document,
          documentId: widget.userId,
        ),
      ),
    ).then((_) {
      setState(() {
        userData = _fetchUserData(); // Refresh data
      });
    });
  }

  Future<void> _deleteAccount() async {
    try {
      bool isConfirmed = await _showDeleteConfirmationDialog();
      if (isConfirmed) {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null && user.email == (await userData)['email']) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .delete();
          await user.delete();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account successfully deleted')),
          );

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LandingPage()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found in Authentication')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete account: $e')),
      );
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              const Text('Delete Account', style: TextStyle(color: Colors.red)),
          content: const Text(
              'Are you sure you want to delete your account permanently?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void _logout() async {
    bool isConfirmed = await _showLogoutConfirmationDialog();
    if (isConfirmed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LandingPage()),
      );
    }
  }

  Future<bool> _showLogoutConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal,
                Color(0xfff5f5f5),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: userData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final user = snapshot.data!;
                print("All User Keys: ${user}");

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: widget.profilePic.isNotEmpty
                              ? NetworkImage(widget.profilePic)
                              : const AssetImage('assets/images/avatar.png')
                                  as ImageProvider,
                        ),
                        const SizedBox(height: 16),
                        Text(user['name'] ?? 'No Name',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(user['email'] ?? 'No Email',
                            style: const TextStyle(color: Colors.white60)),
                        const SizedBox(height: 20),

                        /// User Info Cards
                        _buildInfoCard("Father's Name", user['father_name']),
                        _buildInfoCard("Mother's Name", user['mother_name']),
                        _buildInfoCard("Date of Birth", user['date_of_birth']),
                        _buildInfoCard("District", user['district']),
                        _buildInfoCard("Sub-District", user['sub_district']),
                        _buildInfoCard(
                            "Category", user['category'] ?? "No category"),

                        const SizedBox(height: 20),

                        /// Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(
                                "Edit Profile",
                                Icons.edit,
                                Colors.green,
                                () => _editAccount(context, user)),
                            _buildButton("Delete Account", Icons.delete,
                                Colors.red, _deleteAccount),
                          ],
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Log Out'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return const Center(child: Text('No user data available'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, dynamic content) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.teal)),
        subtitle: Text(
          (content != null && content.toString().isNotEmpty)
              ? content.toString()
              : 'Not available',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildButton(
      String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        text,
        style: TextStyle(
          color: Color(0xfff5f5f5),
        ),
      ),
      style: ElevatedButton.styleFrom(backgroundColor: color),
    );
  }
}
