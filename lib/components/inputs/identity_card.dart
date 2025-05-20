import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/input.dart';

class IdentityCard extends StatefulWidget {
  final String title;
  final TextEditingController dniCtrl;
  final TextEditingController dniComCtrl;
  final FocusNode textSecondFocusNode;
  final TextInputFormatter formatter;
  final TextInputType keyboardType;
  final Function() onEditingComplete;
  final Function() stateAlphanumericFalse;
  final bool? stateAlphanumeric;
  const IdentityCard(
      {super.key,
      required this.title,
      required this.dniCtrl,
      required this.dniComCtrl,
      required this.textSecondFocusNode,
      required this.formatter,
      required this.keyboardType,
      required this.onEditingComplete,
      this.stateAlphanumeric = true,
      required this.stateAlphanumericFalse});

  @override
  State<IdentityCard> createState() => _IdentityCardState();
}

class _IdentityCardState extends State<IdentityCard> {
  final tooltipController = JustTheController();
  bool dniComplement = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title),
            Row(
              children: <Widget>[
                Flexible(
                  child: InputComponent(
                    textInputAction: TextInputAction.next,
                    controllerText: widget.dniCtrl,
                    onEditingComplete: () => widget.onEditingComplete(),
                    validator: (value) {
                      if (value.length > 3) {
                        return null;
                      } else {
                        return 'Ingrese su cédula de indentidad';
                      }
                    },
                    inputFormatters: [LengthLimitingTextInputFormatter(10), widget.formatter],
                    keyboardType: widget.keyboardType,
                    textCapitalization: TextCapitalization.characters,
                    icon: Icons.person,
                    labelText: "Cédula de indentidad",
                  ),
                ),
                if (dniComplement)
                  Text(
                    '  _  ',
                    style: TextStyle(fontSize: 15.sp, color: const Color(0xff419388)),
                  ),
                if (dniComplement)
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.4,
                    child: InputComponent(
                      focusNode: widget.textSecondFocusNode,
                      textInputAction: TextInputAction.next,
                      controllerText: widget.dniComCtrl,
                      inputFormatters: [LengthLimitingTextInputFormatter(2), FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))],
                      onEditingComplete: () => widget.onEditingComplete(),
                      validator: (value) {
                        if (value.isNotEmpty) {
                          return null;
                        } else {
                          return 'complemento';
                        }
                      },
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      icon: Icons.person,
                      labelText: "Complemento",
                    ),
                  ), //container
              ], //widget
            ),
          ],
        ),
        if (widget.stateAlphanumeric!)
          Buttontoltip(
            tooltipController: tooltipController,
            onPressed: (bool state) => functionToltip(state),
          )
      ],
    );
  }

  functionToltip(bool state) async {
    setState(() {
      if (!state) widget.stateAlphanumericFalse();
      dniComplement = state;
      tooltipController.hideTooltip();
    });
  }
}
