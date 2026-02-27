import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/market_provider.dart';
import 'crypto_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 دریافت لیست کامل و لیست محبوب‌ها از پروایدر
    final provider = Provider.of<MarketProvider>(context);

    // فیلتر کردن ارزهایی که ID آن‌ها در لیست محبوب‌هاست
    final favorites = provider.cryptos
        .where((crypto) => provider.favoriteIds.contains(crypto.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Watchlist"),
      ),
      body: favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 100, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 20),
            const Text(
              "No favorites yet!",
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemExtent: 80,
        itemBuilder: (context, index) {
          final crypto = favorites[index];
          return Stack(
            children: [
              CryptoCard(crypto: crypto),
              Positioned(
                right: 20,
                top: 25,
                child: GestureDetector(
                  onTap: () {
                    // حذف از لیست (قلب خاموش می‌شود و لیست رفرش می‌شود)
                    provider.toggleFavorite(crypto.id);
                  },
                  child: const Icon(
                    Icons.favorite, // اینجا همیشه قلبه چون تو لیست فیوریت هستیم
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}