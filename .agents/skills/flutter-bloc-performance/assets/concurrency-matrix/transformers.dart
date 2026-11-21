// Template matrix: choose per event semantics, then adapt repository operations.
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';

sealed class MatrixEvent {
  const MatrixEvent();
}

final class IndependentRead extends MatrixEvent {
  const IndependentRead(this.id);
  final String id;
}

final class OrderedWrite extends MatrixEvent {
  const OrderedWrite(this.value);
  final String value;
}

final class RefreshRequested extends MatrixEvent {
  const RefreshRequested();
}

final class QueryChanged extends MatrixEvent {
  const QueryChanged(this.query);
  final String query;
}

final class MatrixState extends Equatable {
  const MatrixState({this.lastOperation, this.value});
  final String? lastOperation;
  final String? value;
  @override
  List<Object?> get props => [lastOperation, value];
}

class TransformerMatrixBloc extends Bloc<MatrixEvent, MatrixState> {
  TransformerMatrixBloc(this._repository) : super(const MatrixState()) {
    on<IndependentRead>(_read, transformer: concurrent());
    on<OrderedWrite>(_write, transformer: sequential());
    on<RefreshRequested>(_refresh, transformer: droppable());
    on<QueryChanged>(_query, transformer: restartable());
  }

  final MatrixRepository _repository;

  Future<void> _read(IndependentRead event, Emitter<MatrixState> emit) async {
    emit(MatrixState(lastOperation: 'read:${event.id}', value: await _repository.read(event.id)));
  }

  Future<void> _write(OrderedWrite event, Emitter<MatrixState> emit) async {
    await _repository.write(event.value);
    emit(MatrixState(lastOperation: 'write', value: event.value));
  }

  Future<void> _refresh(RefreshRequested event, Emitter<MatrixState> emit) async {
    emit(MatrixState(lastOperation: 'refresh', value: await _repository.refresh()));
  }

  Future<void> _query(QueryChanged event, Emitter<MatrixState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) return;
    try {
      final value = await _repository.search(query);
      if (emit.isDone) return;
      emit(MatrixState(lastOperation: 'query', value: value));
    } on Object catch (error, stackTrace) {
      if (emit.isDone) return;
      addError(error, stackTrace);
    }
  }
}

abstract interface class MatrixRepository {
  Future<String> read(String id);
  Future<void> write(String value);
  Future<String> refresh();
  Future<String> search(String query);
}
