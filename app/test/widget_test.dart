import "package:flutter_test/flutter_test.dart";
import "package:meenakshi_app/api.dart";

void main() {
  test("buildOrder matches half-litre flyer rates", () {
    final o = buildOrder(
      name: "Priya",
      phone: "9876543210",
      addr1: "12 Farm Road",
      area: "",
      pin: "",
      qtyCow: 0.5,
      qtyBuf: 0.5,
      freq: "once",
      startDate: "2026-09-08",
      notes: "",
      lang: "en",
      cowRate: 80,
      bufRate: 90,
    );
    expect(o.total, 85);
    expect(o.items.length, 2);
    expect(o.channel, "app");
    expect(o.ref.startsWith("MDF-"), isTrue);
  });
}
