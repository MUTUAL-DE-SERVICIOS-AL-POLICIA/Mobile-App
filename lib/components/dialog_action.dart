import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:flutter/material.dart';

class DialogAction extends StatelessWidget {
  final String message;
  const DialogAction({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ComponentAnimate(
        child: AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        ButtonComponent(
            text: 'Aceptar', onPressed: () => Navigator.pop(context))
      ],
    ));
  }
}

class DialogOneFunction extends StatelessWidget {
  final String title;
  final String message;
  final String textButton;
  final Function() onPressed;
  const DialogOneFunction(
      {super.key,
      required this.title,
      required this.message,
      required this.textButton,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Bloquea el botón de retroceso
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
      },
      child: ComponentAnimate(
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),
              Text(
                message,
                textAlign: TextAlign.justify,
              ),
            ],
          ),
          actions: <Widget>[
            ButtonComponent(text: textButton, onPressed: () => onPressed()),
          ],
        ),
      ),
    );
  }
}

class DialogTwoAction extends StatefulWidget {
  final String message;
  final Function() actionCorrect;
  final Function()? actionCancel;
  final String messageCorrect;

  const DialogTwoAction(
      {super.key,
      required this.message,
      required this.actionCorrect,
      this.actionCancel,
      required this.messageCorrect});

  @override
  State<DialogTwoAction> createState() => _DialogTwoActionState();
}

class _DialogTwoActionState extends State<DialogTwoAction> {
  bool stateBottons = true;
  @override
  Widget build(BuildContext context) {
    return ComponentAnimate(
        child: AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceAround,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        widget.message,
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ButtonWhiteComponent(
              text: 'Cancelar',
              onPressed: stateBottons
                  ? widget.actionCancel ?? () => Navigator.of(context).pop()
                  : () {},
            ),
            ButtonWhiteComponent(
                text: widget.messageCorrect,
                onPressed: () async {
                  setState(() => stateBottons = !stateBottons);
                  await widget.actionCorrect();
                  setState(() => stateBottons = !stateBottons);
                })
          ],
        )
      ],
    ));
  }
}
