
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';




class RequestDetailsPage extends StatefulWidget {
  final String email;

  const RequestDetailsPage({Key? key, required this.email}) : super(key: key);

  @override
  _RequestDetailsPageState createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: widget.email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        userData = snapshot.docs.first.data(); //its ensure actual data
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _approveUser(BuildContext context, String userId) {
    _showConfirmationDialog(
      context: context,
      title: "Approve User?",
      content: "Are you sure you want to approve this user?",
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'isApproved': true});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User approved successfully!")),
          );

          Navigator.pop(context, true);
        } catch (e) {
          print("Error approving user: $e");
        }
      },
    );
  }

  void _rejectUser(BuildContext context, String userId) {
    _showConfirmationDialog(
      context: context,
      title: "Reject User?",
      content: "Are you sure you want to reject this user?",
      onConfirm: () async {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              // .update({'isApproved': false});
              .delete();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User rejected successfully!")),
          );

          Navigator.pop(context, true);
        } catch (e) {
          print("Error rejecting user: $e");
        }
      },
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
    required BuildContext context,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
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
              'Request Details Page',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
              ? const Center(child: Text("No user found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _openProfileViewer(userData!['profile_pic']);
                        },
                        child: CircleAvatar(
                          radius: 65,
                          backgroundImage: userData!['profile_pic'] != null
                              ? CachedNetworkImageProvider(
                                  userData!['profile_pic'])
                              : const AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        userData!['name'] ?? "No Name",
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(userData!['email'] ?? "No Email",
                          style: TextStyle(color: Colors.grey.shade700)),
                      const SizedBox(height: 20),
                      _buildUserInfoCard(),
                      const SizedBox(height: 20),
                      _buildActionButtons(userData!['id']),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoTile("Category", userData!['category']),
            _buildInfoTile("Date of Birth", userData!['date_of_birth']),
            _buildInfoTile("Phone", userData!['phone']),
            _buildInfoTile("Father's Name", userData!['father_name']),
            _buildInfoTile("Mother's Name", userData!['mother_name']),
            _buildInfoTile("District", userData!['district']),
            _buildInfoTile("Sub-District", userData!['sub_district']),
            _buildInfoTile("Description", userData!['description']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label: ",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: Text(value ?? "Not Provided",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String userId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _approveUser(context, userId),
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text("Approve"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _rejectUser(context, userId),
          icon: const Icon(Icons.cancel, color: Colors.white),
          label: const Text("Reject"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
          ),
        ),
      ],
    );
  }

  void _openProfileViewer(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: PhotoView(
              // zomablr image
              imageProvider: CachedNetworkImageProvider(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
