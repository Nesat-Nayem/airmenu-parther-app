part of 'menu_audit_bloc.dart';

abstract class MenuAuditState extends Equatable {
  const MenuAuditState();

  @override
  List<Object> get props => [];
}

class MenuAuditInitial extends MenuAuditState {}

class MenuAuditLoading extends MenuAuditState {}

class MenuAuditLoaded extends MenuAuditState {
  final MenuAuditStats stats;

  const MenuAuditLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class MenuAuditError extends MenuAuditState {
  final String message;

  const MenuAuditError(this.message);

  @override
  List<Object> get props => [message];
}
