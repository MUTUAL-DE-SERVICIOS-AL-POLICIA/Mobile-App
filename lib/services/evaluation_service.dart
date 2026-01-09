import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muserpol_pvt/model/evaluation_models.dart';
import 'package:muserpol_pvt/model/saved_loan_evaluation.dart';

/// Unified service for loan evaluation functionality
/// Consolidates storage, calculations, utilities, and API calls
class EvaluationService {
  static const String _storageKey = 'saved_loan_evaluations';

  // === STORAGE METHODS ===

  /// Save a loan evaluation to local storage
  Future<bool> saveEvaluation(SavedLoanEvaluation evaluation,
      {int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_storageKey}_$userId' : _storageKey;

      final existingData = prefs.getString(key);
      List<Map<String, dynamic>> evaluations = [];

      if (existingData != null) {
        final decoded = jsonDecode(existingData);
        evaluations = List<Map<String, dynamic>>.from(decoded);
      }

      evaluations.add(evaluation.toJson());
      await prefs.setString(key, jsonEncode(evaluations));

      return true;
    } catch (e) {
      debugPrint('Error saving evaluation: $e');
      return false;
    }
  }

  /// Get all saved evaluations for a user
  Future<List<SavedLoanEvaluation>> getSavedEvaluations({int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_storageKey}_$userId' : _storageKey;

      final data = prefs.getString(key);
      if (data == null) return [];

      final decoded = jsonDecode(data);
      final evaluationsList = List<Map<String, dynamic>>.from(decoded);

      return evaluationsList
          .map((json) => SavedLoanEvaluation.fromJson(json))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error loading evaluations: $e');
      return [];
    }
  }

  /// Check if an evaluation is a duplicate
  Future<bool> isDuplicate(SavedLoanEvaluation newEvaluation,
      {int? userId}) async {
    final existing = await getSavedEvaluations(userId: userId);

    return existing.any((eval) =>
        eval.modalityId == newEvaluation.modalityId &&
        eval.amount == newEvaluation.amount &&
        eval.term == newEvaluation.term &&
        eval.affiliateStateType == newEvaluation.affiliateStateType);
  }

  /// Delete a saved evaluation
  Future<bool> deleteEvaluation(String evaluationId, {int? userId}) async {
    try {
      final evaluations = await getSavedEvaluations(userId: userId);
      evaluations.removeWhere((eval) => eval.id == evaluationId);

      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_storageKey}_$userId' : _storageKey;

      await prefs.setString(
          key, jsonEncode(evaluations.map((e) => e.toJson()).toList()));
      return true;
    } catch (e) {
      debugPrint('Error deleting evaluation: $e');
      return false;
    }
  }

  /// Clear all evaluations for a user
  Future<bool> clearAllEvaluations({int? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_storageKey}_$userId' : _storageKey;
      await prefs.remove(key);
      return true;
    } catch (e) {
      debugPrint('Error clearing evaluations: $e');
      return false;
    }
  }

  /// Toggle favorite status of an evaluation
  Future<bool> toggleFavorite(String evaluationId, {int? userId}) async {
    try {
      final evaluations = await getSavedEvaluations(userId: userId);
      final index = evaluations.indexWhere((eval) => eval.id == evaluationId);

      if (index == -1) return false;

      evaluations[index].isFavorite = !evaluations[index].isFavorite;

      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_storageKey}_$userId' : _storageKey;

      await prefs.setString(
          key, jsonEncode(evaluations.map((e) => e.toJson()).toList()));
      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  /// Clean obsolete evaluations based on current modalities
  Future<int> cleanObsoleteEvaluations(List<dynamic> currentModalities,
      {int? userId}) async {
    try {
      final evaluations = await getSavedEvaluations(userId: userId);
      final validEvaluations = <SavedLoanEvaluation>[];
      int removedCount = 0;

      for (final evaluation in evaluations) {
        // Find corresponding current modality
        final currentModality = currentModalities.firstWhere(
          (m) => m['id'] == evaluation.modalityId,
          orElse: () => null,
        );

        if (currentModality == null) {
          // Modality no longer exists
          removedCount++;
          continue;
        }

        // Validate that key parameters haven't changed
        final params = currentModality['parameters'];
        if (params == null) {
          removedCount++;
          continue;
        }

        final currentAnnualInterest =
            (params['annualInterest'] as num?)?.toDouble() ?? 0.0;
        final currentPeriodInterest =
            (params['periodInterest'] as num?)?.toDouble() ?? 0.0;
        final currentGuarantors = params['guarantors'] as int? ?? 0;

        // Compare with tolerance for decimals
        final interestChanged =
            (evaluation.annualInterest - currentAnnualInterest).abs() > 0.01 ||
                (evaluation.periodInterest - currentPeriodInterest).abs() >
                    0.01;
        final guarantorsChanged = evaluation.guarantors != currentGuarantors;

        if (interestChanged || guarantorsChanged) {
          removedCount++;
          continue;
        }

        // Evaluation is valid
        validEvaluations.add(evaluation);
      }

      // Save only valid evaluations
      if (removedCount > 0) {
        final prefs = await SharedPreferences.getInstance();
        final key = userId != null ? '${_storageKey}_$userId' : _storageKey;
        await prefs.setString(
            key, jsonEncode(validEvaluations.map((e) => e.toJson()).toList()));
      }

      return removedCount;
    } catch (e) {
      debugPrint('Error cleaning obsolete evaluations: $e');
      return 0;
    }
  }

  /// Get evaluation by ID
  Future<SavedLoanEvaluation?> getEvaluationById(String evaluationId,
      {int? userId}) async {
    try {
      final evaluations = await getSavedEvaluations(userId: userId);
      return evaluations.firstWhere(
        (eval) => eval.id == evaluationId,
        orElse: () => throw Exception('Evaluation not found'),
      );
    } catch (e) {
      debugPrint('Error getting evaluation by ID: $e');
      return null;
    }
  }

  // === UTILITY METHODS ===

  /// Parse currency string to double
  static double? parseCurrency(String text) {
    if (text.isEmpty) return null;

    final cleaned = text.replaceAll(RegExp(r'[^\d.,\-]'), '');

    // Handle european format like "1.234,56"
    if (cleaned.contains('.') && cleaned.contains(',')) {
      final normalized = cleaned.replaceAll('.', '').replaceAll(',', '.');
      return double.tryParse(normalized);
    }

    // Handle formats with only comma as decimal separator like "1234,56"
    if (cleaned.contains(',') && !cleaned.contains('.')) {
      final normalized = cleaned.replaceAll(',', '.');
      return double.tryParse(normalized);
    }

    // Default: numbers with dot as decimal separator or plain integers
    return double.tryParse(cleaned);
  }

  /// Format money amount with 2 decimals and thousand separators
  /// Uses '.' as thousand separator and ',' as decimal separator
  static String formatMoney(double amount) {
    // Handle negative values correctly
    final isNegative = amount < 0;
    final positiveAmount = amount.abs();

    // Split into integer and fractional parts
    final parts = positiveAmount.toStringAsFixed(2).split('.');
    var integerPart = parts[0];
    final decimalPart = parts[1];

    // Add thousand separators (.) to the integer part
    if (integerPart.length > 3) {
      integerPart = integerPart.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match.group(1)}.',
      );
    }

    // Combine with ',' as decimal separator
    final formatted = '$integerPart,$decimalPart';

    // Re-add minus sign if needed
    return isNegative ? '-$formatted' : formatted;
  }

  /// Clamp amount between min and max values
  static double clampAmount(double amount, double min, double max) {
    return amount.clamp(min, max);
  }

  /// Get interest label based on loan month term
  static String getInterestLabel(int loanMonthTerm) {
    switch (loanMonthTerm) {
      case 1:
        return 'Interés Mensual';
      case 3:
        return 'Interés Trimestral';
      case 6:
        return 'Interés Semestral';
      case 12:
        return 'Interés Anual';
      default:
        return 'Interés Periódico';
    }
  }

  /// Get term type based on loan month term
  static String getTermType(int loanMonthTerm) {
    switch (loanMonthTerm) {
      case 1:
        return 'meses';
      case 3:
        return 'trimestres';
      case 6:
        return 'semestres';
      case 12:
        return 'años';
      default:
        return 'períodos';
    }
  }

  /// Get singular term type based on loan month term
  static String getTermTypeSingular(int loanMonthTerm) {
    switch (loanMonthTerm) {
      case 1:
        return 'mes';
      case 3:
        return 'trimestre';
      case 6:
        return 'semestre';
      case 12:
        return 'año';
      default:
        return 'período';
    }
  }

  /// Get payment frequency based on loan month term
  static String getPaymentFrequency(int loanMonthTerm) {
    switch (loanMonthTerm) {
      case 1:
        return 'mensual';
      case 3:
        return 'trimestral';
      case 6:
        return 'semestral';
      case 12:
        return 'anual';
      default:
        return 'periódica';
    }
  }

  /// Show error message in context
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success message in context
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show info message in context
  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // === CALCULATION METHODS ===

  /// Calculate monthly payment (cuota)
  static double calculateCuota(
      double amount, int termMonths, LoanParameters params) {
    if (amount <= 0 || termMonths <= 0) return 0.0;

    final ticMensual = (params.annualInterest * 365.25 / 360 / 100) /
        (12 / params.loanMonthTerm);

    if (ticMensual == 0) {
      return (amount / termMonths * 100).roundToDouble() / 100;
    }

    final factor = _pow(1 + ticMensual, termMonths);
    final cuota = (amount * ticMensual * factor) / (factor - 1);
    return (cuota * 100).roundToDouble() / 100;
  }

  /// Calculate maximum loan amount based on liquid for qualification
  static double calculateMontoMaximo(
      double liquidoParaCalificacion, LoanParameters params) {
    if (liquidoParaCalificacion <= 0 || params.debtIndex <= 0) return 0.0;

    final plazoMaximo = params.maximumTermModality.toDouble();
    final ingresoParaDebtIndex = params.loanMonthTerm == 1
        ? liquidoParaCalificacion
        : liquidoParaCalificacion * 6;
    final cuotaMaximaPermitida =
        ingresoParaDebtIndex * (params.debtIndex / 100);

    final ticParaMaximo = (params.annualInterest * 365.25 / 360 / 100) /
        (12 / params.loanMonthTerm);

    double montoMaximoBasadoEnCuota;
    if (ticParaMaximo == 0) {
      montoMaximoBasadoEnCuota = cuotaMaximaPermitida * plazoMaximo;
    } else {
      final factor = _pow(1 + ticParaMaximo, plazoMaximo.toInt());
      montoMaximoBasadoEnCuota =
          cuotaMaximaPermitida * ((factor - 1) / (ticParaMaximo * factor));
    }

    final montoMaximoPersonalizado =
        montoMaximoBasadoEnCuota * params.coveragePercentage;

    return montoMaximoPersonalizado < params.maximumAmountModality
        ? montoMaximoPersonalizado
        : params.maximumAmountModality;
  }

  /// Calculate debt index percentage
  static double calculateDebtIndex(
      double cuota, double liquidoParaCalificacion, LoanParameters params) {
    if (liquidoParaCalificacion <= 0) return 0.0;

    final ingresoMensualParaLimite = params.loanMonthTerm == 1
        ? liquidoParaCalificacion
        : liquidoParaCalificacion * 6;
    return ingresoMensualParaLimite > 0
        ? (cuota / ingresoMensualParaLimite) * 100
        : 0.0;
  }

  /// Helper method for power calculation
  static double _pow(double base, int exponent) {
    return exponent >= 0
        ? pow(base, exponent).toDouble()
        : 1.0 / pow(base, -exponent).toDouble();
  }

  /// Calculate total interest for the loan
  static double calculateTotalInterest(
      double amount, double cuota, int termMonths) {
    final totalPayments = cuota * termMonths;
    return totalPayments - amount;
  }

  /// Calculate amortization schedule
  static List<AmortizationPayment> calculateAmortizationSchedule(
    double amount,
    int termMonths,
    LoanParameters params,
  ) {
    final List<AmortizationPayment> schedule = [];
    final monthlyRate = params.periodInterest / 100;
    final cuota = calculateCuota(amount, termMonths, params);

    double remainingBalance = amount;

    for (int i = 1; i <= termMonths; i++) {
      final interestPayment = remainingBalance * monthlyRate;
      final principalPayment = cuota - interestPayment;
      remainingBalance -= principalPayment;

      schedule.add(AmortizationPayment(
        paymentNumber: i,
        cuota: cuota,
        principalPayment: principalPayment,
        interestPayment: interestPayment,
        remainingBalance: remainingBalance.clamp(0, double.infinity),
      ));
    }

    return schedule;
  }

  // === API METHODS ===
  // Note: API methods are handled by the bloc layer using serviceMethod
  // This service focuses on calculations, utilities, and storage
}

/// Amortization payment details
class AmortizationPayment {
  final int paymentNumber;
  final double cuota;
  final double principalPayment;
  final double interestPayment;
  final double remainingBalance;

  const AmortizationPayment({
    required this.paymentNumber,
    required this.cuota,
    required this.principalPayment,
    required this.interestPayment,
    required this.remainingBalance,
  });
}
