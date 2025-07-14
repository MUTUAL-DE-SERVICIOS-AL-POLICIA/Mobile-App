// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:muserpol_pvt/components/button.dart';
// import 'package:muserpol_pvt/components/headers.dart';
// import 'package:muserpol_pvt/model/qr_model.dart';

// class ScreenWorkFlow extends StatefulWidget {
//   final String stateFlow;
//   final QrModel qrModel;
//   const ScreenWorkFlow({super.key, required this.qrModel, required this.stateFlow});
//   @override
//   State<ScreenWorkFlow> createState() => _ScreenWorkFlowState();
// }

// class _ScreenWorkFlowState extends State<ScreenWorkFlow> {
//   late ValueNotifier<double> valueNotifier;
//   @override
//   void initState() {
//     super.initState();
//     valueNotifier = ValueNotifier(widget.qrModel.payload!.porcentage!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Column(children: [
//       HedersComponent(
//         titleHeader: widget.qrModel.payload!.code!,
//         title: widget.qrModel.payload!.moduleDisplayName!,
//       ),
//       Expanded(
//           child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 15),
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Padding(padding: const EdgeInsets.all(0), child: Text(widget.qrModel.payload!.procedureTypeName!)),
//                 SizedBox(
//                   height: 10.h,
//                 ),
//                 const Text(
//                   'Modalidad:',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '${widget.qrModel.payload!.procedureModalityName}',
//                 ),
//                 SizedBox(
//                   height: 10.h,
//                 ),
//                 Text(
//                   '${widget.qrModel.payload!.title!}:',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     for (final person in widget.qrModel.payload!.person!)
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 10.h,
//                           ),
//                           Text('• ${person.fullName!}'),
//                         ],
//                       )
//                   ],
//                 ),
//                 if (widget.qrModel.payload!.observations != null && widget.qrModel.payload!.observations!.isNotEmpty)
//                   Text(
//                     '${widget.qrModel.payload!.observationsTitle!}:',
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 if (widget.qrModel.payload!.observations != null)
//                   for (final observation in widget.qrModel.payload!.observations!)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 10.h,
//                         ),
//                         Text('• ${observation.message!}'),
//                       ],
//                     ),
//                 if (widget.qrModel.payload!.flow != null)
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Divider(height: 0.03.sh, color: Colors.white),
//                       const Text('Ubicación del trámite:', style: TextStyle(fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 if (widget.qrModel.payload!.flow != null)
//                   Center(
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: List.generate(widget.qrModel.payload!.flow!.length, (index) {
//                           return Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   const Spacer(),
//                                   Expanded(
//                                       flex: 1,
//                                       child: NumberComponent(
//                                           text: '${index + 1}',
//                                           iconColor: widget.qrModel.payload!.flow![index].state! ? true : false)),
//                                   Expanded(flex: 2, child: Text(widget.qrModel.payload!.flow![index].displayName!)),
//                                   const Spacer(),
//                                 ],
//                               ),
//                               if (index != widget.qrModel.payload!.flow!.length - 1)
//                                 Row(
//                                   children: [
//                                     const Spacer(),
//                                     const Expanded(flex: 1, child: Center(child: Text('|'))),
//                                     Expanded(flex: 2, child: Container()),
//                                     const Spacer(),
//                                   ],
//                                 ),
//                             ],
//                           );
//                         })),
//                   )
//               ]))),
//     ]));
//   }
// }
