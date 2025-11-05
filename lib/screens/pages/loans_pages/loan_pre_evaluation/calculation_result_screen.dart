import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/model/loan_pre_evaluation_model.dart';
import 'package:intl/intl.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/documents_screen.dart';

class CalculationResultScreen extends StatefulWidget {
  final int modalityId;
  final double sueldoBase;

  const CalculationResultScreen({
    Key? key,
    required this.modalityId,
    required this.sueldoBase,
  }) : super(key: key);

  @override
  State<CalculationResultScreen> createState() => _CalculationResultScreenState();
}

class _CalculationResultScreenState extends State<CalculationResultScreen> {
  LoanModalityNew? _modality;
  LoanParametersNew? _params;
  late double _montoSolicitado;
  late int _plazoMeses;
  late int _affiliateId;

  final TextEditingController _montoController = TextEditingController();
  final FocusNode _montoFocusNode = FocusNode();
  bool _isFirstTap = true;

  double _cuotaMensual = 0.0;
  double _liquidoParaCalificacion = 0.0;
  String _mensajeError = '';
  double _montoMaximoCalculado = 0.0;

  // Paleta de colores
  static const Color _olive600 = Color(0xFF8B9D6D);
  static const Color _olive700 = Color(0xFF7A8B5E);
  static const Color _green600 = Color(0xFF059669);
  static const Color _red600 = Color(0xFFDC2626);
  static const Color _orange600 = Color(0xFFEA580C);

  @override
  void initState() {
    super.initState();
    _loadModality();
    _setupFocusListener();
  }

  void _setupFocusListener() {
    _montoFocusNode.addListener(() {
      if (!_montoFocusNode.hasFocus) _isFirstTap = true;
    });
  }

  void _loadModality() {
    final state = context.read<LoanPreEvaluationBloc>().state;
    final userState = context.read<UserBloc>().state;
    
    final modalities = _getModalitiesFromState(state);
    
    if (modalities != null && userState.user?.affiliateId != null) {
      final modality = modalities.where((m) => m.id == widget.modalityId).firstOrNull;
      if (modality != null) {
        setState(() {
          _modality = modality;
          _affiliateId = userState.user!.affiliateId!;
        });
        _initValues();
        return;
      }
    }
    
    _showErrorAndExit('No se pudieron cargar las modalidades');
  }

  List<LoanModalityNew>? _getModalitiesFromState(LoanPreEvaluationState state) {
    if (state is LoanModalitiesLoaded) return state.modalities;
    if (state is LoanModalitiesWithContributionsLoaded) return state.modalities;
    return null;
  }

