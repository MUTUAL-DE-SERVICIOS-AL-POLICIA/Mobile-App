import 'dart:convert';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animations/animations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/model/register_number/files_state_veritify.dart';
import 'package:muserpol_pvt/model/register_number/ocr_detector.dart';
import 'package:muserpol_pvt/screens/access/sendmessagelogin.dart';
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
  bool _isFrontSide = true;

  File? _frontImage;

  bool _showVerifying = false;

  bool _cameraDisposed = false;
  bool _navigatingAway = false;

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
      enableAudio: false,
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

  Future<void> _askConfirmAndInitCamera() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var numbercell = widget.body['cellphone'];
      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Registrar nuevo número"),
          content: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'El celular ',
                ),
                TextSpan(
                  text: '$numbercell',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text:
                      ' no esta registrado, se verificará la identidad con la captura de su cédula.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            //Cambiar la estructura del boton
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Sí, registrar"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _initializeCamera();
      } else {
        if (mounted) Navigator.pushNamed(context, 'newlogin');
      }
    });
  }

  Future<void> _captureAndDetect() async {
    if (_controller == null ||
        _cameraDisposed ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _showVerifying = true;
    });

    try {
      await _controller!.pausePreview();

      final XFile image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception("No se pudo decodificar la imagen");
      }

      if (!mounted) return;

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

      final croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      final croppedFile = File('${image.path}_cropped.png')
        ..writeAsBytesSync(img.encodePng(croppedImage));

      if (!mounted) return;

      if (_isFrontSide) {
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

        if (!mounted) return;

        if (!result.isDocumentValid) {
          if (mounted) setState(() => _showVerifying = false);
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

        if (mounted) setState(() => _showVerifying = false);
        if (result.match) {
          _showImagePreview(context, croppedFile, isFront: true);
        }
      } else {
        if (mounted) setState(() => _showVerifying = false);
        _showImagePreview(context, croppedFile, isFront: false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _showVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al procesar imagen: $e')),
        );
      }
    } finally {
      if (mounted &&
          !_navigatingAway &&
          _controller != null &&
          !_cameraDisposed) {
        try {
          await _controller!.resumePreview();
        } catch (_) {}
      }
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  void _showImagePreview(BuildContext context, File imageFile,
      {required bool isFront}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFront ? "Anverso capturado" : "Reverso capturado",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Image.file(imageFile,
                  width: 200, height: 150, fit: BoxFit.contain),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if (isFront) {
                    _frontImage = imageFile;
                    setState(() => _isFrontSide = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ahora capture el reverso")),
                    );
                  } else {
                    setState(() {
                      _showVerifying = true;
                      _navigatingAway = true;
                    });

                    widget.body["isRegisterCellphone"] = true;

                    try {
                      await _controller?.dispose();
                    } catch (_) {}
                    _controller = null;
                    _cameraDisposed = true;

                    sendCredentialsNew(_frontImage!, imageFile);
                  }
                },
                child: Text(isFront ? "Continuar con reverso" : "Finalizar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _askConfirmAndInitCamera();
  }

  @override
  void dispose() {
    _cameraDisposed = true;

    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  sendCredentialsNew(File frontImage, File backImage) async {
    List<Map<String, String>> data = [];

    final frontbytes = await frontImage.readAsBytes();
    String frontbase64 = base64Encode(frontbytes);
    final backbytes = await backImage.readAsBytes();
    String backbase64 = base64Encode(backbytes);

    data.add({'filename': 'ci_anverso', 'content': frontbase64});
    data.add({'filename': 'ci_reverso', 'content': backbase64});

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => SendMessageLogin(
          body: widget.body,
          fileIdentityCard: data,
          activeloading: true,
        ),
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

  Future<bool> backAcction() async {
    if (!mounted) return false;
    final shouldExit = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ComponentAnimate(
          child: DialogTwoAction(
            message: '¿Deseas salir de la verificación de la identidad?',
            actionCorrect: () => Navigator.pop(context, true),
            messageCorrect: 'Salir',
          ),
        );
      },
    );

    if (shouldExit == true) {
      setState(() {
        _navigatingAway = true;
        _showVerifying = true;
      });
      try {
        await _controller?.dispose();
      } catch (_) {}
      _controller = null;
      _cameraDisposed = true;

      if (mounted) {
        Navigator.pushNamed(context, 'newlogin');
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final canShowPreview = _controller != null &&
        !_cameraDisposed &&
        _controller!.value.isInitialized &&
        !_navigatingAway;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await backAcction();
      },
      child: Scaffold(
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
            if (canShowPreview)
              CameraPreview(_controller!)
            else
              Container(color: Colors.black),
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
                  ElevatedButton.icon(
                    onPressed: canShowPreview ? _captureAndDetect : null,
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
            if (_showVerifying) _buildVerifyingOverlay(),
          ],
        ),
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
            color: const Color.fromARGB(255, 255, 255, 255),
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
                "CAPTURAR",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
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

  Widget _buildVerifyingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black45,
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 200),
              Image(
                image: AssetImage('assets/images/loading.gif'),
                height: 120,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 20),
              Text(
                'Verificando',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
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
