import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

List<TargetFocus> getTutorialTargets({
  required GlobalKey keyMenuButton,
  required GlobalKey keyComplemento,
  required GlobalKey keyAportes,
  required GlobalKey keyPrestamos,
  required GlobalKey keyPreEvaluacion,
}) {
  return [
    TargetFocus(
      keyTarget: keyMenuButton,
      shape: ShapeLightFocus.Circle,
      radius: 8,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Text(
            'Este es el botón para abrir el menú principal.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    TargetFocus(
      keyTarget: keyComplemento,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Text(
            'Aquí puedes acceder al módulo de Complemento Económico.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    TargetFocus(
      keyTarget: keyAportes,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Text(
            'Consulta tus aportes individuales aquí.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    TargetFocus(
      keyTarget: keyPrestamos,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Text(
            'Mira tu historial de préstamos.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
    TargetFocus(
      keyTarget: keyPreEvaluacion,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          child: const Text(
            'Verifica si calificas para un préstamo.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  ];
}
