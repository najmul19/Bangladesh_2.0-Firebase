// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static Database? _db;

//   // static Future<Database> getDatabase() async {
//   //   if (_db != null) return _db!;
//   //   final path = join(await getDatabasesPath(), 'app.db');
//   //   _db = await openDatabase(
//   //     path,
//   //     version: 3, // Update to version 3
//   //     onCreate: (db, version) async {
//   //       await db.execute('''
//   //       CREATE TABLE users (
//   //         id INTEGER PRIMARY KEY AUTOINCREMENT,
//   //         name TEXT,
//   //         email TEXT,
//   //         phone TEXT,
//   //         password TEXT,
//   //         category TEXT,
//   //         personal_details TEXT,
//   //         description TEXT,
//   //         profile_pic TEXT,
//   //         photos TEXT,
//   //         video_links TEXT,
//   //         isApproved INTEGER DEFAULT 0
//   //       )
//   //     ''');
//   //       await db.execute('''
//   //       CREATE TABLE categories (
//   //         id INTEGER PRIMARY KEY AUTOINCREMENT,
//   //         name TEXT
//   //       )
//   //     ''');
//   //     },
//   //     onUpgrade: (db, oldVersion, newVersion) async {
//   //       if (oldVersion < 2) {
//   //         await db.execute('''
//   //         ALTER TABLE users ADD COLUMN video_links TEXT
//   //       ''');
//   //       }
//   //       if (oldVersion < 3) {
//   //         await db.execute('''
//   //         ALTER TABLE users ADD COLUMN isRejected INTEGER DEFAULT 0
//   //       ''');
//   //       }
//   //     },
//   //   );
//   //   return _db!;
//   // }

// // static Future<Database> getDatabase() async {
// //   if (_db != null) return _db!;
// //   final path = join(await getDatabasesPath(), 'app.db');
// //   await deleteDatabase(path);
// //   _db = await openDatabase(
// //     path,
// //     version: 4, // Update to version 4
// //     onCreate: (db, version) async {
// //       await db.execute(''' 
// //       CREATE TABLE users (
// //         id INTEGER PRIMARY KEY AUTOINCREMENT,
// //         name TEXT,
// //         email TEXT UNIQUE,
// //         phone TEXT,
// //         password TEXT,
// //         category TEXT,
// //         personal_details TEXT,
// //         description TEXT,
// //         profile_pic TEXT,
// //         photos TEXT,
// //         video_links TEXT,
// //         isApproved INTEGER DEFAULT 0,
// //         isRejected INTEGER DEFAULT 0,
// //         is_admin_added INTEGER DEFAULT 0
// //       )
// //       ''');
// //       await db.execute(''' 
// //       CREATE TABLE categories (
// //         id INTEGER PRIMARY KEY AUTOINCREMENT,
// //         name TEXT
// //       )
// //       ''');
// //     },
// //     onUpgrade: (db, oldVersion, newVersion) async {
// //       if (oldVersion < 2) {
// //         await db.execute(''' 
// //         ALTER TABLE users ADD COLUMN video_links TEXT
// //         ''');
// //       }
// //       if (oldVersion < 3) {
// //         await db.execute(''' 
// //         ALTER TABLE users ADD COLUMN isRejected INTEGER DEFAULT 0
// //         ''');
// //       }
// //       if (oldVersion < 4) {
// //         // Add new column is_admin_added with default value 1
// //         await db.execute(''' 
// //         ALTER TABLE users ADD COLUMN is_admin_added INTEGER DEFAULT 0
// //         ''');
// //       }
// //     },
// //   );
// //   return _db!;
// // }


// static Future<Database> getDatabase() async {
//     if (_db != null) return _db!;

//     final path = join(await getDatabasesPath(), 'app.db');
//     //await deleteDatabase(path); // Deletes existing DB (optional)

