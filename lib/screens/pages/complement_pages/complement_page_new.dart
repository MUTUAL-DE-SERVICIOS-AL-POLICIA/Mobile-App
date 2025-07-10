import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:provider/provider.dart';

class ScreenComplementNew extends StatefulWidget {
  const ScreenComplementNew({super.key});

  @override
  State<ScreenComplementNew> createState() => _ScreenComplementNewState();
}

class _ScreenComplementNewState extends State<ScreenComplementNew> {
  bool stateBtn = true;

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
              'Nuevo Tramite CE: ',
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
      ],
    );
  }
}
