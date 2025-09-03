import 'dart:convert';
import 'package:coinbloc/models/coin_model.dart';
import 'package:http/http.dart' as http;

class CoinRepo {
  final String apiUrl =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd";

  // TODO: replace with your actual MockAPI endpoint
  final String favoritesUrl =
      "https://68918061447ff4f11fbcb7a9.mockapi.io/testapi/post";

  Future<List<Coin>> fetchCoins() async {
    final res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) => Coin.fromJson(e)).toList();
    }
    throw Exception("Error fetching coins");
  }

  /// Add favorite: POST with coinId; do NOT send your own `id`
  Future<void> addFavorite(Coin coin) async {
    final payload = {
      "coinId": coin.id, // ← important
      "name": coin.name,
      "symbol": coin.symbol,
      "price": coin.price,
      "change": coin.change,
      "image": coin.image,
    };
    final res = await http.post(
      Uri.parse(favoritesUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception("Error adding favorite");
    }
  }

  /// Fetch favorites: build Coin objects using coinId
  Future<List<Coin>> fetchFavorites() async {
    final res = await http.get(Uri.parse(favoritesUrl));
    if (res.statusCode == 200) {
      final List data = json.decode(res.body);
      return data.map((e) {
        final coinId = e['coinId'] ?? e['id']; // fallback if older data
        return Coin(
          id: coinId,
          name: e['name'] ?? '',
          symbol: e['symbol'] ?? '',
          price: (e['price'] as num?)?.toDouble() ?? 0.0,
          change: (e['change'] as num?)?.toDouble() ?? 0.0,
          image: e['image'] ?? '',
          isFavorite: true,
        );
      }).toList();
    }
    throw Exception("Error fetching favorites");
  }

  /// Remove favorite by coinId:
  /// 1) find the MockAPI record (resource) whose coinId == coinId
  /// 2) delete that resource by its MockAPI id
  Future<void> removeFavorite(String coinId) async {
    // If your MockAPI supports filtering by field:
    final queryUrl = "$favoritesUrl?coinId=$coinId";
    var res = await http.get(Uri.parse(queryUrl));

    if (res.statusCode != 200) {
      // fallback: fetch all and filter locally
      res = await http.get(Uri.parse(favoritesUrl));
      if (res.statusCode != 200) {
        throw Exception("Error locating favorite to remove");
      }
      final List all = json.decode(res.body);
      final match = all.firstWhere(
        (e) => e['coinId'] == coinId,
        orElse: () => null,
      );
      if (match == null) return; // nothing to delete
      final favResourceId = match['id'];
      final del = await http.delete(Uri.parse("$favoritesUrl/$favResourceId"));
      if (del.statusCode < 200 || del.statusCode >= 300) {
        throw Exception("Error deleting favorite");
      }
      return;
    }

    final List items = json.decode(res.body);
    if (items.isEmpty) return; // nothing to delete

    final favResourceId = items.first['id'];
    final del = await http.delete(Uri.parse("$favoritesUrl/$favResourceId"));
    if (del.statusCode < 200 || del.statusCode >= 300) {
      throw Exception("Error deleting favorite");
    }
  }
}
