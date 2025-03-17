import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/news_feed_screen.dart';
import 'screens/company_selection_screen.dart';
import 'models/stock.dart';
import 'models/news.dart';
import 'services/stock_service.dart';
import 'services/news_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
    print('Environment loaded successfully');
    print('NEWS_API_KEY: ${dotenv.env['NEWS_API_KEY']?.substring(0, 5)}...'); // Only print first 5 chars for security
  } catch (e) {
    print('Error loading .env file: $e');
    // Show error dialog
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error loading environment: $e'),
          ),
        ),
      ),
    );
    return;
  }

  if (dotenv.env['NEWS_API_KEY'] == null || dotenv.env['NEWS_API_KEY']!.isEmpty) {
    print('NEWS_API_KEY is missing or empty');
    // Show error dialog
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('NEWS_API_KEY is missing. Please check your .env file.'),
          ),
        ),
      ),
    );
    return;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Stock> _selectedStocks = [];
  final List<News> _newsItems = [];
  bool _isLoading = false;
  String? _errorMessage;
  final StockService _stockService = StockService();
  final NewsService _newsService = NewsService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Don't load news on init, wait for company selection
  }

  Future<void> _loadNews() async {
    if (_selectedStocks.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one company to view news.';
        _newsItems.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allNews = <News>[];

      for (final stock in _selectedStocks) {
        try {
          print('Loading news for ${stock.symbol}...'); // Debug log
          final news = await _newsService.getCompanyNews(stock.symbol);
          print('Found ${news.length} articles for ${stock.symbol}'); // Debug log
          allNews.addAll(news);
        } catch (e) {
          print('Error loading news for ${stock.symbol}: $e');
          // Continue with other stocks even if one fails
        }
      }

      if (allNews.isEmpty) {
        setState(() {
          _errorMessage = 'No news found for the selected companies.';
          _newsItems.clear();
          _isLoading = false;
        });
        return;
      }

      allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      setState(() {
        _newsItems.clear();
        _newsItems.addAll(allNews);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading news: $e';
        _newsItems.clear();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading news: $e')),
        );
      }
    }
  }

  Future<void> _selectCompanies() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanySelectionScreen(
          selectedStocks: _selectedStocks,
        ),
      ),
    );

    if (result != null && result is List<Stock>) {
      setState(() {
        _selectedStocks.clear();
        _selectedStocks.addAll(result);
      });
      await _loadNews(); // Load news after selecting companies
    }
  }

  Widget _buildBody() {
    if (_selectedStocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.business,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'No companies selected',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectCompanies,
              icon: const Icon(Icons.add),
              label: const Text('Select Companies'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading news...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_newsItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.newspaper,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No news available',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNews,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return NewsFeedScreen(
      selectedStocks: _selectedStocks,
      newsItems: _newsItems,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _selectCompanies,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.business),
            label: 'Companies',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _selectCompanies,
        child: const Icon(Icons.add),
      ),
    );
  }
}