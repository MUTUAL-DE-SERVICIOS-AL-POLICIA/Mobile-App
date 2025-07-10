import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/model/contribution_model.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/provider/app_state.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';

Future<void> loadGeneralServices(BuildContext context) async {
  await _loadContributions(context);
  await _loadLoans(context);
}

Future<void> loadEconomicComplementServices(BuildContext context) async {
  if (await checkVersion(true, context)) {
    final observationState =
        Provider.of<ObservationState>(context, listen: false);
    final processingState =
        Provider.of<ProcessingState>(context, listen: false);
    final userBloc = BlocProvider.of<UserBloc>(context, listen: false);

    var response = await serviceMethod(
      true,
      context,
      'get',
      null,
      serviceGetObservation(userBloc.state.user!.id!),
      true,
      true,
    );

    if (response != null) {
      observationState.updateObservation(response.body);
      if (json.decode(response.body)['data']['enabled']) {
        processingState.updateStateProcessing(true);
      }
    }
  }
}

Future<void> _loadContributions(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final biometric =
      biometricUserModelFromJson(await authService.readBiometric());
  final contributionBloc =
      BlocProvider.of<ContributionBloc>(context, listen: false);

  var response = await serviceMethod(
    true,
    context,
    'get',
    null,
    serviceContributions(biometric.affiliateId!),
    true,
    true,
  );

  if (response != null) {
    contributionBloc
        .add(UpdateContributions(contributionModelFromJson(response.body)));
  }
}

Future<void> _loadLoans(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);
  final biometric =
      biometricUserModelFromJson(await authService.readBiometric());
  final loanBloc = BlocProvider.of<LoanBloc>(context, listen: false);

  var response = await serviceMethod(
    true,
    context,
    'get',
    null,
    serviceLoans(biometric.affiliateId!),
    true,
    true,
  );

  if (response != null) {
    loanBloc.add(UpdateLoan(loanModelFromJson(response.body)));
  }
}
