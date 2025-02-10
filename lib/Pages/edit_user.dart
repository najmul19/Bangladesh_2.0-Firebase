import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class EditUserDocumentPage extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> document;

  EditUserDocumentPage({required this.documentId, required this.document});

  @override
  _EditUserDocumentPageState createState() => _EditUserDocumentPageState();
}

class _EditUserDocumentPageState extends State<EditUserDocumentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  // late TextEditingController personalDetailsController;
  late TextEditingController descriptionController;
  late TextEditingController videoLinksController;
// new
  late TextEditingController fatherController = TextEditingController();
  late TextEditingController motherController = TextEditingController();
  late TextEditingController dobController = TextEditingController();
  late TextEditingController districtController = TextEditingController();
  late TextEditingController subDistrictController = TextEditingController();

  String? category;
  // late List<String> categories;
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
    motherController =
        TextEditingController(text: widget.document['mother_name']);
    dobController =
        TextEditingController(text: widget.document['date_of_birth']);
    districtController =
        TextEditingController(text: widget.document['district']);
    subDistrictController =
        TextEditingController(text: widget.document['sub_district']);
    motherController =
        TextEditingController(text: widget.document['mother_name']);
    motherController =
        TextEditingController(text: widget.document['mother_name']);
    fatherController =
        TextEditingController(text: widget.document['father_name']);
    descriptionController =
        TextEditingController(text: widget.document['description']);
    videoLinksController =
        TextEditingController(text: widget.document['video_links']);
    fetchCategories();
    category = widget.document['category'];

    // categories = ['Memories', 'Injured'];

    if (!categories.contains(category)) {
      category = categories.isNotEmpty ? categories[0] : null;
    }
  }

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

  Future<String?> uploadToCloudinary(File file) async {
    try {
      const cloudinaryUrl = "https://api.cloudinary.com/v1_1/ddup3m4rz/upload";
      const uploadPreset = "flutter_uploads";

      var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (jsonData["secure_url"] == null) {
        print("Cloudinary upload failed: ${jsonData}");
        return null;
      }

      return jsonData["secure_url"];
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
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
      photos = pickedFiles ?? [];
    });
  }

  void editDocument() async {
    if (!_formKey.currentState!.validate()) return;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not authenticated");
      return;
    }

    setState(() => isLoading = true);

    String profilePicUrl = widget.document['profile_pic'] ?? "";
    if (profilePic != null) {
      String? uploadedProfilePic =
          await uploadToCloudinary(File(profilePic!.path));
      if (uploadedProfilePic != null) profilePicUrl = uploadedProfilePic;
    }

    List<String> photoUrls = [];
    if (photos.isNotEmpty) {
      for (var photo in photos) {
        String? uploadedPhoto = await uploadToCloudinary(File(photo.path));
        if (uploadedPhoto != null) photoUrls.add(uploadedPhoto);
      }
    }

    // String existingPhotos = widget.document['photos'] ?? "";
    // String finalPhotoUrls = photoUrls.isNotEmpty ? photoUrls.join(',') : existingPhotos;
    List<dynamic> existingPhotosList = widget.document['photos'] ?? [];
    List<String> existingPhotos = List<String>.from(existingPhotosList);

    List<String> finalPhotoUrls =
        photoUrls.isNotEmpty ? photoUrls : existingPhotos;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.documentId)
        .update({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'category': category,
      'father_name': fatherController.text.trim(),
      'mother_name': fatherController.text.trim(),
      'date_of_birth': dobController.text.trim(),
      'district': districtController.text.trim(),
      'sub_district': subDistrictController.text.trim(),
      'description': descriptionController.text.trim(),
      'profile_pic': profilePicUrl,
      'photos': finalPhotoUrls,
      'video_links': videoLinksController.text.trim().isNotEmpty
          ? videoLinksController.text.trim()
          : widget.document['video_links'] ?? "",
    }).then((_) {
      print("Document successfully updated!");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document updated successfully.')));
      Navigator.pop(context);
    }).catchError((error) {
      print("Firestore Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating document.')));
    });

    setState(() => isLoading = false);
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
              ' Edit Documents',
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
                    _buildTextFieldValid(
                        nameController, 'Name', 'Enter name', Icons.person),
                    const SizedBox(height: 20),
                    _buildTextFieldValid(phoneController, 'Phone Number',
                        'Enter phone number', Icons.phone,
                        isNumeric: true, isPhone: true),
                    buildInputField("Father's Name", Icons.person_outline,
                        fatherController),
                    buildInputField("Mother's Name", Icons.person_outline,
                        motherController),
                    buildInputField(
                        "Date of Birth", Icons.calendar_today, dobController),
                    buildInputField(
                        "District", Icons.location_city, districtController),
                    buildInputField("Sub-District (Upazila)", Icons.map,
                        subDistrictController),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: descriptionController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: "Description",
                          prefixIcon:
                              const Icon(Icons.description, color: Colors.teal),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
                    _buildDropdownField(),
                    const SizedBox(height: 20),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: pickPhotos,
                      icon: const Icon(Icons.add_a_photo, color: Colors.teal),
                      label: const Text('Select Photos',
                          style: TextStyle(color: Colors.teal)),
                      style: ElevatedButton.styleFrom(
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 30),
                          backgroundColor: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : editDocument,
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

  Widget _buildTextFormField(TextEditingController controller, String label,
      {bool isEmail = false, bool isPhone = false, bool isRequired = true}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          isRequired && value!.isEmpty ? '$label is required' : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField(
      value: category,
      items: categories
          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
          .toList(),
      onChanged: (value) => setState(() => category = value),
      decoration: const InputDecoration(labelText: 'Category'),
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

  Widget _buildTextFieldValid(TextEditingController controller, String label,
      String hint, IconData icon,
      {bool isNumeric = false, bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          labelText: label,
          // hintText: hint,
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          if (isPhone &&
              !RegExp(r'^(?:\+8801|01)[3-9]\d{8}$').hasMatch(value)) {
            return 'Enter a valid Bangladeshi phone number';
          }
          return null;
        },
      ),
    );
  }

}
