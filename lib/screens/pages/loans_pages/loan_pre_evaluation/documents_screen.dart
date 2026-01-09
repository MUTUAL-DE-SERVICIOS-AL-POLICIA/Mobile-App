import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:muserpol_pvt/screens/navigation_general_pages.dart';
import 'package:muserpol_pvt/screens/pages/loans_pages/loan_pre_evaluation/widgets/loan_progress_indicator.dart';
import 'package:muserpol_pvt/model/saved_loan_evaluation.dart';
import 'package:muserpol_pvt/model/evaluation_models.dart';
import 'package:muserpol_pvt/services/evaluation_service.dart';
import 'package:muserpol_pvt/bloc/user/user_bloc.dart';
import 'widgets/evaluation_widgets.dart';
// Import para redirigir a la pantalla de préstamos y abrir la evaluación
import 'package:muserpol_pvt/screens/pages/loans_pages/loans_page_new.dart';

class DocumentsScreen extends StatefulWidget {
  final VoidCallback? onExit;
  final List<RequiredDocument> documents;
  final String modalityName;
  final double amount;
  final int term;
  final double monthlyPayment;
  final String paymentFrequency;
  final String termType;
  final double sueldoBase;
  final String affiliateStateType;
  final double annualInterest;
  final double periodInterest;
  final int guarantors;
  final double? liquidoPagable;
  final double? totalBonos;
  final double? seniorityBonus;
  final double? studyBonus;
  final double? positionBonus;
  final double? borderBonus;
  final double? eastBonus;
  final double? rentaDignidad;
  final int modalityId;
  final int procedureModalityId;
  final String? affiliateName;
  final String? affiliateIdentityCard;
  final double? loanCharge;

  const DocumentsScreen({
    super.key,
    this.onExit,
    required this.documents,
    this.modalityName = '',
    this.amount = 0.0,
    this.term = 0,
    this.monthlyPayment = 0.0,
    this.paymentFrequency = 'mensual',
    this.termType = 'meses',
    this.sueldoBase = 0.0,
    this.affiliateStateType = '',
    this.annualInterest = 0.0,
    this.affiliateName,
    this.affiliateIdentityCard,
    this.loanCharge,
    this.periodInterest = 0.0,
    this.guarantors = 0,
    this.liquidoPagable,
    this.totalBonos,
    this.seniorityBonus,
    this.studyBonus,
    this.positionBonus,
    this.borderBonus,
    this.eastBonus,
    this.rentaDignidad,
    this.modalityId = 0,
    this.procedureModalityId = 0,
  });

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final EvaluationService _evaluationService = EvaluationService();

  List<GroupedDocument> _groupDocumentsByNumber() {
    final Map<int, List<RequiredDocument>> grouped = {};

    for (final doc in widget.documents.where((d) => d.number != 0)) {
      grouped.putIfAbsent(doc.number, () => []).add(doc);
    }

    return grouped.entries
        .map((entry) => GroupedDocument(
              number: entry.key,
              documents: entry.value,
              hasMultipleOptions: entry.value.length > 1,
            ))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  Future<bool> _saveEvaluation() async {
    try {
      final evaluation = SavedLoanEvaluation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        modalityName: widget.modalityName,
        amount: widget.amount,
        term: widget.term,
        termType: widget.termType,
        monthlyPayment: widget.monthlyPayment,
        paymentFrequency: widget.paymentFrequency,
        sueldoBase: widget.sueldoBase,
        affiliateStateType: widget.affiliateStateType,
        annualInterest: widget.annualInterest,
        periodInterest: widget.periodInterest,
        guarantors: widget.guarantors,
        liquidoPagable: widget.liquidoPagable,
        totalBonos: widget.totalBonos,
        seniorityBonus: widget.seniorityBonus,
        studyBonus: widget.studyBonus,
        positionBonus: widget.positionBonus,
        borderBonus: widget.borderBonus,
        eastBonus: widget.eastBonus,
        rentaDignidad: widget.rentaDignidad,
        modalityId: widget.modalityId,
        procedureModalityId: widget.procedureModalityId,
        affiliateName: widget.affiliateName,
        affiliateIdentityCard: widget.affiliateIdentityCard,
        loanCharge: widget.loanCharge,
        documents: widget.documents
            .map((doc) => {
                  'number': doc.number,
                  'message': doc.message,
                  'options': doc.options
                      .map((opt) => {'id': opt.id, 'name': opt.name})
                      .toList(),
                })
            .toList(),
      );

      final userBloc = context.read<UserBloc>();
      final userId = userBloc.state.user?.affiliateId;

      final isDuplicate =
          await _evaluationService.isDuplicate(evaluation, userId: userId);

      if (!isDuplicate) {
        await _evaluationService.saveEvaluation(evaluation, userId: userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evaluación guardada exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Esta evaluación ya existe en el historial'),
                backgroundColor: Colors.orange),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al guardar evaluación: $e'),
              backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const LoanProgressIndicator(currentStep: 3),
        centerTitle: true,
        backgroundColor: const Color(0xff419388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                ..._buildDocumentsList(),
                const SizedBox(height: 24),
                _buildLoanSummary(theme),
                _buildImportantInfo(theme),
                _buildActionButton(context, theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return EvaluationWidgets.gradientHeader(
      title: "Documentos Requeridos",
      subtitle: "Para trámite en plataforma",
      icon: Icons.description,
    );
  }

  List<Widget> _buildDocumentsList() {
    return _groupDocumentsByNumber().map((groupedDoc) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xff419388).withAlpha(77), width: 2),
          boxShadow: [
            BoxShadow(
                color: const Color(0xff419388).withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNumberCircle(groupedDoc.number),
            const SizedBox(width: 16),
            Expanded(child: _buildDocumentContent(groupedDoc)),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildNumberCircle(int number) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff419388), Color(0xff2d6b61)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: const Color(0xff419388).withAlpha(77),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp),
        ),
      ),
    );
  }

