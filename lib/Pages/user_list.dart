// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class UsersListPage extends StatefulWidget {
//   @override
//   _UsersListPageState createState() => _UsersListPageState();
// }

// class _UsersListPageState extends State<UsersListPage> {
//   final CollectionReference usersCollection =
//       FirebaseFirestore.instance.collection('users');

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Users List")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: usersCollection.snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text("No users found"));
//           }

//           var users = snapshot.data!.docs;

//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               var user = users[index];
//               var data = user.data() as Map<String, dynamic>;

//               return Card(
//                 margin: EdgeInsets.all(8),
//                 child: ListTile(
//                   title: Text(data['name'] ?? 'No Name'),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Email: ${data['email']}"),
//                       Text("Phone: ${data['phone']}"),
//                       Text("Category: ${data['category']}"),
//                       Text("Description: ${data['description']}"),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
