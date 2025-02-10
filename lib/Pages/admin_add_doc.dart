import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class AdminAddItemPage extends StatefulWidget {
  final bool isAdmin;
  const AdminAddItemPage({Key? key, required this.isAdmin}) : super(key: key);

  @override
  _AdminAddItemPageState createState() => _AdminAddItemPageState();
}

class _AdminAddItemPageState extends State<AdminAddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
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
  // late List<String> categories;
  List<String> categories = [];

  final ImagePicker _picker = ImagePicker();
  XFile? profilePic;
  List<XFile> photos = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

 
  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('categories').get();

      List<String> fetchedCategories = snapshot.docs
          .map((doc) => doc['name'].toString()) 
          .toList();

      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<String> uploadToCloudinary(File imageFile) async {
    try {
      print("🌐 Uploading to Cloudinary...");
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
      var responseData = await response.stream.bytesToString();

      print(
          "Cloudinary Response: $responseData"); // <-- PRINT RESPONSE FOR DEBUGGING

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
    if (pickedFiles.isNotEmpty) {
      setState(() {
        photos = pickedFiles;
      });
    }
  }

  Future<void> addItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (profilePic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture is required')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      print("Uploading Profile Picture...");
      String? profilePicUrl = await uploadToCloudinary(File(profilePic!.path));
      if (profilePicUrl == null)
        throw Exception("Profile picture upload failed");

      print("Uploading Additional Photos...");
      List<String> photoUrls = [];
      for (var photo in photos) {
        String? url = await uploadToCloudinary(File(photo.path));
        if (url != null) photoUrls.add(url);
      }

      String userId = const Uuid().v4(); //Globally Unique
      // String docId = FirebaseFirestore.instance.collection('users').doc().id;

      print("Saving Data to Firestore...");
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'father_name': fatherController.text.trim(),
        'mother_name': fatherController.text.trim(),
        'date_of_birth': dobController.text.trim(),
        'district': districtController.text.trim(),
        'sub_district': subDistrictController.text.trim(),
        'category': category,
        'description': descriptionController.text.trim(),
        'profile_pic': profilePicUrl,
        'photos': photoUrls,
        'video_links': videoLinksController.text.trim(),
        'isApproved': true,
        'is_admin_added': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully.')));
      Navigator.pop(context);
    } catch (e) {
      print("Error adding item: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding item: $e')));
    } finally {
      setState(() {
        isLoading = false;
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
              'Add Documnets',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 20),
              _buildPhotoGallery(),
              const SizedBox(height: 20),
              _buildTextField(
                  nameController, 'Name', 'Enter item name', Icons.person),
              _buildTextField(phoneController, 'Phone Number',
                  'Enter phone number', Icons.phone,
                  isNumeric: true),
              buildInputField(
                  "Father's Name", Icons.person_outline, fatherController),
              buildInputField(
                  "Mother's Name", Icons.person_outline, motherController),
              buildInputField(
                  "Date of Birth", Icons.calendar_today, dobController),
              buildInputField(
                  "District", Icons.location_city, districtController),
              buildInputField(
                  "Sub-District (Upazila)", Icons.map, subDistrictController),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: personalDetailsController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    labelText: "Description",
                    hintText: "Enter description",
                    prefixIcon:
                        const Icon(Icons.description, color: Colors.teal),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
              _buildDropdownField(),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : addItem,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Document',
                          style: TextStyle(
                              letterSpacing: 1.2,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
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

  Widget _buildProfilePicture() {
    return Column(
      children: [
        const Text("Profile Picture",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        InkWell(
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

  Widget _buildTextField(TextEditingController controller, String label,
      String hint, IconData icon,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.teal, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value!.trim().isEmpty) {
            return '$label is required';
          }
          if (isNumeric) {
            String pattern = r'^(?:\+8801|01)[3-9][0-9]{8}$';
            RegExp regExp = RegExp(pattern);
            if (!regExp.hasMatch(value)) {
              return 'Please enter a valid Bangladeshi phone number';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField(
        value: category,
        items: categories
            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
            .toList(),
        onChanged: (value) => setState(() => category = value as String?),
        decoration: InputDecoration(
            labelText: 'Category',
            prefixIcon: const Icon(Icons.category, color: Colors.teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.teal, width: 2),
              borderRadius: BorderRadius.circular(12),
            )),
        validator: (value) => value == null ? 'Category is required' : null,
      ),
    );
  }

  ///new
  // Input Field
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
