import 'package:flutter/material.dart';
import 'package:muserpol_pvt/screens/pages/menu.dart'; 
// import 'package:muserpol_pvt/model/files_model.dart';


class ScreenHomeHola extends StatelessWidget {
  const ScreenHomeHola({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:const MenuDrawer(),
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      
    );
  }
}
