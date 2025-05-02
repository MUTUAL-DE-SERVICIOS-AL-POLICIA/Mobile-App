import 'package:flutter/material.dart';

class ScreenHomeHola extends StatelessWidget {
  const ScreenHomeHola({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: const Center(
        child: Text(
          'Hola',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
