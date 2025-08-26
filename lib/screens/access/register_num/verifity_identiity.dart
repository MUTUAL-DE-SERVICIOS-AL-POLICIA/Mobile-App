import 'dart:convert';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/model/register_number/files_state_veritify.dart';
import 'package:muserpol_pvt/model/register_number/ocr_detector.dart';
import 'package:muserpol_pvt/screens/access/sendmessagelogin.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

class RegisterIdentityScreen extends StatefulWidget {
  final Map<String, dynamic> body;

  const RegisterIdentityScreen({
    super.key,
    required this.body,
  });

  @override
  State<RegisterIdentityScreen> createState() => _RegisterIdentityScreenState();
}

class _RegisterIdentityScreenState extends State<RegisterIdentityScreen> {
  CameraController? _controller;
  bool _isLoading = true;
  bool _isCapturing = false;
  bool _showGuide = true;
  List<CameraDescription> cameras = [];
  File? _lastCaptureImage;

  Future<void> initCameras() async {
    cameras = await availableCameras();
  }

  Future<void> _initializeCamera() async {
    await initCameras();

    if (cameras.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    _controller = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );

    try {
      await _controller!.initialize();
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al inicializar cámara: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _captureAndDetect() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception("No se pudo decodificar la imagen");
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      final guideWidth = screenWidth * 0.9;
      final guideHeight = screenHeight * 0.3;
      final guideLeft = (screenWidth - guideWidth) / 2;
      final guideTop = (screenHeight - guideHeight) / 2;

      final scaleX = originalImage.width / screenWidth;
      final scaleY = originalImage.height / screenHeight;

      final cropX = (guideLeft * scaleX).toInt();
      final cropY = (guideTop * scaleY).toInt();
      final cropWidth = (guideWidth * scaleX).toInt();
      final cropHeight = (guideHeight * scaleY).toInt();

      // Recortar la imagen

      final croppedImage = img.copyCrop(originalImage,
          x: cropX, y: cropY, width: cropWidth, height: cropHeight);

      // Guardar en archivo temporal
      final croppedFile = File('${image.path}_cropped.png')
        ..writeAsBytesSync(img.encodePng(croppedImage));

      _lastCaptureImage = croppedFile;

      final inputImage = InputImage.fromFilePath(croppedFile.path);
      final filesState =
          Provider.of<FilesStateVeritify>(context, listen: false);
      final item = filesState.getFileById('cianverso');

      final result = await TextDetector.detectText(
        inputImage: inputImage,
        fileImage: croppedFile,
        item: item!,
        filesState: filesState,
        userInput: widget.body['username'],
      );

      if (mounted) {
        if (!result.isDocumentValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "No parece ser un documento válido: ${result.error}",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.orange[800],
              duration: const Duration(seconds: 3),
            ),
          );
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.match
                      ? "Coincidencia encontrada!"
                      : "No se encontraron coincidencias",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (result.match && result.matchedBlocks.isNotEmpty)
                  Text(
                    "Se encontró en ${result.matchedBlocks.length} ubicación(es)",
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            backgroundColor: result.match ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        if (result.match) {
          //revisar el carnet sera a cargo de las personas asignadas
          //detalles importantes tienen que tener un interfaz donde lo van a verificar
          // debugPrint(widget.body.toString());
          _showImagePreview(context, _lastCaptureImage!);
        } else {
          debugPrint("no debe dejar entrar");
        }
      }
    } catch (e) {
      if (mounted) {
        debugPrint(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar imagen: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _showImagePreview(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Previsualización de documento",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Coincidencia verificada correctamente",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.body["isRegisterCellphone"] = true;
                        sendCredentialsNew(imageFile);
                      },
                      child: const Text("Continuar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  sendCredentialsNew(File imageFile) async {
    List<Map<String, String>> data = [];

    final bytes = await imageFile.readAsBytes();
    String base64 = base64Encode(bytes);

    data.add({
      'filename': 'cianverso',
      'content': base64,
    });

    var response = await serviceMethod(
        mounted, context, 'post', widget.body, loginAppMobile(), false, true);

    if (response != null) {
      final dataJson = json.decode(response.body);
      widget.body['messageId'] = dataJson['messageId'];
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => SendMessageLogin(body: widget.body, fileIdentityCard: data,),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error de Cámara")),
        body: const Center(child: Text("No se pudo inicializar la cámara")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Capturar Cédula de Identidad"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showDocumentInstructions,
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            icon: Icon(_showGuide ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showGuide = !_showGuide),
            tooltip: _showGuide ? "Ocultar guía" : "Mostrar guía",
          ),
        ],
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          if (_showGuide) _buildDocumentGuide(),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                const Text(
                  "Coloque la cédula dentro del marco",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Asegúrese de que el número de cédula sea visible",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _isCapturing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : ElevatedButton.icon(
                        onPressed: _captureAndDetect,
                        icon: const Icon(Icons.camera),
                        label: const Text("CAPTURAR"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AdaptiveTheme.of(context).theme.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("• $text"),
    );
  }

  Widget _buildDocumentGuide() {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.3,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 3,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Text(
                "ANVERSO",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cómo posicionar su cédula"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstruction("1. Coloque la cédula dentro del marco verde"),
              _buildInstruction("2. Asegúrese de que esté bien iluminada"),
              _buildInstruction("3. El texto debe ser legible y nítido"),
              _buildInstruction("4. Evite reflejos y sombras"),
              _buildInstruction("5. El número de cédula debe ser visible"),
              const SizedBox(height: 10),
              const Text(
                "El sistema validará que sea un documento real",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }
}
