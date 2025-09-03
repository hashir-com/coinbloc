import 'package:flutter_bloc/flutter_bloc.dart';
import 'coin_event.dart';
import 'coin_state.dart';
import 'package:coinbloc/repositories/coin_repo.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final CoinRepo repository;

  CoinBloc(this.repository) : super(CoinInitial()) {
    on<FetchCoins>(_onFetchCoins);
    on<ToggleFavorite>(_onToggleFavorite);
    on<AddFavorite>(_onAddFavorite);
    on<FetchFavorites>(_onFetchFavorites);
  }

Future<void> _onFetchCoins(FetchCoins event, Emitter<CoinState> emit) async {
  emit(CoinLoading());
  try {
    final coins = await repository.fetchCoins();
    final favorites = await repository.fetchFavorites(); // ← from MockAPI

    final favIds = favorites.map((c) => c.id).toSet(); // c.id = coinId we stored

    final updated = coins
        .map((c) => c.copyWith(isFavorite: favIds.contains(c.id)))
        .toList();

    emit(CoinLoaded(updated));
  } catch (e) {
    emit(CoinError(e.toString()));
  }
}



 Future<void> _onToggleFavorite(
  ToggleFavorite event,
  Emitter<CoinState> emit,
) async {
  if (state is! CoinLoaded) return;
  final current = state as CoinLoaded;

  final updatedCoins = current.coins.map((coin) {
    if (coin.id == event.coin.id) {
      return coin.copyWith(isFavorite: !coin.isFavorite);
    }
    return coin;
  }).toList();

  emit(CoinLoaded(updatedCoins));

  final toggled = event.coin.copyWith(isFavorite: !event.coin.isFavorite);

  try {
    if (toggled.isFavorite) {
      await repository.addFavorite(toggled);
    } else {
      await repository.removeFavorite(toggled.id); // ← pass coinId
    }
  } catch (e) {
    // Optional: rollback UI or show a snackbar via separate UI handler
  }
}



  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<CoinState> emit,
  ) async {
    await repository.addFavorite(event.coin);
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<CoinState> emit,
  ) async {
    emit(CoinLoading());
    try {
      final favorites = await repository.fetchFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(CoinError(e.toString()));
    }
  }
}
