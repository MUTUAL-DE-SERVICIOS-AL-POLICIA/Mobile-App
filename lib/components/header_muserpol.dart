import 'package:flutter/material.dart';

class AppBarDualTitle extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final Key? keyMenuButton;
  final bool showBackArrow;
  final VoidCallback? onBackPressed;
  final VoidCallback? onNotificationPressed;

  const AppBarDualTitle({
    super.key,
    this.onMenuPressed,
    this.keyMenuButton,
    this.showBackArrow = false,
    this.onBackPressed,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;

    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/icons/favicon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
      leading: Builder(
        builder: (context) {
          if (showBackArrow) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            );
          } else {
            return IconButton(
              key: keyMenuButton,
              icon: const Icon(Icons.menu),
              onPressed:
                  onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
            );
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: onNotificationPressed ??
              () {
                // Acción por defecto si no se pasa un callback
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Notificaciones aún no implementadas")),
                );
              },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
