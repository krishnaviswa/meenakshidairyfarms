# Meenakshi Dairy Farms — customer app

Flutter app (Android + iOS) for the same catalog and WhatsApp order flow as the website. Prices come from Postgres when the API is reachable; otherwise the flyer fallback (₹40 / ₹45 per half litre) is used.

## Run locally

```bash
# website + database first, so the app can hit /api/catalog
docker compose up -d db
cd web && npm run dev

cd ../app
flutter pub get
flutter run
```

Android emulator talks to `http://10.0.2.2:4321`. iOS simulator uses `http://127.0.0.1:4321`.

A release APK on a real phone will not see your laptop. It still opens WhatsApp with a complete order. To point a build at a hosted API:

```bash
flutter build apk --release --dart-define=API_BASE=https://your-host
```

## Download phone builds

GitHub Actions upload artifacts after each push that touches `app/`:

1. Open the repo on GitHub → **Actions**
2. Run **Android APK** or **iOS IPA** (or wait for the push workflow)
3. Download the artifact at the bottom of the run

**Android:** install `app-release.apk` (allow unknown sources).

**iOS:** the IPA is unsigned. A real iPhone will not install it until you re-sign it (Apple Developer Ad Hoc profile, or AltStore / Sideloadly with your Apple ID).
