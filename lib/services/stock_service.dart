import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/stock.dart';

class StockService {
  final String apiKey = dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? '';
  final String baseUrl = 'https://www.alphavantage.co/query';

  Future<List<Stock>> getStocks() async {
    // For now, return a static list of stocks with mock prices
    // In a real app, you would fetch this data from an API
    return [
      Stock(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 175.43,
        priceChange: 1.23,
      ),
      Stock(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        price: 142.65,
        priceChange: -0.45,
      ),
      Stock(
        symbol: 'MSFT',
        name: 'Microsoft Corporation',
        price: 338.11,
        priceChange: 2.34,
      ),
      Stock(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        price: 145.24,
        priceChange: 0.89,
      ),
      Stock(
        symbol: 'META',
        name: 'Meta Platforms Inc.',
        price: 334.69,
        priceChange: 3.12,
      ),
      Stock(
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        price: 238.45,
        priceChange: -1.67,
      ),
      Stock(
        symbol: 'NVDA',
        name: 'NVIDIA Corporation',
        price: 495.22,
        priceChange: 4.56,
      ),
      Stock(
        symbol: 'JPM',
        name: 'JPMorgan Chase & Co.',
        price: 172.34,
        priceChange: 0.78,
      ),
      Stock(
        symbol: 'V',
        name: 'Visa Inc.',
        price: 277.18,
        priceChange: 1.45,
      ),
      Stock(
        symbol: 'WMT',
        name: 'Walmart Inc.',
        price: 155.23,
        priceChange: -0.34,
      ),
    ];
  }

  Future<Stock> getStockDetails(String symbol) async {
    // In a real app, you would fetch this data from an API
    final stocks = await getStocks();
    return stocks.firstWhere((stock) => stock.symbol == symbol);
  }
} 