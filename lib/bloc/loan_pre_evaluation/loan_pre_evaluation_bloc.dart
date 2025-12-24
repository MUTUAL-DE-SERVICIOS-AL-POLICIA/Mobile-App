import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../model/evaluation_models.dart';
import '../../services/service_method.dart';
import '../../services/services.dart';

part 'loan_pre_evaluation_event.dart';
part 'loan_pre_evaluation_state.dart';

class LoanPreEvaluationBloc extends Bloc<LoanPreEvaluationEvent, LoanPreEvaluationState> {
  final BuildContext context;

  LoanPreEvaluationBloc({required this.context}) : super(LoanPreEvaluationInitial()) {
    on<LoadLoanModalitiesPreEval>(_onLoadLoanModalities);
    on<LoadLoanDocuments>(_onLoadLoanDocuments);
    on<LoadQuotableContributions>(_onLoadQuotableContributions);
    on<ClearPreEvaluationData>(_onClearPreEvaluationData);
  }

  /// Valida la estructura de una modalidad antes del parsing
  bool _validateModalityStructure(Map<String, dynamic> modality) {
    try {
      final requiredFields = [
        'id', 'affiliateId', 'procedure_modality_id', 'name', 
        'category', 'affiliate_state_type', 'subsector', 'parameters'
      ];
      
      for (String field in requiredFields) {
        if (!modality.containsKey(field)) {
          debugPrint('❌ Campo requerido faltante: $field');
          return false;
        }
      }
      
      // Validar que parameters sea un objeto
      if (modality['parameters'] is! Map<String, dynamic>) {
        debugPrint('❌ El campo parameters no es un objeto válido: ${modality['parameters']}');
        return false;
      }
      
      final parameters = modality['parameters'] as Map<String, dynamic>;
      final requiredParams = [
        'debtIndex', 'guarantors', 'maxLenders', 'maximumAmountModality',
        'minimumAmountModality', 'maximumTermModality', 'minimumTermModality',
        'annualInterest', 'periodInterest'
      ];
      
      for (String param in requiredParams) {
        if (!parameters.containsKey(param)) {
          debugPrint('❌ Parámetro requerido faltante: $param');
          return false;
        }
      }
      
      // Validar que los valores no sean null
      for (String field in requiredFields) {
        if (modality[field] == null && field != 'parameters') {
          debugPrint('⚠️ Campo con valor null: $field');
          // No retornamos false aquí, solo advertimos
        }
      }
      
      debugPrint('✅ Estructura de modalidad válida');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error validando estructura de modalidad: $e');
      return false;
    }
  }

