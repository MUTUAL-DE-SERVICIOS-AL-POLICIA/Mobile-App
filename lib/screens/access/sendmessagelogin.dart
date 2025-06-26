import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:provider/provider.dart';

class SendMessageLogin extends StatefulWidget {
  const SendMessageLogin({super.key});

  @override
  State<SendMessageLogin> createState() => _SendMessageLogin();
}

class _SendMessageLogin extends State<SendMessageLogin> {
  final double containerWidth = 320.w;
  final TextEditingController codeCtrl = TextEditingController(); // Agregado
  final FocusNode node = FocusNode();
  Timer? countdownTimer;
  int remainingSeconds = 180;
  bool canResend = false;

  @override
  void dispose() {
    countdownTimer?.cancel();
    codeCtrl.dispose();
    node.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        bool exitApp = await backAcction();
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
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset(
                        AdaptiveTheme.of(context).mode.isDark
                            ? 'assets/images/muserpol-logo.png'
                            : 'assets/images/muserpol-logo2.png',
                        width: 200.w,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: containerWidth,
                      margin: EdgeInsets.symmetric(horizontal: 10.w),
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: const Color(0xff419388),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white24
                                    : Colors.black12,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Ingrese el código enviado a su número",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 18.sp),
                          ),
                          SizedBox(height: 10.h),
                          Center(
                            child: Container(
                              width: 180.w,
                              height: 280.h,
                              decoration: BoxDecoration(
                                color: Colors
                                    .white, // Fondo para ver bien la sombra
                                borderRadius: BorderRadius.circular(100.r),
                                border: Border.all(
                                  color: const Color(0xff419388),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withAlpha((0.25 * 255).toInt()),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100.r),
                                child: Image.asset(
                                  'assets/images/sendmesagge.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            onChanged: (value) {},
                            onCompleted: (value) => node.nextFocus(),
                            controller: codeCtrl,
                            focusNode: node,
                            autoDisposeControllers: false,
                            keyboardType: TextInputType.number,
                            cursorColor: Colors.transparent,
                            pinTheme: PinTheme(
                              inactiveColor: const Color(0xff419388),
                              activeColor: Colors.black,
                              selectedColor: const Color(0xff419388),
                              selectedFillColor: const Color(0xff419388),
                              inactiveFillColor: Colors.transparent,
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              activeFillColor: AdaptiveTheme.of(context)
                                  .theme
                                  .scaffoldBackgroundColor,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            enableActiveFill: true,
                          ),
                          SizedBox(height: 10.h),
                          ButtonComponent(
                            text: 'VERIFICAR',
                            onPressed: () {
                              final code = codeCtrl.text;
                              if (code.length == 4) {
                                verifyPinNew(code);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Por favor, ingresa los 4 dígitos'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(height: 10.h),
                          ButtonComponent(
                            text: 'REENVIAR CÓDIGO',
                            onPressed: canResend
                                ? () {
                                    // Aquí llamás a la función para reenviar el SMS
                                    startCountdown(); // reinicia cronómetro
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Código reenviado'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                : null, // deshabilitado si no puede reenviar
                          ),
                          Text(
                            canResend
                                ? '¿No recibiste el código?'
                                : 'Reintentar en ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                            style:
                                TextStyle(fontSize: 14.sp, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 6.h),
                          SizedBox(
                            height: 10.h,
                          ),
                          Center(
                              child: Text(
                            'Versión ${dotenv.env['version']}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color.fromARGB(255, 255, 255, 255)
                                  : const Color(0xff419388),
                            ),
                          ))
                        ],
                      ),
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

  Future<bool> backAcction() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ComponentAnimate(
              child: DialogTwoAction(
                  message: '¿Deseas salir de recibir codigo de verificación?',
                  actionCorrect: () => Navigator.pushNamed(context, 'newlogin'),
                  messageCorrect: 'Salir'));
        });
  }

  verifyPinNew(code) async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    FocusScope.of(context).unfocus();

    if (await checkVersion(mounted, context)) {
      var requestBody = {
        'code': code,
      };

      if (dotenv.env['storeAndroid'] == 'appgallery') {
        requestBody['firebase_token'] = '';
      } else {
        requestBody['firebase_token'] =
            await PushNotificationService.getTokenFirebase();
      }
      if (!mounted) return;
      var response = await serviceMethod(mounted, context, 'post', requestBody,
          verifytosendmessage(), false, true);

      debugPrint('response $response');

      if (response != null) {
        await DBProvider.db.database;
        UserModel user =
            userModelFromJson(json.encode(json.decode(response.body)['data']));
        await authService.writeAuxtoken(user.apiToken!);
        tokenState.updateStateAuxToken(true);
        if (!mounted) return;
        await authService.writeUser(context, userModelToJson(user));
        userBloc.add(UpdateUser(user.user!));
        final affiliateModel = AffiliateModel(idAffiliate: user.user!.id!);
        await DBProvider.db.newAffiliateModel(affiliateModel);
        notificationBloc.add(UpdateAffiliateId(user.user!.id!));


      }
    }
  }

  initSessionUserApp(dynamic response, UserAppMobile userApp, UserModel user) async{
    final authService = Provider.of<AuthService>(context, listen: false);
    
  }

  void startCountdown() {
    setState(() {
      remainingSeconds = 180;
      canResend = false;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        setState(() {
          canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }
}
