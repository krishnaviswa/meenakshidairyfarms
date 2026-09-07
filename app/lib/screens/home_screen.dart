import "package:flutter/material.dart";

import "../models.dart";
import "../state.dart";
import "../theme.dart";

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state, required this.onOrder});

  final FarmState state;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final cat = state.catalog;
    if (cat == null) return const Center(child: CircularProgressIndicator());
    final cow = cat.byKey("cow");
    final buf = cat.byKey("buffalo");
    final c = Theme.of(context).brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(state.t("home.eyebrow"), style: TextStyle(color: c.leaf, fontWeight: FontWeight.w700, fontSize: 12)),
        const SizedBox(height: 8),
        Text(state.t("home.heroTitle"), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: c.forest, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Text(state.t("home.heroBody"), style: TextStyle(color: c.muted, height: 1.5)),
        const SizedBox(height: 16),
        FilledButton(onPressed: onOrder, child: Text(state.t("home.heroCta"))),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final chip in state.i18n?.strings("home.chips") ?? const <String>[])
              Chip(label: Text(chip), visualDensity: VisualDensity.compact),
          ],
        ),
        const SizedBox(height: 14),
        if (cow != null && buf != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PriceFlag(c: c, amount: cow.pricePerHalfLitre, label: "${state.t("common.cow")} · ${state.t("common.perHalfLitre")}"),
              _PriceFlag(c: c, amount: buf.pricePerHalfLitre, label: "${state.t("common.buffalo")} · ${state.t("common.perHalfLitre")}"),
            ],
          ),
        const SizedBox(height: 28),
        Text(state.t("home.breedsTitle"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        const SizedBox(height: 6),
        Text(state.t("home.breedsBody"), style: TextStyle(color: c.muted)),
        const SizedBox(height: 14),
        if (cow != null) _ProductCard(state: state, product: cow, colors: c, onOrder: onOrder),
        if (buf != null) _ProductCard(state: state, product: buf, colors: c, onOrder: onOrder),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(state.t("home.commitment"), textAlign: TextAlign.center, style: TextStyle(color: c.forest, fontWeight: FontWeight.w700)),
        ),
        Text(state.t("home.whyTitle"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        const SizedBox(height: 10),
        for (final u in cat.usps)
          Card(
            child: ListTile(
              leading: Icon(Icons.check_circle, color: c.leaf),
              title: Text(u),
            ),
          ),
        const SizedBox(height: 18),
        Text(state.t("home.howTitle"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        const SizedBox(height: 8),
        for (final step in state.i18n?.maps("home.how") ?? const <Map<String, dynamic>>[])
          ListTile(
            leading: CircleAvatar(backgroundColor: c.leaf, foregroundColor: c.btnText, child: Text("${step["n"]}")),
            title: Text("${step["t"]}"),
            subtitle: Text("${step["d"]}"),
          ),
        const SizedBox(height: 8),
        FilledButton(onPressed: onOrder, child: Text(state.t("home.howCta"))),
      ],
    );
  }
}

class _PriceFlag extends StatelessWidget {
  const _PriceFlag({required this.c, required this.amount, required this.label});
  final FarmColors c;
  final double amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: c.forest, borderRadius: BorderRadius.circular(999)),
      child: Text(
        "₹${amount.round()}  $label",
        style: TextStyle(color: c.creamCard, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.state, required this.product, required this.colors, required this.onOrder});
  final FarmState state;
  final FarmProduct product;
  final FarmColors colors;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.breed.toUpperCase(), style: TextStyle(color: colors.gold, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 4),
            Text(product.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.forest)),
            Text(product.tagline),
            const SizedBox(height: 8),
            for (final b in product.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  Icon(Icons.check, size: 16, color: colors.leaf),
                  const SizedBox(width: 6),
                  Expanded(child: Text(b)),
                ]),
              ),
            const SizedBox(height: 8),
            Text("₹${product.pricePerHalfLitre.round()} / ${state.t("common.perHalfLitre")}",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: colors.forest, fontWeight: FontWeight.w700)),
            Text("₹${product.pricePerLitre.round()} / ${state.t("common.perLitre")}", style: TextStyle(color: colors.muted, fontSize: 13)),
            const SizedBox(height: 10),
            FilledButton(onPressed: onOrder, child: Text(state.t("common.orderCta"))),
          ],
        ),
      ),
    );
  }
}
