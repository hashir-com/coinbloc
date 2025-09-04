import 'package:coinbloc/repositories/favorites_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepo favRepo;

  FavoritesBloc(this.favRepo) : super(FavoritesInitial()) {
    on<FetchFavorites>(_onFetchFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onFetchFavorites(
      FetchFavorites event, Emitter<FavoritesState> emit) async {
    emit(FavoritesLoading());
    try {
      final favorites = await favRepo.fetchFavorites();
      emit(FavoritesLoaded(favorites));
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
      ToggleFavorite event, Emitter<FavoritesState> emit) async {
    try {
      final currentState = state;
      if (currentState is FavoritesLoaded) {
        final isFav = currentState.favorites.any((c) => c.id == event.coin.id);

        // Optimistic update: update state immediately
        final updatedList = isFav
            ? currentState.favorites.where((c) => c.id != event.coin.id).toList()
            : [...currentState.favorites, event.coin.copyWith(isFavorite: true)];

        emit(FavoritesLoaded(updatedList));

        // API call in background
        if (isFav) {
          favRepo.removeFavorite(event.coin.id).catchError((_) {
            // Optional: handle API failure
          });
        } else {
          favRepo.addFavorite(event.coin.copyWith(isFavorite: true)).catchError((_) {
            // Optional: handle API failure
          });
        }
      }
    } catch (e) {
      emit(FavoritesError(e.toString()));
    }
  }
}
