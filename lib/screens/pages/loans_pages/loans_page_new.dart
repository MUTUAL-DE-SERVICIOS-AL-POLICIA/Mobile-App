import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:muserpol_pvt/bloc/loan/loan_bloc.dart';
import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/model/biometric_user_model.dart';
import 'package:muserpol_pvt/model/loan_model.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/card_loan.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/first_screen.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/saved_evaluations_screen.dart';
import 'package:muserpol_pvt/services/auth_service.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';
import 'package:provider/provider.dart';

class ScreenLoansNew extends StatefulWidget {
  final bool openModalOnInit;

  const ScreenLoansNew({super.key, this.openModalOnInit = false});

  @override
  State<ScreenLoansNew> createState() => _ScreenLoansNewState();
}

class _ScreenLoansNewState extends State<ScreenLoansNew> {
  @override
  void initState() {
    super.initState();

    // Si se debe abrir el modal automáticamente
    if (widget.openModalOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPreEvaluationModal();
        }
      });
    }
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
      //ACA TINENE QUE ESTAR LA EVALUACION REFERENCIAL
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff419388),
        onPressed: _showPreEvaluationModal,
        icon: const Icon(Icons.calculate),
        label: const Text('Evaluación Referencial'),
      ),
    );
  }

  void _showPreEvaluationModal() async {
    // Limpiar evaluaciones obsoletas antes de mostrar el modal
    await _cleanObsoleteEvaluationsIfNeeded();

    if (!mounted) return;

    showBarModalBottomSheet(
      expand: true,
      enableDrag: false,
      isDismissible: true,
      context: context,
      builder: (context) => _buildPreEvaluationModal(),
    );
  }

  Future<void> _cleanObsoleteEvaluationsIfNeeded() async {
    try {
      final loanBloc = BlocProvider.of<LoanBloc>(context, listen: false);

      if (loanBloc.state.existLoan && loanBloc.state.loan != null) {
        // Aquí podrías implementar la limpieza si tienes acceso a las modalidades
        // Por ahora, la limpieza se hará en saved_evaluations_screen
        print('Verificando evaluaciones guardadas...');
      }
    } catch (e) {
      print('Error al verificar evaluaciones: $e');
    }
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
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff419388), Color(0xff2d6b61)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Hero section con gradiente extendido
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff419388), Color(0xff2d6b61)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Título principal
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '¡Descubre a qué modalidad de préstamo puedes acceder!',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Features section con fondo blanco
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(height: 12),
                            _CompactFeature(
                              icon: Icons.calculate,
                              title: 'Calcula el monto y plazo referencial',
                            ),
                            SizedBox(height: 12),
                            _CompactFeature(
                              icon: Icons.folder_copy,
                              title: 'Conoce que documentos debes presentar',
                            ),
                            SizedBox(height: 12),
                            _CompactFeature(
                              icon: Icons.security,
                              title: 'Simula tu préstamo de forma segura',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content con fondo del tema
              Expanded(
                child: Container(
                  color: theme.scaffoldBackgroundColor,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) =>
                                        LoanPreEvaluationBloc(context: context),
                                    child: const FirstScreen(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff419388),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              'INICIAR EVALUACIÓN REFERENCIAL',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Botón Mis Evaluaciones
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SavedEvaluationsScreen(),
                                ),
                              );

                              if (result != null && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Función de recarga en desarrollo'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.history),
                            label: Text(
                              'MIS EVALUACIONES',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xff419388),
                              side: const BorderSide(
                                  color: Color(0xff419388), width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
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

class _CompactFeature extends StatelessWidget {
  final IconData icon;
  final String title;

  const _CompactFeature({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xff2d6b61),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff2d6b61),
            ),
          ),
        ),
      ],
    );
  }
}
