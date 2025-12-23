part of 'loan_pre_evaluation_bloc.dart';

abstract class LoanPreEvaluationEvent {
  const LoanPreEvaluationEvent();
}

class LoadLoanModalitiesPreEval extends LoanPreEvaluationEvent {
  final int affiliateId;

  const LoadLoanModalitiesPreEval(this.affiliateId);
}

class LoadLoanDocuments extends LoanPreEvaluationEvent {
  final int procedureModalityId;
  final int affiliateId;

  const LoadLoanDocuments(this.procedureModalityId, this.affiliateId);
}

class LoadQuotableContributions extends LoanPreEvaluationEvent {
  final int affiliateId;

  const LoadQuotableContributions(this.affiliateId);
}



class ClearPreEvaluationData extends LoanPreEvaluationEvent {
  const ClearPreEvaluationData();
}