import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:badges/badges.dart' as badges;
import 'package:muserpol_pvt/screens/inbox/screen_inbox.dart';

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
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: true).state;

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
        badgeNotification(context, notificationBloc),
      ],
    );
  }

  GestureDetector badgeNotification(
      BuildContext context, NotificationState notificationBloc) {
    final countNotification = notificationBloc.listNotifications.where((e) =>
        e.read == false && e.idAffiliate == notificationBloc.affiliateId);
    return GestureDetector(
      onTap: () => dialogInbox(context),
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: badges.Badge(
          badgeStyle: badges.BadgeStyle(
            badgeColor: notificationBloc.existNotifications
                ? countNotification.isNotEmpty
                    ? Colors.red
                    : Colors.transparent
                : Colors.transparent,
            elevation: 0,
          ),
          badgeContent: notificationBloc.existNotifications &&
                  countNotification.isNotEmpty
              ? Text(
                  '${countNotification.length}',
                  style: const TextStyle(color: Colors.white),
                )
              : Container(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: SvgPicture.asset('assets/icons/bell.svg',
                height: 25.sp,
                colorFilter:
                    const ColorFilter.mode(Color(0xff419388), BlendMode.srcIn)),
          ),
        ),
      ),
    );
  }

  dialogInbox(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => const ScreenInbox());
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
