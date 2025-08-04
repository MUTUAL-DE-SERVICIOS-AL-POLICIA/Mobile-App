import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/card_observation.dart';
import 'package:muserpol_pvt/components/susessful.dart';
import 'package:muserpol_pvt/main.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/provider/files_state.dart';
// import 'package:muserpol_pvt/screens/list_services_menu/service_loader.dart';
// import 'package:muserpol_pvt/screens/list_services_menu/sevice_loader_complement.dart';
import 'package:muserpol_pvt/screens/pages/complement/card_economic_complement.dart';
import 'package:muserpol_pvt/screens/pages/complement/new_procedure/card_procedure.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/save_document.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

class ScreenComplementNew extends StatefulWidget {
  const ScreenComplementNew({super.key});

  @override
  State<ScreenComplementNew> createState() => _ScreenComplementNewState();
}

class _ScreenComplementNewState extends State<ScreenComplementNew> {
  bool stateBtn = true;
  late final ScrollController scroll;

  @override
  void initState() {
    super.initState();
    scroll = ScrollController();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final procedureBloc =
        BlocProvider.of<ProcedureBloc>(context, listen: true).state;
    final observationState =
        Provider.of<ObservationState>(context, listen: true);
    final processingState = Provider.of<ProcessingState>(context, listen: true);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Complemento Economico ',
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
        observationState.messageObservation != ''
            ? json.decode(observationState.messageObservation)['message'] != ""
                ? const CardObservation()
                : Container()
            : Container(),
        if (true && stateBtn)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: ButtonComponent(
                text: 'CREAR TRÁMITE',
                onPressed: stateBtn && processingState.stateProcessing
                    ? () => create()
                    //si esta null el boton estara no disponible
                    : null),
          ),
        if (!stateBtn)
          Image.asset(
            'assets/images/load.gif',
            fit: BoxFit.cover,
            height: 20,
          ),
        if (true)
          Expanded(
              child: procedureBloc.existCurrentProcedures
                  ? procedureBloc.currentProcedures!.isEmpty
                      ? (processingState.stateProcessing && true)
                          ? stateInfo()
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('No se encontraron trámites'),
                                  stateInfo()
                                ],
                              ),
                            )
                      : SingleChildScrollView(
                          controller: scroll,
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 70),
                              child: Column(
                                children: [
                                  for (var item
                                      in procedureBloc.currentProcedures!)
                                    CardEc(item: item),
                                  stateInfo()
                                ],
                              )))
                  : stateInfo()),
      ],
    );
  }

  create() async {
    final filesState = Provider.of<FilesState>(context, listen: false);
    setState(() => stateBtn = false);
    await controleVerified();
    await getProcessingPermit();
    setState(() => stateBtn = true);
    for (var element in filesState.files) {
      filesState.updateFile(element.id!, null);
    }
    if (!mounted) return;
    return showBarModalBottomSheet(
      duration: const Duration(milliseconds: 800),
      expand: false,
      enableDrag: false,
      isDismissible: false,
      context: context,
      builder: (context) => StepperProcedure(
        endProcedure: (response) => procedure(response),
      ),
    );
  }

  procedure(dynamic response) {
    final filesState = Provider.of<FilesState>(context, listen: false);
    final procedureBloc = Provider.of<ProcedureBloc>(context, listen: false);
    final tabProcedureState =
        Provider.of<TabProcedureState>(context, listen: false);
    return showSuccessful(context, 'Trámite registrado correctamente',
        () async {
      if (!prefs!.getBool('isDoblePerception')!) {
        String pathFile = await saveFile(
            'Documents',
            'sol_eco_com_${DateTime.now().millisecondsSinceEpoch}.pdf',
            response.bodyBytes);
        await OpenFilex.open(pathFile);
      }

      setState(() {
        tabProcedureState.updateTabProcedure(0);
        filesState.clearFiles();
      });

      // await getEconomicComplement();
      // await getObservations();
      procedureBloc.add(UpdateStateComplementInfo(false));
      // return widget.reload!();
    });
  }

  controleVerified() async {
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    var response = await serviceMethod(
        mounted, context, 'get', null, serviceGetMessageFace(), true, true);
    if (response != null) {
      userBloc.add(UpdateVerifiedDocument(
          json.decode(response.body)['data']['verified']));
    }
  }

  getProcessingPermit() async {
    final loadingState = Provider.of<LoadingState>(context, listen: false);
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);
    final tabProcedureState =
        Provider.of<TabProcedureState>(context, listen: false);
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
        setState(() {});
      }
      userBloc.add(UpdateProcedureId(
          json.decode(response.body)['data']['procedure_id']));
      if (json.decode(response.body)['data']['cell_phone_number'].length > 0) {
        userBloc.add(UpdatePhone(
            json.decode(response.body)['data']['cell_phone_number'][0]));
      }
    }
  }

// RELOAD recargar la pagina una vez realizada el proceso de tramites e igula implementear
//refresh en acciones que tengan un post, recargar la base de datos interna
 //Se nesecita actualizar 
  // refresh() async {
  //   if (!mounted) return;

  //   // Limpia estados y vuelve a cargar
  //   final filesState = Provider.of<FilesState>(context, listen: false);
  //   final tabProcedureState =
  //       Provider.of<TabProcedureState>(context, listen: false);
  //   final processingState =
  //       Provider.of<ProcessingState>(context, listen: false);
  //   final procedureBloc =
  //       BlocProvider.of<ProcedureBloc>(context, listen: false);

  //   tabProcedureState.updateTabProcedure(0);
  //   for (var element in filesState.files) {
  //     filesState.updateFile(element.id!, null);
  //   }
  //   processingState.updateStateProcessing(false);
  //   procedureBloc.add(ClearProcedures());

  //   await getProcessingPermit();
  //   // await loadEconomicComplementServices();
  //   // await getEconomicComplement(true);
  //   // await getEconomicComplement(false);
  // }

  Widget stateInfo() {
    return Center(
        child: IconBtnComponent(
            iconText: 'assets/icons/reload.svg', onPressed: () => ()));
  }
}
