import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'category_details.dart';
import 'item_details.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String profilePic;
  final bool isGuest;
  final Map<String, dynamic> user;

  const HomePage({
    required this.userName,
    required this.profilePic,
    required this.isGuest,
    required this.user,
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'All';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _categoriesStream() {
    return _firestore.collection('categories').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList(),
        );
  }

  // Stream<List<Map<String, dynamic>>> _approvedUsersStream() {
  //   return _firestore
  //       .collection('users')
  //       .where('isApproved', isEqualTo: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((doc) => doc.data() as Map<String, dynamic>)
  //           .toList());
  // }

  Stream<List<Map<String, dynamic>>> _approvedUsersStream() {
    return _firestore
        .collection('users')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> users = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Apply search filter
      if (_searchController.text.isNotEmpty) {
        String query = _searchController.text.toLowerCase();
        users = users.where((user) {
          String name = user['name']?.toLowerCase() ?? '';
          return name.contains(query);
        }).toList();
      }

      return users;
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    return _firestore.collection('users').doc(widget.user['id']).snapshots();
  }

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailsPage(category: category),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 40, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsPage(item: user),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  user['profile_pic'] ?? '',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Icon(Icons.person,
                          size: 50, color: Colors.white),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.teal,
                          size: 18,
                        ),
                        Flexible(
                          child: Text(
                            user['name'] ?? "Unknown",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Colors.teal,
                          size: 18,
                        ),
                        Flexible(
                          child: Text(
                            user['phone'] ?? "No phone",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.category,
                          color: Colors.teal,
                          size: 18,
                        ),
                        Flexible(
                          child: Text(
                            user['category'] ?? "No category",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120), // Adjust height
        child: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal,
          elevation: 8,
          flexibleSpace: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('users')
                  .doc(widget.user['id'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildAppBarContent("Loading...", "", isLoading: true);
                }

                if (!snapshot.hasData || snapshot.data!.data() == null) {
                  return _buildAppBarContent("Guest", "", isGuest: true);
                }

                final userData = snapshot.data!.data();
                String updatedName = userData?['name'] ?? "Unknown User";
                String updatedProfilePic = userData?['profile_pic'] ?? "";

                return _buildAppBarContent(updatedName, updatedProfilePic);
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Categories Section
            const Text("Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // FutureBuilder<List<Map<String, dynamic>>>(
            //   future: _getCategories(),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _categoriesStream(),
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!categorySnapshot.hasData ||
                    categorySnapshot.data!.isEmpty) {
                  return const Center(child: Text('No categories found.'));
                }

                final categories = categorySnapshot.data!;

                return SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(categories[index]['name']);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            const Text("Approved Users",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _approvedUsersStream(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                  return const Center(child: Text('No approved users found.'));
                }

                final approvedUsers = userSnapshot.data!;

                return GridView.builder(
                  shrinkWrap:
                      true, // Ensures GridView doesn't take infinite height
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents nested scrolling
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78, // Adjusts height of the cards
                  ),
                  itemCount: approvedUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(approvedUsers[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarContent(String name, String profilePic,
      {bool isGuest = false, bool isLoading = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisSize:
      //     MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              // This ensures the text doesn't overflow
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoading ? "Loading..." : "Hey, $name",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: isLoading
                  ? const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    )
                  : profilePic.isNotEmpty
                      ? Image.network(
                          profilePic,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/avatar.png',
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/avatar.png',
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (query) {
              setState(() {}); // Refresh ui typing
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Search Name",
              prefixIcon: Icon(Icons.search, color: Colors.black),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}
