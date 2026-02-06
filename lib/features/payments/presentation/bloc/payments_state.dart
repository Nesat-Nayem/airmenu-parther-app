import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/payments/domain/entities/payment_entity.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final PaymentStatsEntity stats;
  final List<SettlementEntity> settlements;
  final List<DisputeEntity> disputes;
  final PaymentBottomStatsEntity bottomStats;
  final int selectedTabIndex;
  final String activeFilter;

  const PaymentsLoaded({
    required this.stats,
    required this.settlements,
    required this.disputes,
    required this.bottomStats,
    this.selectedTabIndex = 0,
    this.activeFilter = '',
  });

  PaymentsLoaded copyWith({
    PaymentStatsEntity? stats,
    List<SettlementEntity>? settlements,
    List<DisputeEntity>? disputes,
    PaymentBottomStatsEntity? bottomStats,
    int? selectedTabIndex,
    String? activeFilter,
  }) {
    return PaymentsLoaded(
      stats: stats ?? this.stats,
      settlements: settlements ?? this.settlements,
      disputes: disputes ?? this.disputes,
      bottomStats: bottomStats ?? this.bottomStats,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    settlements,
    disputes,
    bottomStats,
    selectedTabIndex,
    activeFilter,
  ];
}

class PaymentsError extends PaymentsState {
  final String message;
  const PaymentsError(this.message);

  @override
  List<Object?> get props => [message];
}
