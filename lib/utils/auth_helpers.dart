import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/main.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/list_services_menu/list_service.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:provider/provider.dart';

class AuthHelpers {
  static Future<void> initSessionUserApp({
    required BuildContext context,
    required dynamic response,
    required UserAppMobile userApp,
    required UserModel user,
  }) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);

    final biometric = await authService.readBiometric();
    tokenState.updateStateAuxToken(false);

    final biometricUserModel = BiometricUserModel(
      biometricUser: biometric == ''
          ? false
          : biometricUserModelFromJson(biometric).biometricUser,
      affiliateId: json.decode(response.body)['data']['information']
          ['affiliateId'],
      userAppMobile: userApp,
    );
    prefs!.setBool('isDoblePerception',
        json.decode(response.body)['data']['information']['isDoblePerception']);
    await authService.writeBiometric(
        context, biometricUserModelToJson(biometricUserModel));

    await authService.writeToken(context, user.apiToken!);
    tokenState.updateStateAuxToken(false);

    showSuccessful(
      context,
      'Correcto, Autenticacion Exitosa',
      () {
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

  // Mostrar error con SnackBar
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Generar code verifier para Ciudadanía Digital
  static String generateCodeVerifier([int length = 64]) {
    final random = Random.secure();
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  static String generateCodeChallenge(String codeVerifier) {
    final bytes = ascii.encode(codeVerifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  static void callDialogAction(BuildContext context, String message) {
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
                Text(
                  message,
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


  static void callDialogActionErrorLogin(BuildContext context, String message) {
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
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ButtonComponent(
                  text: 'CERRAR',
                  onPressed: () {
                    Navigator.pushNamed(context, 'newlogin');
                  },
                )
              ],
            ),
          );
        });
  }
}