  Widget _buildDocumentContent(GroupedDocument groupedDoc) {
    if (groupedDoc.hasMultipleOptions) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMultipleOptionsHeader(),
          const SizedBox(height: 12),
          ...groupedDoc.documents.map((doc) => _buildDocumentOption(doc)),
        ],
      );
    }

    return Text(
      groupedDoc.documents.first.message ?? "Documento ${groupedDoc.number}",
      style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          height: 1.4,
          color: Colors.grey.shade800),
    );
  }

  Widget _buildMultipleOptionsHeader() {
    return Text(
      "Una de las siguientes opciones:",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
        fontSize: 15.sp,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildDocumentOption(RequiredDocument doc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: Color(0xff419388), shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              doc.message ?? "Documento ${doc.number}",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                  height: 1.4,
                  color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanSummary(ThemeData theme) {
    return EvaluationWidgets.gradientContainer(
      primaryColor: const Color(0xff419388),
      secondaryColor: const Color(0xff2d6b61),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumen del Préstamo",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildSummaryRow(
            icon: Icons.account_balance_wallet,
            label: "Modalidad",
            value: widget.modalityName,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            icon: Icons.attach_money,
            label: "Monto Solicitado",
            value: "${EvaluationService.formatMoney(widget.amount)} Bs",
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            icon: Icons.calendar_today,
            label: "Plazo",
            value: "${widget.term} ${widget.termType}",
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildSummaryRow(
            icon: Icons.payments,
            label: "Cuota ${widget.paymentFrequency.toUpperCase()}",
            value: "${EvaluationService.formatMoney(widget.monthlyPayment)} Bs",
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      {required IconData icon,
      required String label,
      required String value,
      bool isHighlighted = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: isHighlighted ? 20.sp : 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImportantInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff419388).withAlpha(26),
            const Color(0xff419388).withAlpha(38)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xff419388).withAlpha(77), width: 2),
        boxShadow: [
          BoxShadow(
              color: const Color(0xff419388).withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: const Color(0xff419388),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.info, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Información Importante",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2d6b61),
                      fontSize: 17.sp),
                ),
                const SizedBox(height: 8),
                Text(
                  "Todos los documentos son obligatorios y deben ser presentados al realizar su préstamo formal en oficinas a nivel nacional.",
                  style: TextStyle(
                      color: const Color(0xff2d6b61),
                      fontSize: 15.sp,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 24.0),
      child: EvaluationWidgets.primaryButton(
        text: 'GUARDAR Y SALIR',
        icon: Icons.save,
        onPressed: () async {
          final saved = await _saveEvaluation();
          if (saved) {
            _goToModule(2); // Índice del módulo de préstamos
          }
        },
      ),
    );
  }

  void _goToModule(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigatorBarGeneral(initialIndex: index),
      ),
    );
  }
}
