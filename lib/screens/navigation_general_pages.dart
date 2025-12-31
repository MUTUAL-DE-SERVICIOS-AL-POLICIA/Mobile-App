import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/header_muserpol.dart';
import 'package:muserpol_pvt/screens/navigator_down.dart';
import 'package:muserpol_pvt/screens/pages/complement_pages/complement_page_new.dart';
import 'package:muserpol_pvt/screens/pages/complement_pages/history_complement.dart';
import 'package:muserpol_pvt/screens/pages/contributions_pages/contributions_page_new.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loans_page_new.dart';
import 'package:muserpol_pvt/screens/pages/menu.dart';

class NavigatorBarGeneral extends StatefulWidget {
  final int initialIndex;

  const NavigatorBarGeneral({super.key, required this.initialIndex});

  @override
  State<NavigatorBarGeneral> createState() => _NavigatorBarGeneralState();
}

class _NavigatorBarGeneralState extends State<NavigatorBarGeneral> {
  late int _currentIndex;
  int _subIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget get currentPage {
    if (_currentIndex == 0) {
      if (_subIndex == 0) return const ScreenComplementNew();
      if (_subIndex == 1) return const ScreenHistoryComplement();
    } else if (_currentIndex == 1) {
      return const ScreenContributionsNew();
    } else if (_currentIndex == 2) {
      // Abrir modal automáticamente para pruebas
      return const ScreenLoansNew(openModalOnInit: true);
    }
    return const PlaceholderScreen(title: 'Sin módulo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDualTitle(
        showBackArrow: _currentIndex != 4,
        onBackPressed: () => Navigator.pop(context),
      ),
      drawer: const MenuDrawer(),
      body: currentPage,
      bottomNavigationBar: NavigationDown(
        currentIndex: _currentIndex,
        onTap: (mainIndex, subIndex) {
          setState(() {
            _currentIndex = mainIndex;
            _subIndex = subIndex ?? 0;
          });
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title (en construcción)',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
