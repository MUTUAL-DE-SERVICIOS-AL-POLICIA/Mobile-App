import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/contribution/contribution_bloc.dart';
import 'package:muserpol_pvt/components/containers.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/screens/pages/contributions_pages/tabs_contributions_new.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:muserpol_pvt/utils/save_document.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';

class ScreenContributionsNew extends StatefulWidget {
  const ScreenContributionsNew({super.key});

  @override
  State<ScreenContributionsNew> createState() => _ScreenContributionsStateNew();
}

class _ScreenContributionsStateNew extends State<ScreenContributionsNew> {
  bool stateLoading = false;
  @override
  Widget build(BuildContext context) {
    final contributionBloc =
        BlocProvider.of<ContributionBloc>(context, listen: true).state;
    return Column(
      children: [
        const Text('Mis Aportes:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 20.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !stateLoading
                  ? Row(
                      children: [
                        if (contributionBloc.existContribution)
                          if (contributionBloc
                              .contribution!.payload.hasContributionsActive!)
                            documentContribution(() => getContributionActive(),
                                'Certificación de Activo'),
                        if (contributionBloc.existContribution)
                          if (contributionBloc
                              .contribution!.payload.hasContributionsPassive!)
                            documentContribution(() => getContributionPasive(),
                                'Certificación de Pasivo')
                      ],
                    )
                  : Center(
                      child: Image.asset(
                      'assets/images/load.gif',
                      fit: BoxFit.cover,
                      height: 20,
                    )),
              if (contributionBloc.existContribution)
                const Text('Mis Aportes por año:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
            : const TabsContributionsNew(),
      ],
    );
  }

  Widget documentContribution(Function() onPressed, String text) {
    final contributionBloc =
        BlocProvider.of<ContributionBloc>(context, listen: true).state;
    return contributionBloc.existContribution
        ? Expanded(
            child: Container(
              padding: const EdgeInsets.all(5),
              child: GestureDetector(
                onTap: () => onPressed(),
                child: ContainerComponent(
                  color:
                      AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
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
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());
    setState(() => stateLoading = true);
    if (!mounted) return;
    var response = await serviceMethod(mounted, context, 'get', null,
        servicePrintContributionPasive(biometric.affiliateId!), true, false);
    setState(() => stateLoading = false);
    if (response != null) {
      String pathFile = await saveFile(
          'Contributions', 'contribucionesPasivo.pdf', response.bodyBytes);
      await OpenFilex.open(pathFile);
    }
  }

  getContributionActive() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());
    setState(() => stateLoading = true);
    if (!mounted) return;
    var response = await serviceMethod(mounted, context, 'get', null,
        servicePrintContributionActive(biometric.affiliateId!), true, false);
    setState(() => stateLoading = false);
    if (response != null) {
      String pathFile = await saveFile(
          'Contributions', 'contribucionesActivo.pdf', response.bodyBytes);
      await OpenFilex.open(pathFile);
    }
  }
}
