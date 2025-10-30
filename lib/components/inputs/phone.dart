import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/components/input.dart';
import 'package:muserpol_pvt/components/inputs/text_input_formarter.dart';

class PhoneNumber extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final bool focusState;
  final Function() onEditingComplete;
  const PhoneNumber(
      {super.key,
      required this.phoneCtrl,
      required this.onEditingComplete,
      this.focusState = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Número telefónico:',
          style: TextStyle(
              fontSize: 15.sp,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black)),
      InputComponent(
        stateAutofocus: focusState,
        textInputAction: TextInputAction.next,
        controllerText: phoneCtrl,
        onEditingComplete: () => onEditingComplete(),
        validator: (value) {
          if (value.isNotEmpty) {
            return null;
          } else {
            return 'Ingrese su número telefónico';
          }
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(11),
          // FilteringTextInputFormatter.allow(RegExp("[0-9]"))
          PhoneNumberFormatter(),
        ],
        keyboardType: TextInputType.number,
        textCapitalization: TextCapitalization.characters,
        icon: Icons.person,
        labelText: "Número de contacto",
      )
    ]);
  }
}
