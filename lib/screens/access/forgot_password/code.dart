import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';

class CodeForgotPwd extends StatefulWidget {
  final String cellPhoneNumber;
  final String dni;
  final bool stateSendSms;
  final Function() resendcode;
  final Function() correct;
  const CodeForgotPwd(
      {super.key, required this.cellPhoneNumber, required this.dni, required this.resendcode, required this.correct, required this.stateSendSms});

  @override
  State<CodeForgotPwd> createState() => _CodeForgotPwdState();
}

class _CodeForgotPwdState extends State<CodeForgotPwd> with CodeAutoFill {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordConfirmCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();
  TextEditingController codeCtrl = TextEditingController();

  bool btnAccess = true;

  @override
  void codeUpdated() {
    debugPrint('code $code');
    setState(() => codeCtrl.text = code!);
  }

  @override
  void initState() {
    super.initState();
    debugPrint('ESCUCHANDO');
    setState(() => codeCtrl.text = '');
    listenForCode();
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    return Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            Text("Ingrese el código enviado a ${widget.cellPhoneNumber}"),
            if (widget.stateSendSms)
              Center(
                  child: Image.asset(
                'assets/images/load.gif',
                fit: BoxFit.cover,
                height: 20,
              )),
            const SizedBox(
              height: 20,
            ),
            PinCodeTextField(
              appContext: context,
              length: 4,
              onChanged: (value) {},
              onCompleted: (value) => node.nextFocus(),
              controller: codeCtrl,
              autoDisposeControllers: false,
              keyboardType: TextInputType.number,
              cursorColor: Colors.transparent,
              pinTheme: PinTheme(
                inactiveColor: const Color(0xff419388),
                activeColor: Colors.black,
                selectedColor: const Color(0xff419388),
                selectedFillColor: const Color(0xff419388),
                inactiveFillColor: Colors.transparent,
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                activeFillColor: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
            ),
            if (!widget.stateSendSms) Password(passwordCtrl: passwordCtrl, onEditingComplete: () => node.nextFocus()),
            if (!widget.stateSendSms)
              Password(
                  confirm: true,
                  passwordCtrl: passwordConfirmCtrl,
                  onEditingComplete: () => sendCode(),
                  validator: (value) {
                    if (value == passwordCtrl.text) {
                      return null;
                    } else {
                      return 'No coincide la contraseña';
                    }
                  }),
            const SizedBox(
              height: 20,
            ),
            if (!widget.stateSendSms)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No recibiste el código?"),
                  ButtonWhiteComponent(text: 'REENVIAR', onPressed: () => widget.resendcode()),
                ],
              ),
            ButtonComponent(text: 'ENVIAR', onPressed: !widget.stateSendSms ? () => sendCode() : null),
          ],
        ));
  }

  sendCode() async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      setState(() => btnAccess = false);
      final Map<String, dynamic> body = {'username': widget.dni, 'code_to_update': codeCtrl.text, 'new_password': passwordCtrl.text.trim()};
      if (!mounted) return;
      var response = await serviceMethod(mounted, context, 'patch', body, serviceSendCodeOF(), false, true);
      setState(() => btnAccess = true);
      if (response != null) {
        widget.correct();
      }
    }
  }
}
