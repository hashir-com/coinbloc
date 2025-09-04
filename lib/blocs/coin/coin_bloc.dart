import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coinbloc/repositories/coin_repo.dart';
import 'coin_event.dart';
import 'coin_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final CoinRepo repository;

  CoinBloc(this.repository) : super(CoinInitial()) {
    on<FetchCoins>(_onFetchCoins);
  }

  Future<void> _onFetchCoins(FetchCoins event, Emitter<CoinState> emit) async {
    emit(CoinLoading());
    try {
      final coins = await repository.fetchCoins();
      emit(CoinLoaded(coins));
    } catch (e) {
      emit(CoinError(e.toString()));
    }
  }
}
