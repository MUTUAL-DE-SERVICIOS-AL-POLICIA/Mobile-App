// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:muserpol_pvt/components/containers.dart';
// import 'package:muserpol_pvt/model/contribution_model.dart';
// import 'package:muserpol_pvt/screens/pages/virtual_officine/contibutions/card_expanded.dart';

// class ContributionsYear extends StatelessWidget {
//   final TabController tabController;
//   final String year;
//   final List<Contribution> contributions;
//   const ContributionsYear({
//     super.key,
//     required this.year,
//     required this.contributions,
//     required this.tabController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return contributions.isNotEmpty
//         ? GridView.count(
//             padding: const EdgeInsets.only(bottom: 68),
//             crossAxisCount: 3,
//             children: List.generate(contributions.length, (index) {
//               return Hero(
//                   tag: 'flipcardHero$index',
//                   child: Material(
//                       type: MaterialType.transparency, // likely needed
//                       child: Padding(
//                         padding: const EdgeInsets.all(5.0),
//                         child: card(
//                             contributions[index].reimbursementTotal != '0,00' && contributions[index].reimbursementTotal != null
//                                 ? const Color(0xffE0A44C)
//                                 : Colors.transparent,
//                             context,
//                             contributions[index],
//                             'flipcardHero$index'),
//                       )));
//             }),
//           )
//         : const Center(
//             child: Text('Gestión sin aportes'),
//           );
//   }

//   Widget card(Color colorRefund, BuildContext context, Contribution key, String hero) {
//     return GestureDetector(
//         onTap: () {
//           Navigator.of(context).push(
//             PageRouteBuilder(
//               opaque: false,
//               pageBuilder: (_, __, ___) => CardExpanded(index: hero, contribution: key, colorRefund: colorRefund),
//             ),
//           );
//         },
//         child: ContainerComponent(
//             color: colorRefund,
//             child: Center(
//                 child: SingleChildScrollView(
//                     child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(key.state, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 Text(
//                   DateFormat('MMMM', "es_ES").format(key.monthYear!).toUpperCase(),
//                   style: TextStyle(fontSize: 15.sp),
//                 ),
//                 Text('${key.total} Bs.'),
//               ],
//             )))));
//   }
// }
