import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/screens/access/newlogin.dart';
import 'package:muserpol_pvt/screens/test_login.dart';
import 'package:muserpol_pvt/screens/list_services_menu/list_service.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/swipe/slider.dart';
import 'package:provider/provider.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Widget que verifica que auth este con datos para redirigirlo
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              print('🔄 CheckAuthScreen: Cargando token...');
              return const CircularProgressIndicator();
            }

            final token = snapshot.data ?? '';
            print(
                '🔍 CheckAuthScreen: Token leído: "${token.isEmpty ? 'VACÍO' : 'EXISTE'}"');

            if (token == '') {
              //Primer Ingreso de la aplicacion
              print('➡️ CheckAuthScreen: No hay token, yendo a goFirstInto()');
              Future.microtask(() {
                return goFirstInto(context);
              });
            } else {
              //lo redirijira al menu de servicios cargando todos los datos de la app
              //del usuario del afiliado
              print('➡️ CheckAuthScreen: Token existe, yendo a getInfo()');
              Future.microtask(() {
                return getInfo(context);
              });
            }
            //En caso de errores se cargara una pantalla vacia (Opcional)
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Iniciando aplicación...'),
                  ],
                ),
              ),
            ); // pantalla temporal con loading
          },
        ),
      ),
    );
  }

  /// Decide si mostrar el slider introductorio o ir directo al login
  goFirstInto(BuildContext context) async {
    print('🚀 goFirstInto: Iniciando...');
    final authService = Provider.of<AuthService>(context, listen: false);

    // MODO DE PRUEBA: Siempre ir al TestLoginScreen
    // Comentar las siguientes líneas y descomentar las de abajo para volver al flujo normal
    print(
        '🧪 goFirstInto: MODO DE PRUEBA - Yendo directamente a TestLoginScreen');
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const TestLoginScreen(),
        transitionDuration: const Duration(seconds: 0),
      ),
    );

    /* FLUJO NORMAL (comentado para pruebas):
    if (await authService.readFirstTime() == '') {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PageSlider(),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    } else {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const TestLoginScreen(),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    }
    */
  }

  /// Carga info del usuario y pasa a la app si está autenticado
  getInfo(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final notificationBloc = BlocProvider.of<NotificationBloc>(context);

    final userJson = await authService.readUser();
    if (userJson == '') {
      if (!context.mounted) return;
      return Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          // MODO DE PRUEBA: Ir al TestLoginScreen
          pageBuilder: (_, __, ___) => const TestLoginScreen(),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    }

    await getNotifications(notificationBloc);
    UserModel user = userModelFromJson(userJson);
    userBloc.add(UpdateUser(user.user!));

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const ScreenListService(showTutorial: false),
        transitionDuration: const Duration(seconds: 0),
      ),
    );
  }

  /// Carga las notificaciones y el ID del afiliado
  getNotifications(NotificationBloc notificationBloc) async {
    final notifications = await DBProvider.db.getAllNotificationModel();
    notificationBloc.add(UpdateNotifications(notifications));

    final affiliates = await DBProvider.db.getAllAffiliateModel();
    if (affiliates.isNotEmpty) {
      notificationBloc.add(UpdateAffiliateId(affiliates[0].idAffiliate));
    }
  }
}
