import 'dart:convert';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/card_login.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:local_auth/local_auth.dart';
import 'package:muserpol_pvt/components/inputs/phone.dart';
import 'package:muserpol_pvt/screens/access/web_screen.dart';
import 'package:muserpol_pvt/screens/access/sendmessagelogin.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // _checkBiometrics();
  }

  // Future<void> _checkBiometrics() async {
  //   final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  //   if (canAuthenticateWithBiometrics) {
  //     // Si el dispositivo es compatible, se habilita la opción de autenticación biométrica
  //     print("El dispositivo soporta autenticación biométrica.");
  //   } else {
  //     // Si no es compatible
  //     print("El dispositivo no soporta autenticación biométrica.");
  //   }
  // }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Autenticación requerida para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true, // Solo biometría
          stickyAuth:
              true, // Mantener la autenticación activa si la app se pausa
        ),
      );

      if (authenticated) {
        // Si la autenticación es exitosa, puedes proceder a la siguiente acción
        // Aquí puedes realizar las acciones necesarias como navegar a otra pantalla
        debugPrint("Autenticación exitosa.");
        // Puedes agregar el código para navegar o realizar alguna acción
      } else {
        // Si la autenticación falla
        debugPrint("Autenticación fallida.");
      }
    } catch (e) {
      debugPrint("Error en la autenticación biométrica: $e");
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
                        onPressed: () => sendCredentialsNew()),
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
                              onTap: _authenticateWithBiometrics,
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fingerprint,
                                    size: 40.sp,
                                    color: color
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Ingreso con biometría',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: color
                                    ),
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
                          color: color
                        ),
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

  //GENERA UN CODIGO VERIFICADOR

  String generateCodeVerifier([int length = 64]) {
    final random = Random.secure();
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  //GENERA UN CODIGO PARA EL CANJE DEL TOKEN

  String generateCodeChallenge(String codeVerifier) {
    final bytes = ascii.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  //HACE LLAMADA AL COMPONENTE PARA LLAMAR A LA PAGINA DE CIUDADANIA DIGITAL
  //CIUDADANIA DIGITAL SOLO INICIARA POR MEDIO DE UNA PAGINA WEB Y NO ASI POR UNA CONEXION POR UNA APP EXTERNA
  //SE ESTA UTILIZANDO UN ESQUEMA DENTRO DE ANDROIDMANIFEST.XML PARA LA LLAMADA AL ESQUEMA "COM.MUSERPOL.PVT://OAUTHREDIRECT"

  Future<void> onAuthCiudadaniaDigital() async {
    setState(() => isLoadingCiudadania = true);

    try {
      if (await checkVersion(mounted, context)) {
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

          final codeVerifier = generateCodeVerifier();
          final codeChallenge = (codeVerifier);

          final authorizationUrl = '$url/auth?response_type=code'
              '&client_id=$clientId'
              '&redirect_uri=$redirectUri'
              '&scope=${Uri.encodeComponent(scope)}'
              '&code_challenge=$codeChallenge'
              '&code_challenge_method=S256';

          // final authorizationUrl =
          //     'http://192.168.2.90:8080/realms/aplicacion-movil/protocol/openid-connect/auth?client_id=muserpol-app&redirect_uri=com.muserpol.pvt:/oauth2redirect&response_type=code&scope=openid';

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
          showError('No se pudo obtener las credenciales.');
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      showError('Ocurrió un error al conectar con el servidor.');
    } finally {
      if (mounted) setState(() => isLoadingCiudadania = false);
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  //INGRESO POR MEDIO DE SMS, INTRODUCIENDO NUMERO DE CARNET, Y SU NUMERO DE CELULAR
  Future<void> sendCredentialsNew() async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return;
    }
    if (await checkVersion(mounted, context)) {
      final username =
          '${dniCtrl.text.trim()}${dniComCtrl.text == '' ? '' : '-${dniComCtrl.text.trim()}'}';
      final cellphone = phoneCtrl.text.trim();

      body['username'] = username;
      body['cellphone'] = cellphone;

      debugPrint(body.toString());
      if (!mounted) return;
      var response = await serviceMethod(
          mounted, context, 'post', body, createtosendmessage(), false, true);
      if (response != null) {
        if (response.statusCode == 200) {
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
  }
}
