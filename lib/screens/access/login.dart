// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:local_auth/local_auth.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/birth_date.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/main.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/files_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/access/model_update_pwd.dart';
import 'package:muserpol_pvt/screens/modal_enrolled/modal.dart';
import 'package:muserpol_pvt/screens/navigator_bar.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenLogin extends StatefulWidget {
  final bool stateOfficeVirtual;
  final String deviceId;
  const ScreenLogin(
      {super.key, required this.stateOfficeVirtual, required this.deviceId});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  TextEditingController dniCtrl = TextEditingController();
  TextEditingController dniComCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

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

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    verifyBiometric();
  }

  // Función para verificar si se debe realizar autenticación biométrica
  Future<void> verifyBiometric() async {
    // Obtenemos el AuthService a través del Provider sin escuchar cambios
    final authService = Provider.of<AuthService>(context, listen: false);

    // Leemos los datos biométricos guardados (probablemente desde SharedPreferences o almacenamiento local)
    final biometricJson = await authService.readBiometric();

    // Verificamos que la cadena JSON no esté vacía
    if (biometricJson.isNotEmpty) {
      // Convertimos el JSON en un modelo de datos (BiometricUserModel)
      final biometricData = biometricUserModelFromJson(biometricJson);

      // Si estamos en el estado "oficina virtual" y el usuario tiene biometría habilitada para ese modo
      if (widget.stateOfficeVirtual &&
          biometricData.biometricVirtualOfficine == true) {
        // Ejecutamos el proceso de autenticación
        _authenticate(biometricData);
      }
      // Si no estamos en oficina virtual y el usuario tiene biometría habilitada para complemento
      else if (!widget.stateOfficeVirtual &&
          biometricData.biometricComplement == true) {
        // Ejecutamos el proceso de autenticación
        _authenticate(biometricData);
      }
    }
  }

