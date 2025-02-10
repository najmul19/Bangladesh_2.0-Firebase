

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'item_details.dart';

class CategoryDetailsPage extends StatelessWidget {
  final String category;

  CategoryDetailsPage({required this.category});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  Future<List<Map<String, dynamic>>> _getApprovedUsersByCategory(
      String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('isApproved', isEqualTo: true)
          .get();

      // Filter users by category
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .where((user) => user['category'] == category)
          .toList();
    } catch (e) {
      print("Error fetching approved users: $e");
      return [];
    }
  }


  Future<void> _makePhoneCall(String? phoneNumber, BuildContext context) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar(context, 'Number not exist');
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Error launching CALL URI: $e');
      _showSnackBar(context, 'Unable to make the call');
    }
  }

  
  Future<void> _sendSms(String? phoneNumber, BuildContext context) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      _showSnackBar(context, 'Number not exist');
      return;
    }
    final Uri launchUri = Uri(scheme: 'sms', path: phoneNumber);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      debugPrint('Error launching SMS URI: $e');
      _showSnackBar(context, 'Unable to send message');
    }
  }

  
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.red[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      
     
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          child: AppBar(
            backgroundColor: Colors.teal,
            leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '$category Details',
              style: const TextStyle(
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

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _getApprovedUsersByCategory(category),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      'No approved users in this category.',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            } else {
              final users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0.5,
                    child: ListTile(
                      leading: user['profile_pic'] != null
                          ? ClipOval(
                              child: Image.network(
                                user['profile_pic'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person,
                                      size: 40, color: Colors.grey);
                                },
                              ),
                            )
                          : const Icon(Icons.person, size: 40, color: Colors.grey),
                      title: Text(
                        user['name'] ?? "Unknown",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['phone'] ?? 'No phone number',
                            style: TextStyle(
                              color: user['phone'] != null
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category,
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.call, color: Colors.green),
                            onPressed: () =>
                                _makePhoneCall(user['phone'], context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.blue),
                            onPressed: () => _sendSms(user['phone'], context),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailsPage(item: user),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
