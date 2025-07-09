import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

TargetFocus targetMenuButton(GlobalKey keyTarget) {
  return TargetFocus(
    identify: "keyMenuButton",
    keyTarget: keyTarget,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          "Este es el menú principal donde accedes a todas las secciones.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ],
  );
}

TargetFocus targetComplemento(GlobalKey keyTarget) {
  return TargetFocus(
    identify: "keyComplemento",
    keyTarget: keyTarget,
    shape: ShapeLightFocus.RRect,
    radius: 16,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          "Aquí puedes gestionar tu Complemento Económico.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ],
  );
}

TargetFocus targetAportes(GlobalKey keyTarget) {
  return TargetFocus(
    identify: "keyAportes",
    keyTarget: keyTarget,
    shape: ShapeLightFocus.RRect,
    radius: 16,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          "Consulta tus aportes realizados.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ],
  );
}

TargetFocus targetPrestamos(GlobalKey keyTarget) {
  return TargetFocus(
    identify: "keyPrestamos",
    keyTarget: keyTarget,
    shape: ShapeLightFocus.RRect,
    radius: 16,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          "Revisa el estado de tus préstamos.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ],
  );
}

TargetFocus targetPreEvaluacion(GlobalKey keyTarget) {
  return TargetFocus(
    identify: "keyPreEvaluacion",
    keyTarget: keyTarget,
    shape: ShapeLightFocus.RRect,
    radius: 16,
    contents: [
      TargetContent(
        align: ContentAlign.bottom,
        child: const Text(
          "Evalúa si calificas para un préstamo.",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ],
  );
}
