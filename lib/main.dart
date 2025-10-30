import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/notification/notification_bloc.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/provider/files_state.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/screens/test_login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Intentar cargar el archivo .env
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Si falla, usar valores por defecto
    print('No se pudo cargar .env, usando valores por defecto: $e');
    dotenv.testLoad(fileInput: '''
STATE_PROD=false
HOST_STI_DEV=https://test-api.muserpol.gob.bo
HOST_STI_PROD=https://api.muserpol.gob.bo
HOST_GATEWAY_DEV=http://192.168.1.201:3000/api
HOST_GATEWAY_PROD=http://192.168.1.201:3000/api
auth=auth
reazonAffiliate=reazonAffiliate
reazonMovil=reazonMovil
version=4.0.1
storeAndroid=playstore
''');
  }
  
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => TokenState()),
            ChangeNotifierProvider(create: (context) => ObservationState()),
            ChangeNotifierProvider(create: (context) => TabProcedureState()),
            ChangeNotifierProvider(create: (context) => ProcessingState()),
            ChangeNotifierProvider(create: (context) => LoadingState()),
            ChangeNotifierProvider(create: (context) => FilesState()),
            ChangeNotifierProvider(create: (context) => AuthService()),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => UserBloc()),
              BlocProvider(create: (context) => LoanBloc()),
              BlocProvider(create: (context) => ContributionBloc()),
              BlocProvider(create: (context) => NotificationBloc()),
              BlocProvider(create: (context) => ProcedureBloc()),
            ],
            child: AdaptiveTheme(
              light: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.teal,
                primaryColor: const Color(0xff419388),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              dark: ThemeData(
                brightness: Brightness.dark,
                primarySwatch: Colors.teal,
                primaryColor: const Color(0xff419388),
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              initial: AdaptiveThemeMode.light,
              builder: (theme, darkTheme) => MaterialApp(
                title: 'MUSERPOL Test',
                debugShowCheckedModeBanner: false,
                theme: theme,
                darkTheme: darkTheme,
                home: const TestLoginScreen(),
              ),
            ),
          ),
        );
      },
    );
  }
}