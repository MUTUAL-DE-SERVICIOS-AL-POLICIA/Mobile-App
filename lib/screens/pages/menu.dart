import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/section_title.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  bool colorValue = false;
  bool biometricValue = false;
  bool stateLoading = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (AdaptiveTheme.of(context).mode.isDark) {
        setState(() => colorValue = true);
      }
    });

    verifyBiometric();
  }

  verifyBiometric() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 50), () {});
    if (await authService.readBiometric() != "") {
      final biometric = await authService.readBiometric();

      setState(() => biometricValue =
          biometricUserModelFromJson(biometric).biometricUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(biometricValue.toString());
    final userBloc =
        BlocProvider.of<UserBloc>(context, listen: true).state.user;
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
        child: Column(
          children: [
            Image(
              image: AssetImage(
                AdaptiveTheme.of(context).mode.isDark
                    ? 'assets/images/muserpol-logo.png'
                    : 'assets/images/muserpol-logo2.png',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('Mis datos',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Column(
                      children: [
                        IconName(
                            icon: Icons.person_outline,
                            text: userBloc!.fullName!),
                        IconName(
                            icon: Icons.person_outline,
                            text: userBloc.kinship!),
                        if (userBloc.degree != null)
                          IconName(
                              icon: Icons.local_police_outlined,
                              text: 'GRADO: ${userBloc.degree!}'),
                        IconName(
                            icon: Icons.contact_page_outlined,
                            text: 'C.I.: ${userBloc.identityCard!}'),
                        if (userBloc.category != null)
                          IconName(
                              icon: Icons.av_timer,
                              text: 'CATEGORÍA: ${userBloc.category!}'),
                        if (userBloc.pensionEntity != null)
                          IconName(
                              icon: Icons.account_balance,
                              text: 'GESTORA: ${userBloc.pensionEntity!}'),
                      ],
                    ),
                    Divider(height: 0.03.sh),
                    const Text('Configuración de preferencias',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SectiontitleSwitchComponent(
                      title: 'Tema Oscuro',
                      valueSwitch: colorValue,
                      onChangedSwitch: (v) => switchTheme(v),
                    ),

                    SectiontitleSwitchComponent(
                      title: 'Autenticación Biométrica',
                      valueSwitch: biometricValue,
                      onChangedSwitch: (v) => authBiometric(v),
                    ),

                    Divider(height: 0.03.sh),
                    const Text('Configuración general',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SectiontitleComponent(
                      title: 'Contactos a nivel nacional',
                      icon: Icons.contact_phone_rounded,
                      onTap: () => Navigator.pushNamed(context, 'contacts'),
                    ),
                    SectiontitleComponent(
                      title: 'Políticas de Privacidad',
                      icon: Icons.privacy_tip,
                      stateLoading: stateLoading,
                      onTap: () => launchUrl(
                        Uri.parse(serviceGetPrivacyPolicy()),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    SectiontitleComponent(
                      title: 'Cerrar Sesión',
                      icon: Icons.logout,
                      onTap: () => closeSession(context),
                    ),
                    Center(
                      child: Text('Versión ${dotenv.env['version']}'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void switchTheme(bool state) {
    setState(() => colorValue = state);
    if (state) {
      AdaptiveTheme.of(context).setDark();
    } else {
      AdaptiveTheme.of(context).setLight();
    }
  }

  void authBiometric(bool state) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    setState(() => biometricValue = state);

    if (state) {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      debugPrint('puede $canAuthenticate');

      final List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();
      debugPrint('availableBiometric $availableBiometrics');

      if (availableBiometrics.isNotEmpty) {
        debugPrint("Algunos datos biometricos estan inscritos");
      }

      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.face)) {
        debugPrint("Hay tipos especificos de datos biometricos disponibles");
      }

      final biometric =
          biometricUserModelFromJson(await authService.readBiometric());

      var biometricUserModel = BiometricUserModel();

      biometricUserModel = BiometricUserModel(
          biometricUser: state,
          affiliateId: biometric.affiliateId,
          userAppMobile: biometric.userAppMobile);

      if (!mounted) return;
      debugPrint(biometricUserModelToJson(biometricUserModel));
      if (!mounted) return;
      await authService.writeBiometric(
          context, biometricUserModelToJson(biometricUserModel));
    } else {
      await authService.deleteBiometric();
    }
  }

  void closeSession(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ComponentAnimate(
          child: DialogTwoAction(
            message: '¿Estás seguro que quieres cerrar sesión?',
            actionCorrect: () => confirmDeleteSession(mounted, context, true),
            messageCorrect: 'Salir',
          ),
        );
      },
    );
  }
}

class IconName extends StatelessWidget {
  final IconData icon;
  final String text;
  const IconName({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [Icon(icon), Flexible(child: Text(text))],
      ),
    );
  }
}
