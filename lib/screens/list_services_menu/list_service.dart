import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/screens/list_services_menu/service_loader.dart';
import 'package:muserpol_pvt/screens/modal_enrolled/modal.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/screens/navigation_general_pages.dart';
import 'package:muserpol_pvt/screens/pages/menu.dart';
import 'package:muserpol_pvt/components/header_muserpol.dart';

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
  bool isGridView = false;

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
        color: Colors.white,
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

  void _goToModule(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigatorBarGeneral(initialIndex: index),
      ),
    );
  }

  Future<bool?> _onBackPressed() async {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final services = <_ServiceData>[
      _ServiceData(
        key: keyComplemento,
        image: 'assets/images/icon_complement_economic.png',
        title: 'Complemento Económico',
        description:
            'Creación e historial de trámites de Complemento Económico.',
        onPressed: () async {
          final userBloc =
              BlocProvider.of<UserBloc>(context, listen: false).state.user;

          if (userBloc?.isEconomicComplement == true) {
            if (userBloc?.enrolled == false) {
              return showBarModalBottomSheet(
                expand: false,
                enableDrag: false,
                isDismissible: false,
                context: context,
                builder: (contextModal) => ModalInsideModal(
                  nextScreen: (message) {
                    return showSuccessful(context, message, () async {
                      Navigator.pop(contextModal);
                      _goToModule(0);
                    });
                  },
                ),
              );
            } else {
              _goToModule(0);
            }
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext contextDialog) {
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
                        onPressed: () => Navigator.of(contextDialog).pop(),
                      )
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      _ServiceData(
        key: keyAportes,
        image: 'assets/images/icon_contributions.png',
        title: 'Certificación de Aportes',
        description:
            'Consulta y descarga tus aportes individuales de activo o pasivo.',
        onPressed: () => _goToModule(1),
      ),
      _ServiceData(
        key: keyPrestamos,
        image: 'assets/images/icon_loans.png',
        title: 'Préstamos',
        description:
            'Consulta de historial de préstamos, Realiza tu calculo para tu nuevo préstamo.',
        onPressed: () => _goToModule(2),
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _onBackPressed();
        if (exit == true) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
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
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Nuestros Servicios',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(
                        isGridView ? Icons.view_list : Icons.grid_view,
                        color: const Color(0xff419388),
                      ),
                      onPressed: () {
                        setState(() {
                          isGridView = !isGridView;
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              if (!isGridView) ...[
                for (final s in services)
                  ServiceOption(
                    key: s.key,
                    image: s.image,
                    title: s.title,
                    description: s.description,
                    onPressed: s.onPressed,
                  ),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final s = services[index];
                      final isLastOdd =
                          services.length.isOdd && index == services.length - 1;

                      if (isLastOdd) {
                        return Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2 - 32,
                            child: ServiceGridItem(
                              service: s,
                            ),
                          ),
                        );
                      }

                      return ServiceGridItem(service: s);
                    },
                  ),
                ),
              ],

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceData {
  final Key key;
  final String image;
  final String title;
  final String description;
  final VoidCallback onPressed;

  _ServiceData({
    required this.key,
    required this.image,
    required this.title,
    required this.description,
    required this.onPressed,
  });
}

class ServiceGridItem extends StatelessWidget {
  final _ServiceData service;

  const ServiceGridItem({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: service.onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffd9e9e7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
              color: Colors.black26,
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              service.image,
              width: 64,
              height: 64,
            ),
            const SizedBox(height: 12),
            Text(
              service.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
