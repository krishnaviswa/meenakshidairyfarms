import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

import "api.dart";
import "models.dart";
import "screens/home_screen.dart";
import "screens/more_screens.dart";
import "screens/order_screen.dart";
import "state.dart";
import "theme.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MeenakshiApp());
}

class MeenakshiApp extends StatefulWidget {
  const MeenakshiApp({super.key});

  @override
  State<MeenakshiApp> createState() => _MeenakshiAppState();
}

class _MeenakshiAppState extends State<MeenakshiApp> {
  final FarmState state = FarmState();

  @override
  void initState() {
    super.initState();
    state.boot();
    state.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    state.removeListener(_onChange);
    state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Meenakshi Dairy Farms",
      debugShowCheckedModeBanner: false,
      theme: farmTheme(Brightness.light),
      darkTheme: farmTheme(Brightness.dark),
      themeMode: state.themeMode,
      locale: Locale(state.lang),
      supportedLocales: const [Locale("en"), Locale("hi"), Locale("ta")],
      home: state.loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : FarmShell(state: state),
    );
  }
}

class FarmShell extends StatefulWidget {
  const FarmShell({super.key, required this.state});
  final FarmState state;

  @override
  State<FarmShell> createState() => _FarmShellState();
}

class _FarmShellState extends State<FarmShell> {
  FarmOrder? prefill;
  int extra = 0; // 0 none, 1 milk, 2 farm, 3 faq

  FarmState get state => widget.state;

  void _goOrder([FarmOrder? order]) {
    setState(() {
      prefill = order;
      extra = 0;
    });
    state.setTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(state: state, onOrder: _goOrder),
      OrderScreen(key: ValueKey(prefill?.ref ?? "new"), state: state, prefill: prefill),
      AccountScreen(state: state, onReorder: _goOrder),
    ];
    final extras = [
      MilkScreen(state: state, onOrder: _goOrder),
      FarmScreen(state: state),
      FaqScreen(state: state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.t("common.brand"), style: const TextStyle(fontSize: 18)),
            Text(state.t("common.brandSub"), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.secondary)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: state.t("common.langLabel"),
            onSelected: state.setLang,
            itemBuilder: (_) => const [
              PopupMenuItem(value: "en", child: Text("EN")),
              PopupMenuItem(value: "hi", child: Text("हिंदी")),
              PopupMenuItem(value: "ta", child: Text("தமிழ்")),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(child: Text(state.lang.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700))),
            ),
          ),
          IconButton(
            tooltip: state.t("common.themeToggle"),
            onPressed: state.cycleTheme,
            icon: Icon(state.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
          ),
          PopupMenuButton<int>(
            onSelected: (v) => setState(() => extra = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: 1, child: Text(state.t("nav.ourMilk"))),
              PopupMenuItem(value: 2, child: Text(state.t("nav.ourFarm"))),
              PopupMenuItem(value: 3, child: Text(state.t("nav.faq"))),
              PopupMenuItem(
                value: 0,
                child: Text(displayPhone(state.catalog?.settings.waNumber ?? "919087282939")),
                onTap: () => launchUrl(
                  Uri.parse("https://wa.me/${state.catalog?.settings.waNumber ?? "919087282939"}"),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
      body: extra == 0 ? pages[state.tab] : extras[extra - 1],
      bottomNavigationBar: NavigationBar(
        selectedIndex: extra == 0 ? state.tab : 0,
        onDestinationSelected: (i) {
          setState(() => extra = 0);
          state.setTab(i);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: state.t("nav.home")),
          NavigationDestination(icon: const Icon(Icons.local_drink_outlined), selectedIcon: const Icon(Icons.local_drink), label: state.t("nav.order")),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: state.t("nav.account")),
        ],
      ),
    );
  }
}
