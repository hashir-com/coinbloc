import 'package:coinbloc/blocs/navigation/navigation_event.dart';
import 'package:coinbloc/blocs/navigation/navigation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class BottomNavBloc extends Bloc<BottomNavEvent, BottomNavState> {
  BottomNavBloc() : super(BottomNavInitial()) {
    on<ChangeTab>((event, emit) {
      emit(BottomNavUpdated(event.index));
    });
  }
}
