// lib/model/evaluation_models.dart
/// Modelo unificado para todos los datos de evaluación referencial

// ============================================================================
// MODELOS DE MODALIDADES
// ============================================================================

class LoanModalitiesResponse {
  final List<LoanModality> modalities;

  LoanModalitiesResponse({required this.modalities});

  factory LoanModalitiesResponse.fromJson(List<dynamic> json) {
    return LoanModalitiesResponse(
      modalities: json.map((item) => LoanModality.fromJson(item)).toList(),
    );
  }
}

class LoanModality {
  final int id;
  final int affiliateId;
  final int procedureModalityId;
  final String name;
  final String category;
  final String pensionEntityName;
  final String affiliateStateType;
  final String subsector;
  final LoanParameters parameters;

  LoanModality({
    required this.id,
    required this.affiliateId,
    required this.procedureModalityId,
    required this.name,
    required this.category,
    required this.pensionEntityName,
    required this.affiliateStateType,
    required this.subsector,
    required this.parameters,
  });

  factory LoanModality.fromJson(Map<String, dynamic> json) {
    try {
      final modality = LoanModality(
        id: _toInt(json['id']),
        affiliateId: _toInt(json['affiliateId']),
        procedureModalityId: _toInt(json['procedure_modality_id']),
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        pensionEntityName: json['pension_entity_name']?.toString() ?? '',
        affiliateStateType: json['affiliate_state_type']?.toString() ?? '',
        subsector: json['subsector']?.toString() ?? '',
        parameters: LoanParameters.fromJson(json['parameters'] ?? {}),
      );

      print('✅ LoanModality parseado exitosamente: ${modality.name}');
      return modality;
    } catch (e) {
      print('❌ Error parsing LoanModality: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return 0;
  }
}

class LoanParameters {
  final int debtIndex;
  final int guarantors;
  final int maxLenders;
  final double minLenderCategory;
  final double maxLenderCategory;
  final double maximumAmountModality;
  final double minimumAmountModality;
  final int maximumTermModality;
  final int minimumTermModality;
  final int loanMonthTerm;
  final double coveragePercentage;
  final double annualInterest;
  final double periodInterest;

  LoanParameters({
    required this.debtIndex,
    required this.guarantors,
    required this.maxLenders,
    required this.minLenderCategory,
    required this.maxLenderCategory,
    required this.maximumAmountModality,
    required this.minimumAmountModality,
    required this.maximumTermModality,
    required this.minimumTermModality,
    required this.loanMonthTerm,
    required this.coveragePercentage,
    required this.annualInterest,
    required this.periodInterest,
  });

  factory LoanParameters.fromJson(Map<String, dynamic> json) {
    try {
      final parameters = LoanParameters(
        debtIndex: _toInt(json['debtIndex']),
        guarantors: _toInt(json['guarantors']),
        maxLenders: _toInt(json['maxLenders']),
        minLenderCategory: _toDouble(json['minLenderCategory']),
        maxLenderCategory: _toDouble(json['maxLenderCategory']),
        maximumAmountModality: _toDouble(json['maximumAmountModality']),
        minimumAmountModality: _toDouble(json['minimumAmountModality']),
        maximumTermModality: _toInt(json['maximumTermModality']),
        minimumTermModality: _toInt(json['minimumTermModality']),
        loanMonthTerm: _toInt(json['loanMonthTerm']),
        coveragePercentage: _toDouble(json['coveragePercentage']),
        annualInterest: _toDouble(json['annualInterest']),
        periodInterest: _toDouble(json['periodInterest']),
      );

      print('✅ LoanParameters parseado exitosamente:');
      print('   - debtIndex: ${parameters.debtIndex}');
      print('   - annualInterest: ${parameters.annualInterest}');
      print('   - periodInterest: ${parameters.periodInterest}');
      print('   - coveragePercentage: ${parameters.coveragePercentage}');
      print('   - minLenderCategory: ${parameters.minLenderCategory}');
      print('   - maxLenderCategory: ${parameters.maxLenderCategory}');
      print('   - maximumAmount: ${parameters.maximumAmountModality}');
      print('   - minimumAmount: ${parameters.minimumAmountModality}');
      return parameters;
    } catch (e) {
      print('❌ Error parsing LoanParameters: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }
}

// ============================================================================
// MODELOS DE CONTRIBUCIONES
// ============================================================================

class ContributionsResponse {
  final bool error;
  final String message;
  final ContributionsPayload payload;
  final bool serviceStatus;

  ContributionsResponse({
    required this.error,
    required this.message,
    required this.payload,
    required this.serviceStatus,
  });

  factory ContributionsResponse.fromJson(Map<String, dynamic> json) {
    return ContributionsResponse(
      error: json['error'] == "false" ? false : true,
      message: json['message'] ?? '',
      payload: ContributionsPayload.fromJson(json['payload'] ?? {}),
      serviceStatus: json['serviceStatus'] ?? false,
    );
  }
}

class ContributionsPayload {
  final int totalContributions;
  final List<Contribution> contributions;
  final ContributionPeriod period;

  ContributionsPayload({
    required this.totalContributions,
    required this.contributions,
    required this.period,
  });

  factory ContributionsPayload.fromJson(Map<String, dynamic> json) {
    return ContributionsPayload(
      totalContributions: json['total_contributions'] ?? 0,
      contributions: (json['contributions'] as List<dynamic>?)
              ?.map((item) => Contribution.fromJson(item))
              .toList() ??
          [],
      period: ContributionPeriod.fromJson(json['period'] ?? {}),
    );
  }
}

class ContributionPeriod {
  final String from;
  final String to;

  ContributionPeriod({
    required this.from,
    required this.to,
  });

  factory ContributionPeriod.fromJson(Map<String, dynamic> json) {
    return ContributionPeriod(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

class Contribution {
  final String id;
  final String monthYear;
  final String quotable;
  final String payableLiquid;
  final String seniorityBonus;
  final String studyBonus;
  final String positionBonus;
  final String borderBonus;
  final String eastBonus;
  final String gain;

  Contribution({
    required this.id,
    required this.monthYear,
    required this.quotable,
    required this.payableLiquid,
    required this.seniorityBonus,
    required this.studyBonus,
    required this.positionBonus,
    required this.borderBonus,
    required this.eastBonus,
    required this.gain,
  });

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: json['id']?.toString() ?? '',
      monthYear: json['month_year'] ?? '',
      quotable: json['quotable'] ?? '',
      payableLiquid: json['payable_liquid'] ?? '',
      seniorityBonus: json['seniority_bonus'] ?? '',
      studyBonus: json['study_bonus'] ?? '',
      positionBonus: json['position_bonus'] ?? '',
      borderBonus: json['border_bonus'] ?? '',
      eastBonus: json['east_bonus'] ?? '',
      gain: json['gain'] ?? '',
    );
  }

  /// Método seguro para parsear números en formato español
  double parseAmount(String value) {
    final cleaned = value.replaceAll(' ', '');

    if (cleaned.contains('.') && cleaned.contains(',')) {
      // Formato: 1.234,56 -> 1234.56
      return double.tryParse(
              cleaned.replaceAll('.', '').replaceAll(',', '.')) ??
          0.0;
    } else if (cleaned.contains(',')) {
      // Formato: 1234,56 -> 1234.56
      return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0.0;
    }

    return double.tryParse(cleaned) ?? 0.0;
  }

  double get liquidoPagableAmount => parseAmount(payableLiquid);
  double get seniorityBonusAmount => parseAmount(seniorityBonus);
  double get studyBonusAmount => parseAmount(studyBonus);
  double get positionBonusAmount => parseAmount(positionBonus);
  double get borderBonusAmount => parseAmount(borderBonus);
  double get eastBonusAmount => parseAmount(eastBonus);

  double get totalBonuses =>
      seniorityBonusAmount +
      studyBonusAmount +
      positionBonusAmount +
      borderBonusAmount +
      eastBonusAmount;

  double get liquidoParaCalificacion => liquidoPagableAmount - totalBonuses;
}

// ============================================================================
// MODELOS DE DOCUMENTOS
// ============================================================================

class DocumentsResponse {
  final int affiliateId;
  final int procedureModalityId;
  final List<RequiredDocument> documents;

  DocumentsResponse({
    required this.affiliateId,
    required this.procedureModalityId,
    required this.documents,
  });

  factory DocumentsResponse.fromJson(Map<String, dynamic> json) {
    // WORKAROUND: El servidor está devolviendo los valores intercambiados
    // Temporalmente intercambiamos los valores para corregir la inconsistencia
    return DocumentsResponse(
      affiliateId: json['procedureModalityId'] ?? 0, // Intercambiado
      procedureModalityId: json['affiliateId'] ?? 0, // Intercambiado
      documents: (json['documents'] as List<dynamic>?)
              ?.map((item) => RequiredDocument.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class RequiredDocument {
  final int id;
  final int number;
  final String name;
  final List<DocumentOption> options;

  RequiredDocument({
    required this.id,
    required this.number,
    required this.name,
    this.options = const [],
  });

  factory RequiredDocument.fromJson(Map<String, dynamic> json) {
    return RequiredDocument(
      id: json['id'] ?? 0,
      number: json['number'] ?? 0,
      name: json['name'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((opt) => DocumentOption.fromJson(opt))
              .toList() ??
          [],
    );
  }

  // Getter para compatibilidad con documents_screen.dart
  String? get message => name.isNotEmpty ? name : null;
}

class DocumentOption {
  final String id;
  final String name;

  DocumentOption({required this.id, required this.name});

  factory DocumentOption.fromJson(Map<String, dynamic> json) {
    return DocumentOption(
      id: json['id'].toString(),
      name: json['name'].toString().trim(),
    );
  }
}

class GroupedDocument {
  final int number;
  final List<RequiredDocument> documents;
  final bool hasMultipleOptions;

  GroupedDocument({
    required this.number,
    required this.documents,
    required this.hasMultipleOptions,
  });
}

// ============================================================================
// MODELOS DE CÁLCULO Y EVALUACIÓN
// ============================================================================

class EvaluationData {
  final int modalityId;
  final String modalityName;
  final double sueldoBase;
  final String affiliateStateType;
  final double amount;
  final int term;
  final double monthlyPayment;
  final LoanParameters parameters;

  // Datos opcionales según tipo de afiliado
  final double? liquidoPagable;
  final double? totalBonos;
  final double? seniorityBonus;
  final double? studyBonus;
  final double? positionBonus;
  final double? borderBonus;
  final double? eastBonus;
  final double? rentaDignidad;

  EvaluationData({
    required this.modalityId,
    required this.modalityName,
    required this.sueldoBase,
    required this.affiliateStateType,
    required this.amount,
    required this.term,
    required this.monthlyPayment,
    required this.parameters,
    this.liquidoPagable,
    this.totalBonos,
    this.seniorityBonus,
    this.studyBonus,
    this.positionBonus,
    this.borderBonus,
    this.eastBonus,
    this.rentaDignidad,
  });

  String get termType => parameters.loanMonthTerm == 1 ? 'meses' : 'semestres';
  String get paymentFrequency =>
      parameters.loanMonthTerm == 1 ? 'mensual' : 'semestral';
  String get interestLabel =>
      parameters.loanMonthTerm == 1 ? 'Interés Mensual' : 'Interés Semestral';
}

// ============================================================================
// UTILIDADES DE PARSING SEGURO
// ============================================================================

class SafeParser {
  /// Convierte de manera segura un valor a int
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.toInt();
    }
    return 0;
  }

  /// Convierte de manera segura un valor a double
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  /// Parsea números en formato español (1.234,56)
  static double parseSpanishNumber(String value) {
    final cleaned = value.replaceAll(' ', '');

    if (cleaned.contains('.') && cleaned.contains(',')) {
      // Formato: 1.234,56 -> 1234.56
      return double.tryParse(
              cleaned.replaceAll('.', '').replaceAll(',', '.')) ??
          0.0;
    } else if (cleaned.contains(',')) {
      // Formato: 1234,56 -> 1234.56
      return double.tryParse(cleaned.replaceAll(',', '.')) ?? 0.0;
    }

    return double.tryParse(cleaned) ?? 0.0;
  }

  /// Parsea moneda eliminando caracteres no numéricos
  static double? parseCurrency(String text) {
    if (text.isEmpty) return null;

    final cleaned = text.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleaned.isEmpty) return null;

    return parseSpanishNumber(cleaned);
  }

  /// Limita un monto entre valores mínimo y máximo
  static double clampAmount(double value, double min, double max) {
    return value.clamp(min, max);
  }
}
