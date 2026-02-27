import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 نیاز به پروایدر داریم
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'providers/market_provider.dart'; // 👈
import 'crypto_card.dart';

class DetailScreen extends StatelessWidget {
  final Crypto crypto;

  const DetailScreen({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    // 👇 دسترسی به پروایدر برای چک کردن وضعیت قلب
    final provider = Provider.of<MarketProvider>(context);
    final isFavorite = provider.isFavorite(crypto.id);

    final isPositive = crypto.change >= 0;
    final color = isPositive ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(crypto.name),
        actions: [
          // 👇 دکمه قلب در AppBar صفحه جزئیات
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              provider.toggleFavorite(crypto.id);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CachedNetworkImage(imageUrl: crypto.image),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crypto.name,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            crypto.symbol,
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${crypto.price}",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${crypto.change}%",
                          style: TextStyle(
                            fontSize: 16,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Sparkline(
                  data: crypto.history7d,
                  useCubicSmoothing: true,
                  cubicSmoothingFactor: 0.2,
                  lineColor: color,
                  fillMode: FillMode.below,
                  fillGradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(context, "High 24h", "\$${crypto.high24h}", Colors.green),
                    _buildStatCard(context, "Low 24h", "\$${crypto.low24h}", Colors.red),
                    _buildStatCard(context, "Market Cap", _formatMarketCap(crypto.marketCap), Colors.blue),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton("Buy", Colors.green),
                  _buildActionButton("Sell", Colors.red),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // رنگ هماهنگ با تم
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      onPressed: () {},
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  String _formatMarketCap(double marketCap) {
    if (marketCap >= 1000000000) {
      return "\$${(marketCap / 1000000000).toStringAsFixed(2)} B";
    } else if (marketCap >= 1000000) {
      return "\$${(marketCap / 1000000).toStringAsFixed(2)} M";
    }
    return "\$${marketCap.toStringAsFixed(0)}";
  }
}