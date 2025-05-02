import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:muserpol_pvt/components/card_login.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';
import 'package:muserpol_pvt/components/inputs/birth_date.dart'; // tu componente personalizado
import 'package:muserpol_pvt/screens/login/loginservice.dart';

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

  final PageController _pageController = PageController();
  final FocusNode _complementFocusNode = FocusNode();

  int _currentPage = 0;
  bool _isLoading = false;
  bool _dateState = false;

  DateTime _selectedDate = DateTime(1950, 1, 1);
  String _dateCtrlText = ''; // Para enviar al backend
  String _dateDisplayText = ''; // Para mostrar en UI

  void _onSubmit() async {
    setState(() => _isLoading = true);
    await LoginService.iniciarSesion(
      context: context,
      deviceId: widget.deviceId,
      identityCard:
          '${_dniCtrl.text.trim()}${_dniCompCtrl.text.isNotEmpty ? '-${_dniCompCtrl.text.trim()}' : ''}',
      password: _currentPage == 0 ? _passwordCtrl.text.trim() : null,
      birthDate: _currentPage == 1 ? _dateCtrlText : null,
      isOfficeVirtual: _currentPage == 0,
    );
    setState(() => _isLoading = false);
  }

  void _onDateSelected(String textDisplay, DateTime dateValue, String _) {
    setState(() {
      _dateDisplayText = textDisplay; // "24, febrero 1950" para mostrar
      _dateCtrlText = _formatDateToIso(dateValue); // "1950-02-24" para enviar
      _selectedDate = dateValue;
      _dateState = false;
    });
  }

  String _formatDateToIso(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildPasswordLogin() {
    return Password(
      passwordCtrl: _passwordCtrl,
      onEditingComplete: _onSubmit,
    );
  }

  Widget _buildBirthDateLogin() {
    return BirthDate(
      dateState: _dateState,
      currentDate: _selectedDate,
      selectDate: _onDateSelected,
      dateCtrl: _dateDisplayText,
    );
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
                    stateAlphanumeric: true,
                    stateAlphanumericFalse: () {},
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 130,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      children: [
                        _buildPasswordLogin(),
                        _buildBirthDateLogin(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? Theme.of(context).primaryColor
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  ButtonWhiteComponent(
                    text: 'Olvidé mi contraseña',
                    onPressed: () => Navigator.pushNamed(context, 'forgot'),
                  ),
                  const SizedBox(height: 10),
                  ButtonComponent(
                    text: "ENTRAR",
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_currentPage == 1 && _dateCtrlText.isEmpty) {
                              setState(() => _dateState = true);
                              return;
                            }
                            _onSubmit();
                          },
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