  void _showErrorAndExit(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  void _initValues() {
    if (_modality != null) {
      _params = _modality!.parameters;
      _montoSolicitado = _params!.minimumAmountModality;
      _plazoMeses = _params!.minimumTermModality;
      _liquidoParaCalificacion = widget.sueldoBase;

      // Mostrar solo el número sin formato en el campo
      _montoController.text = _montoSolicitado.toStringAsFixed(2);
      _calculate();
    }
  }

  double _pow(double base, int exponent) {
    return exponent >= 0
        ? pow(base, exponent).toDouble()
        : 1.0 / pow(base, -exponent).toDouble();
  }

  void _calculate() {
    if (_params == null) return;
    
    final minMonto = _params!.minimumAmountModality;
    final maxMonto = _params!.maximumAmountModality;
    final minPlazo = _params!.minimumTermModality;
    final maxPlazo = _params!.maximumTermModality;

    final montoValidado = _montoSolicitado.clamp(minMonto, maxMonto);
    final plazoValidado = _plazoMeses.clamp(minPlazo, maxPlazo);

    final ticMensual = (_params!.annualInterest * 365.25 / 360 / 100) / (12 / _params!.loanMonthTerm);

    double cuotaFija = 0;
    if (ticMensual == 0) {
      cuotaFija = montoValidado / plazoValidado;
    } else {
      final factor = _pow(1 + ticMensual, plazoValidado);
      cuotaFija = (montoValidado * ticMensual * factor) / (factor - 1);
    }
    cuotaFija = ((cuotaFija * 100).roundToDouble()) / 100;

    // Calcular el límite de endeudamiento considerando si es mensual o semestral
    final ingresoParaCalculo = (_params!.loanMonthTerm == 1) 
        ? _liquidoParaCalificacion  // Mensual: usar sueldo base directo
        : _liquidoParaCalificacion * 6;  // Semestral: sueldo base * 6 meses
    
    // Calcular monto máximo basado en sueldo base, coveragePercentage y plazo máximo
    // montoMaximoBasadoEnSueldo = ingresoParaCalculo * coveragePercentage * maximumTermModality
    final montoMaximoBasadoEnSueldo = ingresoParaCalculo * _params!.coveragePercentage * _params!.maximumTermModality;
    
    // El monto máximo real es el menor entre el calculado y el máximo de la modalidad
    final montoMaximoReal = montoMaximoBasadoEnSueldo < _params!.maximumAmountModality 
        ? montoMaximoBasadoEnSueldo 
        : _params!.maximumAmountModality;
    
    final limiteEndeudamiento = ingresoParaCalculo > 0
        ? (cuotaFija / ingresoParaCalculo) * 100
        : 0.0;

    setState(() {
      _montoSolicitado = montoValidado;
      _plazoMeses = plazoValidado;
      _cuotaMensual = cuotaFija;
      _montoMaximoCalculado = montoMaximoReal;
      _mensajeError = '';

      if (limiteEndeudamiento > _params!.debtIndex) {
        _mensajeError = 'La cuota ${(_params!.loanMonthTerm == 1) ? 'mensual' : 'semestral'} excede el límite de endeudamiento permitido de ${_params!.debtIndex}%.';
      }
    });
  }

  void _onMontoChanged(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9.,]'), '');
    
    if (cleaned.isEmpty) {
      _montoSolicitado = _params?.minimumAmountModality ?? 0;
    } else {
      final value = double.tryParse(cleaned.replaceAll(',', '.'));
      if (value != null && value >= 0) {
        _montoSolicitado = _clampAmount(value);
        if (_montoSolicitado != value) {
          _updateControllerWithClampedValue();
        }
      }
    }
    _calculate();
  }

  double _clampAmount(double value) {
    final maxAmount = _montoMaximoCalculado > 0 
        ? _montoMaximoCalculado 
        : (_params?.maximumAmountModality ?? double.infinity);
    final minAmount = _params?.minimumAmountModality ?? 0;
    
    return value.clamp(minAmount, maxAmount);
  }

  void _updateControllerWithClampedValue() {
    _montoController.text = _montoSolicitado.toStringAsFixed(2);
    _montoController.selection = TextSelection.fromPosition(
      TextPosition(offset: _montoController.text.length),
    );
  }

  String _formatMoney(double amount) {
    return NumberFormat('#,##0.00', 'es_ES').format(amount).replaceAll('.', ' ');
  }

  String _getInterestLabel() {
    return (_params?.loanMonthTerm ?? 1) == 1 ? "Interés Mensual" : "Interés Semestral";
  }

  String _getPlazoText() {
    final termType = (_params?.loanMonthTerm ?? 1) == 1 ? 'meses' : 'semestres';
    return "${_params?.minimumTermModality ?? 0}-${_params?.maximumTermModality ?? 0}\n$termType";
  }

  String _getTermType() {
    return (_params?.loanMonthTerm ?? 1) == 1 ? 'meses' : 'semestres';
  }

  String _getPaymentFrequency() {
    return (_params?.loanMonthTerm ?? 1) == 1 ? 'mensual' : 'semestral';
  }

  double _getMaxAmount() {
    return _montoMaximoCalculado > 0 
        ? _montoMaximoCalculado 
        : (_params?.maximumAmountModality ?? 0);
  }

  void _handleMontoFieldTap(TextEditingController controller) {
    _montoFocusNode.requestFocus();
    if (_isFirstTap) {
      _selectAllText(controller);
      _isFirstTap = false;
    }
  }

