import 'package:coinbloc/models/coin_model.dart';

abstract class CoinState {}

class CoinInitial extends CoinState {}

class CoinLoading extends CoinState {}

class CoinLoaded extends CoinState {
  final List<Coin> coins;
  CoinLoaded(this.coins);
}

class CoinError extends CoinState {
  final String message;
  CoinError(this.message);
}
