import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:muserpol_pvt/components/inputs/identity_card.dart';
import 'package:muserpol_pvt/components/inputs/password.dart';

class ScreenFormLogin extends StatefulWidget {
  const ScreenFormLogin({super.key});

  @override
  State<ScreenFormLogin> createState() => _ScreenFormLoginState();
}

class _ScreenFormLoginState extends State<ScreenFormLogin> {
  TextEditingController dniCtrl = TextEditingController();
  TextEditingController dniComCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool btnAccess = true;
  String dateCtrl = '';
  DateTime? dateTime;
  String? dateCtrlText;
  bool dateState = false;
  DateTime currentDate = DateTime(1950, 1, 1);
  FocusNode textSecondFocusNode = FocusNode();

  final tooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    final node = FocusScope.of(context);
    // return Form(
    //   key: formKey,
    //   child: Column(
    //     children: [
    //       SizedBox(
    //         height: 20.h,
    //       ),
    //       const Text(
    //         'Bienvenido / a',
    //         style: TextStyle(fontWeight: FontWeight.bold),
    //       ),
    //       SizedBox(
    //         height: 10.h,
    //       ),
    //       Column(
    //         children: [
    //           IdentityCard(
    //             title: 'Usuario / Cédula de identidad:',
    //             dniCtrl: dniCtrl,
    //             dniComCtrl: dniComCtrl,
    //             onEditingComplete: () => node.nextFocus(),
    //             textSecondFocusNode: textSecondFocusNode,
    //             formatter:
    //                 FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z-]")),
    //             keyboardType: TextInputType.text,
    //             stateAlphanumericFalse: () =>
    //                 setState(() => dniComCtrl.text = ''),
    //           ),
    //           SizedBox(
    //             height: 10.h,
    //           ),
    //           Password(passwordCtrl: passwordCtrl, onEditingComplete: () => ()),
    //         ],
    //       )
    //     ],
    //   ),
    // );

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bienvenido / a',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.h,
              ),
              IdentityCard(
                title: 'Usuario / Cédula de identidad:',
                dniCtrl: dniCtrl,
                dniComCtrl: dniComCtrl,
                onEditingComplete: () => node.nextFocus(),
                textSecondFocusNode: textSecondFocusNode,
                formatter:
                    FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z-]")),
                keyboardType: TextInputType.text,
                stateAlphanumericFalse: () =>
                    setState(() => dniComCtrl.text = ''),
              ),
              SizedBox(
                height: 10.h,
              ),
              Password(passwordCtrl: passwordCtrl, onEditingComplete: () => ()),
            ],
          ),
        ),
      ),
    );
  }
}
