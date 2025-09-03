import 'package:coinbloc/blocs/coin_bloc.dart';
import 'package:coinbloc/blocs/coin_event.dart';
import 'package:coinbloc/blocs/coin_state.dart';
import 'package:coinbloc/screens/coin_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinBloc, CoinState>(
      builder: (context, state) {
        if (state is CoinLoading || state is CoinInitial) {
          // 🔹 Shimmer loader instead of circular loader
          return ListView.builder(
            itemCount: 6,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          );
        }

        if (state is CoinLoaded) {
          final favorites = state.coins.where((c) => c.isFavorite).toList();

          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                "No favorites yet",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (_, i) {
              final coin = favorites[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CoinDetailScreen(coin: coin, tag: coin.id),
                  ),
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        coin.image,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      "${coin.name} (${coin.symbol.toUpperCase()})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "\$${coin.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        context.read<CoinBloc>().add(ToggleFavorite(coin));
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }

        if (state is CoinError) {
          return Center(
            child: Text(
              "Error: ${state.message}",
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
