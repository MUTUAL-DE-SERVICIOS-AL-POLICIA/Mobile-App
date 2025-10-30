import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/components/input.dart';

class Password extends StatefulWidget {
  final TextEditingController passwordCtrl;
  final Function() onEditingComplete;
  final bool? confirm;
  final Function(String)? validator;
  const Password(
      {super.key,
      required this.passwordCtrl,
      required this.onEditingComplete,
      this.confirm = false,
      this.validator});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  bool hidePassword = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.confirm! ? 'Confirme su contraseña:' : 'Contraseña:',
          style: TextStyle(
              fontSize: 15.sp, color: const Color.fromARGB(255, 0, 0, 0)),
        ),
        InputComponent(
            textInputAction: TextInputAction.done,
            controllerText: widget.passwordCtrl,
            onEditingComplete: () => widget.onEditingComplete(),
            validator: widget.validator ??
                (value) {
                  if (value.isNotEmpty) {
                    if (value.length >= 4) {
                      return null;
                    } else {
                      return 'Debe tener un mínimo de 4 caracteres.';
                    }
                  } else {
                    return 'Ingrese su contraseña';
                  }
                },
            inputFormatters: [LengthLimitingTextInputFormatter(10)],
            keyboardType: TextInputType.text,
            icon: Icons.lock,
            labelText: "Contraseña",
            obscureText: hidePassword,
            onTap: () => setState(() => hidePassword = !hidePassword),
            iconOnTap:
                hidePassword ? Icons.lock_outline : Icons.lock_open_sharp)
      ],
    );
  }
}
