import 'package:coinbloc/models/coin_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coinbloc/repositories/favorites_repo.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepo favRepo;

  FavoritesBloc(this.favRepo) : super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onFetchFavorites(
    FetchFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await favRepo.fetchFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await favRepo.addFavorite(event.coin);
      add(FetchFavorites()); // refresh list
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await favRepo.removeFavorite(event.coinId);
      add(FetchFavorites()); // refresh list
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is FavoritesLoaded) {
        final isAlreadyFavorite = currentState.favorites.any(
          (c) => c.id == event.coin.id,
        );

        // Optimistic UI update
        final updatedList =
            isAlreadyFavorite
                  ? currentState.favorites
                        .where((c) => c.id != event.coin.id)
                        .toList()
                        .cast<Coin>() // 👈 Cast to List<Coin>
                  : List<Coin>.from(currentState.favorites)
              ..add(
                event.coin.copyWith(isFavorite: true),
              ); // 👈 Ensure correct type

        emit(FavoritesLoaded(updatedList));

        // API Call
        if (isAlreadyFavorite) {
          await favRepo.removeFavorite(event.coin.id);
        } else {
          await favRepo.addFavorite(event.coin.copyWith(isFavorite: true));
        }

        // Refresh from server to sync
        add(FetchFavorites());
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
