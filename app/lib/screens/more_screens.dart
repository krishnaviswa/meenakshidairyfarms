import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../api.dart";
import "../models.dart";
import "../state.dart";
import "../theme.dart";

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.state, required this.onReorder});
  final FarmState state;
  final ValueChanged<FarmOrder> onReorder;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(state.t("account.title"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(state.t("account.comingSoon")),
          ),
        ),
        const SizedBox(height: 18),
        Text(state.t("order.recent_title"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.forest)),
        const SizedBox(height: 8),
        if (state.recent.isEmpty)
          Text(state.t("account.noSub"), style: TextStyle(color: c.muted))
        else
          for (final o in state.recent)
            Card(
              child: ListTile(
                title: Text(o.items.map((e) => "${e.litres} L ${e.key}").join(" + ")),
                subtitle: Text("${state.t("order.pay_ref")} ${o.ref} · ₹${o.total}"),
                trailing: TextButton(onPressed: () => onReorder(o), child: Text(state.t("order.reorder"))),
              ),
            ),
        const SizedBox(height: 20),
        Text(state.t("common.callWhatsApp"), style: TextStyle(color: c.muted)),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse("https://wa.me/${state.catalog?.settings.waNumber ?? "919087282939"}"),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(displayPhone(state.catalog?.settings.waNumber ?? "919087282939")),
        ),
      ],
    );
  }
}

class MilkScreen extends StatelessWidget {
  const MilkScreen({super.key, required this.state, required this.onOrder});
  final FarmState state;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(state.t("ourMilk.title"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        Text(state.t("ourMilk.intro"), style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        Text(state.t("ourMilk.a2SectionTitle"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.forest)),
        for (final p in state.i18n?.strings("ourMilk.a2Paras") ?? const <String>[])
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(p, style: const TextStyle(height: 1.45))),
        const SizedBox(height: 16),
        Text(state.t("ourMilk.chooseTitle"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.forest)),
        Text("• ${state.t("ourMilk.chooseCow")}"),
        Text("• ${state.t("ourMilk.chooseBuf")}"),
        Text("• ${state.t("ourMilk.chooseBoth")}"),
        const SizedBox(height: 16),
        Text(state.t("ourMilk.priceNote")),
        const SizedBox(height: 12),
        FilledButton(onPressed: onOrder, child: Text(state.t("ourMilk.priceCta"))),
      ],
    );
  }
}

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key, required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(state.t("ourFarm.title"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        Text(state.t("ourFarm.intro"), style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        Text(state.t("ourFarm.sahiwalTitle"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.forest)),
        for (final p in state.i18n?.strings("ourFarm.sahiwalBody") ?? const <String>[])
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(p)),
        const SizedBox(height: 16),
        Text(state.t("ourFarm.murrahTitle"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.forest)),
        for (final p in state.i18n?.strings("ourFarm.murrahBody") ?? const <String>[])
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(p)),
        const SizedBox(height: 16),
        Text(state.t("ourFarm.practicesTitle"), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: c.forest)),
        for (final p in state.i18n?.maps("ourFarm.practices") ?? const <Map<String, dynamic>>[])
          ListTile(title: Text("${p["t"]}"), subtitle: Text("${p["d"]}")),
      ],
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key, required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark ? FarmColors.dark : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(state.t("faq.title"), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: c.forest)),
        const SizedBox(height: 8),
        for (final item in state.i18n?.maps("faq.items") ?? const <Map<String, dynamic>>[])
          ExpansionTile(title: Text("${item["q"]}"), children: [
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text("${item["a"]}")),
          ]),
      ],
    );
  }
}
