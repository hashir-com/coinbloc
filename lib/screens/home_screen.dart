import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/coin/coin_bloc.dart';
import '../blocs/coin/coin_state.dart';
import '../blocs/coin/coin_event.dart';
import '../blocs/favorite/favorites_bloc.dart';
import '../blocs/favorite/favorites_state.dart';
import '../blocs/favorite/favorites_event.dart';
import '../blocs/navigation/navigation_bloc.dart';
import '../blocs/navigation/navigation_state.dart';
import '../blocs/navigation/navigation_event.dart';
import '../models/coin_model.dart';
import 'coin_detail_screen.dart';
import 'favorites.dart';
import '../shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crypto Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state) {
          final index = (state is BottomNavUpdated) ? state.index : 0;
          return index == 0 ? _buildHome(context) : const FavoritesScreen();
        },
      ),
      floatingActionButton: BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state) {
          final index = (state is BottomNavUpdated) ? state.index : 0;
          return index == 0
              ? FloatingActionButton(
                  backgroundColor: Colors.blueAccent,
                  child: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => context.read<CoinBloc>().add(FetchCoins()),
                )
              : SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<BottomNavBloc, BottomNavState>(
        builder: (context, state) {
          final index = (state is BottomNavUpdated) ? state.index : 0;
          return BottomNavigationBar(
            currentIndex: index,
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            onTap: (i) => context.read<BottomNavBloc>().add(ChangeTab(i)),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_max),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: "Favorites",
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    return BlocBuilder<CoinBloc, CoinState>(
      builder: (context, state) {
        if (state is CoinLoading) return const Center(child: CoinShimmer());
        if (state is CoinError) {
          return _buildMessage(
            context,
            "Oops! ${state.message}",
            Icons.wifi_off,
          );
        }
        if (state is CoinLoaded) {
          if (state.coins.isEmpty) {
            return _buildMessage(
              context,
              "No coins available",
              Icons.search_off,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<CoinBloc>().add(FetchCoins());
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: state.coins.length,
              itemBuilder: (_, i) {
                final coin = state.coins[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CoinDetailScreen(coin: coin, tag: coin.id),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Hero(
                            tag: coin.id,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(coin.image),
                              radius: 26,
                              backgroundColor: Colors.grey.shade100,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coin.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  coin.symbol.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$${coin.price.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: coin.change >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${coin.change.toStringAsFixed(2)}%",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          BlocSelector<FavoritesBloc, FavoritesState, bool>(
                            selector: (state) {
                              if (state is FavoritesLoaded) {
                                return state.favorites.any(
                                  (c) => c.id == coin.id,
                                );
                              }
                              return false;
                            },
                            builder: (context, isFav) {
                              return IconButton(
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.redAccent : Colors.grey,
                                ),
                                onPressed: () {
                                  context.read<FavoritesBloc>().add(
                                    ToggleFavorite(coin),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessage(BuildContext context, String text, IconData icon) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.read<CoinBloc>().add(FetchCoins()),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
}
