import "dart:convert";

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";

import "api.dart";
import "l10n.dart";
import "models.dart";

class FarmState extends ChangeNotifier {
  FarmState();

  final FarmApi _api = FarmApi();

  String lang = "en";
  ThemeMode themeMode = ThemeMode.system;
  L10n? i18n;
  Catalog? catalog;
  List<FarmOrder> recent = const [];
  bool loading = true;
  int tab = 0;

  Future<void> boot() async {
    final prefs = await SharedPreferences.getInstance();
    lang = prefs.getString("meenakshi_lang") ?? "en";
    final theme = prefs.getString("meenakshi_theme");
    if (theme == "dark") themeMode = ThemeMode.dark;
    if (theme == "light") themeMode = ThemeMode.light;
    await _reloadContent();
    await _loadRecent(prefs);
    loading = false;
    notifyListeners();
  }

  Future<void> setLang(String next) async {
    lang = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("meenakshi_lang", next);
    await _reloadContent();
    notifyListeners();
  }

  Future<void> cycleTheme() async {
    themeMode = switch (themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    final prefs = await SharedPreferences.getInstance();
    final stored = switch (themeMode) {
      ThemeMode.light => "light",
      ThemeMode.dark => "dark",
      ThemeMode.system => "",
    };
    if (stored.isEmpty) {
      await prefs.remove("meenakshi_theme");
    } else {
      await prefs.setString("meenakshi_theme", stored);
    }
    notifyListeners();
  }

  void setTab(int i) {
    tab = i;
    notifyListeners();
  }

  Future<void> _reloadContent() async {
    i18n = await L10n.load(lang);
    catalog = await _api.fetchCatalog(lang) ?? fallbackCatalog(lang);
  }

  Future<void> _loadRecent(SharedPreferences prefs) async {
    try {
      final raw = prefs.getString("meenakshi_orders_app") ?? "[]";
      final list = jsonDecode(raw) as List<dynamic>;
      recent = list
          .whereType<Map>()
          .map((e) => FarmOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      recent = const [];
    }
  }

  Future<void> remember(FarmOrder order) async {
    final prefs = await SharedPreferences.getInstance();
    recent = [order, ...recent].take(6).toList();
    await prefs.setString(
      "meenakshi_orders_app",
      jsonEncode(recent.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  String t(String path) => i18n?.t(path) ?? path;
}
