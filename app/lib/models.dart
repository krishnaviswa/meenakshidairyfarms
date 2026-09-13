class FarmProduct {
  const FarmProduct({
    required this.key,
    required this.name,
    required this.breed,
    required this.tagline,
    required this.bullets,
    required this.pricePerLitre,
    required this.pricePerHalfLitre,
  });

  final String key;
  final String name;
  final String breed;
  final String tagline;
  final List<String> bullets;
  final double pricePerLitre;
  final double pricePerHalfLitre;

  factory FarmProduct.fromJson(Map<String, dynamic> j) => FarmProduct(
        key: j["key"] as String,
        name: j["name"] as String,
        breed: j["breed"] as String,
        tagline: (j["tagline"] as String?) ?? "",
        bullets: (j["bullets"] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        pricePerLitre: (j["pricePerLitre"] as num).toDouble(),
        pricePerHalfLitre: (j["pricePerHalfLitre"] as num).toDouble(),
      );
}

class SiteSettings {
  const SiteSettings({
    required this.waNumber,
    required this.contactEmail,
    required this.upiVpa,
    required this.upiName,
  });

  final String waNumber;
  final String contactEmail;
  final String upiVpa;
  final String upiName;

  factory SiteSettings.fromJson(Map<String, dynamic> j) => SiteSettings(
        waNumber: (j["waNumber"] as String?) ?? "919087282939",
        contactEmail: (j["contactEmail"] as String?) ?? "meenakshidairyfarms@gmail.com",
        upiVpa: (j["upiVpa"] as String?) ?? "",
        upiName: (j["upiName"] as String?) ?? "Meenakshi Dairy Farms",
      );
}

class Catalog {
  const Catalog({
    required this.products,
    required this.usps,
    required this.settings,
    required this.fromDb,
  });

  final List<FarmProduct> products;
  final List<String> usps;
  final SiteSettings settings;
  final bool fromDb;

  FarmProduct? byKey(String key) {
    for (final p in products) {
      if (p.key == key) return p;
    }
    return null;
  }

  factory Catalog.fromJson(Map<String, dynamic> j) => Catalog(
        products: (j["products"] as List<dynamic>)
            .map((e) => FarmProduct.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        usps: (j["usps"] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        settings: SiteSettings.fromJson(Map<String, dynamic>.from(j["settings"] as Map)),
        fromDb: j["fromDb"] == true,
      );
}

class AuthUser {
  const AuthUser({required this.id, required this.phone});

  final String id;
  final String phone;

  Map<String, dynamic> toJson() => {"id": id, "phone": phone};

  factory AuthUser.fromJson(Map<String, dynamic> j) => AuthUser(
        id: j["id"] as String,
        phone: j["phone"] as String,
      );
}

class AccountOrder {
  const AccountOrder({
    required this.ref,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final String ref;
  final List<OrderItem> items;
  final double total;
  final String status;
  final String createdAt;

  factory AccountOrder.fromJson(Map<String, dynamic> j) => AccountOrder(
        ref: j["ref"] as String,
        items: (j["items"] as List<dynamic>? ?? const [])
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: double.tryParse("${j["total"]}") ?? 0,
        status: (j["status"] as String?) ?? "pending",
        createdAt: (j["created_at"] as String?) ?? "",
      );
}

class BillingPayment {
  const BillingPayment({
    required this.id,
    required this.orderRef,
    required this.amount,
    required this.status,
  });

  final String id;
  final String orderRef;
  final double amount;
  final String status;

  factory BillingPayment.fromJson(Map<String, dynamic> j) => BillingPayment(
        id: j["id"] as String,
        orderRef: (j["order_ref"] as String?) ?? "",
        amount: double.tryParse("${j["amount"]}") ?? 0,
        status: (j["status"] as String?) ?? "due",
      );
}

class OrderItem {
  const OrderItem({
    required this.key,
    required this.litres,
    required this.pricePerLitre,
    required this.amount,
  });

  final String key;
  final double litres;
  final double pricePerLitre;
  final int amount;

  Map<String, dynamic> toJson() => {
        "key": key,
        "litres": litres,
        "price_per_litre": pricePerLitre,
        "amount": amount,
      };

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        key: j["key"] as String,
        litres: (j["litres"] as num).toDouble(),
        pricePerLitre: (j["price_per_litre"] as num).toDouble(),
        amount: (j["amount"] as num).round(),
      );
}

class FarmOrder {
  const FarmOrder({
    required this.ref,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.area,
    required this.pincode,
    required this.items,
    required this.total,
    required this.frequency,
    this.startDate,
    required this.notes,
    required this.channel,
    required this.language,
    this.ts,
  });

  final String ref;
  final String name;
  final String phone;
  final String addressLine1;
  final String area;
  final String pincode;
  final List<OrderItem> items;
  final int total;
  final String frequency;
  final String? startDate;
  final String notes;
  final String channel;
  final String language;
  final int? ts;

  Map<String, dynamic> toJson() => {
        "ref": ref,
        "name": name,
        "phone": phone,
        "address_line1": addressLine1,
        "area": area,
        "pincode": pincode,
        "items": items.map((e) => e.toJson()).toList(),
        "total": total,
        "frequency": frequency,
        "start_date": startDate,
        "notes": notes,
        "channel": channel,
        "language": language,
        "ts": ts,
      };

  factory FarmOrder.fromJson(Map<String, dynamic> j) => FarmOrder(
        ref: j["ref"] as String,
        name: j["name"] as String,
        phone: j["phone"] as String,
        addressLine1: (j["address_line1"] ?? j["addressLine1"] ?? "") as String,
        area: (j["area"] as String?) ?? "",
        pincode: (j["pincode"] as String?) ?? "",
        items: (j["items"] as List<dynamic>)
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        total: (j["total"] as num).round(),
        frequency: j["frequency"] as String,
        startDate: j["start_date"] as String?,
        notes: (j["notes"] as String?) ?? "",
        channel: (j["channel"] as String?) ?? "app",
        language: (j["language"] as String?) ?? "en",
        ts: j["ts"] as int?,
      );
}
