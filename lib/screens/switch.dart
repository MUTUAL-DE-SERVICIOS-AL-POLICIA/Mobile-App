import 'dart:async';
import 'dart:io';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:animate_do/animate_do.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/components/paint.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
// import 'package:muserpol_pvt/model/qr_model.dart';
// import 'package:muserpol_pvt/screens/flowQR/flow.dart';
import 'package:muserpol_pvt/screens/access/login.dart';
import 'package:muserpol_pvt/services/service_method.dart';
// import 'package:platform_device_id/platform_device_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:muserpol_pvt/services/services.dart';

class ScreenSwitch extends StatefulWidget {
  const ScreenSwitch({super.key});

  @override
  ScreenSwitchState createState() => ScreenSwitchState();
}

class ScreenSwitchState extends State<ScreenSwitch> {
  bool statelogin = false;
  bool stateOF = true;
  String? deviceId;
  // final deviceInfo = DeviceInfoPlugin();
  int value = 0;
  // var deviceInfoo;

  // final _flashOnController = TextEditingController(text: 'CON FLASH');
  // final _flashOffController = TextEditingController(text: 'SIN FLASH');
  // final _cancelController = TextEditingController(text: 'ATRAS');

  @override
  void initState() {
    super.initState();

    checkVersion(mounted, context);
    initializeDateFormatting();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    final deviceInfo = DeviceInfoPlugin();
    String? statusDeviceId;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        statusDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        statusDeviceId = iosInfo.identifierForVendor;
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
      canPop: false,
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
            const Formtop(),
            const FormButtom(),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (statelogin)
                    GestureDetector(
                      onTap: () => setState(() => statelogin = !statelogin),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AdaptiveTheme.of(context).mode.isDark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  Image(
                    image: AssetImage(
                      AdaptiveTheme.of(context).mode.isDark
                          ? 'assets/images/muserpol-logo.png'
                          : 'assets/images/muserpol-logo2.png',
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: statelogin
                            ? FadeIn(
                                animate: statelogin,
                                child: ScreenLogin(
                                  deviceId: deviceId!,
                                  stateOfficeVirtual: stateOF,
                                ),
                              )
                            : FadeIn(
                                animate: !statelogin,
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 20.0),
                                      child: Text(
                                        '¡Bienvenido!',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    optionTool(
                                      const Image(
                                        image: AssetImage(
                                          'assets/images/couple.png',
                                        ),
                                      ),
                                      'COMPLEMENTO ECONÓMICO',
                                      'Creación y seguimiento de trámites de Complemento Económico.',
                                      () => setState(() => stateOF = false),
                                      false,
                                    ),
                                    optionTool(
                                      const Image(
                                        image: AssetImage(
                                          'assets/images/computer.png',
                                        ),
                                      ),
                                      'OFICINA VIRTUAL',
                                      'Control de Aportes y seguimiento de trámites de Préstamos.',
                                      () => setState(() => stateOF = true),
                                      false,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    Center(
                                        child: Text(
                                            'Versión ${dotenv.env['version']}')),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    if (statelogin) {
      setState(() => statelogin = !statelogin);
      return false;
    }
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

  Widget optionTool(Widget child, String title, String description,
      Function() onPress, bool qrstate) {
    return FadeIn(
        animate: !statelogin,
        duration: const Duration(milliseconds: 500),
        child: GestureDetector(
            onTap: () {
              onPress();
              if (!qrstate) {
                setState(() => statelogin = !statelogin);
              }
            },
            child: ContainerComponent(
              width: double.infinity,
              color: const Color(0xffd9e9e7),
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Column(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: child),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 1.5,
                          child: Text(
                            description,
                            style: const TextStyle(color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }
}
