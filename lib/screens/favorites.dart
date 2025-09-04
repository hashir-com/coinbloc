import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/favorite/favorites_bloc.dart';
import '../blocs/favorite/favorites_event.dart';
import '../blocs/favorite/favorites_state.dart';
import 'coin_detail_screen.dart';
import '../shimmer/fav_shimmer.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading || state is FavoritesInitial) {
          return const FavShimmer();
        }

        if (state is FavoritesLoaded) {
          final favorites = state.favorites;

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
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CoinDetailScreen(coin: coin, tag: coin.id),
                    ),
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
                    onPressed: () => _showDeleteDialog(context, coin),
                  ),
                ),
              );
            },
          );
        }

        if (state is FavoritesError) {
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

  void _showDeleteDialog(BuildContext context, dynamic coin) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove Favorite"),
        content: Text(
          "Are you sure you want to remove ${coin.name} from favorites?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Optimistic removal
              context.read<FavoritesBloc>().add(ToggleFavorite(coin));
              Navigator.pop(context);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
