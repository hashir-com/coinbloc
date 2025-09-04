import 'package:coinbloc/models/coin_model.dart';
import 'package:equatable/equatable.dart';

abstract class FavoritesState extends Equatable {
  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Coin> favorites;

  FavoritesLoaded(this.favorites);

  @override
  List<Object> get props => [favorites];
}

class FavoritesError extends FavoritesState {
  final String message;

  FavoritesError(this.message);

  @override
  List<Object> get props => [message];
}
