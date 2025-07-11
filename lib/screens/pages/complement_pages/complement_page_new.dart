import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/components/button.dart';
import 'package:muserpol_pvt/components/card_observation.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/screens/pages/complement/card_economic_complement.dart';
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
                    ? () => ()
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

  Widget stateInfo() {
    return Center(
        child: IconBtnComponent(
            iconText: 'assets/icons/reload.svg', onPressed: () => ()));
  }
}
