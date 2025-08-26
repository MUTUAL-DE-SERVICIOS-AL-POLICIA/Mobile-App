import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class FileDocument {
  final String id;
  final String title;
  final String? textValidate;
  final File? imageFile;
  final String? imagePathDefault;
  final List<String> wordsKey;
  bool validateState;
  bool isDocumentValid;
  List<TextBlock> matchedBlocks;

  FileDocument({
    required this.id,
    required this.title,
    this.textValidate,
    this.imageFile,
    this.imagePathDefault,
    List<String>? wordsKey,
    this.validateState = true,
    this.isDocumentValid = true,
    List<TextBlock>? matchedBlocks,
  }) : wordsKey = wordsKey ?? [],
       matchedBlocks = matchedBlocks ?? [];

  FileDocument copyWith({
    String? id,
    String? title,
    String? textValidate,
    File? imageFile,
    String? imagePathDefault,
    List<String>? wordsKey,
    bool? validateState,
    bool? isDocumentValid,
    List<TextBlock>? matchedBlocks,
  }) {
    return FileDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      textValidate: textValidate ?? this.textValidate,
      imageFile: imageFile ?? this.imageFile,
      imagePathDefault: imagePathDefault ?? this.imagePathDefault,
      wordsKey: wordsKey ?? this.wordsKey,
      validateState: validateState ?? this.validateState,
      isDocumentValid: isDocumentValid ?? this.isDocumentValid,
      matchedBlocks: matchedBlocks ?? this.matchedBlocks,
    );
  }
}
