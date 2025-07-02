import 'package:flutter/material.dart';

class AppBarDualTitle extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;

  const AppBarDualTitle({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return AppBar(
      centerTitle: true,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "MUSERPOL",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          Text(
            "MUTUAL DE SERVICIOS AL POLICÍA",
            style: TextStyle(
              fontSize: 10,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
