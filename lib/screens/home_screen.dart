import 'package:coinbloc/screens/coin_detail_screen.dart';
import 'package:coinbloc/screens/favorites.dart';
import 'package:coinbloc/shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coinbloc/blocs/coin_bloc.dart';
import 'package:coinbloc/blocs/coin_event.dart';
import 'package:coinbloc/blocs/coin_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocBuilder<CoinBloc, CoinState>(
        builder: (context, state) {
          if (state is CoinLoading) {
            return const Center(child: CoinShimmer());
          } else if (state is CoinLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CoinBloc>().add(FetchCoins());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: state.coins.length,
                itemBuilder: (context, index) {
                  final coin = state.coins[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
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
                                radius: 24,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Coin info
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
                                  const SizedBox(height: 2),
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

                            // Price & Change
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
                              ],
                            ),

                            const SizedBox(width: 12),

                            // Favorite Button
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    coin.isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: coin.isFavorite
                                        ? Colors.redAccent
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    context.read<CoinBloc>().add(
                                      ToggleFavorite(coin),
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: coin.change >= 0
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${coin.change.toStringAsFixed(2)}%",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: coin.change >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is CoinError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("No data"));
        },
      ),

      const FavoritesScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Crypto Tracker",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<CoinBloc>().add(FetchCoins());
              },
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
        ],
      ),
    );
  }
}
