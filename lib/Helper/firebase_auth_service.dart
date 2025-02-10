
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // ✅ Function to log in user
//   Future<User?> login(String email, String password) async {
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       print("✅ Logged in as: ${userCredential.user!.email}");
//       return userCredential.user;
//     } catch (e) {
//       print("❌ Login failed: $e");
//       return null;
//     }
//   }

//   // ✅ Function to check if user is admin
//   Future<bool> checkIfUserIsAdmin() async {
//     try {
//       User? user = _auth.currentUser;
//       if (user == null) {
//         print("❌ No authenticated user found!");
//         return false;
//       }

//       String uid = user.uid;
//       print("✅ Checking admin status for UID: $uid");

//       // Query admin collection
//       DocumentSnapshot adminDoc = await _firestore
//           .collection('admins')
//           .doc(uid) // ✅ Query by UID instead of email
//           .get();

//       if (adminDoc.exists && adminDoc['isAdmin'] == true) {
//         print("✅ User is an admin!");
//         return true;
//       }

//       print("❌ User is NOT an admin!");
//       return false;
//     } catch (e) {
//       print("❌ Error checking admin status: $e");
//       return false;
//     }
//   }
// }
