import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // پکیج پروایدر
import 'crypto_card.dart';
import 'providers/market_provider.dart'; // فایل جدید پروایدر
import 'favorites_screen.dart'; // صفحه علاقه‌مندی‌ها

// متغیر تم (Dark Mode)
final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

void main() {
  runApp(
    // 👇 تزریق پروایدر به کل برنامه
    ChangeNotifierProvider(
      create: (context) => MarketProvider(),
      child: const CryptoApp(),
    ),
  );
}

class CryptoApp extends StatelessWidget {
  const CryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Crypto Market',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.indigo.shade50,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
            ),
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const CryptoListScreen(),
        );
      },
    );
  }
}

// 👇 تبدیل به StatelessWidget شد چون State در Provider است
class CryptoListScreen extends StatelessWidget {
  const CryptoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // دسترسی اولیه به پروایدر (فقط برای صدا زدن توابع، نه گوش دادن)
    final marketProvider = Provider.of<MarketProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(isDarkModeNotifier.value ? Icons.wb_sunny : Icons.nightlight_round),
          onPressed: () {
            isDarkModeNotifier.value = !isDarkModeNotifier.value;
          },
        ),
        title: const Text("Live Crypto Market"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // رفتن به صفحه علاقه‌مندی‌ها (دیگر نیازی به پاس دادن لیست نیست)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              marketProvider.fetchCryptoData();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: (value) => marketProvider.runFilter(value), // جستجو از طریق پروایدر
              decoration: InputDecoration(
                labelText: 'Search Crypto...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Theme.of(context).cardColor, // رنگ متناسب با تم
              ),
            ),
          ),

          Expanded(
            // 👇 اینجا گوش می‌دهیم (Consumer)
            child: Consumer<MarketProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.foundCryptos.isEmpty) {
                  return const Center(child: Text("No Coin Found!"));
                }

                return RefreshIndicator(
                  onRefresh: () async => await provider.fetchCryptoData(),
                  child: ListView.builder(
                    itemCount: provider.foundCryptos.length,
                    itemExtent: 80,
                    itemBuilder: (context, index) {
                      final crypto = provider.foundCryptos[index];
                      final isFavorite = provider.isFavorite(crypto.id);

                      return Stack(
                        children: [
                          CryptoCard(crypto: crypto),
                          Positioned(
                            right: 20,
                            top: 25,
                            child: GestureDetector(
                              onTap: () {
                                provider.toggleFavorite(crypto.id);
                              },
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.grey,
                                size: 28,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}