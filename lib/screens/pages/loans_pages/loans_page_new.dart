import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/card_loan.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';

class ScreenLoansNew extends StatefulWidget {
  const ScreenLoansNew({super.key});

  @override
  State<ScreenLoansNew> createState() => _ScreenLoansNewState();
}

class _ScreenLoansNewState extends State<ScreenLoansNew> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loanBloc = BlocProvider.of<LoanBloc>(context, listen: true);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          reloadLoans();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mis Prestamos :',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                loanBloc.state.existLoan
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (loanBloc.state.loan!.notification!.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: AdaptiveTheme.of(context).mode.isDark
                                    ? const Color(0xff184741)
                                    : const Color(0xffD2EAFA),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.info_outline_rounded),
                                    const SizedBox(width: 10),
                                    Flexible(
                                        child: Text(loanBloc
                                            .state.loan!.notification!)),
                                  ],
                                ),
                              ),
                            ),
                          if (loanBloc
                              .state.loan!.payload!.inProcess!.isNotEmpty)
                            loans('Prestamos en proceso:', [
                              for (var item
                                  in loanBloc.state.loan!.payload!.inProcess!)
                                CardLoanNew(
                                    itemProcess: item,
                                    color: const Color(0xffB3D4CF))
                            ]),
                          if (loanBloc.state.loan!.payload!.current!.isNotEmpty)
                            loans('Prestamos vigentes:', [
                              for (var item
                                  in loanBloc.state.loan!.payload!.current!)
                                CardLoanNew(itemCurrent: item)
                            ]),
                          if (loanBloc
                              .state.loan!.payload!.liquited!.isNotEmpty)
                            loans('Prestamos Liquidados:', [
                              for (var item
                                  in loanBloc.state.loan!.payload!.liquited!)
                                CardLoanNew(itemCurrent: item)
                            ]),
                          if (loanBloc.state.loan!.error == 'true')
                            Text(loanBloc.state.loan!.message!),
                          const SizedBox(height: 70),
                        ],
                      )
                    : const Text("normal")
              ],
            ),
          ),
        ),
      ),
      //ACA TINENE QUE ESTAR LA PRE - EVALUACION
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        onPressed: () {
          showBarModalBottomSheet(
            expand: false,
            enableDrag: false,
            isDismissible: true,
            context: context,
            builder: (context) => (const Text("Aca debe estar la calculadora")),
          );
        },
        child: const Icon(Icons.add_circle),
      ),
    );
  }

  reloadLoans() async {
    final loanBloc = BlocProvider.of<LoanBloc>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    loanBloc.add(ClearLoans());
    final biometric =
        biometricUserModelFromJson(await authService.readBiometric());
    if (!mounted) return;
    var response = await serviceMethod(
      mounted,
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

  Widget loans(String text, List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
          ...cards
        ],
      ),
    );
  }
}
