import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/card_loan.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/first_screen.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: Colors.green[600],
        onPressed: () {
          showBarModalBottomSheet(
            expand: true,
            enableDrag: false,
            isDismissible: true,
            context: context,
            builder: (context) => _buildPreEvaluationModal(),
          );
        },
        icon: const Icon(Icons.calculate),
        label: const Text('Pre-evaluación'),
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

  Widget _buildPreEvaluationModal() {
    final theme = Theme.of(context);
    
    return BlocProvider(
      create: (context) => LoanPreEvaluationBloc(context: context),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.close, color: theme.appBarTheme.iconTheme?.color),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pre-evaluación de Préstamo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Calcula tu capacidad de préstamo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[600]!, Colors.green[700]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.trending_up,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '¡Descubre tu capacidad de préstamo!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Simula diferentes modalidades y encuentra la mejor opción para ti.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Info card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[600], size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Esta herramienta te permite realizar una simulación completa de préstamo sin compromiso.',
                                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Features section
                      Text(
                        'Lo que puedes hacer:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      const Column(
                        children: [
                          _FeatureItem(
                            icon: Icons.account_balance_wallet,
                            title: 'Modalidades disponibles',
                            subtitle: 'Explora todas las opciones de préstamo según tu perfil',
                          ),
                          SizedBox(height: 20),
                          _FeatureItem(
                            icon: Icons.calculate,
                            title: 'Cálculo automático',
                            subtitle: 'Conoce tu cuota mensual y capacidad de endeudamiento',
                          ),
                          SizedBox(height: 20),
                          _FeatureItem(
                            icon: Icons.description,
                            title: 'Documentos requeridos',
                            subtitle: 'Lista completa de documentos necesarios para el trámite',
                          ),
                          SizedBox(height: 20),
                          _FeatureItem(
                            icon: Icons.security,
                            title: 'Simulación segura',
                            subtitle: 'Proceso completamente confidencial y sin compromiso',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Cerrar modal
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => LoanPreEvaluationBloc(context: context),
                                  child: const FirstScreen(),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'INICIAR PRE-EVALUACIÓN',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
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

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.green[600],
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
