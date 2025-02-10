import 'package:flutter/material.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          elevation: 8,
          automaticallyImplyLeading: false,
          title: const Text(
            "About This App",
            style: TextStyle(
              letterSpacing: 1.2,
              color: Color(0xfff5f5f5),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.teal,
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "About This App",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'This project is dedicated to all the brave protesters who have stood up for justice, freedom, and the rights of the people. Their relentless struggle and unwavering courage have inspired countless others to join in the fight for a better future.\n\n'
              'In the face of adversity, they have shown resilience, endurance, and commitment, leaving a lasting impact on the community. Their voices have carried the hopes of many, and their sacrifices will never be forgotten.\n\n'
              'We pay tribute to these unsung heroes, whose actions have shaped history and paved the way for positive change. This project stands as a testament to their resilience and dedication.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "Authors",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                AuthorCard(
                  name: 'Md. Najmul Islam',
                  imageUrl: 'assets/images/najmul.jpg',
                  email: 'mdnajmulislam10992@gmail.com',
                ),
                AuthorCard(
                  name: 'Md. Miner Hossain Rimon',
                  imageUrl: 'assets/images/miner.jpg',
                  email: 'minerhossainrimon1033@gmail.com',
                ),
                AuthorCard(
                  name: 'Shah Shadek-E-Akbor Shamim',
                  imageUrl: 'assets/images/shamim.jpg',
                  email: 'shahshamim855@gmail.com',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AuthorCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String email;

  const AuthorCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    // overflow: TextOverflow.ellipsis,
                    // maxLines: 1,
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
