# Reversed Minesweeper (Flutter)

**Reversed Minesweeper** is a Flutter-based board game where you place pieces on a grid while avoiding hidden bombs.  
The twist: every 10 seconds, a random hidden bomb auto-explodes. Real-time BTC price events can add *magic bombs* when the integer price is divisible by 5, up to a maximum cap.

---

## Features

### Core Gameplay
- 10×10 board by default; quick selector for 8×8 and 12×12.
- Drag-and-drop pieces onto empty squares; occupied drops snap back.
- Drop on a hidden bomb to discover it (bomb removed, discovered count increments); the piece stays.
- Auto-explosion every 10 seconds; game ends when no hidden bombs remain.

### Real-time “Magic Bombs”
- Binance **BTCUSDT** ticker stream.
- Each time the integer price (floor) is divisible by 5, add a hidden bomb (up to a cap).

### UI/UX Polish
- Discovery pulse and auto-explosion burst animations.
- Live countdown to the next auto-explosion (smooth).
- Non-blocking *Game Over* overlay with **Play Again**.
- Haptic feedback on discovery/explosion (device-only).
- Reveal bombs toggle (eye icon) to visualize hidden bombs instantly.
- Each piece displays the number of safe, empty neighboring cells (8-directional).

### Auth (Optional)
- Google Sign-In (iOS/Android).
- “Play as Guest” for instant access without setup.

### Robustness
- Bloc-based game logic.
- O(n) randomized board initialization (single shuffle); pieces never spawn on bombs.
- Binance websocket parsing supports both single and combined stream payloads.
- Auto-reconnect on websocket disconnects with exponential backoff.

### Testing & CI
- Unit tests for `GameBloc`, `AuthCubit/AuthRepository`, `BinanceTickerService`.
- GitHub Actions workflow: analyze, test, and debug APK build.

---

## Game Rules

- **Board**: rows × cols grid (default 10×10).
- **Pieces**: placed in non-bomb cells; one piece per cell.

### Drag-and-Drop
- Drop on an empty cell → piece placed.
- Drop on a hidden bomb → bomb discovered, piece remains.
- Drop on an occupied cell → rejected, piece snaps back.

### Timers & Events
- Every 10 seconds → random hidden bomb auto-explodes.
- Magic Bombs: if BTC price integer divisible by 5, add hidden bomb (if under cap).
- Game Over: when hiddenBombs = 0 (all discovered or exploded). Show total discovered bombs.

---

## Controls

**AppBar**
- Grid icon → choose board size (8×8, 10×10, 12×12).
- Eye icon → reveal/hide hidden bombs.
- Refresh icon → reset with defaults.
- Avatar + logout → appears after Google Sign-In; sign out returns to login.

**Header**
- Shows counters (*Discovered, Exploded, Hidden, Total*) and countdown to next explosion.

**Board**
- Drag a piece and drop onto a cell.
- Pieces display the count of safe, empty neighboring cells (0–8).

---

## Tech Stack

- Flutter + Dart (Material 3)
- State management: **Bloc** (`flutter_bloc`)
- WebSocket: `web_socket_channel`
- Equality: `equatable`
- Auth: `google_sign_in`

---

## Project Structure
```
lib/
  features/
    auth/
      bloc/
        auth_cubit.dart
      repository/
        auth_repository_impl.dart
        auth_repository.dart
      models/
        user_profile.dart
      screens/
        login_page.dart
    game/
      bloc/
        game_bloc.dart
        game_event.dart
        game_state.dart
      screens/
        game_page.dart
      models/
        position.dart
      repository/
        binance_ticker_repository_impl.dart
        binance_ticker_repository.dart
      parts/
        cell.dart
      widgets/
        board_grid.dart
        piece_drag_data.dart
  main.dart
```
# Getting Started

## Prerequisites
- Flutter SDK (stable channel recommended)  
- Dart SDK (bundled with Flutter)  
- Android Studio / Xcode for platform toolchains  
- A device/emulator with internet access (for Binance stream)  

## Install
```bash
flutter pub get

Run
Android: flutter run -d android
iOS: flutter run -d ios
Web (optional): flutter run -d chrome
```
Note: INTERNET permission is included by default in Flutter templates for Android; no extra iOS ATS configuration is needed for wss.