  /// Método de diagnóstico para debugging
  void _logResponseDiagnostics(String responseBody) {
    debugPrint('=== DIAGNÓSTICO DE RESPUESTA ===');
    debugPrint('Longitud de respuesta: ${responseBody.length}');
    debugPrint('Primeros 200 caracteres: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}');
    
    if (responseBody.length > 200) {
      debugPrint('Últimos 200 caracteres: ${responseBody.substring(responseBody.length - 200)}');
    }
    
    // Verificar si termina correctamente
    final trimmed = responseBody.trim();
    debugPrint('Termina con ]: ${trimmed.endsWith(']')}');
    debugPrint('Termina con }: ${trimmed.endsWith('}')}');
    debugPrint('Contiene caracteres especiales al final: ${trimmed.substring(trimmed.length - 10)}');
    debugPrint('=== FIN DIAGNÓSTICO ===');
  }

  Future<void> _onLoadLoanModalities(
    LoadLoanModalitiesPreEval event,
    Emitter<LoanPreEvaluationState> emit,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      emit(LoanModalitiesLoading(currentAttempt: retryCount + 1, maxAttempts: maxRetries));
      
      try {
        debugPrint('Intento ${retryCount + 1} de $maxRetries para cargar modalidades');
        
        final response = await serviceMethod(
          context.mounted,
          context,
          'get',
          null,
          servicePreEvaluation(event.affiliateId),
          true,
          true,
        );
        
        if (response != null) {
          debugPrint('Response status: ${response.statusCode}');
          debugPrint('Response body length: ${response.body.length}');
          
          // Verificar que la respuesta no esté vacía
          if (response.body.isEmpty) {
            throw Exception('Respuesta vacía del servidor');
          }
          
          // Diagnóstico detallado de la respuesta
          _logResponseDiagnostics(response.body);
          
          // Verificar el status code
          if (response.statusCode != 200) {
            throw Exception('Error del servidor: ${response.statusCode}');
          }
          
          // Intentar parsear la respuesta JSON
          try {
            final dynamic jsonData = json.decode(response.body);
            
            // Verificar que sea una lista
            if (jsonData is! List) {
              throw Exception('Formato de respuesta inválido: se esperaba una lista, se recibió ${jsonData.runtimeType}');
            }
            
            final List<dynamic> modalitiesList = jsonData;
            
            // Verificar que la lista no esté vacía
            if (modalitiesList.isEmpty) {
              emit(LoanModalitiesError('No hay modalidades disponibles para este afiliado'));
              return;
            }
            
            // Validar estructura de datos antes del parsing
            List<Map<String, dynamic>> validModalities = [];
            for (int i = 0; i < modalitiesList.length; i++) {
              final item = modalitiesList[i];
              if (item is Map<String, dynamic>) {
                if (_validateModalityStructure(item)) {
                  validModalities.add(item);
                } else {
                  debugPrint('Modalidad $i tiene estructura inválida, se omite');
                  debugPrint('Datos de modalidad inválida: $item');
                }
              } else {
                debugPrint('Item $i no es un objeto válido, se omite: $item');
              }
            }
            
            if (validModalities.isEmpty) {
              throw Exception('No se encontraron modalidades con estructura válida');
            }
            
            // Intentar crear las modalidades con mejor manejo de errores
            try {
              final modalitiesResponse = LoanModalitiesResponse.fromJson(validModalities);
              
              if (modalitiesResponse.modalities.isEmpty) {
                emit(LoanModalitiesError('No se pudieron procesar las modalidades'));
                return;
              }
              
              debugPrint('Modalidades cargadas exitosamente: ${modalitiesResponse.modalities.length}');
              emit(LoanModalitiesLoaded(modalitiesResponse.modalities));
              return; // Éxito, salir del bucle de reintentos
              
            } catch (modalityParsingError) {
              debugPrint('❌ Error específico al parsear modalidades: $modalityParsingError');
              debugPrint('Datos que causaron el error: $validModalities');
              throw Exception('Error al crear objetos de modalidad: ${modalityParsingError.toString()}');
            }
            
          } catch (jsonError) {
            debugPrint('❌ Error parsing JSON: $jsonError');
            debugPrint('Response body que falló: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');
            
            // Verificar si es un error de tipo específico
            if (jsonError.toString().contains('type \'String\' is not a subtype of type \'int\'')) {
              throw Exception('Error de formato de datos: El servidor está enviando números como texto. Contacte al administrador.');
            } else if (jsonError.toString().contains('FormatException')) {
              throw Exception('Error en el formato JSON del servidor. Contacte al administrador.');
            } else {
              throw Exception('Error al procesar la respuesta del servidor: ${jsonError.toString()}');
            }
          }
        } else {
          throw Exception('No se recibió respuesta del servidor');
        }
      } catch (e) {
        debugPrint('Error en intento ${retryCount + 1}: $e');
        retryCount++;
        
        if (retryCount >= maxRetries) {
          // Último intento fallido
          String errorMessage = 'Error de conexión después de $maxRetries intentos';
          
          if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
            errorMessage = 'Error de conexión a internet. Verifique su conexión y vuelva a intentar.';
          } else if (e.toString().contains('FormatException')) {
            errorMessage = 'Error en el formato de datos del servidor. Contacte al administrador.';
          } else if (e.toString().contains('500') || e.toString().contains('502') || e.toString().contains('503')) {
            errorMessage = 'El servidor está temporalmente no disponible. Intente más tarde.';
          }
          
          emit(LoanModalitiesError(errorMessage));
        } else {
          // Esperar antes del siguiente intento
          await Future.delayed(Duration(seconds: retryCount * 2));
        }
      }
    }
  }

  Future<void> _onLoadLoanDocuments(
    LoadLoanDocuments event,
    Emitter<LoanPreEvaluationState> emit,
  ) async {
    emit(LoanDocumentsLoading());
    
    try {
      final response = await serviceMethod(
        context.mounted,
        context,
        'get',
        null,
        serviceGetRequiredDocuments(event.procedureModalityId, event.affiliateId),
        true,
        true,
      );
      
      if (response != null) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final documentsResponse = DocumentsResponse.fromJson(jsonData);
        emit(LoanDocumentsLoaded(documentsResponse));
      } else {
        emit(LoanDocumentsError('Error al cargar los documentos requeridos'));
      }
    } catch (e) {
      emit(LoanDocumentsError('Error: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQuotableContributions(
    LoadQuotableContributions event,
    Emitter<LoanPreEvaluationState> emit,
  ) async {
    // Mantener las modalidades actuales si existen
    List<LoanModality>? currentModalities;
    if (state is LoanModalitiesLoaded) {
      currentModalities = (state as LoanModalitiesLoaded).modalities;
    } else if (state is LoanModalitiesWithContributionsLoaded) {
      currentModalities = (state as LoanModalitiesWithContributionsLoaded).modalities;
    }
    
    // Si tenemos modalidades, emitir estado combinado con loading
    if (currentModalities != null) {
      emit(LoanModalitiesWithContributionsLoaded(currentModalities));
    } else {
      emit(QuotableContributionsLoading());
    }
    
    try {
      final response = await serviceMethod(
        context.mounted,
        context,
        'get',
        null,
        serviceLastPayment(event.affiliateId, 0), // Solo necesita affiliateId, el segundo parámetro no se usa
        true,
        true,
      );
      
      if (response != null) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final contributionsResponse = ContributionsResponse.fromJson(jsonData);
        
        if (!contributionsResponse.error) {
          if (currentModalities != null) {
            // Emitir estado combinado con modalidades y contribuciones
            emit(LoanModalitiesWithContributionsLoaded(currentModalities, contributionsResponse));
          } else {
            emit(QuotableContributionsLoaded(contributionsResponse));
          }
        } else {
          emit(QuotableContributionsError(contributionsResponse.message));
        }
      } else {
        emit(QuotableContributionsError('Error al cargar las contribuciones'));
      }
    } catch (e) {
      emit(QuotableContributionsError('Error: ${e.toString()}'));
    }
  }

  void _onClearPreEvaluationData(
    ClearPreEvaluationData event,
    Emitter<LoanPreEvaluationState> emit,
  ) {
    emit(LoanPreEvaluationInitial());
  }
}