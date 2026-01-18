import 'package:airmenuai_partner_app/features/menu_audit/data/models/menu_audit_response.dart';
import 'package:airmenuai_partner_app/features/menu_audit/domain/repositories/i_menu_audit_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'menu_audit_event.dart';
part 'menu_audit_state.dart';

@injectable
class MenuAuditBloc extends Bloc<MenuAuditEvent, MenuAuditState> {
  final IMenuAuditRepository _repository;

  MenuAuditBloc(this._repository) : super(MenuAuditInitial()) {
    on<LoadMenuAuditData>(_onLoadMenuAuditData);
  }

  Future<void> _onLoadMenuAuditData(
    LoadMenuAuditData event,
    Emitter<MenuAuditState> emit,
  ) async {
    emit(MenuAuditLoading());
    final result = await _repository.getMenuAuditStats();
    result.fold(
      (error) => emit(MenuAuditError(error)),
      (stats) => emit(MenuAuditLoaded(stats)),
    );
  }
}
