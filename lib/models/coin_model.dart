class Coin {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double change;
  final String image;
  final bool isFavorite;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.image,
    this.isFavorite = false,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      price: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      change: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      image: json['image'],
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "symbol": symbol,
      "price": price,
      "change": change,
      "image": image,
      "isFavorite": isFavorite,
    };
  }

  Coin copyWith({bool? isFavorite}) {
    return Coin(
      id: id,
      name: name,
      symbol: symbol,
      price: price,
      change: change,
      image: image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
