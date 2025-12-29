// Model for loan modalities response
class LoanModalitiesResponse {
  final List<LoanModalityNew> modalities;

  LoanModalitiesResponse({required this.modalities});

  factory LoanModalitiesResponse.fromJson(List<dynamic> json) {
    return LoanModalitiesResponse(
      modalities: json.map((item) => LoanModalityNew.fromJson(item)).toList(),
    );
  }
}

class LoanModalityNew {
  final int id;
  final int affiliateId;
  final int procedureModalityId;
  final String name;
  final String category;
  final String pensionEntityName;
  final String affiliateStateType;
  final String subsector;
  final LoanParametersNew parameters;

  LoanModalityNew({
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

  factory LoanModalityNew.fromJson(Map<String, dynamic> json) {
    try {
      final modality = LoanModalityNew(
        id: _safeToInt(json['id']),
        affiliateId: _safeToInt(json['affiliateId']),
        procedureModalityId: _safeToInt(json['procedure_modality_id']),
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        pensionEntityName: json['pension_entity_name']?.toString() ?? '',
        affiliateStateType: json['affiliate_state_type']?.toString() ?? '',
        subsector: json['subsector']?.toString() ?? '',
        parameters: LoanParametersNew.fromJson(json['parameters'] ?? {}),
      );

      print('✅ LoanModalityNew parseado exitosamente: ${modality.name}');
      return modality;
    } catch (e) {
      print('❌ Error parsing LoanModalityNew: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  /// Convierte de manera segura un valor a int
  static int _safeToInt(dynamic value) {
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

class LoanParametersNew {
  final int debtIndex;
  final int guarantors;
  final int maxLenders;
  final double minLenderCategory; // DEBE ser double (viene como 0.85)
  final double maxLenderCategory; // DEBE ser double (puede ser decimal)
  final double maximumAmountModality; // DEBE ser double (números grandes)
  final double minimumAmountModality; // DEBE ser double (números grandes)
  final int maximumTermModality;
  final int minimumTermModality;
  final int loanMonthTerm;
  final double coveragePercentage; // DEBE ser double (viene como 0.8)
  final double annualInterest; // DEBE ser double (viene como 13.2)
  final double periodInterest; // DEBE ser double (viene como 1.66)

  LoanParametersNew({
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

  factory LoanParametersNew.fromJson(Map<String, dynamic> json) {
    try {
      final parameters = LoanParametersNew(
        debtIndex: _safeToInt(json['debtIndex']),
        guarantors: _safeToInt(json['guarantors']),
        maxLenders: _safeToInt(json['maxLenders']),
        minLenderCategory: _safeToDouble(json['minLenderCategory']),
        maxLenderCategory: _safeToDouble(json['maxLenderCategory']),
        maximumAmountModality: _safeToDouble(json['maximumAmountModality']),
        minimumAmountModality: _safeToDouble(json['minimumAmountModality']),
        maximumTermModality: _safeToInt(json['maximumTermModality']),
        minimumTermModality: _safeToInt(json['minimumTermModality']),
        loanMonthTerm: _safeToInt(json['loanMonthTerm']),
        coveragePercentage: _safeToDouble(json['coveragePercentage']),
        annualInterest: _safeToDouble(json['annualInterest']),
        periodInterest: _safeToDouble(json['periodInterest']),
      );

      print('✅ LoanParametersNew parseado exitosamente:');
      print('   - debIndex: ${parameters.debtIndex}');
      print('   - annualInterest: ${parameters.annualInterest}');
      print('   - periodInterest: ${parameters.periodInterest}');
      print('   - coveragePercentage: ${parameters.coveragePercentage}');
      print('   - minLenderCategory: ${parameters.minLenderCategory}');
      print('   - maxLenderCategory: ${parameters.maxLenderCategory}');
      print('   - maximumAmount: ${parameters.maximumAmountModality}');
      print('   - minimumAmount: ${parameters.minimumAmountModality}');
      return parameters;
    } catch (e) {
      print('❌ Error parsing LoanParametersNew: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  /// Convierte de manera segura un valor a int
  static int _safeToInt(dynamic value) {
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
  static double _safeToDouble(dynamic value) {
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

// Model for loan documents response
// Helper top-level function to safely parse int values that might come as String or numeric types
int _safeToInt(dynamic value) {
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

class LoanDocumentsResponse {
  final int affiliateId;
  final int procedureModalityId;
  final List<LoanDocument> documents;

  LoanDocumentsResponse({
    required this.affiliateId,
    required this.procedureModalityId,
    required this.documents,
  });

  factory LoanDocumentsResponse.fromJson(Map<String, dynamic> json) {
    // WORKAROUND: El servidor está devolviendo los valores intercambiados
    // Temporalmente intercambiamos los valores para corregir la inconsistencia
    return LoanDocumentsResponse(
      affiliateId: _safeToInt(json['procedureModalityId']), // Intercambiado
      procedureModalityId: _safeToInt(json['affiliateId']), // Intercambiado
      documents: (json['documents'] as List<dynamic>?)
              ?.map((item) => LoanDocument.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class LoanDocument {
  final int id;
  final String name;
  final int number;

  LoanDocument({
    required this.id,
    required this.name,
    required this.number,
  });

  factory LoanDocument.fromJson(Map<String, dynamic> json) {
    return LoanDocument(
      id: _safeToInt(json['id']),
      name: json['name'] ?? '',
      number: _safeToInt(json['number']),
    );
  }
}

// Model for quotable contributions response
class QuotableContributionsResponse {
  final bool error;
  final String message;
  final QuotablePayload payload;
  final bool serviceStatus;

  QuotableContributionsResponse({
    required this.error,
    required this.message,
    required this.payload,
    required this.serviceStatus,
  });

  factory QuotableContributionsResponse.fromJson(Map<String, dynamic> json) {
    return QuotableContributionsResponse(
      error: json['error'] == "false" ? false : true,
      message: json['message'] ?? '',
      payload: QuotablePayload.fromJson(json['payload'] ?? {}),
      serviceStatus: json['serviceStatus'] ?? false,
    );
  }
}

class QuotablePayload {
  final int totalContributions;
  final List<QuotableContribution> contributions;
  final ContributionPeriod period;

  QuotablePayload({
    required this.totalContributions,
    required this.contributions,
    required this.period,
  });

  factory QuotablePayload.fromJson(Map<String, dynamic> json) {
    return QuotablePayload(
      totalContributions: json['total_contributions'] ?? 0,
      contributions: (json['contributions'] as List<dynamic>?)
              ?.map((item) => QuotableContribution.fromJson(item))
              .toList() ??
          [],
      period: ContributionPeriod.fromJson(json['period'] ?? {}),
    );
  }
}

class QuotableContribution {
  final int id;
  final String monthYear;
  final String quotable;
  final String state;

  QuotableContribution({
    required this.id,
    required this.monthYear,
    required this.quotable,
    required this.state,
  });

  factory QuotableContribution.fromJson(Map<String, dynamic> json) {
    return QuotableContribution(
      id: _safeToInt(json['id']),
      monthYear: json['month_year'] ?? '',
      quotable: json['quotable'] ?? '',
      state: json['state'] ?? '',
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
