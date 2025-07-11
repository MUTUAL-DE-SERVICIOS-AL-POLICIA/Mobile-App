import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/procedure/procedure_bloc.dart';
import 'package:muserpol_pvt/model/procedure_model.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

ProcedureModel? procedureCurrent;
ProcedureModel? procedureHistory;

int pageCurrent = 1;
int pageHistory = 1;

Future<void> getEconomicComplement(BuildContext context,
    {required bool current}) async {
  final procedureBloc = BlocProvider.of<ProcedureBloc>(context, listen: false);

  final response = await serviceMethod(
    true,
    context,
    'get',
    null,
    serviceGetEconomicComplements(current ? pageCurrent : pageHistory, current),
    true,
    true,
  );

  if (response != null) {
    final data = procedureModelFromJson(response.body);

    if (current) {
      procedureCurrent = data;
      pageCurrent++;
      procedureBloc.add(AddCurrentProcedures(data.data!.data!));
    } else {
      procedureHistory = data;
      pageHistory++;
      procedureBloc.add(AddHistoryProcedures(data.data!.data!));
    }
  }
}
