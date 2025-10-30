import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/model/loan_pre_evaluation_model.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/calculation_result_screen.dart';

// =================== PANTALLA PRINCIPAL ===================
class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> with WidgetsBindingObserver {
  double? sueldoBase;
  bool _isFetchingSueldo = false;
  bool _isGridView = true; // Para controlar la vista de modalidades

  final TextEditingController sueldoController = TextEditingController();
  final TextEditingController rentaDignidadController = TextEditingController();
  final FocusNode sueldoFocusNode = FocusNode();
  final FocusNode rentaFocusNode = FocusNode();
  
  bool _isFirstTapSueldo = true;
  bool _isFirstTapRenta = true;

  String _affiliateStateType = '';
  int _affiliateId = 0;
  bool _hasNavigatedAway = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    _setupFocusListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _hasNavigatedAway) {
      // La app volvió a primer plano y habíamos navegado, recargar datos
      _refreshData();
      _hasNavigatedAway = false;
    }
  }

  void _setupFocusListeners() {
    sueldoFocusNode.addListener(() {
      if (!sueldoFocusNode.hasFocus) _isFirstTapSueldo = true;
    });
    
    rentaFocusNode.addListener(() {
      if (!rentaFocusNode.hasFocus) _isFirstTapRenta = true;
    });
  }

  void _initData() {
    final userState = context.read<UserBloc>().state;
    if (userState.user?.affiliateId != null) {
      _affiliateId = userState.user!.affiliateId!;
      context.read<LoanPreEvaluationBloc>().add(LoadLoanModalitiesPreEval(_affiliateId));
    }
  }

  void _refreshData() {
    if (_affiliateId > 0) {
      // Recargar las modalidades cuando volvemos a la pantalla
      context.read<LoanPreEvaluationBloc>().add(LoadLoanModalitiesPreEval(_affiliateId));
    }
  }

  void _updateSueldoBase() {
    if (_affiliateStateType != 'Pasivo') return;

    double sueldo = _parseCurrency(sueldoController.text) ?? 0.0;
    double renta = _parseCurrency(rentaDignidadController.text) ?? 0.0;
    double nuevoSueldoBase = sueldo - renta;

    if ((sueldoBase ?? 0.0) != nuevoSueldoBase) {
      setState(() {
        sueldoBase = nuevoSueldoBase;
      });
    }
  }

  double? _parseCurrency(String text) {
    if (text.isEmpty) return 0.0;
    String cleaned = text.replaceAll(RegExp(r'[^\d,\.]'), '');
    if (!RegExp(r'\d').hasMatch(cleaned)) return 0.0;

    String normalized = cleaned.replaceAll(',', '.');
    List<String> parts = normalized.split('.');
    if (parts.length > 2) {
      String integer = parts.take(parts.length - 1).join('');
      String decimal = parts.last;
      normalized = '$integer.$decimal';
    }

    return double.tryParse(normalized);
  }

  void _obtenerUltimoPago(int affiliateId) {
    setState(() => _isFetchingSueldo = true);
    context.read<LoanPreEvaluationBloc>().add(LoadQuotableContributions(affiliateId));
  }

  void _handleQuotableContributionsLoaded(QuotableContributionsResponse contributions) {
    if (contributions.payload.contributions.isEmpty) {
      _showErrorMessage('No hay información de pago. Actualice en oficinas presenciales.');
      return;
    }

    final lastContribution = contributions.payload.contributions.first;
    final quotable = _parseSpanishNumber(lastContribution.quotable);
    
    if (quotable > 0) {
      setState(() {
        sueldoBase = quotable;
        _isFetchingSueldo = false;
      });
    } else {
      _showErrorMessage('Sueldo base no válido: valor parseado es $quotable');
    }
  }

  double _parseSpanishNumber(String value) {
    String cleaned = value.replaceAll(' ', '');
    
    if (cleaned.contains('.') && cleaned.contains(',')) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleaned.contains(',')) {
      cleaned = cleaned.replaceAll(',', '.');
    }
    
    return double.tryParse(cleaned) ?? 0.0;
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.orange),
      );
      setState(() {
        sueldoBase = 0;
        _isFetchingSueldo = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    sueldoController.dispose();
    rentaDignidadController.dispose();
    sueldoFocusNode.dispose();
    rentaFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      // Quitar foco al tocar fuera de los campos
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Pre-evaluación de Préstamo',
            style: theme.appBarTheme.titleTextStyle?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: MultiBlocListener(
        listeners: [
          BlocListener<LoanPreEvaluationBloc, LoanPreEvaluationState>(
            listener: (context, state) {
              if (state is LoanModalitiesLoaded && state.modalities.isNotEmpty) {
                final firstModality = state.modalities.first;
                setState(() {
                  _affiliateStateType = firstModality.affiliateStateType;
                });

                if (_affiliateStateType == 'Activo') {
                  _obtenerUltimoPago(_affiliateId);
                } else {
                  _updateSueldoBase();
                }
              } else if (state is LoanModalitiesWithContributionsLoaded && state.contributions != null) {
                _handleQuotableContributionsLoaded(state.contributions!);
              } else if (state is LoanModalitiesError) {
                _showErrorMessage('Error al cargar modalidades: ${state.message}');
              } else if (state is QuotableContributionsLoaded) {
                _handleQuotableContributionsLoaded(state.contributions);
              } else if (state is QuotableContributionsError) {
                _showErrorMessage(state.message);
              }
            },
          ),
        ],
        child: BlocBuilder<LoanPreEvaluationBloc, LoanPreEvaluationState>(
          builder: (context, state) {
            if (state is LoanModalitiesLoading) {
              String loadingText = 'Cargando modalidades de préstamo...';
              if (state.currentAttempt != null && state.maxAttempts != null) {
                if (state.currentAttempt! > 1) {
                  loadingText = 'Reintentando... (${state.currentAttempt}/${state.maxAttempts})';
                }
              }
              
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(loadingText),
                    if (state.currentAttempt != null && state.currentAttempt! > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Verificando conexión...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            
            if (state is LoanModalitiesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error al cargar modalidades',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LoanPreEvaluationBloc>().add(LoadLoanModalitiesPreEval(_affiliateId));
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            // Manejar tanto LoanModalitiesLoaded como LoanModalitiesWithContributionsLoaded
            if (state is LoanModalitiesLoaded || state is LoanModalitiesWithContributionsLoaded) {
              List<LoanModalityNew> modalities;
              
              if (state is LoanModalitiesLoaded) {
                modalities = state.modalities;
              } else {
                modalities = (state as LoanModalitiesWithContributionsLoaded).modalities;
              }
              
              if (modalities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 60, color: Colors.blue),
                        const SizedBox(height: 16),
                        Text(
                          'No hay modalidades disponibles',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No se encontraron modalidades de préstamo para su perfil.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                );
              }

              final bool isActivo = _affiliateStateType == 'Activo';
              final bool isBaja = _affiliateStateType == 'Baja';

              if (isBaja) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber, size: 60, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          'Actualice su información en oficinas presenciales.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (isActivo)
                      _buildSueldoActivo()
                    else
                      _buildPasivoFields(),
                    
                    // Vista de modalidades integrada
                    _buildModalitiesSection(modalities, (modality) {
                        if (isActivo && (sueldoBase == null || sueldoBase == 0)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No se pudo obtener el sueldo. Intente más tarde.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (!isActivo && (sueldoBase == null || sueldoBase! <= 0)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('El sueldo base debe ser mayor a 0.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Quitar foco antes de navegar
                        FocusScope.of(context).unfocus();
                        
                        // Marcar que hemos navegado para recargar cuando volvamos
                        _hasNavigatedAway = true;
                        
                        // Obtener el BLoC actual antes de navegar
                        final currentBloc = context.read<LoanPreEvaluationBloc>();
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: currentBloc,
                              child: CalculationResultScreen(
                                modalityId: modality.id,
                                sueldoBase: sueldoBase!,
                              ),
                            ),
                          ),
                        ).then((_) {
                          // Cuando volvemos de la navegación, recargar datos
                          _refreshData();
                          _hasNavigatedAway = false;
                        });
                      }),
                  ],
                ),
              );
            }
            
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Inicializando...'),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }

  Widget _buildSueldoActivo() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del afiliado activo',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_isFetchingSueldo)
            const LinearProgressIndicator()
          else if (sueldoBase != null && sueldoBase! > 0)
            Text(
              'Sueldo base: ${_formatMoney(sueldoBase!)} Bs',
              style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
            )
          else
            Text(
              'No se pudo obtener el sueldo.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildPasivoFields() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del afiliado pasivo',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: 'Sueldo',
            controller: sueldoController,
            onChanged: _onSueldoChanged,
            hint: "Ingrese el sueldo",
            suffix: "",
          ),
          const SizedBox(height: 12),
          _buildInputField(
            label: 'Renta Dignidad',
            controller: rentaDignidadController,
            onChanged: _onRentaChanged,
            hint: "Ingrese la renta",
            suffix: "",
          ),
          const SizedBox(height: 16),
          if (sueldoBase != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sueldoBase! > 0 
                  ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50)
                  : (isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: sueldoBase! > 0 
                    ? Colors.green.shade200
                    : Colors.red.shade200,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Sueldo base calculado",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: sueldoBase! > 0 ? Colors.green.shade600 : Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_formatMoney(sueldoBase!)} Bs",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: sueldoBase! > 0 ? Colors.green.shade700 : Colors.red.shade700,
                      letterSpacing: -0.5,
                    ),
                  ),
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
    final isDark = theme.brightness == Brightness.dark;
    final bool isSueldo = label == 'Sueldo';
    final FocusNode focusNode = isSueldo ? sueldoFocusNode : rentaFocusNode;
    final bool isFirstTap = isSueldo ? _isFirstTapSueldo : _isFirstTapRenta;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "💰 $label",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300, 
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
            onTap: () => _handleFieldTap(controller, focusNode, isSueldo),
            onDoubleTap: () => _selectAllText(controller),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: onChanged,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E3A8A),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "0,00",
                hintStyle: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                suffixText: "Bs",
                suffixStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleFieldTap(TextEditingController controller, FocusNode focusNode, bool isSueldo) {
    focusNode.requestFocus();
    
    final isFirstTap = isSueldo ? _isFirstTapSueldo : _isFirstTapRenta;
    if (isFirstTap) {
      _selectAllText(controller);
      setState(() {
        if (isSueldo) {
          _isFirstTapSueldo = false;
        } else {
          _isFirstTapRenta = false;
        }
      });
    }
  }

  void _selectAllText(TextEditingController controller) {
    controller.selection = TextSelection(baseOffset: 0, extentOffset: controller.text.length);
  }

  String _formatMoney(double amount) {
    return NumberFormat('#,##0.00', 'es_ES').format(amount).replaceAll('.', ' ');
  }

  void _onSueldoChanged(String text) {
    _updateSueldoBase();
  }

  void _onRentaChanged(String text) {
    _updateSueldoBase();
  }

  Widget _buildModalitiesSection(List<LoanModalityNew> modalities, Function(LoanModalityNew) onModalitySelected) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Modalidades disponibles',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                tooltip: _isGridView ? 'Ver como lista' : 'Ver como cuadrícula',
              ),
            ],
          ),
        ),
        // Vista dinámica de modalidades
        Padding(
          padding: const EdgeInsets.all(8),
          child: _isGridView ? _buildGridView(modalities, onModalitySelected) : _buildListView(modalities, onModalitySelected),
        ),
      ],
    );
  }

  Widget _buildGridView(List<LoanModalityNew> modalities, Function(LoanModalityNew) onModalitySelected) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modalities.length,
      itemBuilder: (context, index) {
        return ModalityCard(
          modality: modalities[index],
          onPressed: () => onModalitySelected(modalities[index]),
          isGridView: true,
        );
      },
    );
  }

  Widget _buildListView(List<LoanModalityNew> modalities, Function(LoanModalityNew) onModalitySelected) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modalities.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ModalityCard(
            modality: modalities[index],
            onPressed: () => onModalitySelected(modalities[index]),
            isGridView: false,
          ),
        );
      },
    );
  }

}



