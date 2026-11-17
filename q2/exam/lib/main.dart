import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NewsProvider()..fetchArticles(),
      child: const NewsReaderApp(),
    ),
  );
}

// ==========================================
// 1. DATA MODEL CLASS
// ==========================================
class Article {
  final int id;
  final int userId;
  final String title;
  final String body;

  const Article({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

// ==========================================
// 2. BUSINESS LOGIC / STATE MANAGEMENT (Provider)
// ==========================================
class NewsProvider extends ChangeNotifier {
  List<Article> _allArticles = [];
  final Set<int> _favoriteIds = {};
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get favoriteCount => _favoriteIds.length;

  // Filtered articles based on search box query
  List<Article> get filteredArticles {
    if (_searchQuery.trim().isEmpty) {
      return _allArticles;
    }
    return _allArticles
        .where((article) =>
        article.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  bool isFavorite(int articleId) => _favoriteIds.contains(articleId);

  Future<void> fetchArticles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedList = json.decode(response.body);
        _allArticles = decodedList
            .map((item) => Article.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _errorMessage =
        'Failed to load articles (Status Code: ${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Network error: Unable to fetch articles. Please check your connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleFavorite(int articleId) {
    if (_favoriteIds.contains(articleId)) {
      _favoriteIds.remove(articleId);
    } else {
      _favoriteIds.add(articleId);
    }
    notifyListeners();
  }
}

// ==========================================
// 3. UI LAYER (Screens & Widgets)
// ==========================================
class NewsReaderApp extends StatelessWidget {
  const NewsReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const NewsListScreen(),
    );
  }
}

class NewsListScreen extends StatelessWidget {
  const NewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NewsProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: const Text('News Reader'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(
                  '${provider.favoriteCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box to filter articles by title
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) =>
                  context.read<NewsProvider>().updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search articles by title...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),

          // Main Content Area: Loading, Error with Retry, or ListView.builder
          Expanded(
            child: Builder(
              builder: (context) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 56, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                context.read<NewsProvider>().fetchArticles(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final articles = provider.filteredArticles;

                if (articles.isEmpty) {
                  return const Center(
                    child: Text('No matching articles found.'),
                  );
                }

                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    final isFav = provider.isFavorite(article.id);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          child: Text('${article.id}'),
                        ),
                        title: Text(
                          article.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          article.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => context
                              .read<NewsProvider>()
                              .toggleFavorite(article.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ArticleDetailScreen(article: article),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen when an article is tapped
class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<NewsProvider>().isFavorite(article.id);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        title: Text('Article #${article.id}'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white,
            ),
            onPressed: () =>
                context.read<NewsProvider>().toggleFavorite(article.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title.toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Author User ID: ${article.userId}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 28),
            Text(
              article.body,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}