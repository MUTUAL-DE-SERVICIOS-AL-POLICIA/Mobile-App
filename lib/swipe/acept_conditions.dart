import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/headers.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ModalAceptTermin extends StatefulWidget {
  const ModalAceptTermin({super.key});

  @override
  State<ModalAceptTermin> createState() => _ModalAceptTerminState();
}

class _ModalAceptTerminState extends State<ModalAceptTermin> {
  bool stateTermsConditions = false;
  bool stateNotificationsPush = false;
  bool btnAccess = true;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Scaffold(
            body: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(children: [
                  const HedersComponent(title: 'Términos y Condiciones'),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            btnAccess
                                ? OptionTermCondition(
                                    onChanged: (val) => setState(() => stateTermsConditions = !stateTermsConditions),
                                    state: stateTermsConditions,
                                    child: GestureDetector(
                                      onTap: () => launchUrl(Uri.parse(serviceGetPrivacyPolicy()), mode: LaunchMode.externalApplication),
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: 'Acepto ',
                                            style: TextStyle(
                                                color: AdaptiveTheme.of(context).theme.primaryColorDark,
                                                fontFamily: 'Poppins',
                                                fontSize: 17.sp)),
                                        TextSpan(
                                            text: 'Términos y Condiciones ',
                                            style: TextStyle(
                                                color: Colors.blue, decoration: TextDecoration.underline, fontFamily: 'Poppins', fontSize: 17.sp)),
                                        TextSpan(
                                            text: 'de uso de la aplicación móvil "MUSERPOL PVT"',
                                            style: TextStyle(
                                                color: AdaptiveTheme.of(context).theme.primaryColorDark,
                                                fontFamily: 'Poppins',
                                                fontSize: 17.sp))
                                      ])),
                                    ),
                                  )
                                : Center(
                                    child: Image.asset(
                                    'assets/images/load.gif',
                                    fit: BoxFit.cover,
                                    height: 20,
                                  )),
                            OptionTermCondition(
                              onChanged: (val) => setState(() => stateNotificationsPush = !stateNotificationsPush),
                              state: stateNotificationsPush,
                              child: GestureDetector(
                                onTap: () => setState(() => stateNotificationsPush = !stateNotificationsPush),
                                child: Text('Acepto que me envien notificaciones',
                                    style: TextStyle(color: AdaptiveTheme.of(context).theme.primaryColorDark)),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        ButtonComponent(text: 'INGRESAR', onPressed: stateTermsConditions && stateNotificationsPush ? () => getInto(context) : null),
                  ),
                ]))));
  }

  getInto(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.writeFirstTime(context);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'switch');
  }
}

class OptionTermCondition extends StatelessWidget {
  final Function(bool) onChanged;
  final bool state;
  final Widget child;
  const OptionTermCondition({super.key, required this.onChanged, required this.state, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Transform.scale(
            scale: 1.5,
            child: Checkbox(
                value: state,
                activeColor: const Color(0xff419388),
                splashRadius: 50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onChanged: (val) => onChanged(val!))),
        Flexible(child: child)
      ],
    );
  }
}
