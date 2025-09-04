import 'package:coinbloc/models/coin_model.dart';

abstract class FavoritesEvent {}

class FetchFavorites extends FavoritesEvent {}

class AddFavorite extends FavoritesEvent {
  final Coin coin;
  AddFavorite(this.coin);
}

class RemoveFavorite extends FavoritesEvent {
  final String coinId;
  RemoveFavorite(this.coinId);
}

class ToggleFavorite extends FavoritesEvent {
  final Coin coin;
  ToggleFavorite(this.coin);
}