//     _db = await openDatabase(
//       path,
//       version: 1, // Set version to 1 (since we are creating fresh)
//       onCreate: (db, version) async {
//         await db.execute(''' 
//           CREATE TABLE users (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT,
//             email TEXT UNIQUE,
//             phone TEXT,
//             password TEXT,
//             category TEXT,
//             personal_details TEXT,
//             description TEXT,
//             profile_pic TEXT,
//             photos TEXT,
//             video_links TEXT,
//             isApproved INTEGER DEFAULT 0,
//             isRejected INTEGER DEFAULT 0,
//             is_admin_added INTEGER DEFAULT 0
//           )
//         ''');

//         await db.execute(''' 
//           CREATE TABLE categories (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             name TEXT
//           )
//         ''');
//       },
//     );

//     return _db!;
//   }

// ///new
//   // static Future<int> getIsAdminAdded(int userId) async {
//   //   final db = await getDatabase();
//   //   final result = await db.query(
//   //     'users',
//   //     columns: ['is_admin_added'],
//   //     where: 'id = ?',
//   //     whereArgs: [userId],
//   //   );
    
//   //   // If the user is found, return the value of 'is_admin_added'
//   //   if (result.isNotEmpty) {
//   //     return result.first['is_admin_added'] as int;
//   //   } else {
//   //     throw Exception('User not found');
//   //   }
//   // }


// //   static Future<void> insertUser(Map<String, dynamic> user) async {
// //     // final db = await getDatabase();
// //     // await db.insert('users', user);
// //     try {
// //   final db = await DBHelper.getDatabase();
// //   await db.insert('users', user);
// // } catch (e) {
// //   if (e.toString().contains("UNIQUE constraint failed: users.email")) {
// //     print("Email already exists!");
// //   }
// // }
// //   }


// static Future<int> insertUser(Map<String, dynamic> user) async {
//   final db = await getDatabase();
//   try {
//     return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.fail);
//   } catch (e) {
//     print("Database Insert Error: $e");
//     rethrow; // This ensures the error is propagated
//   }
// }

//   static Future<Map<String, dynamic>?> getUserById(int userId) async {
//     final db = await getDatabase();
//     final results = await db.query(
//       'users',
//       // columns: [
//       //   'name',
//       //   'phone',
//       //   'personal_details',
//       //   'description',
//       //   'profile_pic',
//       //   'photos'
//       // ], // Ensure all needed fields are included
//       where: 'id = ?',
//       whereArgs: [userId],
//     );
//     return results.isNotEmpty ? results.first : null;
//   }
//   static Future<void> deleteUserById(int userId) async {
//   final db = await getDatabase();
//   await db.delete(
//     'users',
//     where: 'id = ?',
//     whereArgs: [userId],
//   );
// }


//   static Future<Map<String, dynamic>?> getUserByEmailAndPassword(
//       String email, String password) async {
//     final db = await getDatabase();
//     final results = await db.query(
//       'users',
//       where: 'email = ? AND password = ?',
//       whereArgs: [email, password],
//     );
//     return results.isNotEmpty ? results.first : null;
//   }
//   static Future<void> updateDocument(Map<String, dynamic> document) async {
//   final db = await getDatabase();
//   await db.update(
//     'users', 
//     document,
//     where: 'id = ?',
//     whereArgs: [document['id']],
//   );
// }


//   static Future<void> addCategory(String categoryName) async {
//     final db = await getDatabase();
//     await db.insert('categories', {'name': categoryName});
//   }

//   static Future<void> deleteCategory(int categoryId) async {
//     final db = await getDatabase();
//     await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
//   }

//   static Future<List<Map<String, dynamic>>> getPendingRequests() async {
//     final db = await getDatabase();
//     return db.query(
//       'users',
//       where: 'isApproved = ?',
//       whereArgs: [0], // 0 for pending
//     );
//   }

// //   static Future<void> updateRequestStatus(int userId, {required bool isApproved}) async {
// //   final db = await getDatabase();
// //   await db.update(
// //     'users',
// //     {'isApproved': isApproved ? 1 : 0, 'isRejected': isApproved ? 0 : 1},
// //     where: 'id = ?',
// //     whereArgs: [userId],
// //   );
// // }
//   static Future<void> updateRequestStatus(int userId,
//       {required bool isApproved}) async {
//     final db = await getDatabase();

