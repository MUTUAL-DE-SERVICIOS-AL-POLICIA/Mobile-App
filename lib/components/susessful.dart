import 'dart:async';
import 'package:flutter/material.dart';

showSuccessful(
    BuildContext context, String textDialog, Function() finish) async {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return GifLoadingSuccessful(text: textDialog);
      });
  Timer(const Duration(seconds: 3), () {
    Navigator.of(context).pop();
    finish();
  });
}

class GifLoadingSuccessful extends StatelessWidget {
  final String text;
  const GifLoadingSuccessful({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloquea el botón de retroceso
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage('assets/images/check1.gif'),
              fit: BoxFit.cover,
            ),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
