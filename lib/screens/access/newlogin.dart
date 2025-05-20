import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
// import 'package:muserpol_pvt/components/paint.dart';
import 'package:muserpol_pvt/screens/access/formlogin.dart';

class ScreenNewLogin extends StatefulWidget {
  const ScreenNewLogin({super.key});
  @override
  State<ScreenNewLogin> createState() => _ScreenNewLoginState();
}

class _ScreenNewLoginState extends State<ScreenNewLogin> {
  String? deviceId;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
    return PopScope(
      canPop:
          false, // Evita que el usuario cierre la pantalla con el botón de retroceso
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        bool exitApp = await _onBackPressed();
        if (exitApp) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // const Formtop(),
            // const FormButtom(),
            Padding(
                padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image(
                        image: AssetImage(
                          AdaptiveTheme.of(context).mode.isDark
                              ? 'assets/images/muserpol-logo.png'
                              : 'assets/images/muserpol-logo2.png',
                        ),
                        width: 200.w,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    FadeIn(
                      animate: true,
                      child: const ScreenFormLogin(),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ComponentAnimate(
              child: DialogTwoAction(
                  message:
                      '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
                  actionCorrect: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                  messageCorrect: 'Salir'));
        });
  }
}
