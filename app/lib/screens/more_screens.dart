import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "../api.dart";
import "../config.dart";
import "../models.dart";
import "../state.dart";
import "../theme.dart";

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.state,
    required this.onReorder,
  });
  final FarmState state;
  final ValueChanged<FarmOrder> onReorder;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _api = FarmApi();

  bool _codeStep = false;
  bool _busy = false;
  String? _error;
  String? _devCode;

  List<AccountOrder>? _orders;
  List<BillingPayment>? _payments;
  bool _loadedAccountData = false;

  FarmState get state => widget.state;

  @override
  void didUpdateWidget(covariant AccountScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (state.isLoggedIn && !_loadedAccountData) _loadAccountData();
  }

  @override
  void initState() {
    super.initState();
    if (state.isLoggedIn) _loadAccountData();
  }

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _loadAccountData() async {
    _loadedAccountData = true;
    final token = state.authToken;
    if (token == null) return;
    final orders = await _api.fetchOrderHistory(token);
    final payments = await _api.fetchPayments(token);
    if (!mounted) return;
    setState(() {
      _orders = orders;
      _payments = payments;
    });
  }

  Future<void> _sendCode() async {
    final digits = _phone.text.replaceAll(RegExp(r"\D"), "");
    if (digits.length < 10)
      return setState(() => _error = state.t("account.invalidPhone"));
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await _api.requestOtp(_phone.text.trim());
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (res == null) {
        _error = state.t("account.loadError");
      } else {
        _codeStep = true;
        _devCode = res.devCode;
      }
    });
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final res = await _api.verifyOtp(_phone.text.trim(), code);
    if (!mounted) return;
    setState(() => _busy = false);
    if (res == null) {
      setState(() => _error = state.t("account.invalidCode"));
      return;
    }
    await state.setAuth(res.token, res.user);
    _loadedAccountData = false;
    await _loadAccountData();
  }

  Future<void> _logout() async {
    await state.logout();
    setState(() {
      _orders = null;
      _payments = null;
      _loadedAccountData = false;
      _codeStep = false;
      _phone.clear();
      _code.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? FarmColors.dark
        : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          state.t("account.title"),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: c.forest),
        ),
        const SizedBox(height: 8),
        if (!state.isLoggedIn) _loginCard(c) else ..._loggedInContent(c),
        const SizedBox(height: 20),
        Text(state.t("common.callWhatsApp"), style: TextStyle(color: c.muted)),
        TextButton(
          onPressed: () => launchUrl(
            Uri.parse(
              "https://wa.me/${state.catalog?.settings.waNumber ?? AppConfig.fallbackWa}",
            ),
            mode: LaunchMode.externalApplication,
          ),
          child: Text(state.t("common.callWhatsApp")),
        ),
      ],
    );
  }

  Widget _loginCard(FarmColors c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.t("account.loginTitle"),
              style: TextStyle(
                color: c.forest,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _codeStep
                  ? state.t("account.codeLabel")
                  : state.t("account.loginBody"),
              style: TextStyle(color: c.muted),
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: c.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_devCode != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  "${state.t("account.devCodeHint")} $_devCode",
                  style: TextStyle(color: c.gold, fontWeight: FontWeight.w700),
                ),
              ),
            if (!_codeStep) ...[
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: state.t("account.phoneLabel"),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: _busy ? null : _sendCode,
                child: Text(
                  _busy
                      ? state.t("account.sendingCode")
                      : state.t("account.sendCode"),
                ),
              ),
            ] else ...[
              TextField(
                controller: _code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: state.t("account.codeLabel"),
                ),
              ),
              FilledButton(
                onPressed: _busy ? null : _verify,
                child: Text(
                  _busy
                      ? state.t("account.verifying")
                      : state.t("account.verify"),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _codeStep = false;
                  _error = null;
                  _devCode = null;
                }),
                child: Text(state.t("account.changeNumber")),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _loggedInContent(FarmColors c) {
    return [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _logout,
          child: Text(state.t("account.signOut")),
        ),
      ),
      Text(
        state.t("account.ordersTitle"),
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: c.forest),
      ),
      const SizedBox(height: 8),
      if (_orders == null && state.recent.isNotEmpty)
        for (final o in state.recent)
          Card(
            child: ListTile(
              title: Text(
                o.items.map((e) => "${e.litres} L ${e.key}").join(" + "),
              ),
              subtitle: Text(
                "${state.t("order.pay_ref")} ${o.ref} · ₹${o.total}",
              ),
              trailing: TextButton(
                onPressed: () => widget.onReorder(o),
                child: Text(state.t("order.reorder")),
              ),
            ),
          )
      else if (_orders == null)
        Text(state.t("account.loadError"), style: TextStyle(color: c.muted))
      else if (_orders!.isEmpty)
        Text(state.t("account.noOrders"), style: TextStyle(color: c.muted))
      else
        for (final o in _orders!)
          Card(
            child: ListTile(
              title: Text(
                o.items.map((e) => "${e.litres} L ${e.key}").join(" + "),
              ),
              subtitle: Text("${o.ref} · ${o.createdAt.split("T").first}"),
              trailing: Text(
                "₹${o.total.round()}",
                style: TextStyle(color: c.forest, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      const SizedBox(height: 18),
      Text(
        state.t("account.paymentsTitle"),
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: c.forest),
      ),
      const SizedBox(height: 8),
      if (_payments == null)
        Text(state.t("account.loadError"), style: TextStyle(color: c.muted))
      else if (_payments!.isEmpty)
        Text(state.t("account.noPayments"), style: TextStyle(color: c.muted))
      else
        for (final p in _payments!) _paymentRow(p, c),
    ];
  }

  Widget _paymentRow(BillingPayment p, FarmColors c) {
    return Card(
      child: ListTile(
        title: Text("₹${p.amount.round()} · ${p.orderRef}"),
        trailing: p.status == "due"
            ? FilledButton(
                onPressed: () async {
                  final token = state.authToken;
                  if (token == null) return;
                  final ok = await _api.markPaid(token, p.id);
                  if (ok) await _loadAccountData();
                },
                child: Text(state.t("account.markPaid")),
              )
            : Text(
                state.t("account.paidSelfReported"),
                style: TextStyle(color: c.leaf, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }
}

class MilkScreen extends StatelessWidget {
  const MilkScreen({super.key, required this.state, required this.onOrder});
  final FarmState state;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? FarmColors.dark
        : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          state.t("ourMilk.title"),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: c.forest),
        ),
        Text(state.t("ourMilk.intro"), style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        Text(
          state.t("ourMilk.a2SectionTitle"),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: c.forest),
        ),
        for (final p
            in state.i18n?.strings("ourMilk.a2Paras") ?? const <String>[])
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(p, style: const TextStyle(height: 1.45)),
          ),
        const SizedBox(height: 16),
        Text(
          state.t("ourMilk.chooseTitle"),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: c.forest),
        ),
        Text("• ${state.t("ourMilk.chooseCow")}"),
        Text("• ${state.t("ourMilk.chooseBuf")}"),
        Text("• ${state.t("ourMilk.chooseBoth")}"),
        const SizedBox(height: 16),
        Text(state.t("ourMilk.priceNote")),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onOrder,
          child: Text(state.t("ourMilk.priceCta")),
        ),
      ],
    );
  }
}

