import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:meta/meta.dart'; // ADD this import
import 'package:reversed_minesweeper/features/game/repository/binance_ticker_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef WebSocketConnector = WebSocketChannel Function(Uri uri);
typedef TimerFactory =
    Timer Function(Duration duration, void Function() callback);

class BinanceTickerRepositoryImpl implements BinanceTickerRepository {
  static const _url = 'wss://stream.binance.com:9443/ws';
  static const _subscribePayload = {
    "method": "SUBSCRIBE",
    "params": ["btcusdt@ticker"],
    "id": 1,
  };

  final WebSocketConnector _connector;
  final TimerFactory _timerFactory;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  final _controller = StreamController<int>.broadcast();

  bool _manuallyClosed = false;
  int _reconnectAttempt = 0;
  Timer? _reconnectTimer;

  BinanceTickerRepositoryImpl({
    WebSocketConnector? connector,
    TimerFactory? timerFactory,
  }) : _connector = connector ?? ((uri) => WebSocketChannel.connect(uri)),
       _timerFactory = timerFactory ?? ((d, cb) => Timer(d, cb));

  @override
  Stream<int> get priceIntStream => _controller.stream;

  @override
  void connect() {
    if (_channel != null || _reconnectTimer != null) return;
    _manuallyClosed = false;
    _open();
  }

  void _open() {
    try {
      _channel = _connector(Uri.parse(_url));
      _channel!.sink.add(jsonEncode(_subscribePayload));
      _sub = _channel!.stream.listen(
        (message) {
          final priceInt = extractLastPriceInt(message);
          if (priceInt != null) _controller.add(priceInt);
        },
        onError: (_) => _handleDisconnect(),
        onDone: _handleDisconnect,
        cancelOnError: true,
      );
      _reconnectAttempt = 0;
    } catch (_) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _sub?.cancel();
    _sub = null;
    _channel = null;

    if (_manuallyClosed) return;

    final delaySeconds = min(30, 1 << (_reconnectAttempt.clamp(0, 5)));
    _reconnectAttempt++;

    _reconnectTimer?.cancel();
    _reconnectTimer = _timerFactory(Duration(seconds: delaySeconds), () {
      _reconnectTimer = null;
      if (_manuallyClosed) return;
      _open();
    });
  }

  @visibleForTesting
  int? extractLastPriceInt(dynamic message) {
    final dynamic decoded = message is String ? jsonDecode(message) : message;
    if (decoded is! Map) return null;
    if (decoded.containsKey('result')) return null;
    final payload = (decoded['data'] is Map) ? decoded['data'] : decoded;
    final c = payload['c'];
    if (c is String) {
      final price = double.tryParse(c);
      if (price != null) return price.floor();
    }
    return null;
  }

  @override
  Future<void> close() async {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
    await _controller.close();
  }
}
