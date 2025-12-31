import 'dart:convert';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/database/db_provider.dart';
import 'package:muserpol_pvt/model/register_number/files_state_veritify.dart';
import 'package:muserpol_pvt/provider/files_state.dart';
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

Future<void> main() async {
  // 1) Carga .env y binding
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  // 2) Tema y prefs
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  prefs = await SharedPreferences.getInstance();

  // 3) Inicializa Firebase una sola vez aquí
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 4) 🔥 REGISTRA EL HANDLER DE BACKGROUND **ANTES** de cualquier uso de messaging
  //    Este handler debe ser top-level con @pragma('vm:entry-point') en push_notifications.dart
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 5) Inicializa tu servicio de notificaciones (con await)
  await PushNotificationService.initializeapp(); // ✅ AÑADE await

  // 6) Overrides opcionales
  HttpOverrides.global = MyHttpOverrides();

  // 7) Arranca la app
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
          ChangeNotifierProvider(create: (_) => FilesStateVeritify()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => Muserpol(savedThemeMode: savedThemeMode),
        ),
      ),
    );
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Foreground / cuando abren la app desde la notificación
    PushNotificationService.messagesStream.listen((message) {
      debugPrint('NO TI FI CA CION $message');
      final msg = json.decode(message);
      if (msg['origin'] == '_onMessageHandler') {
        _updatebd();
      } else {
        navigatorKey.currentState!.pushNamed('message', arguments: msg);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updatebd();
  }

  void _updatebd() {
    Future.delayed(Duration.zero, () {
      final notificationBloc = BlocProvider.of<NotificationBloc>(context);
      DBProvider.db.getAllNotificationModel().then(
            (res) => notificationBloc.add(UpdateNotifications(res)),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Locale('es', 'ES'),
          Locale('en', 'US'),
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
        },
      ),
    );
  }
}
