import 'dart:io';

class FileDocument {
  String? id, title, imageName, textValidate, imagePathDefault;
  File? imageFile;
  List<String>? wordsKey;
  bool validateState;

  FileDocument(
      {this.id,
      this.title,
      this.imageName,
      this.textValidate,
      this.imagePathDefault,
      this.imageFile,
      this.wordsKey,
      this.validateState = false});
}

enum StateAplication { virtualOficine, complement }
