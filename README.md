# Stock Market News & Sentiment Analysis App

A Flutter-based mobile application that provides personalized stock market news with sentiment analysis for selected companies.

## Features

- Company Selection: Users can select up to 5 companies to personalize their news feed
- Reel Format News Feed: News articles are presented in a vertical swipe format
- Sentiment Analysis: Each news article includes real-time sentiment analysis
- Live Stock Data: Displays current market prices when the market is open
- Seamless Navigation: Intuitive UI/UX for browsing company-specific financial news

## Tech Stack

- Frontend: Flutter (Dart)
- Backend: Firebase / Node.js
- News API: NewsAPI.org
- Stock Data: Yahoo Finance API
- Sentiment Analysis: OpenAI API / FinBERT

## Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- NewsAPI.org API key
- OpenAI API key (for sentiment analysis)

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/stock_news_app.git
cd stock_news_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory and add your API keys:
```
NEWS_API_KEY=your_news_api_key
OPENAI_API_KEY=your_openai_api_key
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── models/
│   ├── stock.dart
│   └── news.dart
├── screens/
│   ├── news_feed_screen.dart
│   └── company_selection_screen.dart
├── services/
│   ├── stock_service.dart
│   └── news_service.dart
├── widgets/
└── main.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- NewsAPI.org for providing financial news data
- Yahoo Finance API for stock market data
- OpenAI for sentiment analysis capabilities 