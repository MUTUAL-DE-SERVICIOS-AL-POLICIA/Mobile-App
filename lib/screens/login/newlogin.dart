import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/components/paint.dart';
import 'package:muserpol_pvt/screens/login/formlogin.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ScreenNewLogin extends StatefulWidget {
  const ScreenNewLogin({super.key});

  @override
  State<ScreenNewLogin> createState() => _ScreenNewLoginState();
}

class _ScreenNewLoginState extends State<ScreenNewLogin> {
  String? deviceId;

  final TextEditingController dniCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FocusNode textSecondFocusNode = FocusNode();
  final JustTheController tooltipController = JustTheController();

  // Variables
  bool btnAccess = true;
  String dateCtrl = '';
  DateTime? dateTime;
  String? dateCtrlText;
  bool dateState = false;
  DateTime currentDate = DateTime(1950, 1, 1);
  Map<String, dynamic> body = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final deviceInfo = DeviceInfoPlugin();
    String? statusDeviceId;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        statusDeviceId = androidInfo.id; // Obtiene el ID único en Android
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        statusDeviceId =
            iosInfo.identifierForVendor; // Obtiene el ID único en iOS
      } else {
        statusDeviceId = 'Plataforma no soportada';
      }
    } catch (e) {
      statusDeviceId = 'Error obteniendo ID: $e';
    }

    if (!mounted) return;
    setState(() => deviceId = statusDeviceId);
  }

  @override
  Widget build(BuildContext context) {
    // Forzar orientación vertical
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _onBackPressed();
        if (shouldExit) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            const Formtop(),
            const FormButtom(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      AdaptiveTheme.of(context).mode.isDark
                          ? 'assets/images/muserpol-logo.png'
                          : 'assets/images/muserpol-logo2.png',
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Center(
                        child: deviceId != null
                            ? Formlogin(deviceId: deviceId!)
                            : const CircularProgressIndicator(), 
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Diálogo personalizado para salir de la app
  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComponentAnimate(
        child: DialogTwoAction(
          message: '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
          actionCorrect: () =>
              SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
          messageCorrect: 'Salir',
        ),
      ),
    );
  }
}
