import "dart:convert";
import "dart:math";

import "package:http/http.dart" as http;

import "config.dart";
import "models.dart";

double clampHalf(num v) {
  var n = v.toDouble();
  if (n.isNaN || n < 0) n = 0;
  return (n * 2).round() / 2;
}

String makeRef() {
  final d = DateTime.now();
  String p(int x) => x < 10 ? "0$x" : "$x";
  final ymd = "${d.year.toString().substring(2)}${p(d.month)}${p(d.day)}";
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  final r = Random();
  final s = List.generate(4, (_) => chars[r.nextInt(chars.length)]).join();
  return "MDF-$ymd-$s";
}

FarmOrder buildOrder({
  required String name,
  required String phone,
  required String addr1,
  required String area,
  required String pin,
  required double qtyCow,
  required double qtyBuf,
  required String freq,
  required String startDate,
  required String notes,
  required String lang,
  required double cowRate,
  required double bufRate,
}) {
  final cow = clampHalf(qtyCow);
  final buf = clampHalf(qtyBuf);
  final items = <OrderItem>[];
  if (cow > 0) {
    items.add(OrderItem(
      key: "cow",
      litres: cow,
      pricePerLitre: cowRate,
      amount: (cow * cowRate).round(),
    ));
  }
  if (buf > 0) {
    items.add(OrderItem(
      key: "buffalo",
      litres: buf,
      pricePerLitre: bufRate,
      amount: (buf * bufRate).round(),
    ));
  }
  final total = items.fold<int>(0, (s, it) => s + it.amount);
  return FarmOrder(
    ref: makeRef(),
    name: name.trim(),
    phone: phone.trim(),
    addressLine1: addr1.trim(),
    area: area.trim(),
    pincode: pin.trim(),
    items: items,
    total: total,
    frequency: freq,
    startDate: startDate.isEmpty ? null : startDate,
    notes: notes.trim(),
    channel: "app",
    language: lang,
    ts: DateTime.now().millisecondsSinceEpoch,
  );
}

String orderText(FarmOrder o) {
  const names = {
    "cow": "A2 Cow Milk (Sahiwal breed)",
    "buffalo": "A2 Buffalo Milk (Murrah breed)",
  };
  const freq = {"daily": "Daily", "alt": "Alternate days", "once": "One-time"};
  final L = <String>[
    "*New Milk Order — Meenakshi Dairy Farms*",
    "*Order ref:* ${o.ref}",
    "",
    "*Name:* ${o.name}",
    "*Phone:* ${o.phone}",
    "*Address:* ${o.addressLine1}",
  ];
  if (o.area.isNotEmpty) L.add("*Area / landmark:* ${o.area}");
  if (o.pincode.isNotEmpty) L.add("*Pincode:* ${o.pincode}");
  L.add("");
  L.add("*Milk order${o.frequency == "once" ? "" : " (per delivery)"}:*");
  for (final it in o.items) {
    L.add("• ${names[it.key]} — ${it.litres} L × ₹${it.pricePerLitre.round()} = ₹${it.amount}");
  }
  L.add("*Frequency:* ${freq[o.frequency] ?? o.frequency}");
  if (o.startDate != null) L.add("*Start from:* ${o.startDate}");
  L.add("*Estimated total:* ₹${o.total}${o.frequency == "once" ? "" : " per delivery"}");
  if (o.notes.isNotEmpty) {
    L.add("");
    L.add("*Notes:* ${o.notes}");
  }
  L.add("");
  L.add("_Sent from the Meenakshi app_");
  return L.join("\n");
}

String waLink(String waNumber, FarmOrder o) {
  return "https://wa.me/$waNumber?text=${Uri.encodeComponent(orderText(o))}";
}

String displayPhone(String waNumber) {
  final digits = waNumber.replaceAll(RegExp(r"\D"), "").replaceFirst(RegExp(r"^91"), "");
  if (digits.length == 10) return "${digits.substring(0, 5)} ${digits.substring(5)}";
  return digits;
}

class FarmApi {
  Future<Catalog?> fetchCatalog(String lang) async {
    final base = AppConfig.apiBase();
    if (base.isEmpty) return null;
    try {
      final res = await http
          .get(Uri.parse("$base/api/catalog?lang=$lang"))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return null;
      return Catalog.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<({FarmOrder order, String waUrl})?> submitOrder({
    required String name,
    required String phone,
    required String addr1,
    required String area,
    required String pin,
    required double qtyCow,
    required double qtyBuf,
    required String freq,
    required String startDate,
    required String notes,
    required String lang,
  }) async {
    final base = AppConfig.apiBase();
    if (base.isEmpty) return null;
    try {
      final res = await http
          .post(
            Uri.parse("$base/api/orders"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "name": name,
              "phone": phone,
              "addr1": addr1,
              "area": area,
              "pin": pin,
              "qtyCow": qtyCow,
              "qtyBuf": qtyBuf,
              "freq": freq,
              "startdate": startDate,
              "notes": notes,
              "language": lang,
              "channel": "app",
            }),
          )
          .timeout(const Duration(seconds: 8));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data["ok"] != true || data["order"] == null) return null;
      return (
        order: FarmOrder.fromJson(Map<String, dynamic>.from(data["order"] as Map)),
        waUrl: (data["waUrl"] as String?) ?? "",
      );
    } catch (_) {
      return null;
    }
  }
}

