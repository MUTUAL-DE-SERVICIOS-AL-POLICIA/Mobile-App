import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/card_login.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:local_auth/local_auth.dart';
import 'package:muserpol_pvt/components/inputs/phone.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/access/sendmessagelogin.dart';
import 'package:muserpol_pvt/screens/access/web_screen.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/auth_helpers.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:sms_autofill/sms_autofill.dart';

class ScreenFormLogin extends StatefulWidget {
  const ScreenFormLogin({super.key});

  @override
  State<ScreenFormLogin> createState() => _ScreenFormLoginState();
}

class _ScreenFormLoginState extends State<ScreenFormLogin> {
  TextEditingController dniCtrl = TextEditingController();
  TextEditingController dniComCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final double containerWidth = 320.w;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool btnAccess = true;
  String dateCtrl = '';
  DateTime? dateTime;
  String? dateCtrlText;
  bool dateState = false;
  DateTime currentDate = DateTime(1950, 1, 1);
  FocusNode textSecondFocusNode = FocusNode();
  bool isLoadingCiudadania = false;

  final tooltipController = JustTheController();
  Map<String, dynamic> body = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    // verifyBiometric();
  }

  verifyBiometric() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    if (await authService.readBiometric() != "") {
      _authenticate();
    } else {
      debugPrint("no tiene datos biometricos guardados");
    }
  }

  Future<void> _authenticate() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    bool autenticated = false;
    try {
      autenticated = await auth.authenticate(
          localizedReason: 'MUSERPOL',
          authMessages: [
            const AndroidAuthMessages(
              signInTitle: 'Autenticación Biometrica',
              cancelButton: 'No Gracias',
              biometricHint: 'Verificar Identidad',
            ),
          ],
          options: const AuthenticationOptions(
              stickyAuth: true, biometricOnly: true));
    } on PlatformException catch (e) {
      debugPrint('$e');
      return;
    }

    if (!mounted) return;

    if (autenticated) {
      final biometric =
          biometricUserModelFromJson(await authService.readBiometric());

      if (biometric.userAppMobile != null) {
        debugPrint(jsonEncode(biometric.toJson()));
        setState(() {
          dniCtrl.text = biometric.userAppMobile?.identityCard ?? '';
          phoneCtrl.text = biometric.userAppMobile?.numberPhone ?? '';
        });

        sendCredentialsNew(isBiometric: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final color = isDarkMode
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color(0xff419388);

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final node = FocusScope.of(context);
    //devuelve la estructura inicial de la aplicacion: FORMULARIO DEL LOGIN
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: containerWidth,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              padding: EdgeInsets.all(15.w),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Bienvenido a Muserpol Movil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    //COMPONENTE PARA EL INGRESO DEL CARNET DE IDENTIDAD Y CON COMPLEMENTO
                    IdentityCard(
                      title: 'Cedula de Identidad:',
                      dniCtrl: dniCtrl,
                      dniComCtrl: dniComCtrl,
                      onEditingComplete: () => node.nextFocus(),
                      textSecondFocusNode: textSecondFocusNode,
                      formatter: FilteringTextInputFormatter.allow(
                          RegExp("[0-9a-zA-Z-]")),
                      keyboardType: TextInputType.text,
                      stateAlphanumericFalse: () =>
                          setState(() => dniComCtrl.text = ''),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    //COMPONENTE PARA EL INGRESO DE NUMERO DE CELULAR
                    PhoneNumber(phoneCtrl: phoneCtrl, onEditingComplete: () {}),
                    SizedBox(
                      height: 20.h,
                    ),
                    //COMPONENTE BUTTON
                    ButtonComponent(
                        text: 'INGRESAR',
                        stateLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () => sendCredentialsNew(isBiometric: false)),
                    SizedBox(
                      height: 10.h,
                    ),
                    //COMPONENTE BOTON PARA CIUDADANIA DIGITAL
                    CiudadaniaButtonComponent(
                      stateLoading: isLoadingCiudadania,
                      onPressed:
                          isLoadingCiudadania ? null : onAuthCiudadaniaDigital,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    //FALTA ACTIVAR PARA EL INGRESO CON HUELLA DIGITAL
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50.r),
                              onTap: verifyBiometric,
                              child: Column(
                                children: [
                                  Icon(Icons.fingerprint,
                                      size: 40.sp, color: color),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Ingreso con biometría',
                                    style: TextStyle(
                                        fontSize: 12.sp, color: color),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                    //SECCION DE CONTACTOS Y POLITICAS Y PRIVACIDAD
                    SizedBox(
                      height: 20.h,
                    ),
                    SizedBox(
                      width: containerWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: MiniCardButton(
                              icon: Icons.contact_phone,
                              label: 'Contactos\na nivel nacional',
                              onTap: () =>
                                  Navigator.pushNamed(context, 'contacts'),
                            ),
                          ),
                          SizedBox(width: 10.w), // Responsivo
                          Expanded(
                            child: MiniCardButton(
                              icon: Icons.privacy_tip,
                              label: 'Política\nde privacidad',
                              onTap: () => launchUrl(
                                Uri.parse(serviceGetPrivacyPolicy()),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //VERSION DE LA APLICACION VISIBLE
                    SizedBox(
                      height: 20.h, // Responsivo
                    ),
                    // Center(
                    //   child: Text(
                    //     'Versión ${dotenv.env['version']}',
                    //     style: TextStyle(
                    //       fontSize: 12.sp, // Responsivo
                    //       color: Theme.of(context).brightness == Brightness.dark
                    //           ? const Color.fromARGB(255, 0, 0, 0)
                    //           : const Color.fromARGB(255, 0, 0, 0),
                    //     ),
                    //   ),
                    // )
                    Center(
                      child: Text(
                        'Version 4.0.1',
                        style: TextStyle(
                            fontSize: 12.sp, // Responsivo
                            color: color),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  //HACE LLAMADA AL COMPONENTE PARA LLAMAR A LA PAGINA DE CIUDADANIA DIGITAL
  //CIUDADANIA DIGITAL SOLO INICIARA POR MEDIO DE UNA PAGINA WEB Y NO ASI POR UNA CONEXION POR UNA APP EXTERNA
  //SE ESTA UTILIZANDO UN ESQUEMA DENTRO DE ANDROIDMANIFEST.XML PARA LA LLAMADA AL ESQUEMA "COM.MUSERPOL.PVT://OAUTHREDIRECT"

  Future<void> onAuthCiudadaniaDigital() async {
    setState(() => isLoadingCiudadania = true);

    try {
      var response = await serviceMethod(
        mounted,
        context,
        'get',
        null,
        serviceGetCredentials(),
        false,
        true,
      );

      if (response != null && response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final url = decoded['url'];
        final clientId = decoded['clientID'];
        final redirectUri = decoded['redirectURI'];
        final scope = decoded['scope'];

        final codeVerifier = AuthHelpers.generateCodeVerifier();
        final codeChallenge = AuthHelpers.generateCodeChallenge(codeVerifier);

        final authorizationUrl = '$url/auth?response_type=code'
            '&client_id=$clientId'
            '&redirect_uri=$redirectUri'
            '&scope=${Uri.encodeComponent(scope)}'
            '&code_challenge=$codeChallenge'
            '&code_challenge_method=S256';

        debugPrint('acceso a la URL es: . $authorizationUrl');

        if (!mounted) return;
        //RECIBIDO LAS CREDENCIALES DE CIUDADANIA DIGITAL INICIA LA PAGINA DE LOGIN DE CIUDADANIA DIGITAL
        //PARA REALIZAR LAS CONSULTAS CORRESPONDIENTES AL SERVICIO DE CIUDADANIA DIGITAL SE DEBE ENVIAR EL CODE VERIFIER, IMPORTATE GUARDARLO
        //SOLO PARA UN USO
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Webscreen(
              initialUrl: authorizationUrl,
              codeVerifier: codeVerifier,
            ),
          ),
        );
      } else {
        AuthHelpers.showError(context, 'No se pudo obtener las credenciales.');
      }
    } catch (e) {
      debugPrint('Error: $e');
      AuthHelpers.showError(
          context, 'Ocurrió un error al conectar con el servidor.');
    } finally {
      if (mounted) setState(() => isLoadingCiudadania = false);
    }
  }

  //INGRESO POR MEDIO DE SMS, INTRODUCIENDO NUMERO DE CARNET, Y SU NUMERO DE CELULAR
  sendCredentialsNew({required bool isBiometric}) async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final signature = await SmsAutoFill().getAppSignature;
      if (!formKey.currentState!.validate()) {
        return;
      }

      final identityCard =
          '${dniCtrl.text.trim()}${dniComCtrl.text == '' ? '' : '-${dniComCtrl.text.trim()}'}';
      final cellphone = phoneCtrl.text.trim();

      if (dotenv.env['storeAndroid'] == 'appgallery') {
        body['firebase_token'] = '';
      } else {
        body['firebase_token'] =
            await PushNotificationService.getTokenFirebase();
      }

      body['username'] = identityCard;
      body['cellphone'] = cellphone;
      body['signature'] = signature;
      body['isBiometric'] = true;

      if (!mounted) return;
      var response = await serviceMethod(
          mounted, context, 'post', body, createtosendmessage(), false, true);
      // var response = await serviceMethod(
      //     mounted, context, 'post', body, loginAppMobile(), false, true);
      if (response != null) {
        if (isBiometric) {
          if (response.statusCode == 200) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final tokenState = Provider.of<TokenState>(context, listen: false);
            final notificationBloc = BlocProvider.of<NotificationBloc>(context, listen: false);
            final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
            await DBProvider.db.database;
            final dataJson = json.decode(response.body)['data'];

            UserModel user = UserModel.fromJson({
              "api_token": dataJson["apiToken"],
              "user": dataJson["information"]
            });

            await authService.writeAuxtoken(user.apiToken!);
            tokenState.updateStateAuxToken(true);
            if (!mounted) return;
            await authService.writeUser(context, userModelToJson(user));
            userBloc.add(UpdateUser(user.user!));
            final affiliateModel = AffiliateModel(idAffiliate: user.user!.affiliateId!);
            await DBProvider.db.newAffiliateModel(affiliateModel);
            notificationBloc.add(UpdateAffiliateId(user.user!.affiliateId!));

            await AuthHelpers.initSessionUserApp(
              context: context,
              response: response,
                userApp: UserAppMobile(
                    identityCard: body['username'],
                    numberPhone: body['cellphone']),
                user: user);
          }
        } else {
          //debo realizar un nueva interfaz para que vaya
          if (response.statusCode == 200) {
            final pinJson = json.decode(response.body);
            body['messageId'] = pinJson['messageId'];
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => SendMessageLogin(body: body),
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
      }
    } catch (e) {
      debugPrint('Error: $e');
      AuthHelpers.showError(
          context, 'Ocurrio un error al conectar con el servidor');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
}
