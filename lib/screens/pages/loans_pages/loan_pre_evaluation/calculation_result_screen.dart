import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/model/evaluation_models.dart';
import 'package:muserpol_pvt/services/evaluation_service.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/documents_screen.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/widgets/loan_progress_indicator.dart';
import 'widgets/evaluation_widgets.dart';

class CalculationResultScreen extends StatefulWidget {
  final int modalityId;
  final double sueldoBase;
  final String affiliateStateType;
  final double? liquidoPagable;
  final double? totalBonos;
  final double? seniorityBonus;
  final double? studyBonus;
  final double? positionBonus;
  final double? borderBonus;
  final double? eastBonus;
  final double? rentaDignidad;

  const CalculationResultScreen({
    super.key,
    required this.modalityId,
    required this.sueldoBase,
    required this.affiliateStateType,
    this.liquidoPagable,
    this.totalBonos,
    this.seniorityBonus,
    this.studyBonus,
    this.positionBonus,
    this.borderBonus,
    this.eastBonus,
    this.rentaDignidad,
  });

  @override
  State<CalculationResultScreen> createState() =>
      _CalculationResultScreenState();
}

class _CalculationResultScreenState extends State<CalculationResultScreen> {
  LoanModality? _modality;
  LoanParameters? _params;

  late double _montoSolicitado;
  late int _plazoMeses;
  late int _affiliateId;
  double _cuotaMensual = 0.0;
  double _liquidoParaCalificacion = 0.0;
  String _mensajeError = '';
  double _montoMaximoCalculado = 0.0;

