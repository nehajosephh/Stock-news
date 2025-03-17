class Stock {
  final String symbol;
  final String name;
  final String? description;
  final double price;
  final double priceChange;

  Stock({
    required this.symbol,
    required this.name,
    this.description,
    required this.price,
    required this.priceChange,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      priceChange: (json['priceChange'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      if (description != null) 'description': description,
      'price': price,
      'priceChange': priceChange,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Stock &&
          runtimeType == other.runtimeType &&
          symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;
} 