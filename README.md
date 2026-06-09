# Tawakad (توكد)

Tawakad is a cross-platform Flutter mobile app that helps users prepare for different destinations by creating packing lists, receiving smart item suggestions, scanning BLE-tagged belongings, viewing scheduled lists in a calendar, and earning rewards for completed lists.

The app is built with Flutter, Firebase, BLE scanning, and a FastAPI AI backend.

---

## Run Instructions

### 1. Install Flutter packages

From the main project folder:

```bash
flutter pub get
```

### 2. Start the AI backend

Open a terminal in the project folder, then run:

```bash
cd toki_backend
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

The backend must stay running while testing AI recommendations.

### 3. Choose the correct backend URL

| Device           | Backend URL                  |
| ---------------- | ---------------------------- |
| Chrome           | `http://127.0.0.1:8000`      |
| Android Emulator | `http://10.0.2.2:8000`       |
| Physical Phone   | `http://YOUR_LAPTOP_IP:8000` |

For a physical phone, the phone and laptop must be connected to the same Wi-Fi.

To find your laptop IP on Windows:

```bash
ipconfig
```

Use the IPv4 address from the Wi-Fi adapter.

### 4. Run the Flutter app

```bash
flutter run
```

For Chrome testing:

```bash
flutter run -d chrome
```

Chrome is useful for UI testing, but a physical phone is needed for BLE scanning and full mobile behavior.

---

## Device Requirements

A physical Android or iOS phone is recommended because these features need real mobile hardware:

- BLE scanning
- BLE tag mapping
- Nearby/missing item detection
- Bluetooth and location permissions
- Calendar-related mobile behavior

---

## Main Features

- User sign-up, sign-in, email verification, password reset, and Google Sign-In.
- User onboarding for personalization.
- Destination-based packing lists.
- Add, edit, check, and organize list items.
- AI smart suggestions based on list context.
- BLE tag linking and scanning.
- Calendar view for scheduled lists.
- Rewards and badges after completing lists.
- Arabic-first interface with RTL support.

---

## Screenshots

Add the screenshots inside:

```text
docs/screenshots/
```

Then use these image links:

| Feature            | Screenshot                                                 |
| ------------------ | ---------------------------------------------------------- |
| Smart Suggestions  | ![Smart Suggestions](docs/screenshots/ai-suggestions.jpeg) |
| Rewards            | ![Rewards](docs/screenshots/rewards.jpeg)                  |
| BLE Signal Mapping | ![BLE Signal Mapping](docs/screenshots/ble-signal.jpeg)    |
| List View          | ![List View](docs/screenshots/list-view.jpeg)              |
| Calendar           | ![Calendar](docs/screenshots/calendar.jpeg)                |
| Create List        | ![Create List](docs/screenshots/create-list.jpeg)          |

---

## AI Recommendation Feature

The AI backend suggests items based on the list context, such as destination, event type, role, gender, time period, and weather.

Example: for a gym list, the app may suggest items such as a water bottle, towel, athletic shoes, snack, and deodorant.

---

## BLE Scanning Feature

Tawakad can connect personal items to BLE tags. After mapping a tag to an item, the app can scan nearby BLE signals and help detect whether the tagged item is nearby or missing.

To test BLE:

1. Use a physical phone.
2. Turn on Bluetooth.
3. Allow Bluetooth and location permissions.
4. Keep the BLE tag nearby.
5. Run the app on the phone.
6. Open the BLE mapping/scanning feature.

---

## Firebase

The project uses Firebase for authentication and user data storage.

Required Firebase setup:

- Firebase Authentication enabled.
- Email/password provider enabled.
- Google provider enabled if Google Sign-In is used.
- Cloud Firestore enabled.
- `lib/firebase_options.dart` generated using FlutterFire CLI.

Do not place private keys, passwords, or personal configuration IDs inside the README.

---

## Common Issues

### Backend works on Chrome but not on phone

Check that:

- The backend is running with `--host 0.0.0.0`.
- The phone and laptop are on the same Wi-Fi.
- The app uses the laptop IP address, not `127.0.0.1`.
- Firewall is not blocking port `8000`.

### BLE devices do not appear

Check that:

- You are using a real phone.
- Bluetooth is enabled.
- Required permissions are allowed.
- The BLE tag is powered on and close to the phone.

---

## Demo Flow

1. Start the AI backend.
2. Run the app on a physical phone.
3. Sign up or sign in.
4. Complete onboarding.
5. Create a list.
6. Open smart suggestions.
7. Map a BLE tag to an item.
8. Scan nearby BLE signals.
9. View scheduled lists in the calendar.
10. Complete the list and show the reward badge.

---

## Summary

Tawakad combines smart packing lists, AI recommendations, BLE item scanning, calendar organization, and rewards to help users leave prepared and avoid forgetting important belongings.
