import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../crypto_card.dart'; // مدل Crypto را نیاز داریم

class MarketProvider with ChangeNotifier {
  // 1. وضعیت‌ها (State)
  List<Crypto> _allCryptos = [];
  List<Crypto> _foundCryptos = []; // نتیجه جستجو
  bool _isLoading = true;
  List<String> _favoriteIds = [];

  // 👇 گترها (Getters) برای خواندن وضعیت‌ها از بیرون
  List<Crypto> get cryptos => _allCryptos;
  List<Crypto> get foundCryptos => _foundCryptos;
  bool get isLoading => _isLoading;
  List<String> get favoriteIds => _favoriteIds;

  // تایمر برای آپدیت خودکار
  Timer? _timer;

  // 2. سازنده (Constructor)
  MarketProvider() {
    _loadFavorites(); // اول علاقه‌مندی‌ها را لود کن
    fetchCryptoData(); // بعد دیتا را بگیر

    // هر ۳۰ ثانیه آپدیت کن
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) => fetchCryptoData());
  }

  // 👇 وقتی کلاس از بین می‌رود (Dispose)
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // 3. دریافت دیتا از API
  Future<void> fetchCryptoData() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1&sparkline=true');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<Crypto> data = jsonList.map((e) => Crypto.fromJson(e)).toList();

        _allCryptos = data;

        // اگر جستجو خالی است، لیست نمایشی را آپدیت کن
        if (_foundCryptos.length == _allCryptos.length || _foundCryptos.isEmpty) {
          _foundCryptos = data;
        }

        _isLoading = false;

        // 🔔 خبر دادن به تمام صفحات: "آهای! دیتا آپدیت شد، رفرش کنید"
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. جستجو
  void runFilter(String keyword) {
    if (keyword.isEmpty) {
      _foundCryptos = _allCryptos;
    } else {
      _foundCryptos = _allCryptos
          .where((c) =>
      c.name.toLowerCase().contains(keyword.toLowerCase()) ||
          c.symbol.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    notifyListeners(); // 🔔 رفرش UI
  }

  // 5. مدیریت علاقه‌مندی‌ها
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteIds = prefs.getStringList('favorites') ?? [];
    notifyListeners(); // 🔔 رفرش UI
  }

  Future<void> toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await prefs.setStringList('favorites', _favoriteIds);
    notifyListeners(); // 🔔 رفرش UI (مهم: دکمه قلب در تمام صفحات آپدیت می‌شود)
  }

  // متد کمکی برای چک کردن وضعیت قلب
  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }
}