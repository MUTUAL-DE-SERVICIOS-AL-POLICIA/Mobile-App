part of 'loan_pre_evaluation_bloc.dart';

abstract class LoanPreEvaluationEvent extends Equatable {
  const LoanPreEvaluationEvent();

  @override
  List<Object> get props => [];
}

class LoadLoanModalitiesPreEval extends LoanPreEvaluationEvent {
  final int affiliateId;

  const LoadLoanModalitiesPreEval(this.affiliateId);

  @override
  List<Object> get props => [affiliateId];
}

class LoadLoanDocuments extends LoanPreEvaluationEvent {
  final int procedureModalityId;
  final int affiliateId;

  const LoadLoanDocuments(this.procedureModalityId, this.affiliateId);

  @override
  List<Object> get props => [procedureModalityId, affiliateId];
}

class LoadQuotableContributions extends LoanPreEvaluationEvent {
  final int affiliateId;

  const LoadQuotableContributions(this.affiliateId);

  @override
  List<Object> get props => [affiliateId];
}



class ClearPreEvaluationData extends LoanPreEvaluationEvent {
  const ClearPreEvaluationData();
}