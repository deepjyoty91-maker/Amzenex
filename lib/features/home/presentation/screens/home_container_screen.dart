import 'package:flutter/material.dart';
import 'package:medmylife/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:medmylife/features/doctors/presentation/screens/doctor_list_screen.dart';
import 'package:medmylife/features/medicines/presentation/screens/medicines_screen.dart';
import 'package:medmylife/features/appointments/presentation/screens/my_appointments_screen.dart';
import 'package:medmylife/features/profile/presentation/screens/profile_screen.dart';

class HomeContainerScreen extends StatefulWidget {
  const HomeContainerScreen({super.key});

  @override
  State<HomeContainerScreen> createState() => _HomeContainerScreenState();
}

class _HomeContainerScreenState extends State<HomeContainerScreen> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboardScreen(
        onNavigateToDoctors: () => _navigateToTab(1),
        onNavigateToMedicines: () => _navigateToTab(2),
        onNavigateToBookings: () => _navigateToTab(3),
      ),
      const DoctorListScreen(),
      const MedicinesScreen(),
      const MyAppointmentsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateToTab,
        indicatorColor: Colors.teal.shade100,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.teal),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_search_outlined),
            selectedIcon: Icon(Icons.person_search, color: Colors.teal),
            label: 'Doctors',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication, color: Colors.teal),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note, color: Colors.teal),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle, color: Colors.teal),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
