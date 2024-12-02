import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/welcome_screen.dart';

class HamburgerMenu extends StatelessWidget {
  final String token;

  const HamburgerMenu({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        switch (value) {
          case 'Profile':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(token: token),
              ),
            );
            break;
          case 'Settings':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsScreen(token: token),
              ),
            );
            break;
          case 'Log Off':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ),
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return {'Profile', 'Settings', 'Log Off'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }
}
