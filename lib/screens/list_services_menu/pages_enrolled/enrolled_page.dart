import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
// import 'package:muserpol_pvt/components/header_muserpol.dart';
import 'package:muserpol_pvt/components/headers.dart';
// import 'package:muserpol_pvt/model/liveness_data_model.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

class ScreenEnrolledService extends StatefulWidget {
  const ScreenEnrolledService({super.key});

  @override
  State<ScreenEnrolledService> createState() => _ScreenEnrolledServiceState();
}

class _ScreenEnrolledServiceState extends State<ScreenEnrolledService> {
  @override
  void initState() {
    super.initState();
    getMessage();
  }

  getMessage() async {
    // final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    var response = await serviceMethod(mounted, context, 'get', null,
        serviceProcessEnrolled(null), true, true);
    if (response != null) {
      debugPrint("ingreso aca");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop:
            false, // Evita que el usuario cierre la pantalla con el botón de retroceso
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          bool exitScreen = await _onBackPressed();
          if (exitScreen) {
            Navigator.of(context).pop();
          }
        },
        child: const Scaffold(
          body: SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: HedersComponent(
                    titleHeader: "PROCESO DE ENROLAMIENTO",
                    title:
                        "Para el acceso a la Aplicación Móvil debe realizar el proceso de enrolamiento por única vez mediante fotografías de su rostro. Debe quitarse anteojos, sombrero y barbijo para realizar el proceso correctamente.",
                    center: true,
                  ),
                ),
                // Expanded(
                //   child: DefaultTabController(
                //     length: 2,
                //     child: TabBarView(
                //       controller: tabController,
                //       physics: const NeverScrollableScrollPhysics(),
                //       children: [
                //         TabInfo(
                //           text: textContent,
                //           nextScreen: () {
                //             setState(() {
                //               title = message;
                //               titleHeader = titleback;
                //             });
                //             tabController!.animateTo(tabController!.index + 1);
                //           },
                //         ),
                //         ImageCtrlLive(
                //           sendImage: (image) => sendImage(image),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ));
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ComponentAnimate(
            child: DialogTwoAction(
                message: '¿DESEAS SALIR DEL ENROLAMIENTO?',
                actionCorrect: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                messageCorrect: 'Salir')));
  }
}
