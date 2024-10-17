import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'load_event.dart';
part 'load_state.dart';

class LoadBloc extends Bloc<LoadEvent, LoadState> {
  LoadBloc() : super(LoadInitial()) {
    on<LoadEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
