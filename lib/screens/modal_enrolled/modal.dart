import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/animate.dart';
import 'package:muserpol_pvt/components/headers.dart';
import 'package:muserpol_pvt/components/image_ctrl_live.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/components/dialog_action.dart';
import 'package:muserpol_pvt/model/liveness_data_model.dart';
import 'package:muserpol_pvt/screens/modal_enrolled/tab_info.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

class ModalInsideModal extends StatefulWidget {
  final Function(String) nextScreen;
  final bool stateFacialRecognition;
  final String? deviceId;
  final String? firebaseToken;
  const ModalInsideModal(
      {super.key,
      required this.nextScreen,
      this.deviceId,
      this.stateFacialRecognition = false,
      this.firebaseToken});

  @override
  State<ModalInsideModal> createState() => _ModalInsideModalState();
}

class _ModalInsideModalState extends State<ModalInsideModal>
    with TickerProviderStateMixin {
  TabController? tabController;
  String title = '';
  String textContent = '';
  String message = '';
  LivenesData? infoLivenes;
  String titleback = '';
  String titleHeader = '';

  @override
  void initState() {
    super.initState();
    getMessage();
  }

  getMessage() async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    var response = await serviceMethod(
        mounted,
        context,
        'get',
        null,
        serviceProcessEnrolled(
            widget.stateFacialRecognition ? widget.deviceId : null),
        true,
        true);
    if (response != null) {
      userBloc.add(UpdateStateCam(true));
      setState(() {
        infoLivenes = livenesDataFromJson(response.body);
        title = infoLivenes!.data!.dialog!.title!;
        titleback = infoLivenes!.data!.dialog!.title!;
        textContent = infoLivenes!.data!.dialog!.content!;
        message = infoLivenes!.data!.action!.message!;
        tabController = TabController(vsync: this, length: 2);
      });
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
      child: Scaffold(
        body: SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: HedersComponent(
                  titleHeader: titleHeader,
                  title: title,
                  center: true,
                ),
              ),
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: TabBarView(
                    controller: tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      TabInfo(
                        text: textContent,
                        nextScreen: () {
                          setState(() {
                            title = message;
                            titleHeader = titleback;
                          });
                          tabController!.animateTo(tabController!.index + 1);
                        },
                      ),
                      ImageCtrlLive(
                        sendImage: (image) => sendImage(image),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => ComponentAnimate(
            child: DialogTwoAction(
                message: '¿DESEAS SALIR DEL $titleback?',
                actionCorrect: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                messageCorrect: 'Salir')));
  }

  sendImage(String image) async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final Map<String, dynamic> body = {
      'firebase_token': widget.firebaseToken,
      'device_id': widget.deviceId,
      'image': image
    };

    debugPrint(body.toString());
    var response = await serviceMethod(mounted, context, 'post', body,
        serviceProcessEnrolled(null), true, true);
    userBloc.add(UpdateStateCam(true));
    if (response != null) {
      if (json.decode(response.body)['error']) {
        setState(() =>
            title = json.decode(response.body)['data']['action']['message']);
        if (!mounted) return;
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) =>
                DialogAction(message: json.decode(response.body)['message']));
      } else {
        if (json.decode(response.body)['data']['completed']) {
          return widget.nextScreen(json.decode(response.body)['message']);
        } else {
          setState(() =>
              title = json.decode(response.body)['data']['action']['message']);
          if (!mounted) return;
          showSuccessful(
              context,
              'Correcto, ${json.decode(response.body)['data']['action']['message']}',
              () {});
        }
      }
    }
  }
}
