// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
// import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
// import 'package:muserpol_pvt/database/db_provider.dart';
// import 'package:muserpol_pvt/model/user_model.dart';
// import 'package:muserpol_pvt/screens/access/newlogin.dart';
// import 'package:muserpol_pvt/screens/list_service.dart';
// import 'package:muserpol_pvt/screens/navigator_bar.dart';
// // import 'package:muserpol_pvt/screens/switch.dart';
// import 'package:muserpol_pvt/services/auth_service.dart';
// import 'package:muserpol_pvt/swipe/slider.dart';
// import 'package:provider/provider.dart';

// import 'model/files_model.dart';

// //WIDGET: verifica la autenticación del usuario
// class CheckAuthScreen extends StatelessWidget {
//   const CheckAuthScreen({super.key});
//   @override
//   Widget build(BuildContext context) {
//     //llamamos a los proveedores de estados
//     final authService = Provider.of<AuthService>(context, listen: false);
//     return Scaffold(
//       body: Center(
//         child: FutureBuilder(
//           //verificamos si el usuario está autenticado
//           future: authService.readToken(),
//           builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//             if (!snapshot.hasData) return const Text('');
//             if (snapshot.data == '') {
//               Future.microtask(() {
//                 return goFirstInto(context);
//               });
//             } else {
//               Future.microtask(() {
//                 return getInfo(context);
//               });
//             }
//             return const Scaffold();
//           },
//         ),
//       ),
//     );
//   }

//   goFirstInto(BuildContext context) async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     if (await authService.readFirstTime() == '') {
//       if (!context.mounted) return;
//       Future.microtask(() {
//         Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//                 pageBuilder: (_, __, ___) => const PageSlider(),
//                 transitionDuration: const Duration(seconds: 0)));
//       });
//     } else {
//       if (!context.mounted) return;
//       Future.microtask(() {
//         // Navigator.pushReplacement(
//         //     context,
//         //     PageRouteBuilder(
//         //         pageBuilder: (_, __, ___) => const ScreenSwitch(),
//         //         transitionDuration: const Duration(seconds: 0)));

//         Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//                 pageBuilder: (_, __, ___) => const ScreenNewLogin(),
//                 transitionDuration: const Duration(seconds: 0)));
//       });
//     }
//   }

//   getInfo(BuildContext context) async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     final userBloc = BlocProvider.of<UserBloc>(context, listen: false);

//     final notificationBloc = BlocProvider.of<NotificationBloc>(context);
//     if (await authService.readUser() == '') {
//       debugPrint('no hay usuario');
//       return Future.microtask(() {
//         // Navigator.pushReplacement(
//         //     context,
//         //     PageRouteBuilder(
//         //         pageBuilder: (_, __, ___) => const ScreenSwitch(),
//         //         transitionDuration: const Duration(seconds: 0)));

//         Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//                 pageBuilder: (_, __, ___) => const ScreenNewLogin(),
//                 transitionDuration: const Duration(seconds: 0)));
//       });
//     }

//     await getNotifications(notificationBloc);
//     UserModel user = userModelFromJson(await authService.readUser());
//     userBloc.add(UpdateUser(user.user!));
//     final stateApp = await authService.readStateApp();
//     debugPrint(stateApp);
//     //dependiendo el estado inicia la pantalla despues de actualizar o eliminar
//     Future.microtask(() {
//       if (stateApp == 'list_services') {
//         Navigator.pushReplacement(
//           context,
//           PageRouteBuilder(
//             pageBuilder: (_, __, ___) => const ScreenListService(),
//             transitionDuration: const Duration(seconds: 0),
//           ),
//         );
//       } else {
//         Navigator.pushReplacement(
//             context,
//             PageRouteBuilder(
//                 pageBuilder: (_, __, ___) => NavigatorBar(
//                     tutorial: false,
//                     stateApp: stateApp == 'complement'
//                         ? StateAplication.complement
//                         : StateAplication.virtualOficine),
//                 transitionDuration: const Duration(seconds: 0)));
//       }
//     });
//   }

//   getNotifications(NotificationBloc notificationBloc) async {
//     await DBProvider.db
//         .getAllNotificationModel()
//         .then((res) => notificationBloc.add(UpdateNotifications(res)));
//     await DBProvider.db.getAllAffiliateModel().then(
//         (res) => notificationBloc.add(UpdateAffiliateId(res[0].idAffiliate)));
//   }
// }

//Se esta eliminando la logica del auth y estado para cuando se actualiza la pantalla

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/user_model.dart';
import 'package:muserpol_pvt/screens/access/newlogin.dart';
import 'package:muserpol_pvt/screens/list_services_menu/list_service.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/swipe/slider.dart';
import 'package:provider/provider.dart';

class CheckAuthScreen extends StatelessWidget {
  const CheckAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authService.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) return const Text('');
            if (snapshot.data == '') {
              Future.microtask(() {
                return goFirstInto(context);
              });
            } else {
              Future.microtask(() {
                return getInfo(context);
              });
            }
            return const Scaffold(); // pantalla temporal vacía
          },
        ),
      ),
    );
  }

  /// Decide si mostrar el slider introductorio o ir directo al login
  goFirstInto(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
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
          pageBuilder: (_, __, ___) => const ScreenNewLogin(),
          transitionDuration: const Duration(seconds: 0),
        ),
      );
    }
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
          pageBuilder: (_, __, ___) => const ScreenNewLogin(),
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
