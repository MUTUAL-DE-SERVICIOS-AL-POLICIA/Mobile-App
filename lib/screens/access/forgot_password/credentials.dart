// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:just_the_tooltip/just_the_tooltip.dart';
// import 'package:muserpol_pvt/components/button.dart';
// import 'package:muserpol_pvt/components/inputs/birth_date.dart';
// import 'package:muserpol_pvt/components/inputs/identity_card.dart';
// import 'package:muserpol_pvt/components/inputs/phone.dart';

// class CredentialForgotPwd extends StatefulWidget {
//   final TextEditingController dniCtrl;
//   final TextEditingController phoneCtrl;
//   final TextEditingController dniComCtrl;
//   final bool dateState;
//   final Function(String, DateTime, String) selectDate;
//   final Function() sendCredentials;
//   final Function() stateAlphanumericFalse;
//   final DateTime currentDate;
//   final String dateCtrl;
//   const CredentialForgotPwd(
//       {super.key,
//       required this.dniCtrl,
//       required this.phoneCtrl,
//       required this.dniComCtrl,
//       required this.dateState,
//       required this.selectDate,
//       required this.sendCredentials,
//       required this.currentDate,
//       required this.dateCtrl, required this.stateAlphanumericFalse});

//   @override
//   State<CredentialForgotPwd> createState() => _CredentialForgotPwdState();
// }

// class _CredentialForgotPwdState extends State<CredentialForgotPwd> {
//   bool btnAccess = true;

//   FocusNode textSecondFocusNode = FocusNode();
//   final tooltipController = JustTheController();

//   @override
//   Widget build(BuildContext context) {
//     final node = FocusScope.of(context);
//     return 
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           IdentityCard(
//               title: 'Cédula de identidad:',
//               dniCtrl: widget.dniCtrl,
//               dniComCtrl: widget.dniComCtrl,
//               onEditingComplete:() => node.nextFocus(),
//               textSecondFocusNode: textSecondFocusNode,
//               keyboardType: TextInputType.number,
//               formatter: FilteringTextInputFormatter.allow(RegExp("[0-9]")),
//               stateAlphanumericFalse: widget.stateAlphanumericFalse),
//           SizedBox(
//             height: 10.h,
//           ),
//           BirthDate(
//             dateState: widget.dateState,
//             currentDate: widget.currentDate,
//             dateCtrl: widget.dateCtrl,
//             selectDate: (date, dateCurrent, dateFormat) => widget.selectDate(date, dateCurrent, dateFormat),
//           ),
//           SizedBox(
//             height: 10.h,
//           ),
//           PhoneNumber(phoneCtrl: widget.phoneCtrl, onEditingComplete: () {}),
//           SizedBox(
//             height: 10.h,
//           ),
//           ButtonComponent(text: 'ENVIAR', onPressed: () => widget.sendCredentials())
//         ],
//       );
//   }
// }