  final TextEditingController _montoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadModality();
  }

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  void _loadModality() {
    final userState = context.read<UserBloc>().state;

    if (userState.user?.affiliateId != null) {
      setState(() {
        _affiliateId = userState.user!.affiliateId!;
      });

      context
          .read<LoanPreEvaluationBloc>()
          .add(LoadLoanModalitiesPreEval(_affiliateId));
      return;
    }

    _showErrorAndExit('No se pudieron cargar las modalidades');
  }

  List<LoanModality>? _getModalitiesFromState(LoanPreEvaluationState state) {
    if (state is LoanModalitiesLoaded) return state.modalities;
    if (state is LoanModalitiesWithContributionsLoaded) return state.modalities;
    return null;
  }

  void _showErrorAndExit(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  void _initValues() {
    if (_modality == null) return;

    _params = _modality!.parameters;
    _plazoMeses = _params!.maximumTermModality;
    _liquidoParaCalificacion = widget.sueldoBase;
    _montoSolicitado = _params!.minimumAmountModality;

    _calculate();

    _montoSolicitado = _montoMaximoCalculado > 0
        ? _montoMaximoCalculado
        : _params!.minimumAmountModality;

    _montoController.text = _montoSolicitado.toStringAsFixed(2);
    _calculate();
  }

  // === CÃLCULOS ===
  void _calculate() {
    if (_params == null) return;

    final montoValidado = EvaluationService.clampAmount(_montoSolicitado,
        _params!.minimumAmountModality, _params!.maximumAmountModality);
    final plazoValidado = _plazoMeses.clamp(
        _params!.minimumTermModality, _params!.maximumTermModality);

    final convertedParams = LoanParameters(
      debtIndex: _params!.debtIndex,
      guarantors: _params!.guarantors,
      maxLenders: _params!.maxLenders,
      minLenderCategory: _params!.minLenderCategory,
      maxLenderCategory: _params!.maxLenderCategory,
      maximumAmountModality: _params!.maximumAmountModality,
      minimumAmountModality: _params!.minimumAmountModality,
      maximumTermModality: _params!.maximumTermModality,
      minimumTermModality: _params!.minimumTermModality,
      loanMonthTerm: _params!.loanMonthTerm,
      coveragePercentage: _params!.coveragePercentage,
      annualInterest: _params!.annualInterest,
      periodInterest: _params!.periodInterest,
    );

    final cuotaFija = EvaluationService.calculateCuota(
        montoValidado, plazoValidado, convertedParams);
    final montoMaximoReal = EvaluationService.calculateMontoMaximo(
        _liquidoParaCalificacion, convertedParams);
    final limiteEndeudamiento = EvaluationService.calculateDebtIndex(
        cuotaFija, _liquidoParaCalificacion, convertedParams);

    setState(() {
      _montoSolicitado = montoValidado;
      _plazoMeses = plazoValidado;
      _cuotaMensual = cuotaFija;
      _montoMaximoCalculado = montoMaximoReal;
      _mensajeError = '';

      if (limiteEndeudamiento > _params!.debtIndex) {
        _mensajeError =
            'La cuota ${EvaluationService.getPaymentFrequency(_params!.loanMonthTerm)} excede el límite de endeudamiento permitido de ${_params!.debtIndex}% de tu Liquido para Calificación.';
      }
    });
  }

  // === INPUT HANDLING ===
  void _onMontoChanged(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9.,]'), '');

    if (cleaned.isEmpty) {
      _montoSolicitado = _params?.minimumAmountModality ?? 0;
    } else {
      final value = double.tryParse(cleaned.replaceAll(',', '.'));
      if (value != null && value >= 0) {
        _montoSolicitado = _clampAmount(value);
        if (_montoSolicitado != value) _updateControllerWithClampedValue();
      }
    }
    _calculate();
  }

  double _clampAmount(double value) {
    final maxAmount = _montoMaximoCalculado > 0
        ? _montoMaximoCalculado
        : (_params?.maximumAmountModality ?? double.infinity);
    final minAmount = _params?.minimumAmountModality ?? 0;
    return EvaluationService.clampAmount(value, minAmount, maxAmount);
  }

  void _updateControllerWithClampedValue() {
    _montoController.text = _montoSolicitado.toStringAsFixed(2);
    _montoController.selection = TextSelection.fromPosition(
        TextPosition(offset: _montoController.text.length));
  }

  void _loadDocuments() {
    FocusScope.of(context).unfocus();

    if (_modality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Modalidad no encontrada')));
      return;
    }

    context
        .read<LoanPreEvaluationBloc>()
        .add(LoadLoanDocuments(_modality!.procedureModalityId, _affiliateId));
  }

  // === UTILITIES ===
  String _getTermType() =>
      EvaluationService.getTermType(_params?.loanMonthTerm ?? 1);
  String _getPaymentFrequency() =>
      EvaluationService.getPaymentFrequency(_params?.loanMonthTerm ?? 1);
  double _getMaxAmount() => _montoMaximoCalculado > 0
      ? _montoMaximoCalculado
      : (_params?.maximumAmountModality ?? 0);

  // === UI ===
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocListener<LoanPreEvaluationBloc, LoanPreEvaluationState>(
        listener: _handleBlocState,
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const LoanProgressIndicator(currentStep: 2),
            centerTitle: true,
            backgroundColor: const Color(0xff419388),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: BlocBuilder<LoanPreEvaluationBloc, LoanPreEvaluationState>(
            builder: (context, state) {
              if (state is LoanModalitiesLoading) {
                return Center(
                    child: CircularProgressIndicator(
                        color: const Color(0xff419388)));
              }

              if (state is LoanModalitiesLoaded ||
                  state is LoanModalitiesWithContributionsLoaded) {
                final modalities = _getModalitiesFromState(state);
                if (modalities != null) {
                  final modality = modalities.firstWhere(
                    (m) => m.id == widget.modalityId,
                    orElse: () => modalities.first,
                  );

                  if (_modality == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _modality = modality;
                      });
                      _initValues();
                    });
                  }
                }
              }

              return _modality == null
                  ? Center(
                      child: CircularProgressIndicator(
                          color: const Color(0xff419388)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16), child: _buildBody());
            },
          ),
        ),
      ),
    );
  }

  void _handleBlocState(BuildContext context, LoanPreEvaluationState state) {
    if (state is LoanDocumentsLoaded) _navigateToDocuments(state);
    if (state is LoanDocumentsError) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red));
    }
  }

  void _navigateToDocuments(LoanDocumentsLoaded state) {
    final documents = state.documents.documents;

    final currentBloc = context.read<LoanPreEvaluationBloc>();
    final userState = context.read<UserBloc>().state;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: currentBloc,
          child: DocumentsScreen(
            onExit: () {
              // Navegar de vuelta a la pantalla principal de préstamos
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            documents: documents,
            modalityName: _modality?.name ?? '',
            amount: _montoSolicitado,
            term: _plazoMeses,
            monthlyPayment: _cuotaMensual,
            paymentFrequency: _getPaymentFrequency(),
            termType: _getTermType(),
            sueldoBase: widget.sueldoBase,
            affiliateStateType: widget.affiliateStateType,
            annualInterest: _params?.annualInterest ?? 0.0,
            periodInterest: _params?.periodInterest ?? 0.0,
            guarantors: _params?.guarantors ?? 0,
            liquidoPagable: widget.liquidoPagable,
            totalBonos: widget.totalBonos,
            seniorityBonus: widget.seniorityBonus,
            studyBonus: widget.studyBonus,
            positionBonus: widget.positionBonus,
            borderBonus: widget.borderBonus,
            eastBonus: widget.eastBonus,
            rentaDignidad: widget.rentaDignidad,
            modalityId: widget.modalityId,
            procedureModalityId: _modality?.procedureModalityId ?? 0,
            affiliateName: userState.user?.fullName,
            affiliateIdentityCard: userState.user?.identityCard,
            loanCharge: null,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildModalityInfo(),
        const SizedBox(height: 20),
        _buildAmountAndTermSection(),
        const SizedBox(height: 20),
        _mensajeError.isNotEmpty ? _buildErrorAlert() : _buildResultsSection(),
        const SizedBox(height: 24),
        _buildDocumentsButton(),
      ],
    );
  }

  Widget _buildModalityInfo() {
    return Text(
      (_modality?.name ?? 'MODALIDAD DE PRÉSTAMO').toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: const Color(0xff2d6b61),
        fontSize: 20.sp,
      ),
    );
  }

  Widget _buildAmountAndTermSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIGURA TU PRÃ‰STAMO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xff2d6b61),
            fontSize: 20.sp,
          ),
        ),
        const SizedBox(height: 20),
        _buildAmountInput(),
        const SizedBox(height: 20),
        EvaluationWidgets.termSelector(
          currentTerm: _plazoMeses,
          minTerm: _params!.minimumTermModality,
          maxTerm: _params!.maximumTermModality,
          loanMonthTerm: _params!.loanMonthTerm,
          onTermChanged: (newTerm) {
            setState(() {
              _plazoMeses = newTerm;
              _calculate();
            });
          },
        ),
      ],
    );
  }

  Widget _buildAmountInput() {
    final maxAmount = _getMaxAmount();
    final isOverLimit = _montoSolicitado > maxAmount;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Monto Solicitado',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 17.sp,
              color: const Color(0xff2d6b61))),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isOverLimit ? Colors.red.shade300 : Colors.grey.shade300,
                width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: TextField(
          controller: _montoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _onMontoChanged,
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color:
                  isOverLimit ? Colors.red.shade600 : const Color(0xff2d6b61),
              letterSpacing: 0.5),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'Toca para ingresar tu monto',
            hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic),
            suffixText: 'Bs',
            suffixStyle: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isOverLimit
                    ? Colors.red.shade600
                    : const Color(0xff2d6b61)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
          ),
        ),
      ),
    ]);
  }

  Widget _buildErrorAlert() {
    return EvaluationWidgets.errorAlert(
      title: 'Límite Excedido',
      message: _mensajeError,
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RESULTADO DEL CÃLCULO',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xff2d6b61),
            fontSize: 20.sp,
          ),
        ),
        const SizedBox(height: 20),
        EvaluationWidgets.paymentSummary(
          monthlyPayment: _cuotaMensual,
          amount: _montoSolicitado,
          term: _plazoMeses,
          params: LoanParameters(
            debtIndex: _params!.debtIndex,
            guarantors: _params!.guarantors,
            maxLenders: _params!.maxLenders,
            minLenderCategory: _params!.minLenderCategory,
            maxLenderCategory: _params!.maxLenderCategory,
            maximumAmountModality: _params!.maximumAmountModality,
            minimumAmountModality: _params!.minimumAmountModality,
            maximumTermModality: _params!.maximumTermModality,
            minimumTermModality: _params!.minimumTermModality,
            loanMonthTerm: _params!.loanMonthTerm,
            coveragePercentage: _params!.coveragePercentage,
            annualInterest: _params!.annualInterest,
            periodInterest: _params!.periodInterest,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsButton() {
    return EvaluationWidgets.primaryButton(
      text: 'VER DOCUMENTOS REQUERIDOS',
      icon: Icons.description,
      onPressed: _loadDocuments,
    );
  }
}
