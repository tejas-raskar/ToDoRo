import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo/screens/notesPage.dart';
import 'package:todo/screens/pomodoroTimer.dart';
import 'package:todo/screens/profilePage.dart';
import 'package:todo/screens/todolist.dart';

class ToDoFeed extends StatefulWidget {
  const ToDoFeed({super.key});

  @override
  State<ToDoFeed> createState() => _ToDoFeedState();
}

class _ToDoFeedState extends State<ToDoFeed> {
  int index = 0;
  final screens = [
    const ToDoList(),
    const PomodoroPage(),
    const NotesPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: index,
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          setState(() => this.index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle_rounded),
            label: "Tasks",
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: "Timer",
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit_rounded),
            label: "Notes",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
