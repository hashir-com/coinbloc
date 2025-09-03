import 'package:coinbloc/models/coin_model.dart';

abstract class CoinEvent {}

class FetchCoins extends CoinEvent {}

class ToggleFavorite extends CoinEvent {
  final Coin coin;
  ToggleFavorite(this.coin);
}

class FetchFavorites extends CoinEvent {}

class AddFavorite extends CoinEvent {
  final Coin coin;
  AddFavorite(this.coin);
}
