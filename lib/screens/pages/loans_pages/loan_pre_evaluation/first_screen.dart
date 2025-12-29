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

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with WidgetsBindingObserver {
  // State variables
  double? sueldoBase;
  bool _isFetchingSueldo = false;
  bool _isGridView = false;
  bool _showModalitiesForPasivo = false;
  bool _isBonusExpanded = false;
  bool _hasNavigatedAway = false;

  String _affiliateStateType = '';
  int _affiliateId = 0;

  // Variables para afiliados activos
  double _liquidoPagable = 0.0;
  double _totalBonos = 0.0;
  double _liquidoParaCalificacion = 0.0;
  bool _hasLoadedActivoData = false;

  // Controllers simplificados
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

  void _disposeControllers() {
    [
      sueldoController,
      rentaDignidadController,
      liquidoPagableController,
      seniorityBonusController,
      studyBonusController,
      positionBonusController,
      borderBonusController,
      eastBonusController,
      _scrollController
    ].forEach((controller) => controller.dispose());
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

    if ((sueldoBase ?? 0.0) != nuevoSueldoBase) {
      setState(() {
        sueldoBase = nuevoSueldoBase;
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
                        'Advertencia Importante',
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
                              color: Colors.orange.shade300, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Si el afiliado se encuentra en Artículo 57, \nNO podrá realizar su préstamo formal. \nEsta evaluación es únicamente referencial. \nPara la solicitud de préstamo formal debe realizarlo en oficinas a nivel nacional de la MUSERPOL.',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
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

      if (_affiliateStateType == 'Activo' &&
          contributions != null &&
          contributions.payload.contributions.isNotEmpty) {
        _handleContributionsData(contributions.payload.contributions.first);
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
        // The quotable response provides only a "quotable" value; use it as liquidoPagable
        // Guardar contra tipos inesperados
        final rawQuotable = contributionData.quotable;
        if (rawQuotable is String) {
          liquidoPagable = EvaluationService.parseCurrency(rawQuotable) ?? 0.0;
        } else if (rawQuotable is num) {
          liquidoPagable = (rawQuotable as num).toDouble();
        } else {
          debugPrint('Unexpected quotable type: ${rawQuotable.runtimeType}');
        }
        // Bonus breakdown isn't available in this response, assume 0
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

        liquidoPagableController.text = liquidoPagable.toStringAsFixed(2);
        seniorityBonusController.text = seniorityBonus.toStringAsFixed(2);
        studyBonusController.text = studyBonus.toStringAsFixed(2);
        positionBonusController.text = positionBonus.toStringAsFixed(2);
        borderBonusController.text = borderBonus.toStringAsFixed(2);
        eastBonusController.text = eastBonus.toStringAsFixed(2);

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
      return Center(
          child: CircularProgressIndicator(color: const Color(0xff419388)));
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
                child: const Text('Reintentar'),
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
              CircularProgressIndicator(color: const Color(0xff419388)),
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
          if (isActivo || ((!isActivo) && _showModalitiesForPasivo))
            _buildModalitiesSection(modalities)
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

  // === WIDGETS DE SUELDO ACTIVO ===

  Widget _buildSueldoActivo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (_isFetchingSueldo)
            LinearProgressIndicator(color: const Color(0xff419388))
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
          'COTIZABLE',
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
              color: _liquidoParaCalificacion > 0
                  ? const Color(0xff419388).withAlpha(26)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _liquidoParaCalificacion > 0
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
                              fontSize: 14,
                              color: _liquidoParaCalificacion > 0
                                  ? const Color(0xff419388)
                                  : Colors.red.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _liquidoParaCalificacion > 0
                                ? "${EvaluationService.formatMoney(_liquidoParaCalificacion)} Bs"
                                : "Límite Excedido",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                              color: _liquidoParaCalificacion > 0
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
                        color: _liquidoParaCalificacion > 0
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
                      'Toca para ver desglose',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _liquidoParaCalificacion > 0
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

  Widget _buildDesgloseLine(String label, TextEditingController controller) {
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
                  onChanged: _onActivoFieldChanged,
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
            'Información del Sueldo para Calificación',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp),
          ),
          const SizedBox(height: 16),
          EvaluationWidgets.moneyInputField(
            label: 'Sueldo',
            controller: sueldoController,
            onChanged: (_) => _updateSueldoBase(),
          ),
          const SizedBox(height: 12),
          EvaluationWidgets.moneyInputField(
            label: 'Renta Dignidad',
            controller: rentaDignidadController,
            onChanged: (_) => _updateSueldoBase(),
          ),
          const SizedBox(height: 16),
          if (sueldoBase != null) _buildSueldoBaseCard(),
        ],
      ),
    );
  }

  Widget _buildSueldoBaseCard() {
    return EvaluationWidgets.infoCard(
      title: "Sueldo base calculado",
      value: "${EvaluationService.formatMoney(sueldoBase!)} Bs",
      icon: Icons.account_balance_wallet,
      backgroundColor: sueldoBase! > 0
          ? const Color(0xff419388).withAlpha(26)
          : Colors.red.shade50,
      textColor:
          sueldoBase! > 0 ? const Color(0xff2d6b61) : Colors.red.shade700,
      isHighlighted: true,
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

    // Capturar el BLoC antes de navegar
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
