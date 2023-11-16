import 'package:flutter/material.dart';

import '../config/utils/styles/app_colors.dart';
import '../presentation/Modules/History/HistroyPage.dart';
import '../presentation/Modules/Home/BMICalculator/BMICalculator.dart';

class NavigationController extends StatefulWidget {
  const NavigationController({super.key});

  @override
  State<NavigationController> createState() => _NavigationControllerState();
}

class _NavigationControllerState extends State<NavigationController> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const BMICalculator(),
    const HistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0.0,
        unselectedItemColor: AppColors.greyDark,
        selectedItemColor: AppColors.primaryColor,
        enableFeedback: true,
        backgroundColor: Colors.transparent,
        iconSize: 22,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_toggle_off_sharp),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int index) async {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
