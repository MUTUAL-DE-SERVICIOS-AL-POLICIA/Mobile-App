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
import 'package:muserpol_pvt/screens/pages/menu.dart';
import 'package:muserpol_pvt/services/service_method.dart';

class ScreenListService extends StatefulWidget {
  const ScreenListService({super.key});

  @override
  ScreenListServiceState createState() => ScreenListServiceState();
}

class ScreenListServiceState extends State<ScreenListService> {
  @override
  void initState() {
    super.initState();

    // Mostramos los datos del usuario una vez montado el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userBloc =
          BlocProvider.of<UserBloc>(context, listen: false).state.user;
      if (userBloc != null) {
        debugPrint('Datos completos del userBloc:');
        debugPrint(json.encode(userBloc.toJson()));
      } else {
        debugPrint('userBloc es null');
      }
    });
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
          appBar: const AppBarDualTitle(),
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
                SizedBox(
                  height: 20.h,
                ),
                optionTool(
                  const Image(
                    image: AssetImage(
                      'assets/images/couple.png',
                    ),
                  ),
                  'COMPLEMENTO ECONÓMICO',
                  'Creación y seguimiento de trámites de Complemento Económico.',
                  () => (),
                  false,
                ),
                optionTool(
                  const Image(
                    image: AssetImage(
                      'assets/images/computer.png',
                    ),
                  ),
                  'APORTES',
                  'Creación y seguimiento de trámites de Complemento Económico.',
                  () => (),
                  false,
                ),
                optionTool(
                  const Image(
                    image: AssetImage(
                      'assets/images/computer.png',
                    ),
                  ),
                  'PRESTAMOS',
                  'Creación y seguimiento de trámites de Complemento Económico.',
                  () => (),
                  false,
                ),
                optionTool(
                  const Image(
                    image: AssetImage(
                      'assets/images/couple.png',
                    ),
                  ),
                  'PRE - EVALUACION DE PRESTAMOS',
                  'Creación y seguimiento de trámites de Complemento Económico.',
                  () => (),
                  false,
                ),
                SizedBox(
                  height: 20.h,
                ),
                Center(
                    child: Text(
                  'Versión ${dotenv.env['version']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 255, 255, 255)
                        : const Color(0xff419388),
                  ),
                )),
              ],
            ),
          )),
    );
  }

  closeSession(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return ComponentAnimate(
              child: DialogTwoAction(
                  message: '¿Estás seguro que quieres cerrar sesión?',
                  actionCorrect: () =>
                      confirmDeleteSession(mounted, context, true),
                  messageCorrect: 'Salir'));
        });
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

  Widget optionTool(Widget child, String title, String description,
      Function() onPress, bool qrstate) {
    return FadeIn(
      animate: true,
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: () => onPress(),
        child: ContainerComponent(
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
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: child,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Text(
                          description,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
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
