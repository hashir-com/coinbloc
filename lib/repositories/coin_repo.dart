import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coinbloc/models/coin_model.dart';
import 'package:http/http.dart' as http;

class CoinRepo {
  final String apiUrl =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd";

  final String favoritesUrl =
      "https://68918061447ff4f11fbcb7a9.mockapi.io/testapi/post";

  /// Fetch all coins
  Future<List<Coin>> fetchCoins() async {
    try {
      final res = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        return data.map((e) => Coin.fromJson(e)).toList();
      } else {
        throw HttpException(
          "Failed to fetch coins. Status code: ${res.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("No internet connection. Please try again.");
    } on FormatException {
      throw Exception("Invalid response format from server.");
    } on TimeoutException {
      throw Exception("Request timed out. Please try again later.");
    } catch (e) {
      throw Exception("Unexpected error occurred: $e");
    }
  }

  /// Add to favorites
  Future<void> addFavorite(Coin coin) async {
    try {
      final payload = {
        "coinId": coin.id,
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
        throw HttpException(
          "Error adding favorite. Status code: ${res.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("No internet connection. Please try again.");
    } on TimeoutException {
      throw Exception("Request timed out. Please try again later.");
    } catch (e) {
      throw Exception("Unexpected error occurred: $e");
    }
  }

  /// Fetch favorites
  Future<List<Coin>> fetchFavorites() async {
    try {
      final res = await http
          .get(Uri.parse(favoritesUrl))
          .timeout(const Duration(seconds: 10));

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
      } else {
        throw HttpException(
          "Failed to fetch favorites. Status code: ${res.statusCode}",
        );
      }
    } on SocketException {
      throw Exception("No internet connection. Please try again.");
    } on TimeoutException {
      throw Exception("Request timed out. Please try again later.");
    } catch (e) {
      throw Exception("Unexpected error occurred: $e");
    }
  }

  /// Remove a coin from favorites
  Future<void> removeFavorite(String coinId) async {
    try {
      final queryUrl = "$favoritesUrl?coinId=$coinId";
      var res = await http
          .get(Uri.parse(queryUrl))
          .timeout(const Duration(seconds: 10));

      // If API doesn't support query filtering, fetch all and filter manually
      if (res.statusCode != 200) {
        res = await http.get(Uri.parse(favoritesUrl));
        if (res.statusCode != 200) {
          throw HttpException("Error locating favorite to remove.");
        }

        final List all = json.decode(res.body);
        final match = all.firstWhere(
          (e) => e['coinId'] == coinId,
          orElse: () => null,
        );

        if (match == null) return;

        final favResourceId = match['id'];
        final del = await http.delete(
          Uri.parse("$favoritesUrl/$favResourceId"),
        );

        if (del.statusCode < 200 || del.statusCode >= 300) {
          throw HttpException("Error deleting favorite.");
        }
        return;
      }

      // If query worked
      final List items = json.decode(res.body);
      if (items.isEmpty) return;

      final favResourceId = items.first['id'];
      final del = await http.delete(Uri.parse("$favoritesUrl/$favResourceId"));

      if (del.statusCode < 200 || del.statusCode >= 300) {
        throw HttpException("Error deleting favorite.");
      }
    } on SocketException {
      throw Exception("No internet connection. Please try again.");
    } on TimeoutException {
      throw Exception("Request timed out. Please try again later.");
    } catch (e) {
      throw Exception("Unexpected error occurred: $e");
    }
  }
}
