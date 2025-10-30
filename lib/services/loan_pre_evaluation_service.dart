import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:muserpol_pvt/model/loan_pre_evaluation_model.dart';
import 'package:muserpol_pvt/services/service_method.dart';
import 'package:muserpol_pvt/services/services.dart';

class LoanPreEvaluationService {
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void clearAuthToken() {
    _authToken = null;
  }

  /// Obtiene las modalidades de préstamo disponibles para un afiliado
  static Future<LoanModalitiesResponse?> getLoanModalities(int affiliateId) async {
    try {
      // Nota: Este método necesita un contexto, pero como es un servicio estático,
      // necesitaremos pasarlo desde donde se llame o usar un contexto global
      // Por ahora, retornamos null y manejaremos esto en el BLoC
      return null;
    } catch (e) {
      debugPrint('Error en getLoanModalities: $e');
      return null;
    }
  }

  /// Obtiene las contribuciones cotizables (último pago) de un afiliado
  static Future<QuotableContributionsResponse?> getQuotableContributions(int affiliateId) async {
    try {
      return null;
    } catch (e) {
      debugPrint('Error en getQuotableContributions: $e');
      return null;
    }
  }

  /// Obtiene los documentos requeridos para una modalidad de préstamo
  static Future<LoanDocumentsResponse?> getLoanDocuments(int procedureModalityId, int affiliateId) async {
    try {
      return null;
    } catch (e) {
      debugPrint('Error en getLoanDocuments: $e');
      return null;
    }
  }
}