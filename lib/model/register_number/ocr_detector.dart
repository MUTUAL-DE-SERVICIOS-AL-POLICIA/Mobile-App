// text_detector.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'files_state_veritify.dart';
import 'file_document.dart';

class TextDetector {
  static Future<TextDetectionResult> detectText({
    required InputImage inputImage,
    required File fileImage,
    required FileDocument item,
    required FilesStateVeritify filesState,
    required String userInput,
  }) async {
    try {
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      await textRecognizer.close();

      // Validar que sea un documento
      final documentValidation = _validateDocument(recognizedText.text);

      if (!documentValidation.isValid) {
        return TextDetectionResult(
          success: false,
          match: false,
          detectedText: recognizedText.text,
          error: documentValidation.errorMessage,
          isDocumentValid: false,
          validationScore: documentValidation.score,
          matchedBlocks: [],
        );
      }

      debugPrint("===== TEXTO DETECTADO =====");
      debugPrint(recognizedText.text);
      debugPrint("===========================");

      final matches = _findTextMatches(recognizedText, userInput);
      // Actualizar el estado
      filesState.updateFile(item.id, fileImage);
      filesState.updateMatchedBlocks(item.id, matches);

      final hasMatch = matches.isNotEmpty;
      filesState.updateStateFiles(item.id, hasMatch);

      // Verificar coincidencia (case insensitive)
      final cleanedDetectedText = recognizedText.text.toLowerCase().trim();
      final cleanedUserInput = userInput.toLowerCase().trim();

      final match = cleanedDetectedText.contains(cleanedUserInput);

      filesState.updateStateFiles(item.id, match);

      return TextDetectionResult(
        success: true,
        match: match,
        detectedText: recognizedText.text,
        error: null,
        isDocumentValid: true,
        validationScore: documentValidation.score,
        matchedBlocks: matches,
      );
    } catch (e) {
      debugPrint("Error en detección de texto: $e");

      return TextDetectionResult(
        success: false,
        match: false,
        detectedText: '',
        error: e.toString(),
        isDocumentValid: false,
        validationScore: 0,
        matchedBlocks: [],
      );
    }
  }

  static List<TextBlock> _findTextMatches(
    RecognizedText recognizedText,
    String userInput,
  ) {
    final searchText = userInput.toLowerCase().trim();
    final matches = <TextBlock>[];

    for (final block in recognizedText.blocks) {
      final blockText = block.text.toLowerCase();
      if (blockText.contains(searchText)) {
        matches.add(block);
      } else {
        // Buscar también en las líneas individuales
        for (final line in block.lines) {
          if (line.text.toLowerCase().contains(searchText)) {
            matches.add(block);
            break;
          }
        }
      }
    }

    return matches;
  }

  static DocumentValidationResult _validateDocument(String detectedText) {
    final text = detectedText.toLowerCase();
    int score = 0;
    List<String> errors = [];

    // Patrones comunes en cédulas/carnets
    final patterns = [
      // Para cédulas ecuatorianas (ajusta según tu país)
      RegExp(r'cedula|cedula|identificacion|identidad', caseSensitive: false),
      RegExp(r'bolivia|república|estado', caseSensitive: false),
      RegExp(r'[0-9]{10}'), // Número de cédula (10 dígitos)
      RegExp(r'[a-z]{1,2}[0-9]{4,10}'), // Combinación letras-números
      RegExp(r'nombres?|apellidos?|fecha|nacimiento', caseSensitive: false),
      RegExp(r'provincia|canton|ciudad', caseSensitive: false),
    ];

    // Palabras clave que NO deberían aparecer en un documento
    final invalidPatterns = [
      RegExp(r'factura|recibo|boleta|comprobante', caseSensitive: false),
      RegExp(r'pag[ao]|precio|total|importe', caseSensitive: false),
    ];

    // Verificar patrones inválidos primero
    for (final pattern in invalidPatterns) {
      if (pattern.hasMatch(text)) {
        errors.add('El contenido parece ser un documento comercial');
        score -= 30;
      }
    }

    // Verificar patrones válidos
    for (final pattern in patterns) {
      if (pattern.hasMatch(text)) {
        score += 15;
      }
    }

    // Validar longitud mínima (documentos suelen tener bastante texto)
    if (text.length < 50) {
      errors.add('El texto detectado es muy corto para ser un documento');
      score -= 20;
    }

    // Validar presencia de números (documentos tienen números)
    final digitCount = text.replaceAll(RegExp(r'[^0-9]'), '').length;
    if (digitCount < 5) {
      errors.add('Muy pocos números detectados para ser un documento');
      score -= 15;
    }

    // Validar presencia de letras
    final letterCount = text.replaceAll(RegExp(r'[^a-záéíóúñ]'), '').length;
    if (letterCount < 20) {
      errors.add('Muy pocas letras detectadas para ser un documento');
      score -= 15;
    }

    final isValid = score >= 30 && errors.isEmpty;

    return DocumentValidationResult(
      isValid: isValid,
      score: score,
      errorMessage: isValid ? null : errors.join(', '),
    );
  }
}

class TextDetectionResult {
  final bool success;
  final bool match;
  final String detectedText;
  final String? error;
  final bool isDocumentValid;
  final int validationScore;
  final List<TextBlock> matchedBlocks;

  TextDetectionResult({
    required this.success,
    required this.match,
    required this.detectedText,
    this.error,
    required this.isDocumentValid,
    required this.validationScore,
    required this.matchedBlocks,
  });
}

class DocumentValidationResult {
  final bool isValid;
  final int score;
  final String? errorMessage;

  DocumentValidationResult({
    required this.isValid,
    required this.score,
    this.errorMessage,
  });
}