Catalog fallbackCatalog(String lang) {
  const names = {
    "en": ("A2 Cow Milk", "Sahiwal breed", "A2 Buffalo Milk", "Murrah breed"),
    "hi": ("A2 गाय का दूध", "साहीवाल नस्ल", "A2 भैंस का दूध", "मुर्रा नस्ल"),
    "ta": ("A2 பசும் பால்", "சிவால் இனம்", "A2 எருமை பால்", "முர்ரா இனம்"),
  };
  const tag = {
    "en": ("Light & gentle for everyday wellness", "Rich & nourishing for a stronger you"),
    "hi": ("रोज़ की सेहत के लिए हल्का और सौम्य", "मज़बूती के लिए गाढ़ा और पोषक"),
    "ta": ("தினசரி நலனுக்கு இலகுவான, மென்மையான பால்", "வலுவான உடலுக்கு சத்தான, நிறைவான பால்"),
  };
  const bullets = {
    "en": (
      ["From Sahiwal breed", "Easy to digest", "Rich in calcium & nutrients", "100% natural & unprocessed"],
      ["From Murrah breed", "Naturally rich in fat & minerals", "Great taste & energy", "100% natural & unprocessed"],
    ),
    "hi": (
      ["साहीवाल नस्ल से", "पचने में आसान", "कैल्शियम और पोषक तत्वों से भरपूर", "100% प्राकृतिक, बिना प्रोसेस"],
      ["मुर्रा नस्ल से", "स्वाभाविक रूप से वसा और खनिजों से भरपूर", "स्वाद और ऊर्जा", "100% प्राकृतिक, बिना प्रोसेस"],
    ),
    "ta": (
      ["சிவால் இனத்திலிருந்து", "செரிமானத்திற்கு எளிது", "கால்சியம் மற்றும் ஊட்டச்சத்து நிறைந்தது", "100% இயற்கை, பதப்படுத்தப்படாதது"],
      ["முர்ரா இனத்திலிருந்து", "இயற்கையாகவே கொழுப்பு மற்றும் கனிமங்கள் நிறைந்தது", "சுவையும் சக்தியும்", "100% இயற்கை, பதப்படுத்தப்படாதது"],
    ),
  };
  const usps = {
    "en": [
      "Naturally grazed on green fodder",
      "Direct from our farm — no middlemen",
      "Ethical and humane animal care",
      "Freshly milked and handled hygienically",
      "Regular quality testing for purity and safety",
      "Supports local farmers and sustainable farming",
      "Cold chain from farm to your home",
      "Trusted by hundreds of families",
    ],
    "hi": [
      "हरे चारे पर चरते हैं",
      "सीधे हमारे फार्म से — कोई बिचौलिया नहीं",
      "नैतिक और दयालु पशु देखभाल",
      "रोज़ दुहा, साफ़-सुथरे तरीके से संभाला",
      "शुद्धता और सुरक्षा के लिए नियमित जाँच",
      "स्थानीय किसानों और टिकाऊ खेती का साथ",
      "फार्म से आपके घर तक कोल्ड चेन",
      "सैकड़ों परिवारों का भरोसा",
    ],
    "ta": [
      "பசுந்தீவனத்தில் இயற்கையாக மேய்கின்றன",
      "எங்கள் பண்ணையிலிருந்து நேரடி — இடைத்தரகர் இல்லை",
      "நெறிமுறை, அன்பான கால்நடைப் பராமரிப்பு",
      "தினமும் கறந்து சுகாதாரமாக கையாளப்படுகிறது",
      "தூய்மை மற்றும் பாதுகாப்புக்கு வழக்கமான தரச் சோதனை",
      "உள்ளூர் விவசாயிகளுக்கும் நிலையான வேளாண்மைக்கும் ஆதரவு",
      "பண்ணையிலிருந்து உங்கள் வீடு வரை குளிர்ச்சங்கிலி",
      "நூற்றுக்கணக்கான குடும்பங்களின் நம்பிக்கை",
    ],
  };
  final n = names[lang] ?? names["en"]!;
  final t = tag[lang] ?? tag["en"]!;
  final b = bullets[lang] ?? bullets["en"]!;
  return Catalog(
    fromDb: false,
    usps: usps[lang] ?? usps["en"]!,
    settings: const SiteSettings(
      waNumber: AppConfig.fallbackWa,
      contactEmail: AppConfig.fallbackEmail,
      upiVpa: "",
      upiName: AppConfig.brand,
    ),
    products: [
      FarmProduct(
        key: "cow",
        name: n.$1,
        breed: n.$2,
        tagline: t.$1,
        bullets: b.$1,
        pricePerLitre: 80,
        pricePerHalfLitre: 40,
      ),
      FarmProduct(
        key: "buffalo",
        name: n.$3,
        breed: n.$4,
        tagline: t.$2,
        bullets: b.$2,
        pricePerLitre: 90,
        pricePerHalfLitre: 45,
      ),
    ],
  );
}
