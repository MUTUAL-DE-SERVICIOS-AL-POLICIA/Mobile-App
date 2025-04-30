import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';

class ImageCtrlLive extends StatefulWidget {
  final Function(String) sendImage;
  const ImageCtrlLive({super.key, required this.sendImage});

  @override
  State<ImageCtrlLive> createState() => _ImageCtrlLiveState();
}

class _ImageCtrlLiveState extends State<ImageCtrlLive>
    with WidgetsBindingObserver {
  late List<CameraDescription>? _availableCameras;
  CameraController? controllerCam;
  bool? isCameraReady;
  Future<void>? _initializeControllerFuture;
  double mirror = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getAvailableCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controllerCam?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controllerCam == null || !controllerCam!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controllerCam?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controllerCam != null) {
        _getAvailableCameras();
      }
    }
  }

  // Future<void> _getAvailableCameras() async {
  //   _availableCameras = await availableCameras();
  //   CameraDescription newDescription;
  //   newDescription = _availableCameras!.firstWhere((description) =>
  //       description.lensDirection == CameraLensDirection.front);
  //   _initCamera(newDescription);
  // }

  Future<void> _getAvailableCameras() async {
    try {
      _availableCameras = await availableCameras();

      if (_availableCameras == null || _availableCameras!.isEmpty) {
        debugPrint('No se encontraron cámaras disponibles.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No se encontraron cámaras disponibles.')));
        }
        return;
      }
      CameraDescription newDescription;
      final frontCameras = _availableCameras!
          .where((description) =>
              description.lensDirection == CameraLensDirection.front)
          .toList();

      if (frontCameras.isNotEmpty) {
        newDescription = frontCameras.first;
      } else {
        debugPrint(
            'No se encontró cámara frontal, usando la primera disponible.');
        newDescription = _availableCameras!.first;
      }

      _initCamera(newDescription);
    } catch (e) {
      debugPrint('Error al obtener las cámaras: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al inicializar la cámara.')));
      }
    }
  }

  Future<void> _initCamera(CameraDescription description) async {
    final stateCam = BlocProvider.of<UserBloc>(context, listen: false);
    controllerCam = CameraController(description, ResolutionPreset.high,
        enableAudio: false);
    _initializeControllerFuture = controllerCam!.initialize().then((_) {
      if (!mounted) return;
      controllerCam!.setFlashMode(FlashMode.off);
      controllerCam!.addListener(() {
        if (mounted) setState(() {});
        if (controllerCam!.value.hasError) {
          debugPrint('Camera error ${controllerCam!.value.errorDescription}');
        }
      });
      stateCam.add(UpdateStateBtntoggleCameraLens(true));
      setState(() {});
    }).catchError((Object e) {
      debugPrint('error $e');
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            debugPrint('User denied camera access.');
            break;
          default:
            debugPrint('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateCam = BlocProvider.of<UserBloc>(context, listen: true).state;
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            stateCam.stateCam) {
          return Stack(children: <Widget>[
            Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(controllerCam!
                                .description.lensDirection ==
                            CameraLensDirection.front
                        ? math
                            .pi // Aplica el espejo solo para la cámara frontal
                        : 0), // No aplicar nada para la cámara trasera
                    child: CameraPreview(
                      controllerCam!,
                    ))),
            stateCam.stateBtntoggleCameraLens
                ? Positioned(
                    bottom: 20,
                    right: 20,
                    left: 20,
                    child: Row(
                      children: [
                        IconBtnComponent(
                          iconText: 'assets/icons/camera-switch.svg',
                          onPressed: () => switchCam(),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                            child: ButtonComponent(
                                text: 'CAPTURAR',
                                onPressed: () => takePhoto())),
                      ],
                    ))
                : Container(),
          ]);
        } else {
          return Center(
              child: Image.asset(
            'assets/images/load.gif',
            fit: BoxFit.cover,
            height: 20,
          ));
        }
      },
    );
  }

  switchCam() {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    if (userBloc.state.stateCam) {
      userBloc.add(UpdateStateBtntoggleCameraLens(false));
      _toggleCameraLens();
    }
  }

  takePhoto() async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    try {
      if (userBloc.state.stateBtntoggleCameraLens) {
        userBloc.add(UpdateStateCam(false));

        if (controllerCam != null && controllerCam!.value.isInitialized) {
          final XFile image = await controllerCam!.takePicture();
          File imageFile = File(image.path);

          // Convertir imagen a Base64
          String base64 = base64Encode(await imageFile.readAsBytes());
          widget.sendImage(base64);
        }
      }
    } catch (e) {
      debugPrint('Ocurrió un error al capturar la imagen: $e');
    }
  }

  void _toggleCameraLens() {
    final lensDirection = controllerCam!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      setState(() => mirror = math.pi);
      newDescription = _availableCameras!.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      setState(() => mirror = 0);
      newDescription = _availableCameras!.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }
    _initCamera(newDescription);
  }
}
