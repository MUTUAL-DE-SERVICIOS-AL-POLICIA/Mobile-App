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
import 'package:muserpol_pvt/provider/files_state.dart';
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

// Widget principal
class NavigatorBar extends StatefulWidget {
  final bool tutorial; // Indica si se debe mostrar el tutorial
  final StateAplication
      stateApp; // Estado actual de la aplicación (complemento u oficina virtual)

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
  var _currentIndex = 0; // Página seleccionada en el bottom navigation

  int pageCurrent = 1;
  int pageHistory = 1;
  bool stateProcessing = false;

  // Llaves para ubicar elementos en el tutorial
  GlobalKey keyBottomNavigation1 = GlobalKey();
  GlobalKey keyBottomNavigation2 = GlobalKey();
  GlobalKey keyCreateProcedure = GlobalKey();
  GlobalKey keyNotification = GlobalKey();
  GlobalKey keyMenu = GlobalKey();
  GlobalKey keyRefresh = GlobalKey();

  List<Widget> pageList = [];

  bool stateLoad = true; // Cargando datos
  bool? stateLoadTutorial; // Tutorial cargado
  bool consumeService =
      true; // Controla si se puede seguir cargando más datos (scroll infinito)

  @override
  void initState() {
    super.initState();
    services(); // Llama a los servicios cuando inicia
    setState(() => stateLoadTutorial = widget.tutorial);
  }

  // Lógica principal para cargar servicios y datos según el estado de la app
  services() async {
    if (await checkVersion(mounted, context)) {
      if (widget.stateApp == StateAplication.complement) {
        await getProcessingPermit();
        await getObservations();

        // Detecta scroll hasta el fondo para paginar
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

      // Si hay tutorial, lo mostramos
      if (widget.tutorial && stateLoadTutorial!) {
        setState(() => stateLoad = false);
        Future.delayed(const Duration(milliseconds: 500), showTutorial);
      } else {
        // Si no hay tutorial, carga datos normalmente
        if (widget.stateApp == StateAplication.complement) {
          await getEconomicComplement(true);
          await getEconomicComplement(false);
        } else {
          await getContributions();
          await getLoans();
        }
      }
    }
  }

  // Refresca todo el estado de la app
  refresh() async {
    setState(() => stateLoad = true);

    if (await checkVersion(mounted, context)) {
      if (!mounted) return;

      // Limpia estados y vuelve a cargar
      final filesState = Provider.of<FilesState>(context, listen: false);
      final tabProcedureState =
          Provider.of<TabProcedureState>(context, listen: false);
      final processingState =
          Provider.of<ProcessingState>(context, listen: false);
      final procedureBloc =
          BlocProvider.of<ProcedureBloc>(context, listen: false);

      tabProcedureState.updateTabProcedure(0);
      for (var element in filesState.files) {
        filesState.updateFile(element.id!, null);
      }
      processingState.updateStateProcessing(false);
      procedureBloc.add(ClearProcedures());

      setState(() {
        pageCurrent = 1;
        pageHistory = 1;
      });

      // Vuelve a obtener los datos
      if (widget.stateApp == StateAplication.complement) {
        await getProcessingPermit();
        await getObservations();
        await getEconomicComplement(true);
        await getEconomicComplement(false);
      } else {
        await getContributions();
        await getLoans();
      }
    } else {
      setState(() => stateLoad = false);
    }
  }

  // Obtiene complementos económicos (paginados)
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

  // Obtiene observaciones del usuario
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

  // Permisos de proceso
  getProcessingPermit() async {
    final loadingState = Provider.of<LoadingState>(context, listen: false);
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final tabProcedureState =
        Provider.of<TabProcedureState>(context, listen: false);

    if (!mounted) return;

    var response = await serviceMethod(mounted, context, 'get', null,
        serviceGetProcessingPermit(userBloc.state.user!.id!), true, false);

    if (response != null) {
      var data = json.decode(response.body)['data'];
      userBloc.add(UpdateCtrlLive(data['liveness_success']));
      userBloc.add(UpdateProcedureId(data['procedure_id']));

      if (data['cell_phone_number'].length > 0) {
        userBloc.add(UpdatePhone(data['cell_phone_number'][0]));
      }

      if (data['liveness_success']) {
        tabProcedureState.updateTabProcedure(1);
        if (userBloc.state.user!.verified!) {
          loadingState.updateStateLoadingProcedure(true);
        } else {
          loadingState.updateStateLoadingProcedure(false);
        }
      } else {
        tabProcedureState.updateTabProcedure(0);
        loadingState.updateStateLoadingProcedure(false);
      }
    }
  }

  // Obtiene aportes
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

  // Obtiene préstamos
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

  // Construcción del widget visual
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
            reload: () => refresh(),
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
      canPop: false,
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

  // Muestra diálogo al presionar botón atrás
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

  // Mostrar el tutorial
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
      onSkip: onSkip,
    )..show(context: context);
  }

  bool onSkip() {
    setState(() => stateLoadTutorial = !stateLoadTutorial!);
    if (widget.stateApp == StateAplication.complement) {
      getEconomicComplement(true);
      getEconomicComplement(false);
    } else {
      getContributions();
      getLoans();
    }
    Future.delayed(const Duration(milliseconds: 100), () async {});

    return true;
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
