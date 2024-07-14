import 'package:flutter/material.dart';
import '../pages/chatDoctor.dart';
import '../pages/HomeEducation.dart';
import '../pages/side_effects_list.dart';

class DoctorBottomNavigation extends StatefulWidget {
  final ValueChanged<int> onTabTapped;
  final int currentIndex;

  DoctorBottomNavigation({required this.onTabTapped, required this.currentIndex});

  @override
  _DoctorBottomNavigation createState() => _DoctorBottomNavigation();
}

class _DoctorBottomNavigation extends State<DoctorBottomNavigation> {
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
              MaterialPageRoute(builder: (context) => SideEffectsListPage()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ChatPage()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeEducation()),
            );
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Side Effects',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Education',
        ),
      ],
    );
  }
}
