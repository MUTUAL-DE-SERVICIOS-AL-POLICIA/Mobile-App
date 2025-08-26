// files_state.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'file_document.dart';

class FilesStateVeritify with ChangeNotifier {
  List<FileDocument> _files = [];

  FilesStateVeritify() {
    // Inicialización en el constructor
    _files = [
      FileDocument(
        id: 'cianverso',
        title: 'Cédula de Identidad Anverso',
        imagePathDefault: 'assets/images/anverso.png',
        wordsKey: [],
        validateState: true,
      ),
    ];
  }

  List<FileDocument> get files => List.unmodifiable(_files);

  FileDocument? getFileById(String id) {
    try {
      return _files.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  void addKey(String keyId, String keyText) {
    final index = _files.indexWhere((e) => e.id == keyId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(
        wordsKey: List.from(_files[index].wordsKey)..add(keyText),
      );
      notifyListeners();
    }
  }

  void updateStateFiles(String keyId, bool state) {
    final index = _files.indexWhere((e) => e.id == keyId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(validateState: state);
      notifyListeners();
    }
  }

  void updateFile(String keyId, File? file) {
    final index = _files.indexWhere((e) => e.id == keyId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(imageFile: file);
      notifyListeners();
    }
  }

  void clearFiles() {
    _files = _files.map((file) {
      return file.copyWith(imageFile: null, validateState: true);
    }).toList();
    notifyListeners();
  }

  void addFile(FileDocument file) {
    _files.add(file);
    notifyListeners();
  }

  void removeFile(String id) {
    _files.removeWhere((file) => file.id == id);
    notifyListeners();
  }

  void updateDocumentValidation(String keyId, bool isValid) {
    final index = _files.indexWhere((e) => e.id == keyId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(isDocumentValid: isValid);
      notifyListeners();
    }
  }

  void updateMatchedBlocks(String keyId, List<TextBlock> matchedBlocks) {
    final index = _files.indexWhere((e) => e.id == keyId);
    if (index != -1) {
      _files[index] = _files[index].copyWith(matchedBlocks: matchedBlocks);
      notifyListeners();
    }
  }
}
