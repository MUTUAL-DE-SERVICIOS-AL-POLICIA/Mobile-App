import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final liquidPages = [
  const LiquidPage(
      imageBackground: 'assets/images/muserpol_fachada.webp',
      imageFront: "assets/icons/6.png",
      titleText: "BIENVENIDO",
      subtitleText: "MUTUAL DE SERVICIOS AL POLICÍA",
      text: ""),
  const LiquidPage(
      imageBackground: 'assets/images/002.webp',
      imageFront: "assets/icons/7.png",
      titleText: "EVITE HACER FILAS",
      subtitleText: "COMPLEMENTO ECONÓMICO",
      text: "Realice la solicitud y seguimiento del pago del Beneficio del Complemento Económico"),
  const LiquidPage(
      imageBackground: 'assets/images/003.webp',
      imageFront: "assets/icons/003.png",
      titleText: "SEGUIMIENTO\nDE",
      subtitleText: "APORTES",
      text: "Realiza seguimiento de tus aportes"),
  const LiquidPage(
      imageBackground: 'assets/images/004.webp',
      imageFront: "assets/icons/9.png",
      titleText: "SEGUIMIENTO\nDE",
      subtitleText: "PRESTAMOS",
      text: "Realiza seguimiento de tus prestamos"),
];

class LiquidPage extends StatelessWidget {
  final String imageBackground;
  final String imageFront;
  final String titleText;
  final String subtitleText;
  final String text;
  const LiquidPage(
      {super.key,
      required this.imageBackground,
      required this.imageFront,
      required this.titleText,
      required this.subtitleText,
      required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(imageBackground),
          fit: BoxFit.fitHeight,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(titleText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w400)),
              Text(subtitleText, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 10.h,
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ));
  }
}
