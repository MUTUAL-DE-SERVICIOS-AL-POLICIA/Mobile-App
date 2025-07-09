// import 'package:adaptive_theme/adaptive_theme.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
// import 'package:muserpol_pvt/components/containers.dart';
// import 'package:muserpol_pvt/model/contribution_model.dart';
// import 'package:muserpol_pvt/screens/pages/virtual_officine/contibutions/card_contribution.dart';

// class TabsContributions extends StatefulWidget {
//   const TabsContributions({super.key});

//   @override
//   State<TabsContributions> createState() => _TabsContributionsState();
// }

// class _TabsContributionsState extends State<TabsContributions> with TickerProviderStateMixin {
//   List<ContributionsTotal> contributionsTotal = [];
//   TabController? tabController;
//   bool stateSubtract = true;
//   bool stateAdd = false;
//   @override
//   void initState() {
//     super.initState();
//     final contributionBloc = BlocProvider.of<ContributionBloc>(context, listen: false).state;
//     setState(() {
//       contributionsTotal = contributionBloc.contribution!.payload.contributionsTotal!;
//       tabController = TabController(vsync: this, length: contributionsTotal.length, initialIndex: contributionsTotal.length - 1);
//     });
//     tabController!.addListener(() {
//       setState(() {
//         if (tabController!.index == 0) {
//           stateSubtract = false;
//         } else {
//           stateSubtract = true;
//         }
//         if (tabController!.index == tabController!.length - 1) {
//           stateAdd = false;
//         } else {
//           stateAdd = true;
//         }
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//         child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 15),
//             child: Column(
//               children: [
//                 Table(columnWidths: const {
//                   0: FlexColumnWidth(3),
//                   1: FlexColumnWidth(3),
//                   2: FlexColumnWidth(3),
//                 }, children: [
//                   TableRow(children: [
//                     stateSubtract && (contributionsTotal.length - 1 != 0)
//                         ? years(stateSubtract, TextDirection.ltr, contributionsTotal[tabController!.index - 1].year,
//                             () => setState(() => tabController!.animateTo(tabController!.index - 1)), 1)
//                         : Container(),
//                     ContainerComponent(
//                       color: const Color(0xff419388),
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Text(
//                           contributionsTotal[tabController!.index].year,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.bold, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     stateAdd
//                         ? years(stateAdd, TextDirection.rtl, contributionsTotal[tabController!.index + 1].year,
//                             () => setState(() => tabController!.animateTo(tabController!.index + 1)), 0.5)
//                         : Container()
//                   ])
//                 ]),
//                 Expanded(
//                   child: DefaultTabController(
//                       length: contributionsTotal.length,
//                       initialIndex: contributionsTotal.length - 1,
//                       child: TabBarView(
//                         controller: tabController,
//                         children: [
//                           for (var i = 0; i <= contributionsTotal.length - 1; i++)
//                             ContributionsYear(
//                               tabController: tabController!,
//                               year: contributionsTotal[i].year,
//                               contributions: contributionsTotal[i].contributions,
//                             ),
//                         ],
//                       )),
//                 ),
//               ],
//             )));
//   }

//   Widget years(bool state, TextDirection textDirection, String text, Function() onTap, double value) {
//     return GestureDetector(
//         onTap: () => onTap(),
//         child: Row(
//           textDirection: textDirection,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10.0),
//               child: RotationTransition(
//                   turns: AlwaysStoppedAnimation(value),
//                   child: Icon(
//                     Icons.arrow_back_ios,
//                     color: AdaptiveTheme.of(context).theme.hintColor,
//                   )),
//             ),
//             Text(text, style: TextStyle(fontSize: 20.sp)),
//           ],
//         ));
//   }
// }
