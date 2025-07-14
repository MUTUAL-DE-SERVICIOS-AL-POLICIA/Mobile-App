import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/screens/list_services_menu/pages_enrolled/enrolled_page.dart';
import 'package:muserpol_pvt/screens/list_services_menu/sevice_loader_complement.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/components/animate.dart';
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
  final GlobalKey keyPreEvaluacion = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showTutorial) {
        _showTutorial();
      }
    });
  }

  Future<void> _loadInitialData() async {
    final userBloc =
        BlocProvider.of<UserBloc>(context, listen: false).state.user;

    if (userBloc != null) {
      debugPrint('Datos completos del userBloc:');
      debugPrint(json.encode(userBloc.toJson()));
    }

    if (userBloc?.belongsToEconomicComplement == true) {
      await loadGeneralServicesComplementEconomic(context);
      await getEconomicComplement(context, current: true);
      // await getEconomicComplement(context, current: false);
    }

    await loadGeneralServices(context);
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: getTutorialTargets(
        keyMenuButton: keyMenuButton,
        keyComplemento: keyComplemento,
        keyAportes: keyAportes,
        keyPrestamos: keyPrestamos,
        keyPreEvaluacion: keyPreEvaluacion,
      ),
      colorShadow: const Color(0xff419388),
      textSkip: "OMITIR",
      textStyleSkip: const TextStyle(
        color: Color(0xffE0A44C),
        fontWeight: FontWeight.bold,
      ),
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () => debugPrint("Tutorial Finalizado"),
    )..show(context: context);
  }

  void _goToModule(int index) async {
    if (index == 0) {
      final userBloc =
          BlocProvider.of<UserBloc>(context, listen: false).state.user;

      if (userBloc?.enrolled == false) {
        // Logica le pedira las fotos para enrolarse
        // Redirigir a una
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigatorBarGeneral(initialIndex: index),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => ComponentAnimate(
        child: DialogTwoAction(
          message: '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
          actionCorrect: () =>
              SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
          messageCorrect: 'Salir',
        ),
      ),
    );
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
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
              //Llama la lista de servicios al afiliado
              //Existiran 3 servicios generales -> APORTES, PRESTAMOS, PRE-EVALUACION
              //Servicio unico para los beneficiarios -> COMPLEMENTO ECONOMICO
              ServiceOption(
                key: keyComplemento,
                image: 'assets/images/couple.png',
                title: 'COMPLEMENTO ECONÓMICO',
                description:
                    'Creación e Historial de trámites de Complemento Económico.',
                onPressed: () async {
                  final userBloc =
                      BlocProvider.of<UserBloc>(context, listen: false)
                          .state
                          .user;

                  if (userBloc?.belongsToEconomicComplement == true) {
                    // Si tiene acceso, Ingresa a Complemento Economico
                    if (userBloc?.enrolled == false) {
                      debugPrint("Enviarlo a modal de enrolamiento");
                      //Se enviara al modal de enrolamiento para que se pueda guardar las fotografias correspoondientes
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ScreenEnrolledService(),
                        ),
                      );
                    } else {
                      _goToModule(0);
                    }
                  } else {
                    // Si no tiene acceso, mostrar el modal
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Acceso Denegado"),
                        content: const Text(
                            "Usted no es beneficiario del Complemento Económico."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cerrar"),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

              ServiceOption(
                key: keyAportes,
                image: 'assets/images/computer.png',
                title: 'APORTES',
                description: 'Consulta de aportes individuales.',
                onPressed: () => _goToModule(1),
              ),
              ServiceOption(
                key: keyPrestamos,
                image: 'assets/images/computer.png',
                title: 'PRÉSTAMOS',
                description: 'Consulta de historial de préstamos.',
                onPressed: () => _goToModule(2),
              ),
              ServiceOption(
                key: keyPreEvaluacion,
                image: 'assets/images/couple.png',
                title: 'PRE-EVALUACIÓN DE PRÉSTAMOS',
                description: 'Verifica si puedes acceder a un préstamo.',
                onPressed: () {}, // A futuro
              ),
              SizedBox(height: 20.h),
              // Center(
              //   child: Text(
              //     'Versión ${dotenv.env['version']}',
              //     style: TextStyle(
              //       fontSize: 12.sp,
              //       color: Theme.of(context).brightness == Brightness.dark
              //           ? Colors.white
              //           : const Color.fromARGB(255, 0, 0, 0),
              //     ),
              //   ),
              // ),
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
