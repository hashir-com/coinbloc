import 'package:coinbloc/blocs/coin/coin_bloc.dart';
import 'package:coinbloc/blocs/coin/coin_event.dart';
import 'package:coinbloc/blocs/favorite/favorites_bloc.dart';
import 'package:coinbloc/blocs/favorite/favorites_event.dart';
import 'package:coinbloc/blocs/navigation/navigation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/coin_repo.dart';
import 'repositories/favorites_repo.dart';
import 'screens/home_screen.dart';

void main() {
  final coinRepo = CoinRepo();
  final favoritesRepo = FavoritesRepo();

  runApp(MyApp(coinRepo: coinRepo, favoritesRepo: favoritesRepo));
}

class MyApp extends StatelessWidget {
  final CoinRepo coinRepo;
  final FavoritesRepo favoritesRepo;

  const MyApp({super.key, required this.coinRepo, required this.favoritesRepo});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => coinRepo),
        RepositoryProvider(create: (_) => favoritesRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CoinBloc(coinRepo)..add(FetchCoins())),
          BlocProvider(
            create: (_) => FavoritesBloc(favoritesRepo)..add(FetchFavorites()),
          ),
          BlocProvider(create: (_) => BottomNavBloc()),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
        ),
      ),
    );
  }
}
