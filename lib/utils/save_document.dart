import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> saveFile(
    String folderName, String fileName, Uint8List data) async {
  // 1. Usar Application Documents Directory, no Temporary
  final directory = await getApplicationDocumentsDirectory();
  final folderPath = Directory(p.join(directory.path, folderName));

  // 2. Crear carpeta si no existe, de forma segura y asíncrona
  if (!await folderPath.exists()) {
    await folderPath.create(recursive: true);
  }

  // 3. Crear el archivo de manera segura
  final filePath = p.join(folderPath.path, fileName);
  final file = File(filePath);

  // 4. Escribir los datos de forma asíncrona
  await file.writeAsBytes(data);

  // 5. Devolver la ruta completa
  return file.path;
}
