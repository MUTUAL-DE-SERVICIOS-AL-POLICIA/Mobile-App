// Librerías necesarias
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/provider/files_state.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Método principal para realizar llamadas HTTP genéricas (GET, POST, DELETE, PATCH)
Future<dynamic> serviceMethod(
  bool mounted,
  BuildContext context,
  String method,
  Map<String, dynamic>? body,
  String urlAPI,
  bool accessToken,
  bool errorState,
) async {
  // Headers básicos
  final Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  // Si requiere token, lo añade al header (token normal o auxiliar)
  if (accessToken) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final tokenState = Provider.of<TokenState>(context, listen: false);
    headers["Authorization"] =
        "Bearer ${tokenState.stateAuxToken ? await authService.readAuxToken() : await authService.readToken()}";
  }

  try {
    // Verifica si hay conexión a internet
    // final result = await InternetAddress.lookup(
    //     dotenv.env['STATE_PROD'] == 'true'
    //         ? 'pvt.muserpol.gob.bo'
    //         : 'google.com');
    final result = await InternetAddress.lookup('google.com');

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      var url = Uri.parse(urlAPI);

      // Cliente HTTP que ignora certificados inválidos (útil en desarrollo)
      final ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      // Logs útiles para debug
      debugPrint('==========================================');
      debugPrint('== method $method');
      debugPrint('== url $url');
      debugPrint('== body $body');
      debugPrint('== headers $headers');
      debugPrint('==========================================');

      // Selección del método HTTP
      switch (method) {
        case 'get':
          return await http
              .get(url, headers: headers)
              .timeout(const Duration(seconds: 40))
              .then((value) {
            debugPrint('statusCode ${value.statusCode}');
            debugPrint('value ${value.body}');
            switch (value.statusCode) {
              case 200:
                return value;
              default:
                if (errorState) {
                  return confirmDeleteSession(mounted, context, false);
                }
                return null;
            }
          }).catchError((err) {
            // Manejo de errores de red
            debugPrint('errA $err');
            if ('$err'.contains('html')) {
              callDialogAction(context,
                  'Tenemos un problema con nuestro servidor, intente luego');
            } else if ('$err'.contains('connection')) {
              callDialogAction(context, 'Verifique su conexión a Internet1');
            } else {
              callDialogAction(
                  context, 'Lamentamos los inconvenientes, inténtalo de nuevo');
            }
            return null;
          });

        case 'post':
          return await http
              .post(url, headers: headers, body: json.encode(body))
              .timeout(const Duration(seconds: 40))
              .then((value) {
            debugPrint('statusCode ${value.statusCode}');
            debugPrint('value ${value.body}');
            switch (value.statusCode) {
              case 200:
              case 201:
                return value;
              default:
                callDialogAction(context, json.decode(value.body)['message']);
                return null;
            }
          }).catchError((err) {
            debugPrint('errA $err');
            callDialogAction(context, 'Error al conectar con el servidor');
            return null;
          });

        case 'delete':
          return await http
              .delete(url, headers: headers)
              .timeout(const Duration(seconds: 40))
              .then((value) {
            debugPrint('statusCode ${value.statusCode}');
            debugPrint('value ${value.body}');
            switch (value.statusCode) {
              case 200:
                return value;
              default:
                callDialogAction(context, json.decode(value.body)['message']);
                return null;
            }
          }).catchError((err) {
            debugPrint('errA $err');
            callDialogAction(context, 'Error de red');
            return null;
          });

        case 'patch':
          return await http
              .patch(url, headers: headers, body: json.encode(body))
              .timeout(const Duration(seconds: 60))
              .then((value) {
            debugPrint('statusCode ${value.statusCode}');
            debugPrint('value ${value.body}');
            switch (value.statusCode) {
              case 200:
                return value;
              default:
                callDialogAction(context, json.decode(value.body)['message']);
                return null;
            }
          }).catchError((err) {
            debugPrint('errA $err');
            callDialogAction(context, 'Error al actualizar');
            return null;
          });
      }
    }
  } on TimeoutException catch (e) {
    debugPrint('errB $e');
    if (!mounted) return;
    return callDialogAction(
        context, 'Tenemos un problema con nuestro servidor, intente luego');
  } on SocketException catch (e) {
    debugPrint('errC $e');
    if (!mounted) return;
    return callDialogAction(context, 'Verifique su conexión a Internet2');
  } on ClientException catch (e) {
    debugPrint('errD $e');
    if (!mounted) return;
    return callDialogAction(context, 'Verifique su conexión a Internet3');
  } on MissingPluginException catch (e) {
    debugPrint('errF $e');
    if (!mounted) return;
    return callDialogAction(context, 'Verifique su conexión a Internet4');
  } catch (e) {
    debugPrint('errG $e');
    if (!mounted) return;
    callDialogAction(context, '$e');
  }
}

