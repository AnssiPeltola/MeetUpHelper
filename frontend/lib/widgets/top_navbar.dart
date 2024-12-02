import 'package:flutter/material.dart';
import '../widgets/hamburger_menu.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String token;
  final String title;
  final bool automaticallyImplyLeading;

  const TopNavBar({
    super.key,
    required this.token,
    required this.title,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        HamburgerMenu(token: token),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
