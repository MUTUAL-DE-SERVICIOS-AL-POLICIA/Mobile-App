import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/header_muserpol.dart';
import 'package:muserpol_pvt/screens/navigator_down.dart';
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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget get currentPage {
    switch (_currentIndex) {
      case 1:
        return const ScreenContributionsNew();
      case 2:
        return const ScreenLoansNew();
      case 3:
        return const PlaceholderScreen(title: 'Complemento');
      default:
        return const PlaceholderScreen(title: 'Sin módulo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarDualTitle(
        showBackArrow: _currentIndex != 0,
        onBackPressed: () {
          Navigator.pop(context); // Volver a la pantalla anterior
        },
      ),
      drawer: const MenuDrawer(),
      body: currentPage,
      bottomNavigationBar: NavigationDown(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
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
