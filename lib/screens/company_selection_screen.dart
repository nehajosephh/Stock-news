import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/stock_service.dart';

class CompanySelectionScreen extends StatefulWidget {
  final List<Stock> selectedStocks;

  const CompanySelectionScreen({
    Key? key,
    required this.selectedStocks,
  }) : super(key: key);

  @override
  State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
  final StockService _stockService = StockService();
  final TextEditingController _searchController = TextEditingController();
  List<Stock> _searchResults = [];
  List<Stock> _selectedStocks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStocks = List.from(widget.selectedStocks);
    _loadStocks();
  }

  Future<void> _loadStocks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final stocks = await _stockService.getStocks();
      setState(() {
        _searchResults = stocks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stocks: $e')),
        );
      }
    }
  }

  void _searchCompanies(String query) {
    if (query.isEmpty) {
      _loadStocks();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _stockService.getStocks().then((stocks) {
      final lowercaseQuery = query.toLowerCase();
      final results = stocks.where((stock) {
        return stock.symbol.toLowerCase().contains(lowercaseQuery) ||
            stock.name.toLowerCase().contains(lowercaseQuery);
      }).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching stocks: $error')),
        );
      }
    });
  }

  void _toggleStockSelection(Stock stock) {
    setState(() {
      if (_selectedStocks.contains(stock)) {
        _selectedStocks.remove(stock);
      } else {
        _selectedStocks.add(stock);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Companies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, _selectedStocks);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search companies...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchCompanies,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final stock = _searchResults[index];
                      final isSelected = _selectedStocks.contains(stock);
                      return ListTile(
                        title: Text(stock.name),
                        subtitle: Text(stock.symbol),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${stock.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: stock.priceChange >= 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected ? Icons.check_circle : Icons.check_circle_outline,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          ],
                        ),
                        onTap: () => _toggleStockSelection(stock),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 