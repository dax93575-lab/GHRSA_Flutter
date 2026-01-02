import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'store_screen.dart';
import 'encyclopedia_screen.dart';
import 'account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex =
      3; // Default to Home (index 3 because RTL: Account(0), Ency(1), Store(2), Home(3))?
  // Wait, standard RTL bottom nav usually flips visually but logical index stays 0..N?
  // Let's stick to logical order: 0:Home, 1:Store, 2:Encyclopedia, 3:Account.
  // And let Flutter handle RTL visual flipping.

  // Actally, looking at design: Right to Left: Home, Ency, Store, Account.
  // Home is far right. Account is far left.
  // In RTL:
  // Item 0 (Home) -> displayed on Right
  // Item 1 (Ency) -> ...
  // Item 2 (Store) -> ...
  // Item 3 (Account) -> displayed on Left

  // So _selectedIndex = 0 is correct for Home.

  final List<Widget> _screens = [
    const HomeScreen(),
    const EncyclopediaScreen(),
    const StoreScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[800],
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'الموسوعة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            activeIcon: Icon(Icons.store_mall_directory),
            label: 'المتجر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الحساب',
          ),
        ],
      ),
    );
  }
}
