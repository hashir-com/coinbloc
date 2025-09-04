// lib/repositories/coin_repo.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coinbloc/models/coin_model.dart';
import 'package:http/http.dart' as http;

class CoinRepo {
  final String apiUrl =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd";

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
}
