

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/screens/access/formlogin.dart';
import 'package:muserpol_pvt/services/service_method.dart';

class ScreenNewLogin extends StatefulWidget {
  const ScreenNewLogin({super.key});

  @override
  State<ScreenNewLogin> createState() => _ScreenNewLoginState();
}

class _ScreenNewLoginState extends State<ScreenNewLogin> {
  String? deviceId;
  final double containerWidth = 320.w;

  @override
  void initState() {
    super.initState();
    checkVersion(mounted, context);
    initializeDateFormatting();
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              //LOGO DE LA MUSERPOL EN EL LOGIN INICIAL
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        AdaptiveTheme.of(context).mode.isDark
                            ? 'assets/images/muserpol-logo.png'
                            : 'assets/images/muserpol-logo2.png',
                        width: 250.w,
                      ),
                    ),
                    //LLAMAMOS EL FORMULARIO DEL LOGIN
                    SizedBox(height: 10.h),
                    FadeIn(
                      animate: true,
                      child: const ScreenFormLogin(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //FUNCION PARA SALIR DE LA APLICACION

  Future<bool> _onBackPressed() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ComponentAnimate(
          child: DialogTwoAction(
            message: '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
            actionCorrect: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            messageCorrect: 'Salir',
          ),
        );
      },
    );
  }
}
