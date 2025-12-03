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
import 'package:muserpol_pvt/screens/access/register_num/verifity_identiity.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/auth_helpers.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SendMessageLogin extends StatefulWidget {
  final Map<String, dynamic> body;
  final List<Map<String, String>>? fileIdentityCard;
  final bool? activeloading;
  const SendMessageLogin(
      {super.key,
      required this.body,
      this.fileIdentityCard,
      this.activeloading});

  @override
  State<SendMessageLogin> createState() => _SendMessageLogin();
}

class _SendMessageLogin extends State<SendMessageLogin> {
  final double containerWidth = 320.w;
  final TextEditingController codeCtrl = TextEditingController();
  final FocusNode node = FocusNode();
  Timer? countdownTimer;
  int remainingSeconds = 180;
  bool canResend = false;
  bool isLoading = false;
  final SmsAutoFill _autoFill = SmsAutoFill();

  @override
  void initState() {
    super.initState();
    startCountdown();
    listenForSms();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && isLoading) {
        setState(() => isLoading = false);
      }
    });
    if (widget.activeloading!) {
      sendServicesMesagge();
    } else {
      sendServicesMesaggeLogin();
    }
  }

  void sendServicesMesagge() async {
    setState(() => isLoading = true);
    var response = await serviceMethod(
        mounted, context, 'post', widget.body, loginAppMobile(), false, true);
    if (response != null) {
      final dataJson = json.decode(response.body);
      widget.body['messageId'] = dataJson['messageId'];
    }
    setState(() => isLoading = false);
  }

  void sendServicesMesaggeLogin() async {
    setState(() => isLoading = true);
    var response = await serviceMethod(
        mounted, context, 'post', widget.body, loginAppMobile(), false, true);
    final dataJson = json.decode(response.body);
    if (dataJson['error']) {
      if (dataJson['message'] == 'Persona no encontrada') {
        if (!mounted) return;
        AuthHelpers.callDialogActionErrorLogin(context, dataJson['message']);
        setState(() => isLoading = false);
      } else if (dataJson['message'] ==
          'Número de teléfono no registrado para esta persona.') {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RegisterIdentityScreen(body: widget.body)),
        );
      } else if (dataJson['message'] ==
          'La persona titular no se encuentra fallecida, pasar por oficinas de la MUSERPOL') {
        if (!mounted) return;
        AuthHelpers.callDialogActionErrorLogin(context, dataJson['message']);
        setState(() => isLoading = false);
      } else if (dataJson['message'] == 'La persona se encuentra fallecida') {
        if (!mounted) return;
        AuthHelpers.callDialogActionErrorLogin(context, dataJson['message']);
        setState(() => isLoading = false);
      }
    } else {
      if (dataJson['message'] ==
          'Persona verificada, afiliado policial, Inicio de sesión para pruebas') {
        userTest(response);
      }
      widget.body['messageId'] = dataJson['messageId'];
      setState(() => isLoading = false);
    }
  }

  void listenForSms() async {
    await _autoFill.listenForCode();
    SmsAutoFill().code.listen((code) {
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
    var numbercell = widget.body['cellphone'];
    var countryCode = widget.body['countryCode'];
    return Stack(
      children: [
        PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              await backAcction();
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
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
                              SizedBox(height: 10.h),
                              Center(
                                  child: Text('PIN de Seguridad',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.sp,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ))),
                              SizedBox(height: 30.h),
                              PinCodeTextField(
                                appContext: context,
                                length: 4,
                                onChanged: (value) {},
                                onCompleted: (value) {
                                  FocusScope.of(context).unfocus();
                                },
                                controller: codeCtrl,
                                focusNode: node,
                                autoDisposeControllers: false,
                                keyboardType: TextInputType.number,
                                cursorColor: Colors.transparent,
                                pinTheme: PinTheme(
                                  inactiveColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  activeColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
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
                                animationDuration:
                                    const Duration(milliseconds: 300),
                                enableActiveFill: true,
                              ),
                              SizedBox(height: 30.h),
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
                                                  style:
                                                      TextStyle(fontSize: 16),
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
                                        startCountdown();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Código reenviado'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    : null,
                              ),
                              Text(
                                canResend
                                    ? '¿No recibiste el código?'
                                    : 'Reintentar en ${remainingSeconds ~/ 60}:${(remainingSeconds % 60).toString().padLeft(2, '0')}',
                                style: TextStyle(
                                    fontSize: 14.sp, color: Colors.grey),
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
                                      : const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 360.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.asset(
                        'assets/images/mensaje.gif',
                        height: 120.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    if (countryCode == '+591')
                      Text(
                        'Enviando pin de seguridad mediante SMS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      )
                    else
                      Text(
                        'Enviando pin de seguridad mediante WhatsApp',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    SizedBox(height: 20.h),
                    Text(
                      'al $numbercell',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
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

  Future userTest(dynamic response) async {
    final dataJson = json.decode(response.body)['data'];
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    await DBProvider.db.database;

    UserModel user = UserModel.fromJson(
        {"api_token": dataJson["apiToken"], "user": dataJson["information"]});
    await authService.writeAuxtoken(user.apiToken!);
    tokenState.updateStateAuxToken(true);
    if (!mounted) return;
    await authService.writeUser(context, userModelToJson(user));
    userBloc.add(UpdateUser(user.user!));
    final affiliateModel = AffiliateModel(idAffiliate: user.user!.affiliateId!);
    await DBProvider.db.newAffiliateModel(affiliateModel);
    notificationBloc.add(UpdateAffiliateId(user.user!.affiliateId!));
    if (!mounted) return;
    await AuthHelpers.initSessionUserApp(
        context: context,
        response: response,
        userApp: UserAppMobile(
            identityCard: widget.body['username'],
            numberPhone: widget.body['cellphone']),
        user: user);
  }

  Future verifyPinNew(code) async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);

    FocusScope.of(context).unfocus();

    var requestBody = {'pin': code, 'messageId': widget.body['messageId']};

    if (!mounted) return;

    var response = await serviceMethod(mounted, context, 'post', requestBody, verifyPin(), false, true);

    if (response != null) {
      final decoded = json.decode(response.body);

      if (decoded['error'] == true) {
        if (!mounted) return;
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
                      "PIN, Verifique el SMS",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
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
      // Código correcto: continúa flujo normal
      await DBProvider.db.database;
      final dataJson = json.decode(response.body)['data'];

      UserModel user = UserModel.fromJson(
          {"api_token": dataJson["apiToken"], "user": dataJson["information"]});

      await authService.writeAuxtoken(user.apiToken!);
      tokenState.updateStateAuxToken(true);
      if (!mounted) return;
      await authService.writeUser(context, userModelToJson(user));
      userBloc.add(UpdateUser(user.user!));
      final affiliateModel =
          AffiliateModel(idAffiliate: user.user!.affiliateId!);
      await DBProvider.db.newAffiliateModel(affiliateModel);
      notificationBloc.add(UpdateAffiliateId(user.user!.affiliateId!));
      if (!mounted) return;
      if (widget.fileIdentityCard != null) {
        var newrequestBody = {'attachments': widget.fileIdentityCard};
        var newrequest = await serviceMethod(mounted, context, 'post',
            newrequestBody, sendIdentityCard(), true, false);
        if (newrequest != null) {
          debugPrint("envio la fotografia correctamentes");
        }
      }
      if (!mounted) return;
      await AuthHelpers.initSessionUserApp(
          context: context,
          response: response,
          userApp: UserAppMobile(
              identityCard: widget.body['username'],
              numberPhone: widget.body['cellphone']),
          user: user);
    }
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