> **Note:** `INTERNET` permission is included by default in Flutter templates for Android.  
> No extra iOS ATS configuration is needed for `wss://`.

---

# Social Login Setup (Optional)

You can always play without login via **Play as Guest**.  
If you want to test Google Sign-In:

## iOS
1. Create an iOS OAuth client in Google Cloud Console:  
   - Go to **APIs & Services > Credentials > Create Credentials > OAuth client ID**  
   - Application type: **iOS**  
   - Bundle ID: your app’s bundle identifier (Xcode → Runner target → General)  

2. Add to `ios/Runner/Info.plist`:
```xml
<key>GIDClientID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.YOUR_CLIENT_ID_PREFIX</string>
    </array>
  </dict>
</array>
```

YOUR_CLIENT_ID_PREFIX is the portion before “.apps.googleusercontent.com”.
3. Clean & run:
```bash
flutter clean
cd ios && pod install && cd ..
flutter run -d ios
```
## Troubleshooting (iOS)

If you see:  
> **“No active configuration. Make sure GIDClientID is set in Info.plist.”**  

Verify:
- `GIDClientID`
- URL scheme
- Bundle ID matches the OAuth client

---

## Android Setup

1. **Find your package name and SHA-1:**
   - Package name: `android/app/build.gradle` (`defaultConfig.applicationId`)
   - Get SHA-1:
     ```bash
     cd android
     ./gradlew signingReport
     ```
     Use the debug variant SHA-1 (or release keystore SHA-1 if building release).

2. **Create an Android OAuth client in Google Cloud Console:**
   - Application type: **Android**
   - Package name: your `applicationId`
   - SHA-1: your debug/release SHA-1
   - Wait 2–5 minutes for propagation

3. **Run:**
   ```bash
   flutter clean
   flutter run -d android

## Troubleshooting (Android)

**Error 10 (DEVELOPER_ERROR) or 12500**  
- Ensure package name and SHA-1 match the OAuth client.  
- For release builds with a different keystore, add that keystore’s SHA-1 as a separate Android OAuth client.  

---

## Binance WebSocket Feed

- **Endpoint:** `wss://stream.binance.com:9443/ws`  
- **Subscribe payload (send after connect):**
```json
{
  "method": "SUBSCRIBE",
  "params": ["btcusdt@ticker"],
  "id": 1
}
```
## Binance WebSocket Feed

Parsing supports both single and combined stream shapes.  
- The last price is read from the **`c`** field (string), floored to an integer.  
- **Magic bombs** are added when that integer is divisible by 5, up to `maxBombs`.  
- Auto-reconnect with exponential backoff on disconnect.  

---

## Testing

Run all tests:  
```bash
flutter test -r expanded
```
## Included Tests

- **GameBloc:** discovery, auto-explosion, occupancy rules, magic bomb addition, game over  
- **Auth:** `AuthCubit` and `AuthRepository` (mocks/fakes for GoogleSignIn)  
- **BinanceTickerService:** parsing (single/combined), stream emission, reconnect behavior (via injected connector/timer)  

---

## Continuous Integration

GitHub Actions workflow: `.github/workflows/flutter_ci.yml`

Runs:
```yaml
- flutter analyze
- flutter test
# optional sanity check: build debug APK
```
## Troubleshooting

- **Haptics not felt:**  
  - Emulators don’t vibrate → test on a physical device  
  - Check device settings (vibration/haptics enabled, DND off)  

- **No Binance updates:**  
  - Check network connectivity/firewalls  
  - Reconnect logic retries automatically; wait a few seconds  

- **Drag-and-drop snapping back:**  
  - Fixed by stabilizing `DragTarget` keys and limiting rebuild scope  
  - If it happens again, provide steps to reproduce  

---

## License

MIT (or your preferred license)  

---

## Notes

- Pieces show the number of safe, empty neighboring cells (not bombs).  
- Use the **eye icon** to reveal hidden bombs for verification.  
- Guest mode allows anyone to evaluate the game without OAuth setup.  
