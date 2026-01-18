part of 'menu_audit_bloc.dart';

abstract class MenuAuditEvent extends Equatable {
  const MenuAuditEvent();

  @override
  List<Object> get props => [];
}

class LoadMenuAuditData extends MenuAuditEvent {}
