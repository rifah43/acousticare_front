import 'package:acousticare_front/home_page.dart';
import 'package:acousticare_front/views/dashboard/health_recommendation.dart';
import 'package:acousticare_front/views/dashboard/trend_visualization.dart';
import 'package:acousticare_front/views/profile/profile_setup.dart';
import 'package:acousticare_front/views/profile/user_profile.dart';
import 'package:acousticare_front/views/styles.dart';
import 'package:flutter/material.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Widget page = const HomePage();
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const HomePage();
        // trend page hobe
        break;
      case 2:
        page = const ProfileSetup(isAddingNewProfile: true);
        break;
      case 3:
        page = const HealthRecommendations();
        break;
      case 4:
        page = const UserProfile();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 1,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.iconPrimary,
        unselectedItemColor: AppColors.iconSecondary,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Trends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Add Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Recommendations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        elevation: 0,
      ),
    );
  }
}

