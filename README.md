--- README.md ---

Reversed Minesweeper (Flutter)

Overview
Reversed Minesweeper is a Flutter-based board game where you place pieces on a grid while avoiding hidden bombs. The twist: every 10 seconds, a random hidden bomb auto-explodes. Real-time BTC price events can add “magic bombs” when the integer price is divisible by 5, up to a maximum cap.

Features

10x10 board by default with selectable sizes (8x8, 10x10, 12x12).
Drag-and-drop pieces onto empty squares; occupied drops snap back.
Hidden bombs: dropping on one discovers it (counter increments, bomb removed).
Auto-explosions every 10 seconds (hidden → exploded).
Magic bombs from Binance BTCUSDT ticker (integer price divisible by 5), capped by maxBombs.
Smooth UI:
Discovery and explosion animations.
Haptic feedback on bomb events.
Live countdown to next explosion.
Game Over overlay with Play Again.
Robust:
Bloc-based game logic and unit tests.
Binance websocket parsing supports single/combined stream.
Auto-reconnect on websocket disconnects.
Game Rules

Board: rows x cols grid (default 10x10).
Pieces: placed in non-bomb cells; one piece per cell.
Drag-and-Drop:
Drop on an empty cell to move a piece.
Drop on a hidden bomb to discover it (bomb removed; piece stays).
Drop on an occupied cell is rejected; the piece returns to origin.
Timer: every 10s a random hidden bomb auto-explodes.
Magic Bombs: whenever BTC price integer (floor) is divisible by 5, add a hidden bomb if under maxBombs.
Game Over: when no hidden bombs remain (all discovered or exploded). Show total discovered bombs.
Tech Stack

Flutter + Dart (Material 3)
State Management: Bloc (flutter_bloc)
WebSocket: web_socket_channel
Equality: Equatable
Project Structure
lib/
core/
models/
position.dart
services/
binance_ticker_service.dart
game/
bloc/
game_bloc.dart
game_event.dart
game_state.dart
ui/
screens/
game_page.dart
widgets/
board_grid.dart
piece_drag_data.dart
main.dart

Setup

Prerequisites

Flutter SDK (3.x recommended)
Dart SDK (bundled with Flutter)
Android Studio/Xcode for platform toolchains
Install

flutter pub get
Run

Android: flutter run -d android
iOS: flutter run -d ios
Web (optional): flutter run -d chrome Notes:
INTERNET permission is included by default in Flutter templates for Android; no extra iOS ATS config is needed for wss.
Tests

Unit tests for GameBloc:
flutter test
Controls

AppBar:
Grid icon: choose board size (8x8, 10x10, 12x12).
Refresh: reset with defaults.
Header shows counters and next explosion countdown.
Board:
Drag pieces; drop onto cells.
In debug mode, hidden bombs are visualized with a small red dot.
Implementation Notes

GameBloc enforces:
Pieces never overlap and never spawn on bombs.
Game Over when hiddenBombs is empty.
Price updates are deduped by integer value to avoid repeated magic bomb triggers.
BinanceTickerService:
Parses both single and combined stream shapes.
Auto-reconnect with exponential backoff.
Animations:
Discovery pulse and explosion burst overlays.
Non-blocking Game Over overlay.
Haptics on discovery (heavy) and auto-explosion (medium).
Config

No external secrets required.
Uses Binance public websocket wss://stream.binance.com:9443/ws with SUBSCRIBE payload for btcusdt@ticker.
Known Trade-offs / Future Work

Social authentication (Google/Apple/Facebook) not included (optional bonus).
Countdown pause/resume on app lifecycle can be added (skipped intentionally).
Additional polish: piece slide animation (intentionally omitted due to drag stability preference).
License
MIT (or your preferred license)

--- end README.md ---