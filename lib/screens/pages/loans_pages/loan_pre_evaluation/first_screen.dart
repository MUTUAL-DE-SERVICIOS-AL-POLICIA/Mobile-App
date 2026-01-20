import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/model/evaluation_models.dart';
import 'package:muserpol_pvt/services/evaluation_service.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/calculation_result_screen.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/widgets/loan_progress_indicator.dart';
import 'package:muserpol_pvt/model/loan_pre_evaluation_model.dart';
import 'widgets/evaluation_widgets.dart';
import 'package:flutter/services.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with WidgetsBindingObserver {
  double? sueldoBase;
  bool _isFetchingSueldo = false;
  bool _isGridView = true;
  bool _showModalitiesForPasivo = false;
  bool _isBonusExpanded = false;
  bool _hasNavigatedAway = false;

  String _affiliateStateType = '';
  int _affiliateId = 0;

  double _liquidoPagable = 0.0;
  double _totalBonos = 0.0;
  double _liquidoParaCalificacion = 0.0;
  bool _hasLoadedActivoData = false;

  final TextEditingController sueldoController = TextEditingController();
  final TextEditingController rentaDignidadController = TextEditingController();
  final TextEditingController liquidoPagableController =
      TextEditingController();
  final TextEditingController seniorityBonusController =
      TextEditingController();
  final TextEditingController studyBonusController = TextEditingController();
  final TextEditingController positionBonusController = TextEditingController();
  final TextEditingController borderBonusController = TextEditingController();
  final TextEditingController eastBonusController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _showArticle57Warning());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasNavigatedAway) {
      _refreshData();
      _hasNavigatedAway = false;
    }
  }

  String _formatNumberWithComma(double value) {
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _disposeControllers() {
    final textControllers = <TextEditingController>[
      sueldoController,
      rentaDignidadController,
      liquidoPagableController,
      seniorityBonusController,
      studyBonusController,
      positionBonusController,
      borderBonusController,
      eastBonusController,
    ];

    for (final c in textControllers) {
      c.dispose();
    }

    _scrollController.dispose();
  }

  void _initData() {
    final userState = context.read<UserBloc>().state;
    if (userState.user?.affiliateId != null) {
      _affiliateId = userState.user!.affiliateId!;
      context
          .read<LoanPreEvaluationBloc>()
          .add(LoadLoanModalitiesPreEval(_affiliateId));
    }
  }

  void _refreshData() {
    if (_affiliateId > 0) {
      context
          .read<LoanPreEvaluationBloc>()
          .add(LoadLoanModalitiesPreEval(_affiliateId));
    }
  }

  // === LÓGICA DE NEGOCIO ===

  void _updateSueldoBase() {
    if (_affiliateStateType != 'Pasivo') return;

    final sueldo =
        EvaluationService.parseCurrency(sueldoController.text) ?? 0.0;
    final renta =
        EvaluationService.parseCurrency(rentaDignidadController.text) ?? 0.0;
    final nuevoSueldoBase = sueldo - renta;

    if ((sueldoBase ?? 0.0) != nuevoSueldoBase ||
        _liquidoPagable != sueldo ||
        _totalBonos != renta) {
      setState(() {
        sueldoBase = nuevoSueldoBase;
        _liquidoPagable = sueldo;
        _totalBonos = renta; // here totalBonos acts as the renta deduction
        _liquidoParaCalificacion = nuevoSueldoBase;
        _showModalitiesForPasivo = sueldo > 0;
      });
    }
  }

  void _onActivoFieldChanged(String value) {
    final liquidoPagable =
        EvaluationService.parseCurrency(liquidoPagableController.text) ?? 0.0;
    final totalBonos = [
      seniorityBonusController,
      studyBonusController,
      positionBonusController,
      borderBonusController,
      eastBonusController
    ]
        .map((c) => EvaluationService.parseCurrency(c.text) ?? 0.0)
        .reduce((a, b) => a + b);

    final liquidoCalificacion = liquidoPagable - totalBonos;

    setState(() {
      _liquidoPagable = liquidoPagable;
      _totalBonos = totalBonos;
      _liquidoParaCalificacion = liquidoCalificacion;
      sueldoBase = liquidoCalificacion;
    });
  }

  void _showArticle57Warning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.orange.shade50, Colors.orange.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[600]!, Colors.orange[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded,
                            color: Colors.white, size: 36),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'IMPORTANTE',
                        style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                const Color(0xFF419388).withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Esta evaluación es solo referencial sin considerar los prestamos que este garantizando; '
                              'para iniciar la solicitud formal del préstamo debes realizarlo de manera presencial en las oficinas de la MUSERPOL a nivel nacional.',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: const Color(0xFF2D6B61),
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          child: Text(
                            'ENTENDIDO',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // === BUILD UI ===

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: AppBar(
          title: const LoanProgressIndicator(currentStep: 1),
          centerTitle: true,
          backgroundColor: const Color(0xff419388),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocListener<LoanPreEvaluationBloc, LoanPreEvaluationState>(
          listener: (context, state) {
            if (state is LoanModalitiesLoaded) {
              _handleModalitiesLoaded(state.modalities);
            } else if (state is LoanModalitiesWithContributionsLoaded) {
              _handleModalitiesWithContributionsLoaded(
                  state.modalities, state.contributions);
            } else if (state is LoanModalitiesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is QuotableContributionsLoaded) {
              // Handle contributions loaded separately if needed
            } else if (state is QuotableContributionsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: BlocBuilder<LoanPreEvaluationBloc, LoanPreEvaluationState>(
            builder: (context, state) => _buildContent(context, state),
          ),
        ),
      ),
    );
  }

  void _handleModalitiesLoaded(List<LoanModalityNew> modalities) {
    if (modalities.isNotEmpty) {
      final firstModality = modalities.first;
      setState(() => _affiliateStateType = firstModality.affiliateStateType);

      if (_affiliateStateType == 'Activo') {
        context
            .read<LoanPreEvaluationBloc>()
            .add(LoadQuotableContributions(_affiliateId));
      } else {
        _updateSueldoBase();
      }
    }
  }

  void _handleModalitiesWithContributionsLoaded(
      List<LoanModalityNew> modalities,
      QuotableContributionsResponse? contributions) {
    if (modalities.isNotEmpty) {
      final firstModality = modalities.first;
      setState(() => _affiliateStateType = firstModality.affiliateStateType);

      if (_affiliateStateType == 'Activo') {
        if (contributions != null &&
            contributions.payload.contributions.isNotEmpty) {
          _handleContributionsData(contributions.payload.contributions.first);
        } else {
          setState(() {
            _isFetchingSueldo = false;
            _hasLoadedActivoData = true;
            _liquidoPagable = 0.0;
            _totalBonos = 0.0;
            _liquidoParaCalificacion = 0.0;
            sueldoBase = 0.0;
            _isBonusExpanded = true;
            liquidoPagableController.text = _formatNumberWithComma(0.0);
            seniorityBonusController.text = _formatNumberWithComma(0.0);
            studyBonusController.text = _formatNumberWithComma(0.0);
            positionBonusController.text = _formatNumberWithComma(0.0);
            borderBonusController.text = _formatNumberWithComma(0.0);
            eastBonusController.text = _formatNumberWithComma(0.0);
          });
        }
      } else {
        _updateSueldoBase();
      }
    }
  }

  void _handleContributionsData(dynamic contributionData) {
    setState(() => _isFetchingSueldo = true);

    double liquidoPagable = 0.0;
    double seniorityBonus = 0.0;
    double studyBonus = 0.0;
    double positionBonus = 0.0;
    double borderBonus = 0.0;
    double eastBonus = 0.0;

    try {
      if (contributionData is Contribution) {
        liquidoPagable =
            contributionData.parseAmount(contributionData.payableLiquid);
        seniorityBonus =
            contributionData.parseAmount(contributionData.seniorityBonus);
        studyBonus = contributionData.parseAmount(contributionData.studyBonus);
        positionBonus =
            contributionData.parseAmount(contributionData.positionBonus);
        borderBonus =
            contributionData.parseAmount(contributionData.borderBonus);
        eastBonus = contributionData.parseAmount(contributionData.eastBonus);
      } else if (contributionData is QuotableContribution) {
        final rawPayable = contributionData.payableLiquid.isNotEmpty
            ? contributionData.payableLiquid
            : contributionData.quotable;

        liquidoPagable = EvaluationService.parseCurrency(rawPayable) ?? 0.0;

        seniorityBonus =
            EvaluationService.parseCurrency(contributionData.seniorityBonus) ??
                0.0;
        studyBonus =
            EvaluationService.parseCurrency(contributionData.studyBonus) ?? 0.0;
        positionBonus =
            EvaluationService.parseCurrency(contributionData.positionBonus) ??
                0.0;
        borderBonus =
            EvaluationService.parseCurrency(contributionData.borderBonus) ??
                0.0;
        eastBonus =
            EvaluationService.parseCurrency(contributionData.eastBonus) ?? 0.0;

        // debugPrint(
        //     'QuotableContribution raw values -> payable_liquid: ${contributionData.payableLiquid}, seniority_bonus: ${contributionData.seniorityBonus}, study_bonus: ${contributionData.studyBonus}, position_bonus: ${contributionData.positionBonus}, border_bonus: ${contributionData.borderBonus}, east_bonus: ${contributionData.eastBonus}');
        // debugPrint(
        //     'Parsed values -> liquidoPagable: $liquidoPagable, seniority: $seniorityBonus, study: $studyBonus, position: $positionBonus, border: $borderBonus, east: $eastBonus');
      }

      final totalBonuses =
          seniorityBonus + studyBonus + positionBonus + borderBonus + eastBonus;
      final liquidoCalificacion = liquidoPagable - totalBonuses;

      setState(() {
        _liquidoPagable = liquidoPagable;
        _totalBonos = totalBonuses;
        _liquidoParaCalificacion = liquidoCalificacion;
        sueldoBase = liquidoCalificacion;
        _hasLoadedActivoData = true;
        _isBonusExpanded = (liquidoPagable == 0.0 && totalBonuses == 0.0);
        liquidoPagableController.text = _formatNumberWithComma(liquidoPagable);
        seniorityBonusController.text = _formatNumberWithComma(seniorityBonus);
        studyBonusController.text = _formatNumberWithComma(studyBonus);
        positionBonusController.text = _formatNumberWithComma(positionBonus);
        borderBonusController.text = _formatNumberWithComma(borderBonus);
        eastBonusController.text = _formatNumberWithComma(eastBonus);

        _isFetchingSueldo = false;
      });
    } catch (e, st) {
      debugPrint('Error parsing contribution data: $e\n$st');
      setState(() {
        _isFetchingSueldo = false;
        _hasLoadedActivoData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No se pudo procesar la boleta de pago.'),
          backgroundColor: Colors.red));
    }
  }

  Widget _buildContent(BuildContext context, LoanPreEvaluationState? state) {
    if (state is LoanModalitiesLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xff419388)));
    }

    if (state is LoanModalitiesError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Reestablecer'),
              ),
            ],
          ),
        ),
      );
    }

    List<LoanModalityNew>? modalities;
    if (state is LoanModalitiesLoaded) {
      modalities = state.modalities;
    } else if (state is LoanModalitiesWithContributionsLoaded) {
      modalities = state.modalities;
    }

    if (modalities == null || modalities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xff419388)),
              const SizedBox(height: 16),
              Text(
                'Cargando modalidades...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return _buildMainContent(modalities);
  }

  Widget _buildMainContent(List<LoanModalityNew> modalities) {
    final bool isActivo = _affiliateStateType == 'Activo';
    final bool isBaja = _affiliateStateType == 'Baja';

    if (isBaja) return _buildBajaState();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          if (isActivo) _buildSueldoActivo() else _buildPasivoFields(),
          if ((isActivo && _liquidoParaCalificacion > 0) ||
              ((!isActivo) && _showModalitiesForPasivo))
            _buildModalitiesSection(modalities)
          else if (isActivo && _liquidoParaCalificacion <= 0)
            _buildActivoInvalidPrompt()
          else if (!isActivo && !_showModalitiesForPasivo)
            _buildPromptForPasivo(),
        ],
      ),
    );
  }

  Widget _buildBajaState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, size: 60, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Actualice su información en oficinas presenciales.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptForPasivo() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.blue.shade600),
            const SizedBox(height: 12),
            Text(
              'Ingrese su sueldo para ver las modalidades disponibles',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.blue.shade700, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete los campos de sueldo y renta dignidad para calcular su sueldo base y ver las opciones de préstamo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.blue.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivoInvalidPrompt() {
    final theme = Theme.of(context);
    const primaryGreen = Color(0xFF419388);
    const softGreenBg = Color(0xFFE8F4F2);
    const mediumGreen = Color(0xFF2D6B61);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: softGreenBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: mediumGreen.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 48, color: primaryGreen),
            const SizedBox(height: 8),
            Text(
              'Su "Líquido para Calificación" debe ser mayor a 0 para acceder a nuestras modalidades de préstamo.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mediumGreen,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'REESTABLECER',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === WIDGETS DE SUELDO ACTIVO ===

  Widget _buildSueldoActivo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_isFetchingSueldo)
            const LinearProgressIndicator(color: Color(0xff419388))
          else if (_hasLoadedActivoData)
            _buildLiquidoCalificacionExpandable()
          else
            Text('No se pudo obtener la información de pago.',
                style: TextStyle(color: Colors.red, fontSize: 15.sp)),
        ],
      ),
    );
  }

  Widget _buildLiquidoCalificacionExpandable() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTO PARA EVALUAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: const Color(0xff2d6b61),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _isBonusExpanded = !_isBonusExpanded),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _liquidoParaCalificacion >= 0
                  ? const Color(0xff419388).withAlpha(26)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _liquidoParaCalificacion >= 0
                    ? const Color(0xff419388).withAlpha(77)
                    : Colors.red.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Líquido para Calificación",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 18,
                              color: _liquidoParaCalificacion >= 0
                                  ? const Color(0xff419388)
                                  : Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _liquidoParaCalificacion >= 0
                                ? "${EvaluationService.formatMoney(_liquidoParaCalificacion)} Bs"
                                : "Límite Excedido",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                              color: _liquidoParaCalificacion >= 0
                                  ? const Color(0xff2d6b61)
                                  : Colors.red.shade700,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isBonusExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: _liquidoParaCalificacion >= 0
                            ? const Color(0xff419388)
                            : Colors.red.shade600,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                if (!_isBonusExpanded) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Ver mas detalles',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _liquidoParaCalificacion >= 0
                            ? const Color(0xff419388)
                            : Colors.red.shade600,
                        fontStyle: FontStyle.italic,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ],
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isBonusExpanded
                      ? Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildDesgloseLine(
                                '+ Líquido Pagable', liquidoPagableController),
                            const SizedBox(height: 12),
                            _buildDesgloseLine(
                                '- Bono Antigüedad', seniorityBonusController),
                            const SizedBox(height: 12),
                            _buildDesgloseLine(
                                '- Bono Estudios', studyBonusController),
                            const SizedBox(height: 12),
                            _buildDesgloseLine(
                                '- Bono Cargo', positionBonusController),
                            const SizedBox(height: 12),
                            _buildDesgloseLine(
                                '- Bono Frontera', borderBonusController),
                            const SizedBox(height: 12),
                            _buildDesgloseLine(
                                '- Bono Oriente', eastBonusController),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesgloseLine(String label, TextEditingController controller,
      {ValueChanged<String>? onChanged}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                      width: 1),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    DecimalTextInputFormatter()
                  ], // ← AGREGAR ESTA LÍNEA
                  onChanged: onChanged ?? _onActivoFieldChanged,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "0,00",
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 16),
                    suffixText: "Bs",
                    suffixStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // === WIDGETS DE PASIVO ===

  Widget _buildPasivoFields() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MONTO PARA EVALUAR',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _isBonusExpanded = !_isBonusExpanded),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _liquidoParaCalificacion >= 0
                    ? const Color(0xff419388).withAlpha(26)
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _liquidoParaCalificacion >= 0
                      ? const Color(0xff419388).withAlpha(77)
                      : Colors.red.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Líquido para Calificación",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 18,
                                color: _liquidoParaCalificacion >= 0
                                    ? const Color(0xff419388)
                                    : Colors.red.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _liquidoParaCalificacion >= 0
                                  ? "${EvaluationService.formatMoney(_liquidoParaCalificacion)} Bs"
                                  : "Límite Excedido",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp,
                                color: _liquidoParaCalificacion >= 0
                                    ? const Color(0xff2d6b61)
                                    : Colors.red.shade700,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isBonusExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.expand_more,
                          color: _liquidoParaCalificacion >= 0
                              ? const Color(0xff419388)
                              : Colors.red.shade600,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  if (!_isBonusExpanded) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Ver más detalles',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _liquidoParaCalificacion >= 0
                              ? const Color(0xff419388)
                              : Colors.red.shade600,
                          fontStyle: FontStyle.italic,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _isBonusExpanded
                        ? Column(
                            children: [
                              const SizedBox(height: 16),
                              // Líquido Pagable = Sueldo Base
                              _buildDesgloseLine(
                                '+ Líquido Pagable',
                                sueldoController,
                                onChanged: (_) => _updateSueldoBase(),
                              ),
                              const SizedBox(height: 12),
                              // Renta Dignidad como única deducción
                              _buildDesgloseLine(
                                '- Renta Dignidad',
                                rentaDignidadController,
                                onChanged: (_) => _updateSueldoBase(),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // === WIDGETS DE MODALIDADES ===

  Widget _buildModalitiesSection(List<LoanModalityNew> modalities) {
    return EvaluationWidgets.modalitiesSection(
      modalities: modalities,
      isGridView: _isGridView,
      onToggleView: () => setState(() => _isGridView = !_isGridView),
      onModalitySelected: (modality) => _onModalitySelected(modality),
    );
  }

  void _onModalitySelected(LoanModalityNew modality) {
    final isActivo = _affiliateStateType == 'Activo';

    if (isActivo && (sueldoBase == null || sueldoBase == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se pudo obtener el sueldo. Intente más tarde.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (!isActivo && (sueldoBase == null || sueldoBase! <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('El sueldo base debe ser mayor a 0.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _hasNavigatedAway = true;

    final currentBloc = context.read<LoanPreEvaluationBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: currentBloc,
          child: CalculationResultScreen(
            modalityId: modality.id,
            sueldoBase: sueldoBase!,
            affiliateStateType: _affiliateStateType,
            liquidoPagable:
                _affiliateStateType == 'Activo' ? _liquidoPagable : null,
            totalBonos: _affiliateStateType == 'Activo' ? _totalBonos : null,
            seniorityBonus: _affiliateStateType == 'Activo'
                ? EvaluationService.parseCurrency(seniorityBonusController.text)
                : null,
            studyBonus: _affiliateStateType == 'Activo'
                ? EvaluationService.parseCurrency(studyBonusController.text)
                : null,
            positionBonus: _affiliateStateType == 'Activo'
                ? EvaluationService.parseCurrency(positionBonusController.text)
                : null,
            borderBonus: _affiliateStateType == 'Activo'
                ? EvaluationService.parseCurrency(borderBonusController.text)
                : null,
            eastBonus: _affiliateStateType == 'Activo'
                ? EvaluationService.parseCurrency(eastBonusController.text)
                : null,
            rentaDignidad: _affiliateStateType == 'Pasivo'
                ? EvaluationService.parseCurrency(rentaDignidadController.text)
                : null,
          ),
        ),
      ),
    ).then((_) {
      _refreshData();
      _hasNavigatedAway = false;
    });
  }
}

/// Formatter que permite edición libre pero limita a 2 decimales
class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalPlaces;

  DecimalTextInputFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Permitir campo vacío
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Permitir solo números, punto y coma
    final String text = newValue.text;
    if (!RegExp(r'^[0-9.,]*$').hasMatch(text)) {
      return oldValue;
    }

    // Contar separadores decimales
    final commaCount = text.split(',').length - 1;
    final dotCount = text.split('.').length - 1;

    // No permitir más de un separador decimal
    if (commaCount + dotCount > 1) {
      return oldValue;
    }

    // Verificar cantidad de decimales
    String separator = '';
    if (text.contains(',')) {
      separator = ',';
    } else if (text.contains('.')) {
      separator = '.';
    }

    if (separator.isNotEmpty) {
      final parts = text.split(separator);
      if (parts.length == 2 && parts[1].length > decimalPlaces) {
        // Si intenta agregar más decimales de los permitidos, rechazar
        return oldValue;
      }
    }

    return newValue;
  }
}
