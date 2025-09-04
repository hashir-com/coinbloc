import 'package:coinbloc/blocs/coin/coin_bloc.dart';
import 'package:coinbloc/blocs/coin/coin_state.dart';
import 'package:coinbloc/blocs/favorite/favorites_bloc.dart';
import 'package:coinbloc/blocs/favorite/favorites_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/coin_model.dart';

class CoinDetailScreen extends StatelessWidget {
  final Coin coin;
  final String tag;

  const CoinDetailScreen({super.key, required this.coin, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          coin.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: BlocBuilder<CoinBloc, CoinState>(
        builder: (context, state) {
          // find the latest version of this coin from state
          Coin updatedCoin = coin;
          if (state is CoinLoaded) {
            updatedCoin = state.coins.firstWhere(
              (c) => c.id == coin.id,
              orElse: () => coin,
            );
          }

          final isPositive = updatedCoin.change >= 0;

          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Hero(
                        tag: tag,
                        child: Image.network(
                          updatedCoin.image,
                          width: 100,
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        updatedCoin.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        updatedCoin.symbol.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          updatedCoin.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: updatedCoin.isFavorite
                              ? Colors.red
                              : Colors.grey,
                          size: 30,
                        ),
                        onPressed: () {
                          context.read<FavoritesBloc>().add(
                            ToggleFavorite(updatedCoin),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // 💰 Price Section
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "\$${updatedCoin.price.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${updatedCoin.change.toStringAsFixed(2)}%",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isPositive ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Back"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
