part of 'loan_pre_evaluation_bloc.dart';

abstract class LoanPreEvaluationState {
  const LoanPreEvaluationState();
}

class LoanPreEvaluationInitial extends LoanPreEvaluationState {}

// Loan Modalities States
class LoanModalitiesLoading extends LoanPreEvaluationState {
  final int? currentAttempt;
  final int? maxAttempts;

  const LoanModalitiesLoading({this.currentAttempt, this.maxAttempts});
}

class LoanModalitiesLoaded extends LoanPreEvaluationState {
  final List<LoanModalityNew> modalities;

  const LoanModalitiesLoaded(this.modalities);
}

class LoanModalitiesError extends LoanPreEvaluationState {
  final String message;

  const LoanModalitiesError(this.message);
}

// Loan Documents States
class LoanDocumentsLoading extends LoanPreEvaluationState {}

class LoanDocumentsLoaded extends LoanPreEvaluationState {
  final LoanDocumentsResponse documents;

  const LoanDocumentsLoaded(this.documents);
}

class LoanDocumentsError extends LoanPreEvaluationState {
  final String message;

  const LoanDocumentsError(this.message);
}

// Quotable Contributions States
class QuotableContributionsLoading extends LoanPreEvaluationState {}

class QuotableContributionsLoaded extends LoanPreEvaluationState {
  final QuotableContributionsResponse contributions;

  const QuotableContributionsLoaded(this.contributions);
}

class QuotableContributionsError extends LoanPreEvaluationState {
  final String message;

  const QuotableContributionsError(this.message);
}

// Combined State for Modalities and Contributions
class LoanModalitiesWithContributionsLoaded extends LoanPreEvaluationState {
  final List<LoanModalityNew> modalities;
  final QuotableContributionsResponse? contributions;

  const LoanModalitiesWithContributionsLoaded(this.modalities, [this.contributions]);
}