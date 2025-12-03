import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/screens/access/formlogin.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenNewLogin extends StatefulWidget {
  const ScreenNewLogin({super.key});

  @override
  State<ScreenNewLogin> createState() => _ScreenNewLoginState();
}

class _ScreenNewLoginState extends State<ScreenNewLogin> {
  String? deviceId;
  final double containerWidth = 320.w;

  @override
  void initState() {
    super.initState();
    checkVersion(mounted, context);
    initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        bool exitApp = await _onBackPressed();
        if (exitApp) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Column(
                      children: [
                        Image.asset(
                          AdaptiveTheme.of(context).mode.isDark
                              ? 'assets/images/muserpol-logo.png'
                              : 'assets/images/muserpol-logo2.png',
                          width: 270.w,
                        ),
                        SizedBox(height: 5.h),
                        FadeIn(child: const ScreenFormLogin()),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),

        //SECCION DE CONTACTOS Y POLITICAS Y PRIVACIDAD
        bottomNavigationBar: const _FooterBar(),
      ),
    );
  }

  //FUNCION PARA SALIR DE LA APLICACION
  Future<bool> _onBackPressed() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ComponentAnimate(
          child: DialogTwoAction(
            message: '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
            actionCorrect: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            messageCorrect: 'Salir',
          ),
        );
      },
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: _FooterButton(
                icon: Icons.contact_phone,
                label: 'Contactos',
                onTap: () => Navigator.pushNamed(context, 'contacts'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _FooterButton(
                icon: Icons.privacy_tip,
                label: 'Términos',
                onTap: () => launchUrl(
                  Uri.parse(serviceGetPrivacyPolicy()),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20.sp),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  label,
                  style:
                      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
