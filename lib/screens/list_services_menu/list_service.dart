import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/screens/modal_enrolled/modal.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/screens/navigation_general_pages.dart';
import 'package:muserpol_pvt/screens/pages/menu.dart';
import 'package:muserpol_pvt/components/header_muserpol.dart';
import 'service_loader.dart';
import 'service_option.dart';
import 'tutorial_targets.dart';

class ScreenListService extends StatefulWidget {
  final bool showTutorial;
  const ScreenListService({super.key, required this.showTutorial});

  @override
  State<ScreenListService> createState() => _ScreenListServiceState();
}

class _ScreenListServiceState extends State<ScreenListService> {
  final GlobalKey keyMenuButton = GlobalKey();
  final GlobalKey keyComplemento = GlobalKey();
  final GlobalKey keyAportes = GlobalKey();
  final GlobalKey keyPrestamos = GlobalKey();

  TutorialCoachMark? tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    checkVersion(mounted, context);
    _loadInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showTutorial && mounted) {
        _showTutorial();
      }
    });
  }

  Future<void> _loadInitialData() async {
    final userBloc =
        BlocProvider.of<UserBloc>(context, listen: false).state.user;

    if (userBloc?.isEconomicComplement == true) {
      if (!mounted) return;
      await loadGeneralServicesComplementEconomic(context);
    }

    if (!mounted) return;
    await loadGeneralServices(context);
  }

  void _showTutorial() {
    if (!mounted) return;
    tutorialCoachMark = TutorialCoachMark(
      targets: getTutorialTargets(
        keyMenuButton: keyMenuButton,
        keyComplemento: keyComplemento,
        keyAportes: keyAportes,
        keyPrestamos: keyPrestamos,
      ),
      colorShadow: const Color(0xff419388),
      textSkip: "OMITIR",
      textStyleSkip: const TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontWeight: FontWeight.bold,
        fontSize: 30,
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () => debugPrint("Tutorial Finalizado"),
    )..show(context: context);
  }

  void _closeTutorialIfActive() {
    if (tutorialCoachMark != null && tutorialCoachMark!.isShowing) {
      try {
        tutorialCoachMark!.skip();
      } catch (e) {
        debugPrint("Error cerrando tutorial: $e");
      }
    }
  }

  void _goToModule(int index) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigatorBarGeneral(initialIndex: index),
      ),
    );
  }

  _onBackPressed() async {
    return await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (_) => DialogTwoAction(
        message: '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
        actionCorrect: () => Navigator.of(context).pop(true),
        actionCancel: () => Navigator.of(context).pop(false),
        messageCorrect: 'Salir',
      ),
    );
  }

  @override
  void dispose() {
    _closeTutorialIfActive();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _onBackPressed();
        if (exit) SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      },
      child: Scaffold(
        appBar: AppBarDualTitle(keyMenuButton: keyMenuButton),
        drawer: const MenuDrawer(),
        body: CustomMaterialIndicator(
          onRefresh: () async {
            await _loadInitialData();
            await Future.delayed(const Duration(seconds: 2));
          },
          trigger: IndicatorTrigger.leadingEdge,
          triggerMode: IndicatorTriggerMode.onEdge,
          trailingScrollIndicatorVisible: false,
          notificationPredicate: (notification) => notification.depth == 0,
          backgroundColor: const Color(0xff419388),
          indicatorBuilder: (context, controller) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Nuestros Servicios',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ServiceOption(
                key: keyComplemento,
                image: 'assets/images/icon_complement_economic.png',
                title: 'COMPLEMENTO ECONÓMICO',
                description:
                    'Creación e Historial de trámites de Complemento Económico.',
                onPressed: () async {
                  final userBloc =
                      BlocProvider.of<UserBloc>(context, listen: false)
                          .state
                          .user;

                  if (userBloc?.isEconomicComplement == true) {
                    // Si tiene acceso, Ingresa a Complemento Economico
                    if (userBloc?.enrolled == false) {
                      return showBarModalBottomSheet(
                          expand: false,
                          enableDrag: false,
                          isDismissible: false,
                          context: context,
                          builder: (contextModal) => ModalInsideModal(
                                nextScreen: (message) {
                                  return showSuccessful(context, message,
                                      () async {
                                    Navigator.pop(contextModal);
                                    _goToModule(0);
                                  });
                                },
                              ));
                    } else {
                      _goToModule(0);
                    }
                  } else {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.warning_amber,
                                  size: 40,
                                  color: Colors.amber,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Usted no es beneficiario, contactarse con la MUSERPOL',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 20),
                                ButtonComponent(
                                  text: 'OK',
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            ),
                          );
                        });
                  }
                },
              ),
              ServiceOption(
                key: keyAportes,
                image: 'assets/images/icon_contributions.png',
                title: 'CERTIFICACIÓN DE APORTES',
                description:
                    'Consulta y Descarga tus aportes individuales de activo o pasivo.',
                onPressed: () => _goToModule(1),
              ),
              ServiceOption(
                key: keyPrestamos,
                image: 'assets/images/icon_loans.png',
                title: 'SERVICIOS DE PRÉSTAMOS',
                description:
                    'Consulta de historial de préstamos, Realiza tu calculo para tu nuevo préstamo.',
                onPressed: () => _goToModule(2),
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'Versión 4.0.1',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
