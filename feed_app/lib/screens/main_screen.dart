import 'package:feed_app/screens/infinity_screen.dart';
import 'package:feed_app/screens/refresh_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // 선택 화면
  Widget _selectedScreen = const InfinityScreen();

  // 선택 index
  int _selectedIndex = 0;

  void _onTab(int index) {
    
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0: _selectedScreen = const InfinityScreen(); break;
        case 1: _selectedScreen = const RefreshScreen(); break;
        default: _selectedScreen = const InfinityScreen(); break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.circle),
            label: 'infinity'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.refresh),
            label: 'refresh'
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onTab,
      ),
    );
  }
}