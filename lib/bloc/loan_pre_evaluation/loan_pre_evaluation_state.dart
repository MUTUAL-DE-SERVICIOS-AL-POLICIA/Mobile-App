part of 'loan_pre_evaluation_bloc.dart';

abstract class LoanPreEvaluationState extends Equatable {
  const LoanPreEvaluationState();

  @override
  List<Object> get props => [];
}

class LoanPreEvaluationInitial extends LoanPreEvaluationState {}

// Loan Modalities States
class LoanModalitiesLoading extends LoanPreEvaluationState {
  final int? currentAttempt;
  final int? maxAttempts;

  const LoanModalitiesLoading({this.currentAttempt, this.maxAttempts});

  @override
  List<Object> get props => [currentAttempt ?? 0, maxAttempts ?? 0];
}

class LoanModalitiesLoaded extends LoanPreEvaluationState {
  final List<LoanModalityNew> modalities;

  const LoanModalitiesLoaded(this.modalities);

  @override
  List<Object> get props => [modalities];
}

class LoanModalitiesError extends LoanPreEvaluationState {
  final String message;

  const LoanModalitiesError(this.message);

  @override
  List<Object> get props => [message];
}

// Loan Documents States
class LoanDocumentsLoading extends LoanPreEvaluationState {}

class LoanDocumentsLoaded extends LoanPreEvaluationState {
  final LoanDocumentsResponse documents;

  const LoanDocumentsLoaded(this.documents);

  @override
  List<Object> get props => [documents];
}

class LoanDocumentsError extends LoanPreEvaluationState {
  final String message;

  const LoanDocumentsError(this.message);

  @override
  List<Object> get props => [message];
}

// Quotable Contributions States
class QuotableContributionsLoading extends LoanPreEvaluationState {}

class QuotableContributionsLoaded extends LoanPreEvaluationState {
  final QuotableContributionsResponse contributions;

  const QuotableContributionsLoaded(this.contributions);

  @override
  List<Object> get props => [contributions];
}

class QuotableContributionsError extends LoanPreEvaluationState {
  final String message;

  const QuotableContributionsError(this.message);

  @override
  List<Object> get props => [message];
}

// Combined State for Modalities and Contributions
class LoanModalitiesWithContributionsLoaded extends LoanPreEvaluationState {
  final List<LoanModalityNew> modalities;
  final QuotableContributionsResponse? contributions;

  const LoanModalitiesWithContributionsLoaded(this.modalities, [this.contributions]);

  @override
  List<Object> get props => [modalities, contributions ?? ''];
}