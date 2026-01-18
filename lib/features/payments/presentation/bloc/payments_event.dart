abstract class PaymentsEvent {}

class LoadPaymentsData extends PaymentsEvent {}

class SwitchPaymentsTab extends PaymentsEvent {
  final int index;
  SwitchPaymentsTab(this.index);
}

class FilterPayments extends PaymentsEvent {
  final String query;
  FilterPayments(this.query);
}
