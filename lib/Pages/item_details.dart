import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;

  ItemDetailsPage({required this.item});

  @override
  Widget build(BuildContext context) {
    List<String> photoPaths =
        item['photos'] is List ? List<String>.from(item['photos']) : [];

    return Scaffold(
      backgroundColor: Colors.grey[100],

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
            title: Text(
              item['name'] ?? 'Item Details',
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: InkWell(
                onTap: () {
                  if (item['profile_pic'] != null &&
                      item['profile_pic'].isNotEmpty) {
                    _openFullScreenPhoto([item['profile_pic']], 0, context);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      boxShadow: [
                        const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            spreadRadius: 2)
                      ],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal, width: 2),
                    ),
                    child: item['profile_pic'] != null &&
                            item['profile_pic'].isNotEmpty
                        ? Image.network(
                            item['profile_pic'],
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Icon(Icons.person,
                                        size: 100, color: Colors.grey)),
                          )
                        : const Center(
                            child: Icon(Icons.person,
                                size: 100, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Information Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Name", item['name']),
                    _buildInfoRow("Father Name", item['father_name']),
                    _buildInfoRow("Mother Name", item['mother_name']),
                    _buildInfoRow("Date of Birth", item['date_of_birth']),
                    _buildInfoRow("District", item['district']),
                    _buildInfoRow("Sub District", item['sub_district']),
                    _buildInfoRow("Section", item['category']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    // Phone Icon
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      radius: 28,
                      child: const Icon(Icons.phone,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),

                    // Phone Number Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Phone Number",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['phone']?.isNotEmpty == true
                                ? item['phone']
                                : "No number available",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons (Call & SMS)
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.call,
                          color: Colors.greenAccent,
                          onTap: () => _makePhoneCall(item['phone'], context),
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          icon: Icons.message,
                          color: Colors.blueAccent,
                          onTap: () => _sendSms(item['phone'], context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildExpandableSection("Description", item['description']),
            const SizedBox(height: 16),

            _buildPhotoSection(photoPaths, context),
            const SizedBox(height: 16),

            _buildVideoSection(item['videos']),
            const SizedBox(height: 16),
          ],
        ),
      ),

      // Floating

      floatingActionButton: item['phone']?.isNotEmpty == true
          ? FloatingActionButton.extended(
              onPressed: () => _makePhoneCall(item['phone'], context),
              icon: const Icon(Icons.call),
              label: const Text("Call Now"),
              backgroundColor: Colors.teal,
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text("$label:",
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value?.isNotEmpty == true ? value! : "N/A",
                style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        radius: 24,
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildExpandableSection(String title, String? content) {
    return ExpansionTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
              content?.isNotEmpty == true ? content! : "No details provided."),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(List<String> photoPaths, BuildContext context) {
    if (photoPaths.isEmpty)
      return const Center(child: Text("No photos available."));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Photos",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        CarouselSlider(
          options: CarouselOptions(
              height: 200, enlargeCenterPage: true, autoPlay: true),
          items: photoPaths.map((path) {
            return InkWell(
              onTap: () => _openFullScreenPhoto(
                  photoPaths, photoPaths.indexOf(path), context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  path,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image,
                          size: 50, color: Colors.red)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVideoSection(List<String>? videos) {
    if (videos == null || videos.isEmpty) {
      return const Center(child: Text("No videos available."));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Videos",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                color: Colors.grey[300],
                child: Center(child: Text("Video ${index + 1}")),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _makePhoneCall(String? phoneNumber, BuildContext context) async {
    if (phoneNumber?.isEmpty == true) {
      _showSnackBar(context, "Number not available");
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phoneNumber));
  }

  Future<void> _sendSms(String? phoneNumber, BuildContext context) async {
    if (phoneNumber?.isEmpty == true) {
      _showSnackBar(context, "Number not available");
      return;
    }
    await launchUrl(Uri(scheme: 'sms', path: phoneNumber));
  }

  void _openFullScreenPhoto(
      List<String> photoPaths, int index, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FullScreenPhotoView(
                photoPaths: photoPaths, initialIndex: index)));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }
}

class FullScreenPhotoView extends StatelessWidget {
  final List<String> photoPaths;
  final int initialIndex;

  FullScreenPhotoView({required this.photoPaths, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'View Full Screen',
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
      body: PhotoViewGallery.builder(
        itemCount: photoPaths.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider:
                CachedNetworkImageProvider(photoPaths[index]), // Cached image
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/avatar.png',
              fit: BoxFit.cover,
            ),
          );
        },
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
        backgroundDecoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
