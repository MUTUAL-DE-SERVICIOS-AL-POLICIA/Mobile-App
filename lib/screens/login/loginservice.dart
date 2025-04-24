import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
// import 'package:muserpol_pvt/model/files_model.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/login/newpage.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

class LoginService {
  static Future<void> iniciarSesion({
    required BuildContext context,
    required String deviceId,
    required String identityCard,
    String? password,
    String? birthDate,
    required bool isOfficeVirtual,
  }) async {
    try {
      final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
      final notificationBloc =
          BlocProvider.of<NotificationBloc>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final tokenState = Provider.of<TokenState>(context, listen: false);

      final Map<String, dynamic> body = {
        'device_id': deviceId,
        'firebase_token': dotenv.env['storeAndroid'] == 'appgallery'
            ? ''
            : await PushNotificationService.getTokenFirebase(),
      };

      if (isOfficeVirtual) {
        body['username'] = identityCard;
        body['password'] = password;
      } else {
        body['identity_card'] = identityCard;
        body['birth_date'] = birthDate;
        body['is_new_app'] = true;
        body['is_new_version'] = true;
      }

      final response = await serviceMethod(
        true,
        context,
        'post',
        body,
        isOfficeVirtual ? serviceAuthSessionOF() : serviceAuthSession(null),
        false,
        true,
      );

      if (response == null) return;

      final data = json.decode(response.body)['data'];

      if (data['user'] == null) {
        throw Exception('No se encontró información del usuario.');
      }

      final user = UserModel(
        apiToken: data['api_token'],
        user: User.fromJson(data['user']),
      );

      // Guardar token auxiliar y estado
      await authService.writeAuxtoken(user.apiToken!);
      tokenState.updateStateAuxToken(true);
      await authService.writeUser(context, userModelToJson(user));
      userBloc.add(UpdateUser(user.user!));
      notificationBloc.add(UpdateAffiliateId(user.user!.id!));

      // Guardar afiliado local
      final affiliateModel = AffiliateModel(idAffiliate: user.user!.id!);
      await DBProvider.db.newAffiliateModel(affiliateModel);

      // Guardar en biometría
      final previousBiometric = await authService.readBiometric();
      final biometricParsed = previousBiometric.isNotEmpty
          ? biometricUserModelFromJson(previousBiometric)
          : null;

      final newBiometric = BiometricUserModel(
        biometricVirtualOfficine:
            biometricParsed?.biometricVirtualOfficine ?? false,
        biometricComplement: biometricParsed?.biometricComplement ?? false,
        affiliateId: user.user!.id!,
        userComplement: !isOfficeVirtual
            ? UserComplement(
                identityCard: identityCard,
                dateBirth: birthDate ?? '',
              )
            : biometricParsed?.userComplement ?? UserComplement(),
        userVirtualOfficine: isOfficeVirtual
            ? UserVirtualOfficine(
                identityCard: identityCard,
                password: password ?? '',
              )
            : biometricParsed?.userVirtualOfficine ?? UserVirtualOfficine(),
      );

      await authService.writeBiometric(
          context, biometricUserModelToJson(newBiometric));

      // Guardar estado de app
      await authService.writeStateApp(
          context, isOfficeVirtual ? 'virtualofficine' : 'complement');
      await authService.writeToken(context, user.apiToken!);
      tokenState.updateStateAuxToken(false);

      // Redirigir a pantalla final (por ahora "Hola")
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const ScreenHomeHola()),
      // );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ScreenHomeHola(),
        ),
      );
    } catch (e) {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    }
  }
}
