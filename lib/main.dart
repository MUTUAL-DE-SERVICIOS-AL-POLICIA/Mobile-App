import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/register_number/files_state_veritify.dart';
import 'package:muserpol_pvt/provider/files_state.dart';
// import 'package:muserpol_pvt/screens/access/forgot_password/forgot_pwd.dart';
import 'package:muserpol_pvt/screens/access/newlogin.dart';
import 'package:muserpol_pvt/screens/inbox/notification.dart';
import 'package:muserpol_pvt/services/push_notifications.dart';
import 'package:muserpol_pvt/swipe/slider.dart';
import 'package:muserpol_pvt/utils/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc/notification/notification_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/check_auth_screen.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'bloc/procedure/procedure_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'provider/app_state.dart';
import 'screens/contacts/screen_contact.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

SharedPreferences? prefs;
void main() async {
  //carga las variales de entorno
  await dotenv.load(fileName: ".env");
  //recupera tema guardado oscuro o claro
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  //variable global que guardara los estados si tiene doble percepcion
  prefs = await SharedPreferences.getInstance();
  //inicializa firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //inicializa las notificaciones
  PushNotificationService.initializeapp();
  HttpOverrides.global = MyHttpOverrides();
  //Arranca la app
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Proporciona múltiples BLoCs a toda la app (gestión del estado por eventos).
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => UserBloc()),
          BlocProvider(create: (_) => ProcedureBloc()),
          BlocProvider(create: (_) => NotificationBloc()),
          BlocProvider(create: (_) => ContributionBloc()),
          BlocProvider(create: (_) => LoanBloc()),
        ],
        child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthService()),
              ChangeNotifierProvider(create: (_) => LoadingState()),
              ChangeNotifierProvider(create: (_) => TokenState()),
              ChangeNotifierProvider(create: (_) => FilesState()),
              ChangeNotifierProvider(create: (_) => ObservationState()),
              ChangeNotifierProvider(create: (_) => TabProcedureState()),
              ChangeNotifierProvider(create: (_) => ProcessingState()),
              ChangeNotifierProvider(create: (_) => FilesStateVeritify())
            ],
            // Inicializa utilidades para diseño adaptable en distintos tamaños de pantalla
            child: ScreenUtilInit(
                designSize: const Size(360, 690),
                minTextAdapt: true,
                splitScreenMode: true,
                // Carga el widget principal de la app: 'Muserpol'
                builder: (context, child) =>
                    Muserpol(savedThemeMode: savedThemeMode))));
  }
}

class Muserpol extends StatefulWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const Muserpol({super.key, this.savedThemeMode});

  @override
  State<Muserpol> createState() => _MuserpolState();
}

class _MuserpolState extends State<Muserpol> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updatebd();
    }
  }

  @override
  void initState() {
    //en el void initState siempre se colocan las funciones que funcionen primero
    WidgetsBinding.instance.addObserver(this);
    PushNotificationService.messagesStream.listen((message) {
      debugPrint('NO TI FI CA CION $message');
      final msg = json.decode(message);
      if (msg['origin'] == '_onMessageHandler') {
        _updatebd();
      } else {
        navigatorKey.currentState!.pushNamed('message', arguments: msg);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    //funciones para liberar la memoria
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _updatebd() {
    //actualiza la base de datos interna. (NOTIFICACIONES)
    Future.delayed(Duration.zero, () {
      final notificationBloc = BlocProvider.of<NotificationBloc>(context);
      DBProvider.db
          .getAllNotificationModel()
          .then((res) => notificationBloc.add(UpdateNotifications(res)));
    });
  }

  @override
  Widget build(BuildContext context) {
    //Contruccion del Widgets
    //Define el tema a la aplicacion
    //La ruta de inicio de la aplicacion
    //Siempre iniciara en "check_auth" -> Ruta que verifica si inicio la sesion para redirigirlo a la pagina correcta
    //las otras rutas son abiertas dentro de la interfaz que puede navegarse sin estar autenticado
    return AdaptiveTheme(
        light: styleLigth(),
        dark: styleDark(),
        debugShowFloatingThemeButton: true,
        initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
        builder: (theme, darkTheme) => MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'), // Spanish
              Locale('en', 'US'), // English
            ],
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: theme,
            darkTheme: darkTheme,
            title: 'MUSERPOL PVT',
            initialRoute: 'check_auth',
            routes: {
              'check_auth': (_) => const CheckAuthScreen(),
              'slider': (_) => const PageSlider(),
              'newlogin': (_) => const ScreenNewLogin(),
              'contacts': (_) => const ScreenContact(),
              'message': (_) => const ScreenNotification(),
            }));
  }
}