// Muestra un cuadro de diálogo con mensaje de error
void callDialogAction(BuildContext context, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => DialogAction(message: message),
  );
}

/// Cierra la sesión del usuario, limpia estados, tokens, y redirige al inicio
confirmDeleteSession(bool mounted, BuildContext context, bool voluntary) async {
  final procedureBloc = BlocProvider.of<ProcedureBloc>(context, listen: false);
  final authService = Provider.of<AuthService>(context, listen: false);
  final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
  final contributionBloc =
      BlocProvider.of<ContributionBloc>(context, listen: false);
  final loanBloc = BlocProvider.of<LoanBloc>(context, listen: false);
  final filesState = Provider.of<FilesState>(context, listen: false);
  final tabProcedureState =
      Provider.of<TabProcedureState>(context, listen: false);
  final processingState = Provider.of<ProcessingState>(context, listen: false);

  if (voluntary) {
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());
    if (!mounted) return;
    await serviceMethod(
      mounted,
      context,
      'delete',
      null,
      serviceAuthSession(biometric.affiliateId!),
      true,
      false,
    );
  }

  // Limpia archivos temporales
  for (var element in filesState.files) {
    filesState.updateFile(element.id!, null);
  }

  // Resetea estados
  userBloc.add(UpdateCtrlLive(false));
  await PushNotificationService.closeStreams();
  authService.logout();
  contributionBloc.add(ClearContributions());
  loanBloc.add(ClearLoans());
  procedureBloc.add(ClearProcedures());
  tabProcedureState.updateTabProcedure(0);
  processingState.updateStateProcessing(false);

  // Navega al inicio
  if (!mounted) return;
  Navigator.pushReplacementNamed(context, 'switch');
}

/// Verifica si hay una nueva versión de la app disponible y sugiere actualizar
Future<bool> checkVersion(bool mounted, BuildContext context) async {
  try {
    // final result = await InternetAddress.lookup(
    //     dotenv.env['STATE_PROD'] == 'true'
    //         ? 'pvt.muserpol.gob.bo'
    //         : 'google.com');

    final result = await InternetAddress.lookup('google.com');

    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      // Prepara datos para el backend
      final Map<String, dynamic> data = {'version': dotenv.env['version']};
      if (Platform.isIOS) data['store'] = dotenv.env['storeIOS'];
      if (Platform.isAndroid) data['store'] = dotenv.env['storeAndroid'];

      if (!mounted) return false;

      var response = await serviceMethod(
        mounted,
        context,
        'post',
        data,
        servicePostVersion(),
        false,
        false,
      );

      if (response != null && !json.decode(response.body)['error']) {
        // Si hay nueva versión, muestra diálogo con botón para actualizar
        if (!mounted) return false;
        return await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => ComponentAnimate(
            child: DialogOneFunction(
              title: json.decode(response.body)['message'],
              message:
                  'Para mejorar la experiencia, Por favor actualiza la nueva versión',
              textButton: 'Actualizar',
              onPressed: () async {
                launchUrl(
                  Uri.parse(json.decode(response.body)['data']['url_store']),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
          ),
        );
      }
      return true;
    } else {
      return false;
    }
  } on SocketException catch (e) {
    debugPrint('errC $e');
    callDialogAction(context, 'Verifique su conexión a Internet5');
    return false;
  } catch (e) {
    debugPrint('errG $e');
    callDialogAction(context, '$e');
    return false;
  }
}