//     if (isApproved) {
//       // Approve the user, so set isApproved to 1 and isRejected to 0
//       await db.update(
//         'users',
//         {'isApproved': 1, 'isRejected': 0},
//         where: 'id = ?',
//         whereArgs: [userId],
//       );
//     } else {
//       // Reject the user and permanently delete the user from the database
//       await db.delete(
//         'users',
//         where: 'id = ?',
//         whereArgs: [userId],
//       );
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getAllUsers() async {
//     final db = await getDatabase();
//     return db.query('users');
//   }

//   static Future<List<Map<String, dynamic>>> getAllCategories() async {
//     final db = await getDatabase();
//     return db.query('categories');
//   }

//   //----
//   // static Future<List<Map<String, dynamic>>> getItemsByCategory(
//   //     String category) async {
//   //   final db = await getDatabase();
//   //   return db.query(
//   //     'users',
//   //     where: 'category = ? AND isApproved = ?',
//   //     whereArgs: [category, 1], // Only fetch approved users
//   //   );
//   // }

//   static Future<List<Map<String, dynamic>>> getItemsByCategory(
//       String category) async {
//     final db = await getDatabase();
//     List<Map<String, dynamic>> result = await db.query(
//       'users',
//       columns: [
//         'id',
//         'name',
//         'phone',
//         'personal_details',
//         'description',
//         'profile_pic',
//         'photos'
//       ],
//       where: 'category = ? AND isApproved = ?',
//       whereArgs: [category, 1], // Only fetch approved users
//     );

//     // Log the result to check if personal_details and description are present
//     print('Fetched items for category: $category');
//     result.forEach((item) {
//       print(
//           'Item: ${item['name']}, Personal Details: ${item['personal_details']}, Description: ${item['description']}');
//     });

//     return result;
//   }

//   static Future<List<Map<String, dynamic>>> searchItems(String query) async {
//     final db = await getDatabase();
//     return db.query('users', where: 'name LIKE ?', whereArgs: ['%$query%']);
//   }

//   // static Future<void> updateUser(Map<String, dynamic> user) async {
//   //   final db = await getDatabase();
//   //   await db.update('users', user, where: 'id = ?', whereArgs: [user['id']]);
//   // }

// //-------
//   // static Future<void> createNotificationsTable(Database db) async {
//   //   await db.execute('''
//   //   CREATE TABLE notifications (
//   //     id INTEGER PRIMARY KEY AUTOINCREMENT,
//   //     type TEXT,
//   //     message TEXT,
//   //     timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
//   //     isRead INTEGER DEFAULT 0
//   //   )
//   // ''');
//   // }

//   // static Future<void> addNotification(String type, String message) async {
//   //   final db = await getDatabase();
//   //   await db.insert('notifications', {'type': type, 'message': message});
//   // }

//   static Future<List<Map<String, dynamic>>> getFilteredItems(
//       {String? category, bool approvedOnly = false}) async {
//     final db = await getDatabase();
//     String query = 'SELECT * FROM users WHERE 1=1';
//     List<dynamic> args = [];

//     if (category != null && category != 'All') {
//       query += ' AND category = ?';
//       args.add(category);
//     }
//     if (approvedOnly) {
//       query += ' AND isApproved = 1';
//     }

//     return db.rawQuery(query, args);
//   }

//   // static Future<void> createBookmarksTable(Database db) async {
//   //   await db.execute('''
//   //   CREATE TABLE bookmarks (
//   //     id INTEGER PRIMARY KEY AUTOINCREMENT,
//   //     userId INTEGER,
//   //     itemId INTEGER
//   //   )
//   // ''');
//   // }

//   // static Future<void> addBookmark(int userId, int itemId) async {
//   //   final db = await getDatabase();
//   //   await db.insert('bookmarks', {'userId': userId, 'itemId': itemId});
//   // }

//   // static Future<void> removeBookmark(int userId, int itemId) async {
//   //   final db = await getDatabase();
//   //   await db.delete(
//   //     'bookmarks',
//   //     where: 'userId = ? AND itemId = ?',
//   //     whereArgs: [userId, itemId],
//   //   );
//   // }
// }
