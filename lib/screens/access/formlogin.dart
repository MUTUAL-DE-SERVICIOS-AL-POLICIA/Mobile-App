import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/card_login.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';
import 'package:local_auth/local_auth.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
// import 'package:local_auth_android/local_auth_android.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/access/model_update_pwd.dart';
import 'package:muserpol_pvt/screens/list_service.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:muserpol_pvt/model/user_model.dart';

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
                ButtonComponent(
                    text: 'INGRESAR', onPressed: () => initSession()),
                SizedBox(
                  height: 20.h,
                ),
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
    ))));
  }

  initSession() async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (await checkVersion(mounted, context)) {
      body['device_id'] = widget.deviceId;
      await authService.writeDeviceId(widget.deviceId);
      if (dotenv.env['storeAndroid'] == 'appgallery') {
        body['firebase_token'] = '';
      } else {
        body['firebase_token'] =
            await PushNotificationService.getTokenFirebase();
      }
      body['username'] =
          '${dniCtrl.text.trim()}${dniComCtrl.text == '' ? '' : '-${dniComCtrl.text.trim()}'}';
      body['password'] = passwordCtrl.text.trim();
      if (!mounted) return;

      var response = await serviceMethod(
          mounted, context, 'post', body, serviceAuthSessionOF(), false, true);
      setState(() => btnAccess = true);
      debugPrint('response $response');
      if (response != null) {
        await DBProvider.db.database;
        if (json.decode(response.body)['data']['status'] != null &&
            json.decode(response.body)['data']['status'] == 'Pendiente') {
          return virtualOfficineUpdatePwd(
              json.decode(response.body)['message']);
        }
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

        initSessionVirtualOfficine(
            response,
            UserVirtualOfficine(
                identityCard: body['username'], password: body['password']),
            user);
      }
    }
  }

  initSessionVirtualOfficine(dynamic response,
      UserVirtualOfficine userVirtualOfficine, UserModel user) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    tokenState.updateStateAuxToken(false);
    final biometric = await authService.readBiometric();
    final biometricUserModel = BiometricUserModel(
        biometricVirtualOfficine: biometric == ''
            ? false
            : biometricUserModelFromJson(biometric).biometricVirtualOfficine,
        biometricComplement: biometric == ''
            ? false
            : biometricUserModelFromJson(biometric).biometricComplement,
        affiliateId: json.decode(response.body)['data']['user']['id'],
        userComplement: biometric == ''
            ? UserComplement()
            : biometricUserModelFromJson(biometric).userComplement,
        userVirtualOfficine: userVirtualOfficine);
    if (!mounted) return;
    await authService.writeBiometric(
        context, biometricUserModelToJson(biometricUserModel));
    if (!mounted) return;
    await authService.writeStateApp(context, 'list_services');
    if (!mounted) return;
    await authService.writeToken(context, user.apiToken!);
    tokenState.updateStateAuxToken(false);
    if (!mounted) return;
    return Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ScreenListService(),
            transitionDuration: const Duration(seconds: 0)));
  }

  virtualOfficineUpdatePwd(String message) {
    return showBarModalBottomSheet(
      expand: false,
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) => ModalUpdatePwd(
          message: message,
          stateLoading: btnAccess,
          onPressed: (password) async {
            setState(() => btnAccess = false);
            body['new_password'] = password;
            var response = await serviceMethod(mounted, context, 'patch', body,
                serviceChangePasswordOF(), false, true);

            setState(() => btnAccess = true);
            if (response != null) {
              if (!mounted) return;
              return showSuccessful(
                  context, json.decode(response.body)['message'], () {
                debugPrint('res ${response.body}');
                setState(() => passwordCtrl.text = '');
                Navigator.of(context).pop();
              });
            }
          }),
    );
  }
}