class FarmScreen extends StatelessWidget {
  const FarmScreen({super.key, required this.state});
  final FarmState state;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).brightness == Brightness.dark
        ? FarmColors.dark
        : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          state.t("ourFarm.title"),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: c.forest),
        ),
        Text(state.t("ourFarm.intro"), style: TextStyle(color: c.muted)),
        const SizedBox(height: 16),
        Text(
          state.t("ourFarm.sahiwalTitle"),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: c.forest),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            "assets/images/sahiwal-natural.webp",
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: state.t("ourFarm.sahiwalTitle"),
          ),
        ),
        const SizedBox(height: 12),
        for (final p
            in state.i18n?.strings("ourFarm.sahiwalBody") ?? const <String>[])
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(p)),
        const SizedBox(height: 20),
        Text(
          state.t("ourFarm.murrahTitle"),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: c.forest),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            "assets/images/murrah-natural.webp",
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            semanticLabel: state.t("ourFarm.murrahTitle"),
          ),
        ),
        const SizedBox(height: 12),
        for (final p
            in state.i18n?.strings("ourFarm.murrahBody") ?? const <String>[])
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(p)),
        const SizedBox(height: 16),
        Text(
          state.t("ourFarm.practicesTitle"),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: c.forest),
        ),
        for (final p
            in state.i18n?.maps("ourFarm.practices") ??
                const <Map<String, dynamic>>[])
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
    final c = Theme.of(context).brightness == Brightness.dark
        ? FarmColors.dark
        : FarmColors.light;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          state.t("faq.title"),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: c.forest),
        ),
        const SizedBox(height: 8),
        for (final item
            in state.i18n?.maps("faq.items") ?? const <Map<String, dynamic>>[])
          ExpansionTile(
            title: Text("${item["q"]}"),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text("${item["a"]}"),
              ),
            ],
          ),
      ],
    );
  }
}
