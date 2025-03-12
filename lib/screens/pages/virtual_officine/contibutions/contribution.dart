import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/components/headers.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/screens/pages/virtual_officine/contibutions/tabs_contributions.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/save_document.dart';
// import 'package:open_file_safe/open_file_safe.dart';
import 'package:open_file_safe_plus/open_file_safe_plus.dart';
import 'package:provider/provider.dart';

class ScreenContributions extends StatefulWidget {
  final GlobalKey? keyNotification;
  const ScreenContributions({super.key, required this.keyNotification});

  @override
  State<ScreenContributions> createState() => _ScreenContributionsState();
}

class _ScreenContributionsState extends State<ScreenContributions> {
  bool stateLoading = false;
  @override
  Widget build(BuildContext context) {
    final contributionBloc = BlocProvider.of<ContributionBloc>(context, listen: true).state;
    return Column(children: [
      HedersComponent(keyNotification: widget.keyNotification, title: 'Mis Aportes', stateBell: true),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !stateLoading
                ? Row(
                    children: [
                      if (contributionBloc.existContribution)
                        if (contributionBloc.contribution!.payload.hasContributionsActive!)
                          documentContribution(() => getContributionActive(), 'Certificación de Activo'),
                      if (contributionBloc.existContribution)
                        if (contributionBloc.contribution!.payload.hasContributionsPassive!)
                          documentContribution(() => getContributionPasive(), 'Certificación de Pasivo')
                    ],
                  )
                : Center(
                    child: Image.asset(
                    'assets/images/load.gif',
                    fit: BoxFit.cover,
                    height: 20,
                  )),
            if (contributionBloc.existContribution)
              const Text('Mis Aportes por año:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
      !contributionBloc.existContribution
          ? Center(
              child: Image.asset(
              'assets/images/load.gif',
              fit: BoxFit.cover,
              height: 20,
            ))
          : const TabsContributions(),
    ]);
  }

  Widget documentContribution(Function() onPressed, String text) {
    final contributionBloc = BlocProvider.of<ContributionBloc>(context, listen: true).state;
    return contributionBloc.existContribution
        ? Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () => onPressed(),
                child: ContainerComponent(
                  color: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          )
        : Container();
  }

  getContributionPasive() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final biometric = biometricUserModelFromJson(await authService.readBiometric());
    setState(() => stateLoading = true);
    if (!mounted) return;
    var response = await serviceMethod(
        mounted, context, 'get', null, servicePrintContributionPasive(biometric.affiliateId!), true, false);
    setState(() => stateLoading = false);
    if (response != null) {
      String pathFile = await saveFile('Contributions', 'contribucionesPasivo.pdf', response.bodyBytes);
      await OpenFileSafePlus.open(pathFile);
    }
  }

  getContributionActive() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final biometric = biometricUserModelFromJson(await authService.readBiometric());
    setState(() => stateLoading = true);
    if (!mounted) return;
    var response = await serviceMethod(
        mounted, context, 'get', null, servicePrintContributionActive(biometric.affiliateId!), true, false);
    setState(() => stateLoading = false);
    if (response != null) {
      String pathFile = await saveFile('Contributions', 'contribucionesActivo.pdf', response.bodyBytes);
      await OpenFileSafePlus.open(pathFile);
    }
  }
}
