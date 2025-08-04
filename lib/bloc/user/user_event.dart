part of 'user_bloc.dart';

abstract class UserEvent {}

class UpdateUser extends UserEvent {
  final User user;

  UpdateUser(this.user);
}

class UpdateCtrlLive extends UserEvent {
  final bool controlLive;

  UpdateCtrlLive(this.controlLive);
}

class UpdateCi extends UserEvent {
  final String ci;

  UpdateCi(this.ci);
}

class UpdateProcedureId extends UserEvent {
  final int procedureId;

  UpdateProcedureId(this.procedureId);
}

class UpdatePhone extends UserEvent {
  final String phone;

  UpdatePhone(this.phone);
}

class UpdateStateCam extends UserEvent {
  final bool state;

  UpdateStateCam(this.state);
}

class UpdateStateBtntoggleCameraLens extends UserEvent {
  final bool state;

  UpdateStateBtntoggleCameraLens(this.state);
}

class UpdateVerifiedDocument extends UserEvent {
  final bool state;

  UpdateVerifiedDocument(this.state);
}

class UpdateEnrolled extends UserEvent {
  final bool enrolled;
  UpdateEnrolled(this.enrolled);
}
