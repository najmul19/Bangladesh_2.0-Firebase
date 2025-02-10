//=====================================================================================================

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController personalDetailsController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController videoLinksController = TextEditingController();
  String cloudinaryCloudName = "ddup3m4rz";
  String cloudinaryUploadPreset = "flutter_uploads";
  // new
  final TextEditingController fatherController = TextEditingController();
  final TextEditingController motherController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController subDistrictController = TextEditingController();

  String? category;
  // List<String> categories = ['Memories', 'Injured'];
  List<String> categories = [];

  final ImagePicker _picker = ImagePicker();
  XFile? profilePic;
  List<XFile> photos = [];

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

// new
  Future<void> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      categories.clear(); // Clear existing list before adding new data

      for (var doc in querySnapshot.docs) {
        String categoryName =
            doc['name']; // Assuming 'name' is the field for category name

        if (categoryName != 'Martyrs') {
          categories.add(categoryName);
        }
      }

      setState(() {}); // Refresh UI after fetching categories
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void pickProfilePic() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      profilePic = pickedFile;
    });
  }

  void pickPhotos() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      // photos = pickedFiles ?? [];
      photos = pickedFiles;
    });
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    try {
      print("Uploading to Cloudinary...");
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload"),
      );

      request.fields['upload_preset'] = cloudinaryUploadPreset;
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));

      print("Sending request to Cloudinary...");
      var response = await request.send();

      if (response.statusCode != 200) {
        print("Cloudinary Upload Failed: Status Code ${response.statusCode}");
      }

      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse.containsKey('error')) {
        print("Cloudinary Error: ${jsonResponse['error']['message']}");
        throw Exception(jsonResponse['error']['message']);
      }

      print("Cloudinary Upload Success: ${jsonResponse['secure_url']}");
      return jsonResponse['secure_url'];
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      throw Exception("Failed to upload image");
    }
  }

  void signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (profilePic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture is required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print("Starting Sign Up...");
      print("Name: ${nameController.text}");
      print("Email: ${emailController.text}");

      print("Creating Firebase user...");
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user == null) {
        throw Exception("User creation failed. Please try again.");
      }

      String uid = user.uid;
      print("User created with UID: $uid");

      print("Sending email verification...");
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Verification email sent! Please check your email and verify your account."),
        ),
      );

      print("Uploading profile picture to Cloudinary...");
      String profilePicUrl = await uploadToCloudinary(File(profilePic!.path));
      print("Profile picture uploaded: $profilePicUrl");

      List<String> photoUrls = [];
      if (photos.isNotEmpty) {
        print("Uploading multiple photos...");
        for (XFile photo in photos) {
          String photoUrl = await uploadToCloudinary(File(photo.path));
          photoUrls.add(photoUrl);
          print("Uploaded photo: $photoUrl");
        }
      }

      print("Storing user data in Firestore...");
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'id': uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'category': category,
        'father_name': fatherController.text.trim(),
        'mother_name': motherController.text.trim(),
        'date_of_birth': dobController.text.trim(),
        'district': districtController.text.trim(),
        'sub_district': subDistrictController.text.trim(),
        'description': descriptionController.text.trim(),
        'profile_pic': profilePicUrl,
        'video_links': videoLinksController.text.trim(),
        'photos': photoUrls,
        'isApproved': false,
        'isRejected': false,
        'is_admin_added': false,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false,
      });

      print("User data stored in Firestore.");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Registration successful! Please verify your email before logging in."),
        ),
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      print("Sign-Up Error: $e"); // Log the full error

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              'Sign Up',
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.white,
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Join the Revolution!',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal)),
                  const SizedBox(height: 20),
                  _buildProfilePicture(),
                  const SizedBox(height: 20),
                  _buildPhotoGallery(),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(nameController, 'Name', Icons.person),
                        buildTextField(emailController, 'Email', Icons.email,
                            isEmail: true),
                        buildTextField(
                            phoneController, 'Phone Number', Icons.phone,
                            isNumber: true),
                        buildPasswordField(passwordController, 'Password'),
                        buildPasswordField(
                            confirmPasswordController, 'Confirm Password',
                            isConfirm: true),
                        buildInputField("Father's Name", Icons.person_outline,
                            fatherController),
                        buildInputField("Mother's Name", Icons.person_outline,
                            motherController),
                        buildInputField("Date of Birth", Icons.calendar_today,
                            dobController),
                        buildInputField("District", Icons.location_city,
                            districtController),
                        buildInputField("Sub-District (Upazila)", Icons.map,
                            subDistrictController),
                        buildTextField(descriptionController,
                            'Description (optional)', Icons.description,
                            maxLines: 5),
                        buildTextField(videoLinksController,
                            'Video Links (optional)', Icons.video_call),
                        DropdownButtonFormField(
                          value: category,
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                                value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => category = value),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Category *',
                            prefixIcon:
                                const Icon(Icons.category, color: Colors.teal),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Category is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: signUp,
                                style: ElevatedButton.styleFrom(
                                  elevation: 8,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  backgroundColor: Colors.teal,

                                  // backgroundColor: Colors.transparent,
                                  // shadowColor: Colors.transparent,
                                ),
                                child: Ink(
                                  // decoration: BoxDecoration(
                                  //   // gradient: LinearGradient(
                                  //   //   colors: [Colors.teal, Colors.green],
                                  //   // ),
                                  //   borderRadius: BorderRadius.circular(12),
                                  // ),
                                  child: Container(
                                    alignment:
                                        Alignment.center, // means ful width
                                    //height: 50,
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                          letterSpacing: 1.2,
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      children: [
        const Text("Profile Picture",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: pickProfilePic,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.teal,
            backgroundImage:
                profilePic != null ? FileImage(File(profilePic!.path)) : null,
            child: profilePic == null
                ? const Icon(Icons.add_a_photo, color: Colors.white, size: 40)
                : null,
          ),
        ),
      ],
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isEmail = false, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        keyboardType: isEmail
            ? TextInputType.emailAddress
            : isNumber
                ? TextInputType.number
                : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            if (!label.toLowerCase().contains("optional")) {
              return '$label is required';
            }
          } else if (isNumber &&
              !RegExp(r'^(?:\+8801|01)[3-9]\d{8}$').hasMatch(value)) {
            return 'Enter a valid Bangladeshi phone number';
          } else if (isEmail &&
              !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
            return 'Please enter a valid email address';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      children: [
        const Text("Additional Photos",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: photos
                .map((photo) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(photo.path),
                            width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: pickPhotos,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add More Photos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ],
    );
  }

  Widget buildPasswordField(TextEditingController controller, String label,
      {bool isConfirm = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        obscureText:
            isConfirm ? !_isConfirmPasswordVisible : !_isPasswordVisible,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.lock, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                if (isConfirm) {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                } else {
                  _isPasswordVisible = !_isPasswordVisible;
                }
              });
            },
            child: Icon(
              isConfirm
                  ? (_isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off)
                  : (_isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
              color: Colors.teal,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          // Validate password strength with simpler regex
          else if (!RegExp(
                  r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&#]).{6,}$')
              .hasMatch(value)) {
            return 'Password must have 6+ chars, one uppercase, one lowercase, one number & one special char.';
          }
          // Validate confirm password
          else if (isConfirm && value != passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
    );
  }

  Widget buildInputField(
      String label, IconData icon, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
