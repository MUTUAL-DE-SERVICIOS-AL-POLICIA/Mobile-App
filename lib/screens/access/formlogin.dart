import 'dart:convert';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:installed_apps/index.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/card_login.dart';
// import 'package:muserpol_pvt/components/inputs/password.dart';
import 'package:local_auth/local_auth.dart';
import 'package:muserpol_pvt/components/inputs/phone.dart';
import 'package:muserpol_pvt/screens/access/WebScreen.dart';
// import 'package:local_auth_android/local_auth_android.dart';
import 'package:muserpol_pvt/screens/access/sendmessagelogin.dart';

import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_web_auth/flutter_web_auth.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class ScreenFormLogin extends StatefulWidget {
  final String deviceId;

  const ScreenFormLogin({super.key, required this.deviceId});

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

  final tooltipController = JustTheController();
  Map<String, dynamic> body = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  // Future<void> verifyBiometric() async {
  //   final authService = Provider.of<AuthService>(context, listen: false);
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final node = FocusScope.of(context);
    return SafeArea(
        child: SingleChildScrollView(
            child: Center(
                child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: containerWidth,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xff419388)
                  : const Color(0xff419388),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white24
                    : Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bienvenido / a',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                IdentityCard(
                  title: 'Cedula de Identidad:',
                  dniCtrl: dniCtrl,
                  dniComCtrl: dniComCtrl,
                  onEditingComplete: () => node.nextFocus(),
                  textSecondFocusNode: textSecondFocusNode,
                  formatter:
                      FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z-]")),
                  keyboardType: TextInputType.text,
                  stateAlphanumericFalse: () =>
                      setState(() => dniComCtrl.text = ''),
                ),
                SizedBox(
                  height: 10.h,
                ),
                PhoneNumber(phoneCtrl: phoneCtrl, onEditingComplete: () {}),
                SizedBox(
                  height: 10.h,
                ),
                ButtonComponent(
                    text: 'INGRESAR', onPressed: () => sendCredentialsNew()),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(50.r),
                          onTap: () {},
                          child: Column(
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 40.sp,
                                color: const Color(0xff419388),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Ingreso con biometría',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xff419388),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF2B3486), width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2B3486),
                      elevation: 0,
                    ),
                    onPressed: () => onAuthCiudadaniaDigital(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logoCiudadania.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Ciudadania Digital',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
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
                  onTap: () => Navigator.pushNamed(context, 'contacts'),
                ),
              ),
              const SizedBox(width: 10),
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
        SizedBox(
          height: 10.h,
        ),
        Center(
            child: Text(
          'Versión ${dotenv.env['version']}',
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 255, 255, 255)
                : const Color(0xff419388),
          ),
        )),
      ],
    ))));
  }

  // onAuthCiudadaniaDigital() async {
  //   final result = await Navigator.of(context)
  //       .push(MaterialPageRoute(builder: (c) => Webscreen()));
  // }

  String generateCodeVerifier([int length = 64]) {
    final random = Random.secure();
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String generateCodeChallenge(String codeVerifier) {
    final bytes = ascii.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  onAuthCiudadaniaDigital() async {
    const url = 'https://proveedor.ciudadania.demo.agetic.gob.bo';
    const clientId = 'uHIB5dPNuYuKtRYx0GsBE';
    // const clientSecret = 'a30d729ce83b7d662ade840677258e267a24ba6f';
    const redirectUri = 'com.muserpol.pvt:/oauth2redirect';
    const scope =
        'openid profile offline_access fecha_nacimiento email celular';

    final codeVerifier = generateCodeVerifier();
    debugPrint(codeVerifier);
    final codeChallenge = generateCodeChallenge(codeVerifier);
    final authorizationUrl = '$url/auth?response_type=code&client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=${Uri.encodeComponent(scope)}'
        '&code_challenge=$codeChallenge'
        '&code_challenge_method=S256';

    debugPrint(authorizationUrl);
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => Webscreen(initialUrl: authorizationUrl)),
    );
  }

  sendCredentialsNew() async {
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
