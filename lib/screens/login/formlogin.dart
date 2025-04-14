import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muserpol_pvt/components/card_login.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';

class Formlogin extends StatefulWidget {
  final String deviceId;
  const Formlogin({super.key, required this.deviceId});

  @override
  State<Formlogin> createState() => _FormloginState();
}

class _FormloginState extends State<Formlogin> {
  final TextEditingController _dniCtrl = TextEditingController();
  final TextEditingController _dniCompCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final FocusNode _complementFocusNode = FocusNode();
  bool _stateAlphanumeric = true;
  bool _isLoading = false;

  void _setAlphanumericFalse() {
    setState(() {
      _stateAlphanumeric = false;
    });
  }

  void _onSubmit() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      debugPrint("CI: ${_dniCtrl.text}-${_dniCompCtrl.text}");
      debugPrint("Password: ${_passwordCtrl.text}");
      debugPrint("Device ID: ${widget.deviceId}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  IdentityCard(
                    title: 'Cédula de identidad:',
                    dniCtrl: _dniCtrl,
                    dniComCtrl: _dniCompCtrl,
                    textSecondFocusNode: _complementFocusNode,
                    formatter: FilteringTextInputFormatter.digitsOnly,
                    keyboardType: TextInputType.number,
                    onEditingComplete: () {},
                    stateAlphanumeric: _stateAlphanumeric,
                    stateAlphanumericFalse: _setAlphanumericFalse,
                  ),
                  const SizedBox(height: 20),
                  Password(
                    passwordCtrl: _passwordCtrl,
                    onEditingComplete: _onSubmit,
                  ),
                  const SizedBox(height: 10),
                  ButtonWhiteComponent(
                    text: 'Olvidé mi contraseña',
                    onPressed: () => Navigator.pushNamed(context, 'forgot'),
                  ),
                  const SizedBox(height: 10),
                  ButtonComponent(
                    text: "ENTRAR",
                    onPressed: _isLoading ? null : _onSubmit,
                    stateLoading: _isLoading,
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: MiniCardButton(
                          icon: Icons.contact_phone,
                          label: 'Contactos\na nivel nacional',
                          onTap: () => Navigator.pushNamed(context, 'contacts'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MiniCardButton(
                          icon: Icons.privacy_tip,
                          label: 'Política\nde privacidad',
                          onTap: () => launchUrl(
                            Uri.parse(serviceGetPrivacyPolicy()),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Versión ${dotenv.env['version']}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "¿Quieres utilizar la app de la MUSERPOL? Regístrate",
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
