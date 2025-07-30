import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
import 'package:muserpol_pvt/screens/list_services_menu/list_service.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SendMessageLogin extends StatefulWidget {
  final Map<String, dynamic> body;
  const SendMessageLogin({super.key, required this.body});

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
  final SmsAutoFill _autoFill = SmsAutoFill();

  @override
  void initState() {
    super.initState();
    startCountdown();
    listenForSms();
  }

  void listenForSms() async {
    await _autoFill.listenForCode();
    SmsAutoFill().code.listen((code) {
      debugPrint('Código capturado por sms_autofill: $code');
      if (code.length == 4) {
        setState(() {
          codeCtrl.text = code;
        });
      } else {
        debugPrint('No se capturó un código válido.');
      }
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    codeCtrl.dispose();
    node.dispose();
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 90.w,
                          height: 190.h,
                          child: ClipRRect(
                            child: Image.asset(
                              'assets/images/sendmesagge.png',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Verificación de Codigo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.h),
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
                          fieldHeight: 60,
                          fieldWidth: 60,
                        ),
                        animationDuration: const Duration(milliseconds: 300),
                        enableActiveFill: true,
                      ),

                      SizedBox(height: 20.h),
                      ButtonComponent(
                        text: 'VERIFICAR',
                        onPressed: () {
                          final code = codeCtrl.text;
                          if (code.length == 4) {
                            verifyPinNew(code);
                          } else {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning_amber,
                                          size: 40,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(height: 20),
                                        const Text(
                                          'Introduzca el pin de 4 digitos',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 20),
                                        ButtonComponent(
                                          text: 'CERRAR',
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                });
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
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      SizedBox(
                        height: 10.h,
                      ),
                      // Center(
                      //     child: Text(
                      //   'Versión ${dotenv.env['version']}',
                      //   style: TextStyle(
                      //     fontSize: 12.sp,
                      //     color: Theme.of(context).brightness ==
                      //             Brightness.dark
                      //         ? const Color.fromARGB(255, 255, 255, 255)
                      //         : const Color(0xff419388),
                      //   ),
                      // ))
                      Center(
                        child: Text(
                          'Version 4.0.1',
                          style: TextStyle(
                            fontSize: 12.sp, // Responsivo
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : const Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
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

      if (response != null) {
        final decoded = json.decode(response.body);

        if (decoded['error'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código incorrecto, por favor intentá nuevamente'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        // Código correcto: continúa flujo normal
        await DBProvider.db.database;
        final dataJson = json.decode(response.body)['data'];

        if (dataJson.containsKey('belongs_to_economic_complement') &&
            dataJson['user'] is Map<String, dynamic>) {
          debugPrint("seeee");
          dataJson['user']['belongs_to_economic_complement'] =
              dataJson['belongs_to_economic_complement'];
        }

        UserModel user = userModelFromJson(json.encode(dataJson));

        await authService.writeAuxtoken(user.apiToken!);
        tokenState.updateStateAuxToken(true);
        if (!mounted) return;
        await authService.writeUser(context, userModelToJson(user));
        userBloc.add(UpdateUser(user.user!));
        final affiliateModel = AffiliateModel(idAffiliate: user.user!.id!);
        await DBProvider.db.newAffiliateModel(affiliateModel);
        notificationBloc.add(UpdateAffiliateId(user.user!.id!));

        initSessionUserApp(
            response,
            UserAppMobile(
                identityCard: widget.body['username'],
                numberPhone: widget.body['cellphone']),
            user);
      } else {}
    }
  }

  initSessionUserApp(
      dynamic response, UserAppMobile userApp, UserModel user) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    tokenState.updateStateAuxToken(false);
    final biometricUserModel = BiometricUserModel(
      affiliateId: json.decode(response.body)['data']['user']['id'],
    );
    if (!mounted) return;
    await authService.writeBiometric(
        context, biometricUserModelToJson(biometricUserModel));

    if (!mounted) return;
    await authService.writeToken(context, user.apiToken!);

    if (!mounted) return;
    await authService.writeToken(context, user.apiToken!);
    tokenState.updateStateAuxToken(false);

    if (!mounted) return;

    showSuccessful(
      context,
      'Correcto, Autenticacion Exitosa',
      () {
        // Luego de que el mensaje de éxito se cierre, navegamos a la siguiente pantalla
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ScreenListService(
              showTutorial: true,
            ),
            transitionDuration: const Duration(seconds: 0),
          ),
        );
      },
    );
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
