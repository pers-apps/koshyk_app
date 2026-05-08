import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kCurrencyKey = 'default_currency';
const _kDefaultCurrency = '₴';

const kCurrencyOptions = ['₴', '\$', '€'];

class CurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return _kDefaultCurrency;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kCurrencyKey);
    if (saved != null && kCurrencyOptions.contains(saved)) {
      state = saved;
    }
  }

  Future<void> setCurrency(String symbol) async {
    state = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrencyKey, symbol);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, String>(
  CurrencyNotifier.new,
);
