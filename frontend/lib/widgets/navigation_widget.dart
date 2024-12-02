import 'package:flutter/material.dart';
import '../screens/group_screen.dart';
import '../screens/invitations_screen.dart';

class NavigationWidget extends StatefulWidget {
  final String token;
  final int initialIndex;

  const NavigationWidget(
      {super.key, required this.token, this.initialIndex = 0});

  @override
  _NavigationWidgetState createState() => _NavigationWidgetState();
}

class _NavigationWidgetState extends State<NavigationWidget> {
  late int _selectedIndex;
  int newInvitationsCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateInvitationCount(int count) {
    setState(() {
      newInvitationsCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _screens = [
      GroupScreen(
          token: widget.token, updateInvitationCount: updateInvitationCount),
      InvitationsScreen(
          token: widget.token, updateInvitationCount: updateInvitationCount),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (newInvitationsCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$newInvitationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
