import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/coin_repo.dart';
import 'blocs/coin_bloc.dart';
import 'blocs/coin_event.dart';
import 'screens/home_screen.dart';

void main() {
  final CoinRepo repository = CoinRepo();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final CoinRepo repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CoinRepo>(
          create: (context) => repository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CoinBloc>(
            create: (context) =>
                CoinBloc(context.read<CoinRepo>())..add(FetchCoins()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
        ),
      ),
    );
  }
}
