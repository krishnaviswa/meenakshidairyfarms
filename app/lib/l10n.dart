import "dart:convert";

import "package:flutter/services.dart";

class L10n {
  L10n(this._data);
  final Map<String, dynamic> _data;

  static Future<L10n> load(String lang) async {
    final raw = await rootBundle.loadString("assets/i18n/$lang.json");
    return L10n(jsonDecode(raw) as Map<String, dynamic>);
  }

  dynamic dig(String path) {
    dynamic cur = _data;
    for (final part in path.split(".")) {
      if (cur is Map<String, dynamic>) {
        cur = cur[part];
      } else {
        return null;
      }
    }
    return cur;
  }

  String t(String path) {
    final v = dig(path);
    return v == null ? path : v.toString();
  }

  List<String> strings(String path) {
    final v = dig(path);
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }

  List<Map<String, dynamic>> maps(String path) {
    final v = dig(path);
    if (v is List) {
      return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }
}
