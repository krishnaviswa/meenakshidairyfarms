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
    final c = Theme.of(context).brightness == Brightness.dark
        ? FarmColors.dark
        : FarmColors.light;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        _HeroPanel(state: state, colors: c, onOrder: onOrder),
        const SizedBox(height: 22),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final chip
                in state.i18n?.strings("home.chips") ?? const <String>[])
              Chip(label: Text(chip), visualDensity: VisualDensity.compact),
          ],
        ),
        const SizedBox(height: 16),
        if (cow != null && buf != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PriceFlag(
                c: c,
                amount: cow.pricePerHalfLitre,
                label:
                    "${state.t("common.cow")} · ${state.t("common.perHalfLitre")}",
              ),
              _PriceFlag(
                c: c,
                amount: buf.pricePerHalfLitre,
                label:
                    "${state.t("common.buffalo")} · ${state.t("common.perHalfLitre")}",
              ),
            ],
          ),
        const SizedBox(height: 36),
        _SectionHeading(
          title: state.t("home.breedsTitle"),
          body: state.t("home.breedsBody"),
        ),
        const SizedBox(height: 16),
        if (cow != null)
          _ProductCard(
            state: state,
            product: cow,
            colors: c,
            asset: "assets/images/sahiwal-natural.webp",
            onOrder: onOrder,
          ),
        if (buf != null)
          _ProductCard(
            state: state,
            product: buf,
            colors: c,
            asset: "assets/images/murrah-natural.webp",
            onOrder: onOrder,
          ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 32),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: c.creamSunk,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.line),
          ),
          child: Text(
            state.t("home.commitment"),
            textAlign: TextAlign.center,
            style: TextStyle(color: c.forest, fontWeight: FontWeight.w700),
          ),
        ),
        _SectionHeading(title: state.t("home.whyTitle")),
        const SizedBox(height: 14),
        for (final u in cat.usps)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BenefitTile(text: u, colors: c),
          ),
        const SizedBox(height: 26),
        _SectionHeading(title: state.t("home.howTitle")),
        const SizedBox(height: 14),
        for (final step
            in state.i18n?.maps("home.how") ?? const <Map<String, dynamic>>[])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StepTile(step: step, colors: c),
          ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onOrder,
            child: Text(state.t("home.howCta")),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.state,
    required this.colors,
    required this.onOrder,
  });

  final FarmState state;
  final FarmColors colors;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 510,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.forest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.forest.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/images/hero-natural.webp",
            fit: BoxFit.cover,
            alignment: const Alignment(0.2, 0),
            semanticLabel:
                "Representative farm scene with a Sahiwal cow and Murrah buffalo",
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x150D1D13),
                  Color(0x66101F16),
                  Color(0xED102319),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  state.t("home.eyebrow"),
                  style: TextStyle(
                    color: const Color(0xFFF3D488),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.t("home.heroTitle"),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFFFFFAF4),
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.t("home.heroBody"),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xE8FFFAF4),
                    height: 1.42,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.leaf,
                    foregroundColor: colors.btnText,
                  ),
                  child: Text(state.t("home.heroCta")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? FarmColors.dark
        : FarmColors.light;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 4,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: c.gold,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: c.forest,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 4),
          Text(body!, style: TextStyle(color: c.muted, height: 1.45)),
        ],
      ],
    );
  }
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.text, required this.colors});

  final String text;
  final FarmColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.leaf.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: colors.leaf, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.colors});

  final Map<String, dynamic> step;
  final FarmColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.creamCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colors.leaf,
            foregroundColor: colors.btnText,
            child: Text(
              "${step["n"]}",
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${step["t"]}",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.forest,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text("${step["d"]}", style: TextStyle(color: colors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceFlag extends StatelessWidget {
  const _PriceFlag({
    required this.c,
    required this.amount,
    required this.label,
  });
  final FarmColors c;
  final double amount;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.forest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "₹${amount.round()}  $label",
        style: TextStyle(color: c.creamCard, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.state,
    required this.product,
    required this.colors,
    required this.asset,
    required this.onOrder,
  });
  final FarmState state;
  final FarmProduct product;
  final FarmColors colors;
  final String asset;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Image.asset(
              asset,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              semanticLabel: product.breed,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.breed.toUpperCase(),
                  style: TextStyle(
                    color: colors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: colors.forest),
                ),
                Text(product.tagline),
                const SizedBox(height: 8),
                for (final b in product.bullets)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 16, color: colors.leaf),
                        const SizedBox(width: 6),
                        Expanded(child: Text(b)),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  "₹${product.pricePerHalfLitre.round()} / ${state.t("common.perHalfLitre")}",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "₹${product.pricePerLitre.round()} / ${state.t("common.perLitre")}",
                  style: TextStyle(color: colors.muted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: onOrder,
                  child: Text(state.t("common.orderCta")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
