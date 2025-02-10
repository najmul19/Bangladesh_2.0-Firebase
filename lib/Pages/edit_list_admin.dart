import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EditDocumentPage extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> document;

  EditDocumentPage({required this.documentId, required this.document});

  @override
  _EditDocumentPageState createState() => _EditDocumentPageState();
}

class _EditDocumentPageState extends State<EditDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController descriptionController;
  late TextEditingController videoLinksController;
  late TextEditingController fatherController;
  late TextEditingController motherController;
  late TextEditingController dobController;
  late TextEditingController districtController;
  late TextEditingController subDistrictController;

  String? category;
  // List<String> categories = ['Memories', 'Injured'];
  List<String> categories = [];
  final ImagePicker _picker = ImagePicker();
  XFile? profilePic;
  List<XFile> photos = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.document['name']);
    emailController = TextEditingController(text: widget.document['email']);
    phoneController = TextEditingController(text: widget.document['phone']);
    fatherController =
        TextEditingController(text: widget.document['father_name']);
    motherController =
        TextEditingController(text: widget.document['mother_name']);
    dobController =
        TextEditingController(text: widget.document['date_of_birth']);
    districtController =
        TextEditingController(text: widget.document['district']);
    subDistrictController =
        TextEditingController(text: widget.document['sub_district']);
    descriptionController =
        TextEditingController(text: widget.document['description']);
    videoLinksController =
        TextEditingController(text: widget.document['video_links']);

    category = widget.document['category'];
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      List<String> fetchedCategories =
          snapshot.docs.map((doc) => doc['name'].toString()).toList();

      String? currentCategory = widget.document['category'];

      if (currentCategory != 'Martyrs') {
        fetchedCategories.removeWhere((category) => category == 'Martyrs');
      }

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<String> uploadToCloudinary(XFile image) async {
    try {
      File file = File(image.path);
      String cloudName = "ddup3m4rz"; // Replace with your Cloudinary Cloud Name
      String uploadPreset =
          "flutter_uploads"; // Replace with your Upload Preset

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
      );

      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      return jsonResponse['secure_url'];
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return "";
    }
  }

  void editDocument() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not authenticated");
      return;
    }

    setState(() => isLoading = true);

    try {
      // Upload Profile Picture to Cloudinary
      String? profilePicUrl;
      if (profilePic != null) {
        profilePicUrl = await uploadToCloudinary(profilePic!);
      }

      // Upload Multiple Photos to Cloudinary
      List<String> finalPhotoUrls = [];
      for (XFile photo in photos) {
        String url = await uploadToCloudinary(photo);
        finalPhotoUrls.add(url);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.documentId)
          .update({
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
        'profile_pic': profilePicUrl ?? widget.document['profile_pic'],
        'photos': finalPhotoUrls.isNotEmpty
            ? finalPhotoUrls
            : widget.document['photos'] ?? [],
        'video_links': videoLinksController.text.trim().isNotEmpty
            ? videoLinksController.text.trim()
            : widget.document['video_links'] ?? "",
      });

      print("Document successfully updated!");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully.')));

      Navigator.pop(context);
    } catch (error) {
      print("Firestore Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating document.')));
    }

    setState(() => isLoading = false);
  }

  void pickProfilePic() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profilePic = pickedFile;
      });
    }
  }

  void pickPhotos() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        photos = pickedFiles;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
              'Edit Documents',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
            centerTitle: true,
            elevation: 8,
          ),
        ),
      ),
    
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickProfilePic,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profilePic != null
                            ? FileImage(File(profilePic!.path))
                            : (widget.document['profile_pic'] != null
                                ? NetworkImage(widget.document['profile_pic'])
                                : null),
                        backgroundColor: Colors.grey[300],
                        child: profilePic == null &&
                                widget.document['profile_pic'] == null
                            ? const Icon(Icons.camera_alt, color: Colors.teal)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(nameController, 'Name', Icons.person),
                    buildTextField(phoneController, 'Phone Number', Icons.phone,
                        isNumber: true),
                    buildInputField(fatherController, "Father's Name",
                        Icons.person_outline),
                    buildInputField(motherController, "Mother's Name",
                        Icons.person_outline),
                    buildInputField(
                        dobController, "Date of Birth", Icons.calendar_today),
                    buildInputField(
                        districtController, "District", Icons.location_city),
                    buildInputField(subDistrictController,
                        "Sub-District (Upazila)", Icons.map),
                    buildInputField(descriptionController, "Description",
                        Icons.description),
                    _buildDropdownField(),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: pickPhotos,
                      icon: const Icon(Icons.add_a_photo, color: Colors.teal),
                      label: const Text('Select Photos',
                          style: TextStyle(color: Colors.teal)),
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 30),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : editDocument, // Call the function to save data
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Save Changes',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 30),
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, bool isEmail = false, int maxLines = 1}) {
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
            if (!label.contains("optional")) {
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

  Widget _buildDropdownField() {
    return DropdownButtonFormField(
      value: category,
      items: categories
          .map((cat) => DropdownMenuItem<String>(
              value: cat,
              child: Text(cat, style: const TextStyle(fontSize: 16))))
          .toList(),
      onChanged: (value) {
        setState(() {
          category = value as String?;
        });
      },
      decoration: InputDecoration(
        labelText: 'Category',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget buildInputField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text,
      bool isNumeric = false}) {
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
