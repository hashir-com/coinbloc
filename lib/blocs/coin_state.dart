import '../models/coin_model.dart';

abstract class CoinState {}

class CoinInitial extends CoinState {}
class CoinLoading extends CoinState {}

class CoinLoaded extends CoinState {
  final List<Coin> coins;
  CoinLoaded(this.coins);
}

class FavoritesLoaded extends CoinState {
  final List<Coin> favorites;
  FavoritesLoaded(this.favorites);
}

class CoinError extends CoinState {
  final String message;
  CoinError(this.message);
}