// Función para autenticar al usuario con huella digital o reconocimiento facial
  Future<void> _authenticate(BiometricUserModel biometric) async {
    bool authenticated =
        false; // Variable para saber si la autenticación fue exitosa

    try {
      // Mostramos el prompt de autenticación biométrica al usuario
      authenticated = await auth.authenticate(
        localizedReason:
            'MUSERPOL', // Mensaje que aparece en el diálogo biométrico
        authMessages: [
          const AndroidAuthMessages(
            signInTitle:
                'Autenticación Biometrica requerida', // Título del diálogo
            cancelButton: 'No Gracias', // Texto del botón para cancelar
            biometricHint: 'Verificar Identidad', // Hint que aparece en la UI
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth:
              true, // Mantiene la autenticación activa si la app se pausa
          biometricOnly: true, // Solo se permite autenticación por biometría
        ),
      );

      debugPrint('HECHO'); // Si pasa sin errores, imprimimos un log
    } on PlatformException catch (e) {
      // Si ocurre algún error en el proceso (ej: el usuario cancela), lo mostramos
      debugPrint('$e');
      return;
    }

    // Verificamos si el widget sigue montado (útil si la autenticación tomó tiempo y se deshizo el widget)
    if (!mounted) return;

    // Si la autenticación fue exitosa
    if (authenticated) {
      setState(() {
        // Dependiendo del tipo de sesión, rellenamos los campos del formulario con los datos almacenados
        if (widget.stateOfficeVirtual) {
          dniCtrl.text =
              biometric.userVirtualOfficine?.identityCard ?? ''; // Cédula
          passwordCtrl.text =
              biometric.userVirtualOfficine?.password ?? ''; // Contraseña
        } else {
          dniCtrl.text = biometric.userComplement?.identityCard ??
              ''; // Cédula para complemento
          dateCtrlText = biometric.userComplement?.dateBirth ??
              ''; // Fecha de nacimiento para complemento
        }
      });

      // Iniciamos la sesión con los datos llenados automáticamente
      initSession();
    }
  }

  // verifyBiometric() async {
  //   final authService = Provider.of<AuthService>(context, listen: false);

  //   if (await authService.readBiometric() != "") {
  //     if (widget.stateOfficeVirtual) {
  //       if (biometricUserModelFromJson(await authService.readBiometric()).biometricVirtualOfficine!) {
  //         //BIOMETICO OFICINA VIRTUAL
  //         _authenticate();
  //       }
  //     } else {
  //       debugPrint('${biometricUserModelFromJson(await authService.readBiometric()).biometricComplement}');
  //       if (biometricUserModelFromJson(await authService.readBiometric()).biometricComplement!) {
  //         //BIOMETICO COMPLEMENTO
  //         _authenticate();
  //       }
  //     }
  //   }
  // }

  // Future<void> _authenticate() async {
  //   final authService = Provider.of<AuthService>(context, listen: false);
  //   bool authenticated = false;
  //   try {
  //     authenticated = await auth.authenticate(
  //       localizedReason: 'MUSERPOL',
  //       authMessages: [
  //         const AndroidAuthMessages(
  //           signInTitle: 'Autenticación Biometrica requerida',
  //           cancelButton: 'No Gracias',
  //           biometricHint: 'Verificar Identidad',
  //         ),
  //       ],
  //       options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
  //     );
  //     debugPrint('HECHO');
  //   } on PlatformException catch (e) {
  //     debugPrint('$e');
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //   if (authenticated) {
  //     final biometric = biometricUserModelFromJson(await authService.readBiometric());
  //     if (widget.stateOfficeVirtual) {
  //       setState(() {
  //         dniCtrl.text = biometric.userVirtualOfficine!.identityCard!;
  //         passwordCtrl.text = biometric.userVirtualOfficine!.password!;
  //       });
  //     } else {
  //       setState(() {
  //         dniCtrl.text = biometric.userComplement!.identityCard!;
  //         dateCtrlText = biometric.userComplement!.dateBirth!;
  //       });
  //     }
  //     initSession();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    final node = FocusScope.of(context);
    return Form(
        key: formKey,
        child: Column(children: [
          Text(
            widget.stateOfficeVirtual
                ? 'Oficina Virtual'
                : 'Complemento Económico',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.h,
          ),
          if (btnAccess)
            Column(
              children: [
                IdentityCard(
                  title: widget.stateOfficeVirtual
                      ? 'Usuario:'
                      : 'Cédula de identidad:',
                  dniCtrl: dniCtrl,
                  dniComCtrl: dniComCtrl,
                  onEditingComplete: () => node.nextFocus(),
                  textSecondFocusNode: textSecondFocusNode,
                  formatter: widget.stateOfficeVirtual
                      ? FilteringTextInputFormatter.allow(
                          RegExp("[0-9a-zA-Z-]"))
                      : FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                  keyboardType: widget.stateOfficeVirtual
                      ? TextInputType.text
                      : TextInputType.number,
                  stateAlphanumericFalse: () =>
                      setState(() => dniComCtrl.text = ''),
                  stateAlphanumeric: !widget.stateOfficeVirtual,
                ),
                SizedBox(
                  height: 10.h,
                ),
                if (!widget.stateOfficeVirtual)
                  BirthDate(
                    dateState: dateState,
                    currentDate: currentDate,
                    dateCtrl: dateCtrl,
                    selectDate: (date, dateCurrent, dateFormat) => {
                      setState(() {
                        dateCtrl = date;
                        currentDate = dateCurrent;
                        dateCtrlText = dateFormat;
                        dateState = false;
                      })
                    },
                  ),
                if (widget.stateOfficeVirtual)
                  Password(
                      passwordCtrl: passwordCtrl,
                      onEditingComplete: () => initSession()),
                SizedBox(
                  height: 10.h,
                ),
                ButtonComponent(
                    text: 'INGRESAR', onPressed: () => initSession()),
                if (widget.stateOfficeVirtual)
                  ButtonWhiteComponent(
                      text: 'Olvidé mi contraseña',
                      onPressed: () => Navigator.pushNamed(context, 'forgot')),
                ButtonWhiteComponent(
                    text: 'Contactos a nivel nacional',
                    onPressed: () => Navigator.pushNamed(context, 'contacts')),
                ButtonWhiteComponent(
                  text: 'Política de privacidad',
                  onPressed: () => launchUrl(
                      Uri.parse(serviceGetPrivacyPolicy()),
                      mode: LaunchMode.externalApplication),
                ),
                SizedBox(
                  height: 10.h,
                ),
                Center(child: Text('Versión ${dotenv.env['version']}'))
              ],
            ),
          if (!btnAccess)
            Center(
                child: Image.asset(
              'assets/images/load.gif',
              fit: BoxFit.cover,
              height: 20,
            )),
        ]));
  }

  initSession() async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc =
        BlocProvider.of<NotificationBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    FocusScope.of(context).unfocus();
    if (!widget.stateOfficeVirtual) validateDate();
    if (formKey.currentState!.validate()) {
      if (dateCtrlText == null && !widget.stateOfficeVirtual) return;
      setState(() => btnAccess = false);
      if (await checkVersion(mounted, context)) {
        body['device_id'] = widget.deviceId;
        if (dotenv.env['storeAndroid'] == 'appgallery') {
          body['firebase_token'] = '';
        } else {
          body['firebase_token'] =
              await PushNotificationService.getTokenFirebase();
        }
        if (!widget.stateOfficeVirtual) {
          body['identity_card'] =
              '${dniCtrl.text.trim()}${dniComCtrl.text == '' ? '' : '-${dniComCtrl.text.trim()}'}';
          body['birth_date'] = dateCtrlText;
          body['is_new_app'] = true;
          body['is_new_version'] = true;
        } else {
          body['username'] =
              '${dniCtrl.text.trim()}${dniComCtrl.text == '' ? '' : '-${dniComCtrl.text.trim()}'}';
          body['password'] = passwordCtrl.text.trim();
        }
        if (!mounted) return;
        var response = await serviceMethod(
            mounted,
            context,
            'post',
            body,
            widget.stateOfficeVirtual
                ? serviceAuthSessionOF()
                : serviceAuthSession(null),
            false,
            true);
        setState(() => btnAccess = true);
        debugPrint('response $response');
        if (response != null) {
          await DBProvider.db.database;
          if (json.decode(response.body)['data']['status'] != null &&
              json.decode(response.body)['data']['status'] == 'Pendiente') {
            return virtualOfficineUpdatePwd(
                json.decode(response.body)['message']);
          }
          UserModel user = userModelFromJson(
              json.encode(json.decode(response.body)['data']));
          await authService.writeAuxtoken(user.apiToken!);
          tokenState.updateStateAuxToken(true);
          if (!mounted) return;
          await authService.writeUser(context, userModelToJson(user));
          userBloc.add(UpdateUser(user.user!));
          final affiliateModel = AffiliateModel(idAffiliate: user.user!.id!);
          await DBProvider.db.newAffiliateModel(affiliateModel);
          notificationBloc.add(UpdateAffiliateId(user.user!.id!));
          if (widget.stateOfficeVirtual) {
            initSessionVirtualOfficine(
                response,
                UserVirtualOfficine(
                    identityCard: body['username'], password: body['password']),
                user);
          } else {
            intSessionComplement(
                response,
                UserComplement(
                    identityCard: body['identity_card'],
                    dateBirth: body['birth_date']),
                user);
          }
        }
      } else {
        setState(() => btnAccess = true);
      }
    }
  }

  intSessionComplement(
      dynamic response, UserComplement userComplement, UserModel user) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    final biometric = await authService.readBiometric();
    final biometricUserModel = BiometricUserModel(
        biometricComplement: biometric == ''
            ? false
            : biometricUserModelFromJson(biometric).biometricComplement,
        biometricVirtualOfficine: biometric == ''
            ? false
            : biometricUserModelFromJson(biometric).biometricVirtualOfficine,
        affiliateId: user.user!.id,
        userComplement: userComplement,
        userVirtualOfficine: biometric == ''
            ? UserVirtualOfficine()
            : biometricUserModelFromJson(biometric).userVirtualOfficine);
    if (!mounted) return;
    await authService.writeBiometric(
        context, biometricUserModelToJson(biometricUserModel));
    prefs!.setBool('isDoblePerception',
        json.decode(response.body)['data']['is_doble_perception']);
    if (response.statusCode == 200) {
      if (!user.user!.enrolled!) {
        //proceso de enrolamiento
        if (dotenv.env['storeAndroid'] == 'appgallery') {
          _showModalInside(user.apiToken!, false, '');
        } else {
          _showModalInside(user.apiToken!, false,
              await PushNotificationService.getTokenFirebase());
        }
      } else {
        if (!mounted) return;
        await authService.writeStateApp(context, 'complement');
        if (!mounted) return;
        await authService.writeToken(context, user.apiToken!);
        tokenState.updateStateAuxToken(false);
        if (!mounted) return;
        return Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    const NavigatorBar(stateApp: StateAplication.complement),
                transitionDuration: const Duration(seconds: 0)));
      }
    } else {
      if (json.decode(response.body)['data']['update_device_id']) {
        //reconocimiento facial
        if (dotenv.env['storeAndroid'] == 'appgallery') {
          return _showModalInside(user.apiToken!, true, '');
        } else {
          return _showModalInside(user.apiToken!, true,
              await PushNotificationService.getTokenFirebase());
        }
      } else {
        if (!mounted) return;
        return callDialogAction(context, json.decode(response.body)['message']);
      }
    }
  }

  _showModalInside(
      String token, bool facialRecognition, String firebaseToken) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    if (!mounted) return;
    return showBarModalBottomSheet(
      expand: false,
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) => ModalInsideModal(
          firebaseToken: firebaseToken,
          deviceId: widget.deviceId,
          stateFacialRecognition: facialRecognition,
          nextScreen: (message) {
            return showSuccessful(context, message, () async {
              if (!mounted) return;
              await authService.writeStateApp(context, 'complement');
              if (!mounted) return;
              await authService.writeToken(context, token);
              tokenState.updateStateAuxToken(false);
              if (!mounted) return;
              Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const NavigatorBar(
                          stateApp: StateAplication.complement),
                      transitionDuration: const Duration(seconds: 0)));
            });
          }),
    );
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
    await authService.writeStateApp(context, 'virtualofficine');
    if (!mounted) return;
    await authService.writeToken(context, user.apiToken!);
    tokenState.updateStateAuxToken(false);
    if (!mounted) return;
    return Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                const NavigatorBar(stateApp: StateAplication.virtualOficine),
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

  validateDate() {
    if (dateCtrlText == null) return setState(() => dateState = true);
    return setState(() => dateState = false);
  }
}