  void _selectAllText(TextEditingController controller) {
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  void _loadDocuments() async {
    FocusScope.of(context).unfocus();
    
    try {
      if (_modality == null) throw Exception('Modalidad no encontrada');
      
      context.read<LoanPreEvaluationBloc>().add(
        LoadLoanDocuments(_modality!.procedureModalityId, _affiliateId)
      );
    } catch (e) {
      if (!mounted) return;
      final errorMessage = e.toString().contains('Exception:') 
          ? e.toString().split('Exception:')[1].trim() 
          : e.toString();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener documentos: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      // Quitar foco al tocar fuera del campo
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: BlocListener<LoanPreEvaluationBloc, LoanPreEvaluationState>(
      listener: (context, state) {
        if (state is LoanDocumentsLoaded) {
          // Navegar a la pantalla de documentos
          // Convertir los documentos al formato esperado por DocumentsScreen
          final documents = state.documents.documents.map((doc) => 
            RequiredDocument(
              number: doc.number,
              message: doc.name,
              options: [], // La nueva API no incluye opciones, se puede manejar después
            )
          ).toList();
          
          // Obtener el BLoC actual antes de navegar
          final currentBloc = context.read<LoanPreEvaluationBloc>();
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: currentBloc,
                child: DocumentsScreen(documents: documents),
              ),
            ),
          );
        } else if (state is LoanDocumentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Cálculo de Préstamo',
            style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _modality == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // === Información de la Modalidad ===
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(colors: [_olive600, _olive700]),
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                ),
                                child: const Center(
                                  child: Text(
                                    "M",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _modality?.name ?? 'Modalidad',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: _olive600,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.visible,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Modalidad Seleccionada",
                                      style: TextStyle(
                                        color: _olive600.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.7,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: [
                              _buildInfoCard(
                                icon: Icons.percent,
                                label: _getInterestLabel(),
                                value: "${_params?.periodInterest ?? 0}%",
                                bgColor: Colors.blue.shade100,
                                textColor: Colors.blue.shade700,
                              ),
                              _buildInfoCard(
                                icon: Icons.trending_up,
                                label: "Interés Anual",
                                value: "${_params?.annualInterest ?? 0}%",
                                bgColor: Colors.purple.shade100,
                                textColor: Colors.purple.shade700,
                              ),
                              _buildInfoCard(
                                icon: Icons.people,
                                label: "Garantes",
                                value: "${_params?.guarantors ?? 0}",
                                bgColor: Colors.orange.shade100,
                                textColor: Colors.orange.shade700,
                              ),
                              _buildInfoCard(
                                icon: Icons.calendar_today,
                                label: "Plazo",
                                value: _getPlazoText(),
                                bgColor: Colors.green.shade100,
                                textColor: Colors.green.shade700,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _olive600.withOpacity(0.2)),
                            ),
                            child: Text(
                              "💰 Monto disponible: ${_formatMoney(_params?.minimumAmountModality ?? 0)} - ${_formatMoney(_getMaxAmount())} Bs",
                              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // === Monto Solicitado ===
                  _buildInputField(
                    label: "💵 Monto Solicitado",
                    controller: _montoController,
                    onChanged: _onMontoChanged,
                    hint: "Ingrese el monto",
                    suffix: "",
                  ),

                  // === Plazo ===
                  _buildTermSelector(
                    label: "📅 Plazo (${_getTermType()})",
                    value: _plazoMeses,
                    min: _params?.minimumTermModality ?? 1,
                    max: _params?.maximumTermModality ?? 12,
                    onChange: (value) {
                      setState(() {
                        _plazoMeses = value;
                        _calculate();
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // === Mensaje de Error ===
                  if (_mensajeError.isNotEmpty) _buildErrorAlert(),

                  const SizedBox(height: 24),

                  // === Resultados ===
                  Container(
                    decoration: BoxDecoration(
                      gradient: _mensajeError.isEmpty
                          ? const LinearGradient(colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)])
                          : const LinearGradient(colors: [Color(0xFFFFEFEF), Color(0xFFFFE5E5)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _mensajeError.isEmpty ? Colors.green.shade300 : Colors.red.shade300,
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildResultHeader(),
                          const SizedBox(height: 20),
                          _buildMonthlyPaymentCard(),
                          const SizedBox(height: 20),
                          _buildGuarantorsInfo(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _loadDocuments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      elevation: 8,
                      minimumSize: const Size(double.infinity, 60),
                    ),
                    child: Text(
                      "VER DOCUMENTOS REQUERIDOS",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                ],
              ),
            ),
      ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: textColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: const TextStyle(
                    fontSize: 10, 
                    color: Colors.grey
                  )
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String hint,
    required String suffix,
  }) {
    final theme = Theme.of(context);
    final maxAmount = _getMaxAmount();
    final isOverLimit = _montoSolicitado > maxAmount;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        
        // Campo de entrada estilo bancario
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverLimit ? Colors.red.shade300 : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: GestureDetector(
            onTap: () => _handleMontoFieldTap(controller),
            onDoubleTap: () => _selectAllText(controller),
            child: TextField(
              controller: controller,
              focusNode: _montoFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: onChanged,

            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: isOverLimit ? Colors.red.shade600 : const Color(0xFF1E3A8A),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: "0,00",
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
              suffixText: "Bs",
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isOverLimit ? Colors.red.shade600 : Colors.grey.shade600,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Monto formateado elegante
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isOverLimit 
                ? [Colors.red.shade50, Colors.red.shade100]
                : [Colors.green.shade50, Colors.green.shade100],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOverLimit ? Colors.red.shade200 : Colors.green.shade200,
            ),
          ),
          child: Column(
            children: [
              Text(
                "Monto solicitado",
                style: TextStyle(
                  fontSize: 14,
                  color: isOverLimit ? Colors.red.shade600 : Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${_formatMoney(_montoSolicitado)} Bs",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isOverLimit ? Colors.red.shade700 : Colors.green.shade700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermSelector({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChange,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold, 
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildIconButton(Icons.remove, value > min, () => onChange(value - 1)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orange.shade100, Colors.orange.shade50]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Center(
                  child: Text(
                    "$value",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _orange600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildIconButton(Icons.add, value < max, () => onChange(value + 1)),
          ],
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Slider(
                value: value.toDouble(),
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: (max - min),
                activeColor: _orange600,
                inactiveColor: Colors.orange.shade200,
                onChanged: (v) => onChange(v.round()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$min ${(_params?.loanMonthTerm ?? 1) == 1 ? 'meses' : 'semestres'}",
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                  ),
                  Text(
                    "$max ${(_params?.loanMonthTerm ?? 1) == 1 ? 'meses' : 'semestres'}",
                    style: TextStyle(fontSize: 12, color: Colors.orange.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, bool enabled, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange.shade300,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 0,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }

  Widget _buildErrorAlert() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFFEFEF), Color(0xFFFFE5E5)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.warning_amber, size: 20, color: _red600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚠️ Límite excedido",
                    style: TextStyle(fontWeight: FontWeight.bold, color: _red600),
                  ),
                  Text(
                    _mensajeError,
                    style: TextStyle(fontSize: 10, color: Colors.red.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _mensajeError.isEmpty ? Colors.green.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _mensajeError.isEmpty ? Icons.check_circle : Icons.warning_amber,
            color: _mensajeError.isEmpty ? _green600 : _red600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "Resultado del Cálculo",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _mensajeError.isEmpty ? _green600 : _red600,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _mensajeError.isEmpty
            ? const LinearGradient(colors: [_green600, Color(0xFF047857)])
            : const LinearGradient(colors: [_red600, Color(0xFF991B1B)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _mensajeError.isEmpty ? Colors.green.shade200 : Colors.red.shade200,
          width: 3,
        ),
      ),
      child: Column(
        children: [
          Text("💰 CUOTA ${(_params?.loanMonthTerm ?? 1) == 1 ? 'MENSUAL' : 'SEMESTRAL'}", style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _formatMoney(_cuotaMensual).replaceFirst("Bs ", ""),
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text("Bolivianos", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9))),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "🗓️ Pagarás ${_formatMoney(_cuotaMensual)} cada "
              "${(_params?.loanMonthTerm ?? 1) == 1 ? 'mes' : 'semestre'} "
              "por $_plazoMeses "
              "${(_params?.loanMonthTerm ?? 1) == 1 ? 'meses' : 'semestres'}",
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuarantorsInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
        boxShadow: [BoxShadow(color: Colors.orange.shade100.withOpacity(0.3), blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.people, color: _orange600, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                "Garantes Requeridos:",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_orange600, Color(0xFFC2410C)]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.orange.shade300.withOpacity(0.6), blurRadius: 3, offset: const Offset(0, 2)),
              ],
            ),
            child: Text(
              "${_params?.guarantors ?? 0}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _montoController.dispose();
    _montoFocusNode.dispose();
    super.dispose();
  }
}