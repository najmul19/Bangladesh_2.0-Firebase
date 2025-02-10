
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'about.dart';
import 'category.dart';
import 'home.dart';

import 'profile.dart';

class Bottomavigation extends StatefulWidget {
  final String userName;
  final String profilePic;
  final bool isGuest;
  final Map<String, dynamic> user;

  const Bottomavigation({
    Key? key,
    required this.userName,
    required this.profilePic,
    required this.isGuest,
    required this.user,
  }) : super(key: key);

  @override
  State<Bottomavigation> createState() => _BottomavigationState();
}


class _BottomavigationState extends State<Bottomavigation> {
  int _currentTabIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Extract the userId from the widget.user map

    final String userId = widget.user['id']?.toString() ?? ''; 
    final String profilePic = widget.user['profile_pic'] ?? ''; 


    // Initialize the pages 
    _pages = [
      HomePage(
        userName: widget.userName,
        profilePic: widget.profilePic,
        isGuest: widget.isGuest,
        user: widget.user,
      ),
      const CategoryPage(),
      ProfilePage(
          userId: userId, profilePic: profilePic), 
      const About(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: IndexedStack(
        index: _currentTabIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 65,
        backgroundColor: const Color(0xfff5f5f5),
        color: Colors.teal,
        animationDuration: const Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          Icon(Icons.home_outlined, color: Colors.white, size: 30),
          Icon(Icons.category_outlined, color: Colors.white, size: 30),
          Icon(Icons.person_2_outlined, color: Colors.white, size: 30),
          Icon(Icons.help_outline, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}

