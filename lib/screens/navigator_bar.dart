import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/components/target.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/contribution_model.dart';
import 'package:muserpol_pvt/model/files_model.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/model/procedure_model.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
// import 'package:muserpol_pvt/provider/files_state.dart';
import 'package:muserpol_pvt/screens/navigator_down.dart';
import 'package:muserpol_pvt/screens/pages/complement/procedure.dart';
import 'package:muserpol_pvt/screens/pages/menu.dart';
import 'package:muserpol_pvt/screens/pages/virtual_officine/contibutions/contribution.dart';
import 'package:muserpol_pvt/screens/pages/virtual_officine/loans/loan.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class NavigatorBar extends StatefulWidget {
  final bool tutorial;
  final StateAplication stateApp;
  const NavigatorBar({super.key, this.tutorial = true, required this.stateApp});

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  ProcedureModel? procedureCurrent;
  ProcedureModel? procedureHistory;
  final ScrollController _scrollController = ScrollController();
  var _currentIndex = 0;

  int pageCurrent = 1;
  int pageHistory = 1;
  bool stateProcessing = false;

  GlobalKey keyBottomNavigation1 = GlobalKey();
  GlobalKey keyBottomNavigation2 = GlobalKey();
  GlobalKey keyBottomHeader = GlobalKey();
  GlobalKey keyCreateProcedure = GlobalKey();
  GlobalKey keyNotification = GlobalKey();
  GlobalKey keyMenu = GlobalKey();
  GlobalKey keyRefresh = GlobalKey();

  List<Widget> pageList = [];

  bool stateLoad = true;
  bool? stateLoadTutorial;
  bool consumeService = true;
  @override
  void initState() {
    super.initState();
    services();
    setState(() => stateLoadTutorial = widget.tutorial);
  }

  services() async {
    if (await checkVersion(mounted, context)) {
      if (widget.stateApp == StateAplication.complement) {
        await getProcessingPermit();
        await getObservations();
        _scrollController.addListener(() async {
          if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
            if (_currentIndex == 0 &&
                procedureCurrent!.data!.nextPageUrl != null) {
              if (consumeService) await getEconomicComplement(true);
            }
            if (_currentIndex == 1 &&
                procedureHistory!.data!.nextPageUrl != null) {
              if (consumeService) await getEconomicComplement(false);
            }
          }
        });
      }
      if (widget.tutorial && stateLoadTutorial!) {
        setState(() => stateLoad = false);
        Future.delayed(const Duration(milliseconds: 500), showTutorial);
      } else {
        if (widget.stateApp == StateAplication.complement) {
          await getEconomicComplement(true);
          await getEconomicComplement(false);
        } else {
          debugPrint('OBTENINENDO TODOS LOS APORTES Y PRESTAMOS');
          await getContributions();
          await getLoans();
        }
      }
    }
  }

  // refresh() async {
  //   setState(() => stateLoad = true);
  //   if (await checkVersion(mounted, context)) {
  //     if (!mounted) return;
  //     final filesState = Provider.of<FilesState>(context, listen: false);
  //     final tabProcedureState =
  //         Provider.of<TabProcedureState>(context, listen: false);
  //     final processingState =
  //         Provider.of<ProcessingState>(context, listen: false);
  //     final procedureBloc =
  //         BlocProvider.of<ProcedureBloc>(context, listen: false);
  //     tabProcedureState.updateTabProcedure(0);
  //     for (var element in filesState.files) {
  //       filesState.updateFile(element.id!, null);
  //     }
  //     processingState.updateStateProcessing(false);
  //     procedureBloc.add(ClearProcedures());
  //     // procedureBloc.add(Clear);
  //     setState(() {
  //       pageCurrent = 1;
  //       pageHistory = 1;
  //     });
  //     if (widget.stateApp == StateAplication.complement) {
  //       await getProcessingPermit();
  //       await getObservations();
  //       await getEconomicComplement(true);
  //       await getEconomicComplement(false);
  //     } else {
  //       debugPrint('OBTENINENDO TODOS LOS APORTES Y PRESTAMOS');
  //       await getContributions();
  //       await getLoans();
  //     }
  //   } else {
  //     setState(() => stateLoad = false);
  //   }
  // }

  getEconomicComplement(bool current) async {
    final procedureBloc =
        BlocProvider.of<ProcedureBloc>(context, listen: false);
    setState(() {
      stateLoad = true;
      consumeService = false;
    });
    var response = await serviceMethod(
        mounted,
        context,
        'get',
        null,
        serviceGetEconomicComplements(
            current ? pageCurrent : pageHistory, current),
        true,
        true);
    if (response != null) {
      if (current) {
        procedureCurrent = procedureModelFromJson(response.body);
        procedureBloc.add(AddCurrentProcedures(procedureCurrent!.data!.data!));
        setState(() => pageCurrent++);
      } else {
        debugPrint('&current=false $pageHistory');
        procedureHistory = procedureModelFromJson(response.body);
        procedureBloc.add(AddHistoryProcedures(procedureHistory!.data!.data!));
        setState(() => pageHistory++);
      }
    }
    setState(() {
      stateLoad = false;
      consumeService = true;
    });
  }

  getObservations() async {
    final observationState =
        Provider.of<ObservationState>(context, listen: false);
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final processingState =
        Provider.of<ProcessingState>(context, listen: false);
    if (!mounted) return;
    var response = await serviceMethod(mounted, context, 'get', null,
        serviceGetObservation(userBloc.state.user!.id!), true, true);
    if (response != null) {
      observationState.updateObservation(response.body);
      if (json.decode(response.body)['data']['enabled']) {
        processingState.updateStateProcessing(true);
      }
    }
  }

  getProcessingPermit() async {
    final loadingState = Provider.of<LoadingState>(context, listen: false);
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final tabProcedureState =
        Provider.of<TabProcedureState>(context, listen: false);
    if (!mounted) return;
    var response = await serviceMethod(mounted, context, 'get', null,
        serviceGetProcessingPermit(userBloc.state.user!.id!), true, false);
    if (response != null) {
      userBloc.add(UpdateCtrlLive(
          json.decode(response.body)['data']['liveness_success']));
      if (json.decode(response.body)['data']['liveness_success']) {
        tabProcedureState.updateTabProcedure(1);
        if (userBloc.state.user!.verified!) {
          loadingState.updateStateLoadingProcedure(
              true); //MOSTRAMOS EL BTN DE CONTINUAR
          setState(() {});
        } else {
          loadingState.updateStateLoadingProcedure(
              false); //OCULTAMOS EL BTN DE CONTINUAR
          setState(() {});
        }
      } else {
        tabProcedureState.updateTabProcedure(0);
        loadingState
            .updateStateLoadingProcedure(false); //OCULTAMOS EL BTN DE CONTINUAR
      }
      userBloc.add(UpdateProcedureId(
          json.decode(response.body)['data']['procedure_id']));
      if (json.decode(response.body)['data']['cell_phone_number'].length > 0) {
        userBloc.add(UpdatePhone(
            json.decode(response.body)['data']['cell_phone_number'][0]));
      }
    }
  }

  getContributions() async {
    final contributionBloc =
        BlocProvider.of<ContributionBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());
    if (!mounted) return;
    var response = await serviceMethod(mounted, context, 'get', null,
        serviceContributions(biometric.affiliateId!), true, true);
    if (response != null) {
      contributionBloc
          .add(UpdateContributions(contributionModelFromJson(response.body)));
    }
  }

  getLoans() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final loanBloc = BlocProvider.of<LoanBloc>(context, listen: false);
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());
    if (!mounted) return;
    var response = await serviceMethod(mounted, context, 'get', null,
        serviceLoans(biometric.affiliateId!), true, true);
    if (response != null) {
      loanBloc.add(UpdateLoan(loanModelFromJson(response.body)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateApp == StateAplication.complement) {
      pageList = [
        ScreenProcedures(
            current: true,
            scroll: _scrollController,
            keyProcedure: keyCreateProcedure,
            keyRefresh: keyRefresh,
            keyNotification: keyNotification,
            stateLoad: stateLoad),
        ScreenProcedures(current: false, scroll: _scrollController),
      ];
    }
    if (widget.stateApp == StateAplication.virtualOficine) {
      pageList = [
        ScreenContributions(keyNotification: keyNotification),
        ScreenPageLoans(keyNotification: keyNotification)
      ];
    }
    return PopScope(
      canPop:
          false, // Evita que el usuario cierre la app con el botón de retroceso
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        bool exitApp = await _onBackPressed();
        if (exitApp) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        drawer: const MenuDrawer(),
        body: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Column(
              children: [
                const SizedBox(height: 25),
                SizedBox(
                  key: keyMenu,
                  height: MediaQuery.of(context).size.width / 6,
                  width: MediaQuery.of(context).size.width / 6,
                ),
              ],
            ),
            pageList.elementAt(_currentIndex),
            NavigationDown(
              stateApp: widget.stateApp,
              currentIndex: _currentIndex,
              keyBottomNavigation1: keyBottomNavigation1,
              keyBottomNavigation2: keyBottomNavigation2,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ComponentAnimate(
              child: DialogTwoAction(
                  message:
                      '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
                  actionCorrect: () => SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop'),
                  messageCorrect: 'Salir'));
        });
  }

  void showTutorial() {
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xff419388),
      textSkip: "OMITIR",
      textStyleSkip: const TextStyle(
          color: Color(0xffE0A44C), fontWeight: FontWeight.bold),
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        setState(() => stateLoadTutorial = !stateLoadTutorial!);
        if (await checkVersion(mounted, context)) {
          if (widget.stateApp == StateAplication.complement) {
            getEconomicComplement(true);
            getEconomicComplement(false);
          } else {
            debugPrint('OBTENINENDO TODOS LOS APORTES Y PRESTAMOS');
            getContributions();
            getLoans();
          }
        }
      },
      onClickTarget: (target) {
        debugPrint('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        debugPrint("target: $target");
        debugPrint(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        debugPrint('onClickOverlay: $target');
      },
      onSkip: () => onSkip(),
    )..show(context: context);
  }

  onSkip() async {
    debugPrint("skip");
    setState(() => stateLoadTutorial = !stateLoadTutorial!);
    if (await checkVersion(mounted, context)) {
      if (widget.stateApp == StateAplication.complement) {
        getEconomicComplement(true);
        getEconomicComplement(false);
      } else {
        debugPrint('OBTENINENDO TODOS LOS APORTES Y PRESTAMOS');
        getContributions();
        getLoans();
      }
    }
  }

  void initTargets() {
    targets.clear();
    targets.add(targetBottomNagigation1(keyBottomNavigation1, widget.stateApp));
    targets.add(targetBottomNavigation2(keyBottomNavigation2, widget.stateApp));
    if (widget.stateApp == StateAplication.complement) {
      targets.add(targetCreateProcedure(keyCreateProcedure));
    }
    targets.add(targetNotification(keyNotification));
    targets.add(targetMenu(keyMenu));
    targets.add(targetRefresh(keyRefresh));
  }
}
