import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/card_login.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenFormLogin extends StatefulWidget {
  final String deviceId;

  const ScreenFormLogin({super.key, required this.deviceId});

  @override
  State<ScreenFormLogin> createState() => _ScreenFormLoginState();
}

class _ScreenFormLoginState extends State<ScreenFormLogin> {
  TextEditingController dniCtrl = TextEditingController();
  TextEditingController dniComCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  final double containerWidth = 320.w;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  Future<void> _authenticate() async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'MUSERPOL',
        authMessages: [
          const AndroidAuthMessages(
            signInTitle: 'Autenticación Biométrica requerida',
            cancelButton: 'NO GRACIAS',
            biometricHint: 'Verificar Identidad',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Error: $e');
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      debugPrint('Autenticación exitosa');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Autenticación biométrica exitosa")),
      );
    } else {
      debugPrint('Autenticación cancelada o fallida');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final node = FocusScope.of(context);
    return Center(
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
                  title: 'Usuario / CI:',
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
                Password(
                    passwordCtrl: passwordCtrl, onEditingComplete: () => ()),
                SizedBox(
                  height: 10.h,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, 'forgot'),
                    child: Text('¿Olvidaste tus credenciales?',
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black,
                        )),
                  ),
                ),
                SizedBox(
                  height: 10.h,
                ),
                ButtonComponent(text: 'INGRESAR', onPressed: () => ()),
                SizedBox(
                  height: 20.h,
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50.r),
                    onTap: () {
                      _authenticate();
                    },
                    child: Column(
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 40.sp,
                          color: Colors.black,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Ingreso con biometría',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black,
                          ),
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
              const SizedBox(width: 10),
              Expanded(
                child: MiniCardButton(
                  icon: Icons.person_add,
                  label: 'Nuevo\nUsuario de la app',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'MUSERPOL',
                    applicationVersion: dotenv.env['version'] ?? '',
                    applicationLegalese:
                        'Aplicación de consulta de datos de la Policía Boliviana.',
                    children: [
                      const Text('Desarrollado por MUSERPOL'),
                      const SizedBox(height: 10),
                      const Text('Versión 1.0.0'),
                    ],
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
        ))
      ],
    ));
  }

  initSession() async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      setState(() => btnAccess = false);
      if (await checkVersion(mounted, context)) {
        body['device_id'] = widget.deviceId;
        debugPrint('device_id: ${widget.deviceId}');
      }
    }
  }
}
