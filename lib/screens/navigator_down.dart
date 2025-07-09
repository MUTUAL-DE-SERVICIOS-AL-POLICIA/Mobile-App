import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:muserpol_pvt/utils/nav.dart';

class NavigationDown extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationDown({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Función para obtener ítem según el índice
    CurvedNavigationBarItem getItem(int index) {
      switch (index) {
        case 0:
          return CurvedNavigationBarItem(
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
            label: "Compleneto Economico",
          );
        case 1:
          return CurvedNavigationBarItem(
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
          );
        case 2:
          return CurvedNavigationBarItem(
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
            label: "Prestamos",
          );
        default:
          return CurvedNavigationBarItem(
            icon: const Icon(Icons.error),
            label: "Error",
          );
      }
    }

    return CurvedNavigationBar(
      items: [getItem(currentIndex)],
      index: 0,
      animationCurve: Curves.fastOutSlowIn,
      onTap: (i) => onTap(currentIndex),
      letIndexChange: (_) => false, // No deja cambiar ya que solo hay 1 ítem
    );
  }
}