// =================== TARJETA DE MODALIDAD ===================
class ModalityCard extends StatelessWidget {
  final LoanModalityNew modality;
  final VoidCallback onPressed;
  final bool isGridView;

  const ModalityCard({
    Key? key,
    required this.modality,
    required this.onPressed,
    this.isGridView = true,
  }) : super(key: key);

  String formatAmount(double amount) {
    return NumberFormat('#,##0', 'es_ES').format(amount).replaceAll('.', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[600]!.withOpacity(0.3), width: 1),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: isGridView ? _buildGridLayout(context) : _buildListLayout(context),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          modality.name,
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          Icons.attach_money,
          'Monto: ${formatAmount(modality.parameters.minimumAmountModality)} - ${formatAmount(modality.parameters.maximumAmountModality)}',
          Colors.green[600]!,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          Icons.percent,
          'Interés: ${modality.parameters.periodInterest.toStringAsFixed(2)}%',
          Colors.orange[600]!,
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          context,
          Icons.group,
          'Garantes: ${modality.parameters.guarantors}',
          Colors.blue[600]!,
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 40),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600]!,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                minimumSize: const Size(100, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text(
                'Seleccionar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListLayout(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Información principal expandida
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modality.name,
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      Icons.attach_money,
                      'Monto',
                      '${formatAmount(modality.parameters.minimumAmountModality)} - ${formatAmount(modality.parameters.maximumAmountModality)} Bs',
                      Colors.green[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      Icons.percent,
                      'Interés',
                      '${modality.parameters.periodInterest.toStringAsFixed(2)}%',
                      Colors.orange[600]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      Icons.group,
                      'Garantes',
                      '${modality.parameters.guarantors}',
                      Colors.blue[600]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      Icons.calendar_today,
                      'Plazo',
                      '${modality.parameters.minimumTermModality}-${modality.parameters.maximumTermModality} ${(modality.parameters.loanMonthTerm == 1) ? 'meses' : 'semestres'}',
                      Colors.purple[600]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Botón de selección
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600]!,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Seleccionar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color color) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoColumn(BuildContext context, IconData icon, String label, String value, Color color) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
          maxLines: 2,
          overflow: TextOverflow.visible,
        ),
      ],
    );
  }
}