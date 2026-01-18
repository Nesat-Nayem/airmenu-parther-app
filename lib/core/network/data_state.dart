import 'package:airmenuai_partner_app/core/network/data_error.dart';

abstract class DataState<T> {
  final T? data;
  final DataError? error;

  const DataState({this.data, this.error});
}

/// Success
class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

/// Failure
class DataFailure<T> extends DataState<T> {
  const DataFailure(DataError dataError) : super(error: dataError);
}
