import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/components/header_muserpol.dart';
import 'package:muserpol_pvt/components/target_list_service.dart';
import 'package:muserpol_pvt/screens/navigation_general_pages.dart';
import 'package:muserpol_pvt/screens/pages/menu.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/contribution_model.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';

class ScreenListService extends StatefulWidget {
  final bool showTutorial;
  const ScreenListService({super.key, required this.showTutorial});

  @override
  ScreenListServiceState createState() => ScreenListServiceState();
}

class ScreenListServiceState extends State<ScreenListService> {
  GlobalKey keyMenuButton = GlobalKey();
  GlobalKey keyComplemento = GlobalKey();
  GlobalKey keyAportes = GlobalKey();
  GlobalKey keyPrestamos = GlobalKey();
  GlobalKey keyPreEvaluacion = GlobalKey();

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  @override
  void initState() {
    super.initState();
    services();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.showTutorial) {
        showTutorial();
      }
      final userBloc =
          BlocProvider.of<UserBloc>(context, listen: false).state.user;
      if (userBloc != null) {
        debugPrint('Datos completos del userBloc:');
        debugPrint(json.encode(userBloc.toJson()));
      }
    });
  }

  services() async {
    if (await checkVersion(mounted, context)) {
      await getContributions();
      await getLoans();
    }
  }

  getContributions() async {
    final contributionBloc =
        BlocProvider.of<ContributionBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());

    if (!mounted) return;

    debugPrint("ingresa aca");
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
      onFinish: () => debugPrint("Tutorial Finalizado"),
      onClickTarget: (target) {
        debugPrint('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        debugPrint("target: $target");
        debugPrint(
            "clicked at position local: \${tapDetails.localPosition} - global: \${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        debugPrint('onClickOverlay: $target');
      },
      onSkip: () => onSkip(),
    )..show(context: context);
  }

  void initTargets() {
    targets = [
      targetMenuButton(keyMenuButton),
      targetComplemento(keyComplemento),
      targetAportes(keyAportes),
      targetPrestamos(keyPrestamos),
      targetPreEvaluacion(keyPreEvaluacion),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              optionTool(
                const Image(image: AssetImage('assets/images/couple.png')),
                'COMPLEMENTO ECONÓMICO',
                'Creación y seguimiento de trámites de Complemento Económico.',
                () => (),
                false,
                key: keyComplemento,
              ),
              optionTool(
                const Image(image: AssetImage('assets/images/computer.png')),
                'APORTES',
                'Consulta de aportes individuales.',
                () => goToModule(context, 1),
                false,
                key: keyAportes,
              ),
              optionTool(
                const Image(image: AssetImage('assets/images/computer.png')),
                'PRESTAMOS',
                'Consulta de historial de préstamos.',
                () => goToModule(context, 2),
                false,
                key: keyPrestamos,
              ),
              optionTool(
                const Image(image: AssetImage('assets/images/couple.png')),
                'PRE - EVALUACION DE PRESTAMOS',
                'Verifica si puedes acceder a un préstamo.',
                () => (),
                false,
                key: keyPreEvaluacion,
              ),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'Versión ${dotenv.env['version']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xff419388),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goToModule(BuildContext context, int index) {
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
      builder: (BuildContext context) {
        return ComponentAnimate(
          child: DialogTwoAction(
            message: '¿Estás seguro de salir de la aplicación MUSERPOL PVT?',
            actionCorrect: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            messageCorrect: 'Salir',
          ),
        );
      },
    );
  }

  bool onSkip() {
    return true;
  }

  Widget optionTool(
    Widget child,
    String title,
    String description,
    Function() onPress,
    bool qrstate, {
    Key? key,
  }) {
    return FadeIn(
      animate: true,
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => onPress(),
        child: ContainerComponent(
          key: key,
          width: double.infinity,
          color: const Color(0xffd9e9e7),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 60, height: 60, child: child),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        description,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
