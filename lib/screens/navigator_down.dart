import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muserpol_pvt/utils/nav.dart';

class NavigationDown extends StatefulWidget {
  final int currentIndex;
  final Function(int mainIndex, int? subIndex) onTap;

  const NavigationDown({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NavigationDown> createState() => _NavigationDownState();
}

class _NavigationDownState extends State<NavigationDown> {
  int _selectedSubIndex = 0;

  List<CurvedNavigationBarItem> getItems() {
    switch (widget.currentIndex) {
      case 0:
        return [
          CurvedNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/newProcedure.svg',
              height: 25.sp,
              colorFilter: ColorFilter.mode(
                AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: "Nuevo Trámite",
          ),
          CurvedNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/historyProcedure.svg',
              height: 25.sp,
              colorFilter: ColorFilter.mode(
                AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: "Historial",
          ),
        ];
      case 1:
        return [
          CurvedNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/requisites.svg',
              height: 25.sp,
              colorFilter: ColorFilter.mode(
                AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: "Aportes",
          )
        ];
      case 2:
        return [
          CurvedNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/historyProcedure.svg',
              height: 25.sp,
              colorFilter: ColorFilter.mode(
                AdaptiveTheme.of(context).mode.isDark
                    ? Colors.white
                    : Colors.black,
                BlendMode.srcIn,
              ),
            ),
            label: "Préstamos",
          )
        ];
      default:
        return [
          CurvedNavigationBarItem(
            icon: Icon(Icons.error),
            label: "Error",
          )
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      items: getItems(),
      index: _selectedSubIndex,
      animationCurve: Curves.fastOutSlowIn,
      onTap: (index) {
        setState(() {
          _selectedSubIndex = index;
        });

        // Mandamos el índice principal y el subíndice (solo para el caso 0)
        widget.onTap(
            widget.currentIndex, widget.currentIndex == 0 ? index : null);
      },
      letIndexChange: (_) => true,
    );
  }
}
