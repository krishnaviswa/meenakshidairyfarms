import "package:flutter/foundation.dart";

/// API root for the Astro + Postgres backend.
///
/// Release phone builds leave this empty unless you pass
/// `--dart-define=API_BASE=https://your-host` so the APK still works offline
/// (embedded catalog + WhatsApp). Debug builds talk to the local site.
class AppConfig {
  static const brand = "Meenakshi Dairy Farms";
  static const fallbackWa = "919087282939";
  static const fallbackEmail = "meenakshidairyfarms@gmail.com";

  static String apiBase() {
    const defined = String.fromEnvironment("API_BASE");
    if (defined.isNotEmpty) return defined.replaceAll(RegExp(r"/$"), "");
    if (kDebugMode) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return "http://10.0.2.2:4321";
      }
      return "http://127.0.0.1:4321";
    }
    return "";
  }
}
