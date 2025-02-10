

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';

import 'about.dart';
import 'category.dart';
import 'home.dart';
import 'landing.dart';

class BottomavigationGuest extends StatefulWidget {
  final String userName;
  final String profilePic;
  final bool isGuest;
  final Map<String, dynamic> user;

  const BottomavigationGuest({
    Key? key,
    required this.userName,
    required this.profilePic,
    required this.isGuest,
    required this.user,
  }) : super(key: key);

  @override
  State<BottomavigationGuest> createState() => _BottomavigationGuestState();
}

class _BottomavigationGuestState extends State<BottomavigationGuest> {
  int _currentTabIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        userName: widget.userName,
        profilePic: widget.profilePic,
        isGuest: widget.isGuest,
        user: widget.user,
      ),
      const CategoryPage(),
      const About(),
    ];
  }

  Future<bool> _onWillPop() async {
    // Navigate Landing Page  not close the app
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()),
    );
    return false; // Prevents back button 
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      
      onWillPop: _onWillPop,
      child: Scaffold(
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
            Icon(Icons.help_outline, color: Colors.white, size: 30),
          ],
        ),
      ),
    );
  }
}
