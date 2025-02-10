import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:experiment/Pages/item_details.dart';
import 'package:flutter/material.dart';

import 'edit_list_admin.dart';

class ViewDocumentsPage extends StatefulWidget {
  @override
  _ViewDocumentsPageState createState() => _ViewDocumentsPageState();
}

class _ViewDocumentsPageState extends State<ViewDocumentsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> documents = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();

      setState(() {
        documents = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
      });
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  void editDocument(BuildContext context, Map<String, dynamic> document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDocumentPage(
          document: document,
          documentId: document['id'],
        ),
      ),
    ).then((_) {
      fetchDocuments();
    });
  }

  void _showDeleteConfirmationDialog(String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Document?"),
          content: const Text(
              "Are you sure you want to delete this document? This action cannot be undone."),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.teal)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete",
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
                deleteDocument(docId);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteDocument(String docId) async {
    try {
      await _firestore.collection('users').doc(docId).delete();
      fetchDocuments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document deleted successfully!")),
      );
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  Widget buildImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(Icons.person, size: 60, color: Colors.grey);
    }

    try {
      final decodedBytes =
          base64Decode(imagePath); // into raw bytes as a text string.
      return CircleAvatar(
        radius: 30,
        backgroundImage: MemoryImage(decodedBytes),
      );
    } catch (e) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imagePath),
        onBackgroundImageError: (_, __) =>
            const Icon(Icons.broken_image, size: 60),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'View Documents',
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
      body: documents.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_empty,
                      size: 100, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text('No documents available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                ],
              ),
            )
          : ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final document = documents[index];
                return Card(
                  color: const Color(0xfff5f5f5),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: buildImage(document['profile_pic']),
                    title: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      document['name'] ?? 'Unknown Name',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      document['phone'] ?? 'No Phone Number',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editDocument(context, document),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(document['id']),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsPage(item: document),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
