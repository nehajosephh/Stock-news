import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news.dart';

class NewsService {
  final String apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  final String baseUrl = 'https://newsapi.org/v2';

  // Keywords for sentiment analysis
  final List<String> bullishKeywords = [
    'surge', 'jump', 'rise', 'gain', 'up', 'higher', 'growth', 'profit',
    'positive', 'success', 'breakthrough', 'innovation', 'expansion',
    'outperform', 'beat', 'exceed', 'strong', 'bullish', 'rally'
  ];

  final List<String> bearishKeywords = [
    'drop', 'fall', 'decline', 'down', 'lower', 'loss', 'negative',
    'failure', 'risk', 'concern', 'warning', 'underperform', 'miss',
    'weak', 'bearish', 'crash', 'plunge', 'slump', 'downgrade'
  ];

  Future<List<News>> getCompanyNews(String symbol) async {
    if (apiKey.isEmpty) {
      print('Error: NewsAPI key is empty');
      throw Exception('NewsAPI key is not configured');
    }

    try {
      final url = Uri.parse(
        '$baseUrl/everything?q=$symbol&sortBy=publishedAt&language=en&apiKey=$apiKey'
      );

      print('Fetching news for $symbol from: $url'); // Debug log

      final response = await http.get(url);
      print('Response status code: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'error') {
          final message = data['message'] ?? 'Unknown error from NewsAPI';
          print('NewsAPI error: $message'); // Debug log
          throw Exception(message);
        }

        final articles = data['articles'] as List;
        if (articles.isEmpty) {
          print('No articles found for $symbol'); // Debug log
          return [];
        }

        final newsList = articles.map((article) {
          try {
            final news = News.fromJson(article);
            // Calculate sentiment score for the title
            news.sentimentScore = calculateSentimentScore(news.title);
            return news;
          } catch (e) {
            print('Error parsing article: $e'); // Debug log
            print('Article data: $article'); // Debug log
            return null;
          }
        }).whereType<News>().toList();

        print('Successfully parsed ${newsList.length} articles for $symbol'); // Debug log
        return newsList;
      } else if (response.statusCode == 401) {
        print('Unauthorized: Invalid API key'); // Debug log
        throw Exception('Invalid API key. Please check your NewsAPI key.');
      } else if (response.statusCode == 429) {
        print('Rate limit exceeded'); // Debug log
        throw Exception('API rate limit exceeded. Please try again later.');
      } else {
        print('Unexpected status code: ${response.statusCode}'); // Debug log
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching news for $symbol: $e'); // Debug log
      rethrow;
    }
  }

  double calculateSentimentScore(String text) {
    if (text.isEmpty) return 0.0;

    final words = text.toLowerCase().split(' ');
    int bullishCount = 0;
    int bearishCount = 0;

    for (final word in words) {
      if (bullishKeywords.contains(word)) {
        bullishCount++;
      }
      if (bearishKeywords.contains(word)) {
        bearishCount++;
      }
    }

    if (bullishCount == 0 && bearishCount == 0) return 0.0;
    
    // Calculate score between -1 and 1
    final total = bullishCount + bearishCount;
    return (bullishCount - bearishCount) / total;
  }
} 