import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:muserpol_pvt/model/saved_loan_evaluation.dart';
import 'package:muserpol_pvt/services/evaluation_service.dart';

import 'package:muserpol_pvt/bloc/loan_pre_evaluation/loan_pre_evaluation_bloc.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/calculation_result_screen.dart';

class SavedEvaluationsScreen extends StatefulWidget {
  const SavedEvaluationsScreen({super.key});

  @override
  State<SavedEvaluationsScreen> createState() => _SavedEvaluationsScreenState();
}

class _SavedEvaluationsScreenState extends State<SavedEvaluationsScreen> {
  final EvaluationService _evaluationService = EvaluationService();
  List<SavedLoanEvaluation> _evaluations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvaluations();
  }

  Future<void> _loadEvaluations() async {
    setState(() => _isLoading = true);
    final userBloc = context.read<UserBloc>();
    final userId = userBloc.state.user?.affiliateId;
    await _cleanObsoleteEvaluations();

    final evaluations =
        await _evaluationService.getSavedEvaluations(userId: userId);
    setState(() {
      _evaluations = evaluations;
      _isLoading = false;
    });
  }

  Future<void> _cleanObsoleteEvaluations() async {
    try {
      final loanBloc = context.read<LoanPreEvaluationBloc>();
      final state = loanBloc.state;

      List<dynamic>? currentModalities;

      if (state is LoanModalitiesLoaded) {
        currentModalities = state.modalities
            .map((m) => {
                  'id': m.id,
                  'parameters': {
                    'annualInterest': m.parameters.annualInterest,
                    'periodInterest': m.parameters.periodInterest,
                    'guarantors': m.parameters.guarantors,
                  }
                })
            .toList();
      } else if (state is LoanModalitiesWithContributionsLoaded) {
        currentModalities = state.modalities
            .map((m) => {
                  'id': m.id,
                  'parameters': {
                    'annualInterest': m.parameters.annualInterest,
                    'periodInterest': m.parameters.periodInterest,
                    'guarantors': m.parameters.guarantors,
                  }
                })
            .toList();
      }

      if (currentModalities != null && currentModalities.isNotEmpty) {
        final removedCount = await _evaluationService
            .cleanObsoleteEvaluations(currentModalities);

        if (removedCount > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '⚠️ Se eliminaron $removedCount evaluación(es) con datos obsoletos'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al limpiar evaluaciones obsoletas: $e');
    }
  }

  Future<void> _deleteEvaluation(String id) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true) {
      // Obtener userId del usuario actual
      final userBloc = context.read<UserBloc>();
      final userId = userBloc.state.user?.affiliateId;

      final success =
          await _evaluationService.deleteEvaluation(id, userId: userId);
      if (success) {
        _loadEvaluations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evaluación eliminada'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Evaluación'),
        content: const Text('¿Está seguro de eliminar esta evaluación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(String id) async {
    final userBloc = context.read<UserBloc>();
    final userId = userBloc.state.user?.affiliateId;

    await _evaluationService.toggleFavorite(id, userId: userId);
    _loadEvaluations();
  }

  void _reloadEvaluation(SavedLoanEvaluation evaluation) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final newBloc = LoanPreEvaluationBloc(context: context);
      final userBloc = context.read<UserBloc>();
      final affiliateId = userBloc.state.user?.affiliateId;

      if (affiliateId == null) {
        throw Exception('No se pudo obtener el ID del afiliado');
      }

      newBloc.add(LoadLoanModalitiesPreEval(affiliateId));

      await for (final state in newBloc.stream) {
        if (state is LoanModalitiesLoaded ||
            state is LoanModalitiesWithContributionsLoaded) {
          break;
        } else if (state is LoanModalitiesError) {
          throw Exception(state.message);
        }
      }

      if (!mounted) return;

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: newBloc,
            child: CalculationResultScreen(
              modalityId: evaluation.modalityId,
              sueldoBase: evaluation.sueldoBase,
              affiliateStateType: evaluation.affiliateStateType,
              liquidoPagable: evaluation.liquidoPagable,
              totalBonos: evaluation.totalBonos,
              seniorityBonus: evaluation.seniorityBonus,
              studyBonus: evaluation.studyBonus,
              positionBonus: evaluation.positionBonus,
              borderBonus: evaluation.borderBonus,
              eastBonus: evaluation.eastBonus,
              rentaDignidad: evaluation.rentaDignidad,
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al recargar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatMoney(double amount) {
    return NumberFormat('#,##0.00', 'es_ES')
        .format(amount)
        .replaceAll('.', ' ');
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? theme.scaffoldBackgroundColor : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mis Evaluaciones'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _evaluations.isEmpty
              ? _buildEmptyState(theme)
              : _buildEvaluationsList(theme, isDark),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open,
                size: 60,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay evaluaciones guardadas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Realiza una evaluación preliminar y guárdala para verla aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationsList(ThemeData theme, bool isDark) {
    final sortedEvaluations = List<SavedLoanEvaluation>.from(_evaluations)
      ..sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    return RefreshIndicator(
      onRefresh: _loadEvaluations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedEvaluations.length,
        itemBuilder: (context, index) {
          final evaluation = sortedEvaluations[index];
          return _buildEvaluationCard(evaluation, theme, isDark);
        },
      ),
    );
  }

  Widget _buildEvaluationCard(
    SavedLoanEvaluation evaluation,
    ThemeData theme,
    bool isDark,
  ) {
    final daysSinceCreation =
        DateTime.now().difference(evaluation.createdAt).inDays;
    final isOld = daysSinceCreation > 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: evaluation.isFavorite
              ? Colors.amber.shade400
              : (isDark ? Colors.grey.shade700 : Colors.grey.shade200),
          width: evaluation.isFavorite ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isOld)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Evaluación de hace $daysSinceCreation días. Los datos podrían haber cambiado.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: evaluation.isFavorite
                  ? Colors.amber.shade50
                  : (isDark ? Colors.grey.shade700 : Colors.grey.shade50),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    evaluation.isFavorite ? Icons.star : Icons.star_border,
                    color: evaluation.isFavorite
                        ? Colors.amber.shade700
                        : Colors.grey.shade400,
                  ),
                  onPressed: () => _toggleFavorite(evaluation.id),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evaluation.modalityName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(evaluation.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.attach_money,
                  label: 'Monto',
                  value: '${_formatMoney(evaluation.amount)} Bs',
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: 'Plazo',
                  value: '${evaluation.term} ${evaluation.termType}',
                  theme: theme,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.payments,
                  label: 'Cuota ${evaluation.paymentFrequency}',
                  value: '${_formatMoney(evaluation.monthlyPayment)} Bs',
                  theme: theme,
                  isHighlighted: true,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.account_balance_wallet,
                  label: 'Sueldo Base',
                  value: '${_formatMoney(evaluation.sueldoBase)} Bs',
                  theme: theme,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _reloadEvaluation(evaluation),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Recargar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[600],
                          side: BorderSide(color: Colors.green[600]!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteEvaluation(evaluation.id),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Eliminar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[600],
                          side: BorderSide(color: Colors.red[600]!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlighted ? Colors.green[600] : Colors.grey.shade600,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                  color: isHighlighted ? Colors.green[700] : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
