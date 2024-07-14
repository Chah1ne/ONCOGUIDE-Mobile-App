import 'package:flutter/material.dart';
import 'package:patient_app/pages/chatPatient.dart';
import '../pages/journey.dart';
import '../pages/calendar_page.dart';
import '../pages/education.dart';
import '../pages/home.dart';

class BottomNavigation extends StatefulWidget {
  final ValueChanged<int> onTabTapped;
  final int currentIndex;

  BottomNavigation({required this.onTabTapped, required this.currentIndex});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        widget.onTabTapped(index);
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChatPatientPage()),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EducationPage()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => JourneyPage()),
            );
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Education',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Journey',
        ),
      ],
    );
  }
}
