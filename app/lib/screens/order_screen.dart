import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../api.dart";
import "../models.dart";
import "../state.dart";
import "../theme.dart";

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, required this.state, this.prefill});
  final FarmState state;
  final FarmOrder? prefill;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _addr1 = TextEditingController();
  final _area = TextEditingController();
  final _pin = TextEditingController();
  final _notes = TextEditingController();
  double qtyCow = 1;
  double qtyBuf = 0;
  String freq = "daily";
  DateTime start = DateTime.now().add(const Duration(days: 1));
  FarmOrder? last;
  String? lastWa;
  bool sending = false;
  String? error;

  FarmState get state => widget.state;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    if (p != null) {
      _name.text = p.name;
      _phone.text = p.phone;
      _addr1.text = p.addressLine1;
      _area.text = p.area;
      _pin.text = p.pincode;
      _notes.text = p.notes;
      freq = p.frequency;
      qtyCow = p.items.where((e) => e.key == "cow").fold(0.0, (s, e) => e.litres);
      qtyBuf = p.items.where((e) => e.key == "buffalo").fold(0.0, (s, e) => e.litres);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _addr1.dispose();
    _area.dispose();
    _pin.dispose();
    _notes.dispose();
    super.dispose();
  }

  Catalog get cat => state.catalog ?? fallbackCatalog(state.lang);
  double get cowRate => cat.byKey("cow")?.pricePerLitre ?? 80;
  double get bufRate => cat.byKey("buffalo")?.pricePerLitre ?? 90;
  int get total => (qtyCow * cowRate + qtyBuf * bufRate).round();

  Future<void> _submit() async {
    final name = _name.text.trim();
    final phone = _phone.text.replaceAll(RegExp(r"\D"), "");
    final addr1 = _addr1.text.trim();
    setState(() => error = null);
    if (name.isEmpty) return setState(() => error = state.t("order.e_name"));
    if (phone.length < 10) return setState(() => error = state.t("order.e_phone"));
    if (addr1.isEmpty) return setState(() => error = state.t("order.e_addr1"));
    if (qtyCow + qtyBuf < 0.5) return setState(() => error = state.t("order.e_qty"));

    setState(() => sending = true);
    final startStr =
        "${start.year.toString().padLeft(4, "0")}-${start.month.toString().padLeft(2, "0")}-${start.day.toString().padLeft(2, "0")}";
    final posted = await FarmApi().submitOrder(
      name: name,
      phone: _phone.text.trim(),
      addr1: addr1,
      area: _area.text,
      pin: _pin.text,
      qtyCow: qtyCow,
      qtyBuf: qtyBuf,
      freq: freq,
      startDate: startStr,
      notes: _notes.text,
      lang: state.lang,
    );
    final order = posted?.order ??
        buildOrder(
          name: name,
          phone: _phone.text.trim(),
          addr1: addr1,
          area: _area.text,
          pin: _pin.text,
          qtyCow: qtyCow,
          qtyBuf: qtyBuf,
          freq: freq,
          startDate: startStr,
          notes: _notes.text,
          lang: state.lang,
          cowRate: cowRate,
          bufRate: bufRate,
        );
    final wa = (posted?.waUrl.isNotEmpty ?? false) ? posted!.waUrl : waLink(cat.settings.waNumber, order);
    await state.remember(order);
    setState(() {
      last = order;
      lastWa = wa;
      sending = false;
    });
    await launchUrl(Uri.parse(wa), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
    if (last != null) return _done(c);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        Text(state.t("order.eyebrow"), style: TextStyle(color: c.leaf, fontWeight: FontWeight.w700)),
        Text(state.t("order.title"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        Text(state.t("order.sub"), style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        TextField(controller: _name, textCapitalization: TextCapitalization.words, decoration: InputDecoration(labelText: state.t("order.l_name"), hintText: state.t("order.ph_name"))),
        const SizedBox(height: 10),
        TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: state.t("order.l_phone"), hintText: state.t("order.ph_phone"))),
        const SizedBox(height: 10),
        TextField(controller: _addr1, decoration: InputDecoration(labelText: state.t("order.l_addr1"), hintText: state.t("order.ph_addr1"))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: TextField(controller: _area, decoration: InputDecoration(labelText: state.t("order.l_area")))),
          const SizedBox(width: 10),
          Expanded(child: TextField(controller: _pin, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: state.t("order.l_pin")))),
        ]),
        const SizedBox(height: 16),
        Text(state.t("order.l_milk"), style: TextStyle(color: c.forest, fontWeight: FontWeight.w700)),
        Text(state.t("order.milk_hint"), style: TextStyle(color: c.muted, fontSize: 13)),
        _stepper(cat.byKey("cow")?.name ?? state.t("order.p_cow"), qtyCow, (v) => setState(() => qtyCow = v)),
        _stepper(cat.byKey("buffalo")?.name ?? state.t("order.p_buf"), qtyBuf, (v) => setState(() => qtyBuf = v)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: freq,
          decoration: InputDecoration(labelText: state.t("order.l_freq")),
          items: [
            DropdownMenuItem(value: "daily", child: Text(state.t("order.fr_daily"))),
            DropdownMenuItem(value: "alt", child: Text(state.t("order.fr_alt"))),
            DropdownMenuItem(value: "once", child: Text(state.t("order.fr_once"))),
          ],
          onChanged: (v) => setState(() => freq = v ?? "daily"),
        ),
        const SizedBox(height: 10),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(state.t("order.l_date")),
          subtitle: Text("${start.year}-${start.month.toString().padLeft(2, "0")}-${start.day.toString().padLeft(2, "0")}"),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: start,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
            );
            if (picked != null) setState(() => start = picked);
          },
        ),
        TextField(controller: _notes, maxLines: 3, decoration: InputDecoration(labelText: state.t("order.l_notes"), hintText: state.t("order.ph_notes"))),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.creamSunk,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: c.gold, style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Expanded(child: Text(state.t("order.est_label"), style: TextStyle(color: c.muted, fontWeight: FontWeight.w700))),
              Text("₹$total", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(error!, style: TextStyle(color: c.danger, fontWeight: FontWeight.w700)),
          ),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: sending ? null : _submit,
          child: Text(sending ? "…" : state.t("order.cta")),
        ),
        const SizedBox(height: 8),
        Text(state.t("order.fineprint"), textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 12)),
      ],
    );
  }

  Widget _stepper(String label, double value, ValueChanged<double> onChanged) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () => onChanged((value - 0.5).clamp(0, 20)), icon: const Icon(Icons.remove)),
            Text(value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1), style: const TextStyle(fontWeight: FontWeight.w700)),
            IconButton(onPressed: () => onChanged((value + 0.5).clamp(0, 20)), icon: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }

  Widget _done(FarmColors c) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      children: [
        Icon(Icons.check_circle, color: c.leaf, size: 56),
        const SizedBox(height: 12),
        Text(state.t("order.done_title"), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        Text(state.t("order.done_msg"), textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(state.t("order.next_title"), style: TextStyle(color: c.forest, fontWeight: FontWeight.w700)),
              Text("1. ${state.t("order.next_1")}"),
              Text("2. ${state.t("order.next_2")}"),
              Text("3. ${state.t("order.next_3")}"),
              if (last != null) Text("${state.t("order.pay_ref")}: ${last!.ref}"),
            ]),
          ),
        ),
        FilledButton(
          onPressed: lastWa == null ? null : () => launchUrl(Uri.parse(lastWa!), mode: LaunchMode.externalApplication),
          child: Text(state.t("order.reopen")),
        ),
        TextButton(onPressed: () => setState(() => last = null), child: Text(state.t("order.new_order"))),
      ],
    );
  }
}
