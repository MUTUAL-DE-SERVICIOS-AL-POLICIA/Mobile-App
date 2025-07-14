// import 'package:flutter/material.dart';
// import 'package:muserpol_pvt/components/animate.dart';
// import 'package:muserpol_pvt/components/dialog_action.dart';
// import 'package:muserpol_pvt/components/headers.dart';
// import 'package:muserpol_pvt/components/susessful.dart';
// import 'package:muserpol_pvt/screens/access/forgot_password/code.dart';
// import 'package:muserpol_pvt/screens/access/forgot_password/credentials.dart';
// import 'package:muserpol_pvt/services/service_method.dart';
// import 'package:muserpol_pvt/services/services.dart';

// class ForgotPwd extends StatefulWidget {
//   const ForgotPwd({super.key});

//   @override
//   State<ForgotPwd> createState() => _ForgotPwdState();
// }

// class _ForgotPwdState extends State<ForgotPwd> {
//   TextEditingController dniCtrl = TextEditingController();
//   TextEditingController phoneCtrl = TextEditingController();
//   TextEditingController dniComCtrl = TextEditingController();
//   TextEditingController codeCtrl = TextEditingController();

//   bool dateState = false;
//   bool btnAccess = true;
//   bool stateSendSms = false;
//   String? dateCtrlText;

//   String stateForgot = "credentials";

//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   String dateCtrl = '';
//   DateTime currentDate = DateTime(1950, 1, 1);

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop:
//           false, // Evita que el usuario cierre la pantalla con el botón de retroceso
//       onPopInvokedWithResult: (didPop, _) async {
//         if (didPop) return;
//         await backAcction(); // Llama a la acción de retroceso personalizada
//       },
//       child: Scaffold(
//         body: Padding(
//           padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
//           child: Column(
//             children: [
//               const HedersComponent(title: 'Recuperar Contraseña'),
//               Expanded(
//                 child: Center(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         btnAccess
//                             ? Form(
//                                 key: formKey,
//                                 child: Column(
//                                   children: [
//                                     if (stateForgot == 'credentials')
//                                       CredentialForgotPwd(
//                                         dniCtrl: dniCtrl,
//                                         dniComCtrl: dniComCtrl,
//                                         phoneCtrl: phoneCtrl,
//                                         dateState: dateState,
//                                         currentDate: currentDate,
//                                         dateCtrl: dateCtrl,
//                                         selectDate:
//                                             (date, dateCurrent, dateFormat) {
//                                           setState(() {
//                                             dateCtrl = date;
//                                             currentDate = dateCurrent;
//                                             dateCtrlText = dateFormat;
//                                             dateState = false;
//                                           });
//                                         },
//                                         sendCredentials: () =>
//                                             sendCredentials(),
//                                         stateAlphanumericFalse: () => setState(
//                                             () => dniComCtrl.text = ''),
//                                       ),
//                                     if (stateForgot == 'code')
//                                       CodeForgotPwd(
//                                         cellPhoneNumber: phoneCtrl.text,
//                                         dni:
//                                             '${dniCtrl.text.trim()}${dniComCtrl.text.isEmpty ? '' : '-${dniComCtrl.text.trim()}'}',
//                                         stateSendSms: stateSendSms,
//                                         resendcode: () => sendCredentials(),
//                                         correct: () {
//                                           if (!mounted) return;
//                                           return showSuccessful(
//                                               context, 'CORRECTO', () {
//                                             Navigator.of(context).pop();
//                                           });
//                                         },
//                                       ),
//                                   ],
//                                 ),
//                               )
//                             : Center(
//                                 child: Image.asset(
//                                   'assets/images/load.gif',
//                                   fit: BoxFit.cover,
//                                   height: 20,
//                                 ),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   sendCredentials() async {
//     setState(() => stateForgot = 'credentials');
//     FocusScope.of(context).unfocus();
//     validateDate();
//     if (formKey.currentState!.validate()) {
//       final Map<String, dynamic> body = {
//         'ci':
//             '${dniCtrl.text.trim()}${dniComCtrl.text == '' ? '' : '-${dniComCtrl.text.trim()}'}',
//         'birth_date': dateCtrlText,
//         'cell_phone_number': phoneCtrl.text.trim()
//       };
//       await Future.delayed(const Duration(milliseconds: 50), () {});
//       setState(() {
//         stateForgot = 'code';
//         stateSendSms = !stateSendSms;
//       });
//       if (!mounted) return;
//       var response = await serviceMethod(mounted, context, 'patch', body,
//           serviceForgotPasswordOF(), false, true);
//       setState(() => stateSendSms = !stateSendSms);
//       if (response == null) {
//         setState(() => stateForgot = 'credentials');
//       }
//     }
//   }

//   validateDate() {
//     if (dateCtrlText == null) return setState(() => dateState = true);
//     return setState(() => dateState = false);
//   }

//   Future<bool> backAcction() async {
//     return await showDialog(
//         barrierDismissible: false,
//         context: context,
//         builder: (BuildContext context) {
//           return ComponentAnimate(
//               child: DialogTwoAction(
//                   message: '¿Deseas salir de la actualización de contraseña?',
//                   actionCorrect: () =>
//                       Navigator.pushNamed(context, 'check_auth'),
//                   messageCorrect: 'Salir'));
//         });
//   }
//   // backAcction() async {
//   //   return await showDialog(
//   //       barrierDismissible: false,
//   //       context: context,
//   //       builder: (context) => ComponentAnimate(
//   //           child: DialogTwoAction(
//   //               message: '¿Deseas salir de la actualización de contraseña?',
//   //               actionCorrect: () {
//   //                 Navigator.pop(context);
//   //                 Navigator.pop(context);
//   //                 return true;
//   //               },
//   //               messageCorrect: 'Salir')));
//   // }
// }
