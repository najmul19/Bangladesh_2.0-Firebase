import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'landing.dart';
import 'admin_add_doc.dart';
import 'manage_category.dart';
import 'pending_request.dart';
import 'view_all_doc.dart';
import 'view_all_users.dart';

class AdminPage extends StatelessWidget {

  void navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text("No", style: TextStyle(color: Colors.teal)),
            ),
            TextButton(
              onPressed: () async {
                FirebaseAuth.instance.signOut(); // 🔸 Logout from Firebase
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
            automaticallyImplyLeading: false,
            backgroundColor: Colors.teal,
            // leading: IconButton(
            //   icon:
            //       Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            //   onPressed: () => Navigator.pop(context),
            // ),
            title: const Text(
              'Admin Panel',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: [
            _buildAdminCard(context, Icons.pending_actions,
                "Manage Pending Requests", PendingRequestsPage()),
            _buildAdminCard(
                context, Icons.people, "View All Users", ViewAllUsersPage()),
            _buildAdminCard(context, Icons.category, "Manage Categories",
                ManageCategoriesPage()),
            _buildAdminCard(context, Icons.insert_drive_file, "View Documents",
                ViewDocumentsPage()),
            _buildAdminCard(context, Icons.add, "Add Items",
                const AdminAddItemPage(isAdmin: true)),
            _buildAdminCard(context, Icons.logout, "Logout", null,
                isLogout: true),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
      BuildContext context, IconData icon, String title, Widget? page,
      {bool isLogout = false}) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => isLogout ? logout(context) : navigateTo(context, page!),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: isLogout ? Colors.red : Colors.teal),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isLogout ? Colors.red : Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
