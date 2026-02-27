import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'detail_screen.dart';

class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double change;
  final String image;
  final List<double> history7d;

  // 👇 فیلدهای جدید
  final double marketCap;
  final double high24h;
  final double low24h;

  const Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.image,
    required this.history7d,
    // 👇 اضافه شدن به سازنده
    required this.marketCap,
    required this.high24h,
    required this.low24h,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    var historyList = json['sparkline_in_7d']?['price'] as List<dynamic>?;
    List<double> history = historyList != null
        ? historyList.map((e) => (e as num).toDouble()).toList()
        : [];

    return Crypto(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'].toString().toUpperCase(),
      image: json['image'],
      price: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      change: (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      history7d: history,

      // 👇 دریافت فیلدهای جدید (با ایمن‌سازی نال)
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// 2. ویجت کارت که قبلا ساختیم
class CryptoCard extends StatelessWidget {
  // این ویجت برای کار کردن به یک ابجکت از نوع Crypto نیاز دارد
  final Crypto crypto;

  const CryptoCard({super.key, required this.crypto});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

      // 👇 اینجا InkWell اضافه شد تا قابلیت کلیک داشته باشیم
      child: InkWell(
        borderRadius: BorderRadius.circular(15), // تطبیق شعاع کلیک با کارت
        onTap: () {
          // 👇 جادوی نویگیشن اینجاست:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(crypto: crypto),
            ),
          );
        },
        child: Padding( // همان Padding قبلی شما
          padding: const EdgeInsets.all(12.0),
          child: Row(
            // ... بقیه کدهای Row و Column که قبلا داشتیم و درست بودند ...
            // (این قسمت را تغییر ندهید، فقط کپی/پیست نکنید که کد قبلی پاک شود)
            // اگر کد Row یادتان رفته، بگویید بفرستم. اما احتمالا داریدش.
            children: [
              //SizedBox(width: 50, height: 50, child: Image.network(crypto.image)),
              // 👇 کد جدید و بهینه:
              SizedBox(
                width: 50,
                height: 50,
                child: CachedNetworkImage(
                  imageUrl: crypto.image,
                  // تا زمانی که عکس لود شود، یک دایره کمرنگ نشان بده
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  // اگر عکس ارور داشت (لینک خراب بود)، یک آیکون ارور نشان بده
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  // عکس را نرم فید (Fade-in) کن تا چشم نواز باشد
                  fadeInDuration: const Duration(milliseconds: 500),
                ),
              ),

              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(crypto.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(crypto.symbol, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("\$${crypto.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text("${crypto.change}%", style: TextStyle(color: crypto.change >= 0 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
