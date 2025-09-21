import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reversed_minesweeper/features/game/repository/binance_ticker_repository_impl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MockWebSocketChannel extends Mock implements WebSocketChannel {}

class MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('BinanceTickerService parsing', () {
    late BinanceTickerRepositoryImpl service;

    setUp(() {
      service = BinanceTickerRepositoryImpl();
    });

    test('extractLastPriceInt parses combined stream payload', () {
      final msg = jsonEncode({
        "stream": "btcusdt@ticker",
        "data": {"c": "67890.99"},
      });
      final out = service.extractLastPriceInt(msg);
      expect(out, 67890);
    });

    test('extractLastPriceInt parses single stream payload', () {
      final msg = jsonEncode({"e": "24hrTicker", "c": "43210.4"});
      final out = service.extractLastPriceInt(msg);
      expect(out, 43210);
    });

    test('extractLastPriceInt ignores subscribe ack with result', () {
      final msg = jsonEncode({"result": null, "id": 1});
      final out = service.extractLastPriceInt(msg);
      expect(out, isNull);
    });
  });

  group('BinanceTickerService stream and reconnect', () {
    test('emits integer prices and re-subscribes after disconnect', () async {
      // First channel
      final ch1 = MockWebSocketChannel();
      final sink1 = MockWebSocketSink();
      final inCtrl1 = StreamController<dynamic>();

      when(() => ch1.stream).thenAnswer((_) => inCtrl1.stream);
      when(() => ch1.sink).thenReturn(sink1);
      when(() => sink1.add(any())).thenReturn(null);
      when(() => sink1.close()).thenAnswer((_) async {});

      // Second channel
      final ch2 = MockWebSocketChannel();
      final sink2 = MockWebSocketSink();
      final inCtrl2 = StreamController<dynamic>();

      when(() => ch2.stream).thenAnswer((_) => inCtrl2.stream);
      when(() => ch2.sink).thenReturn(sink2);
      when(() => sink2.add(any())).thenReturn(null);
      when(() => sink2.close()).thenAnswer((_) async {});

      // Connector returns ch1 then ch2
      var call = 0;
      WebSocketChannel connector(Uri _) {
        call++;
        return call == 1 ? ch1 : ch2;
      }

      // TimerFactory executes immediately (no waiting)
      Timer timerFactory(Duration _, void Function() cb) {
        cb();
        return Timer(Duration.zero, () {}); // dummy
      }

      final service = BinanceTickerRepositoryImpl(
        connector: connector,
        timerFactory: timerFactory,
      );

      final events = <int>[];
      final sub = service.priceIntStream.listen(events.add);

      service.connect();

      // Should subscribe on first connect
      verify(
        () => sink1.add(
          any(
            that: predicate((dynamic s) {
              try {
                final m = jsonDecode(s as String);
                return m is Map &&
                    m['method'] == 'SUBSCRIBE' &&
                    (m['params'] as List).contains('btcusdt@ticker');
              } catch (_) {
                return false;
              }
            }),
          ),
        ),
      ).called(1);

      // Push a price on ch1
      inCtrl1.add(
        jsonEncode({
          "data": {"c": "30005.9"},
        }),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [30005]);

      // Close ch1 -> triggers reconnect -> ch2 should subscribe
      await inCtrl1.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      verify(
        () => sink2.add(
          any(
            that: predicate((dynamic s) {
              try {
                final m = jsonDecode(s as String);
                return m is Map && m['method'] == 'SUBSCRIBE';
              } catch (_) {
                return false;
              }
            }),
          ),
        ),
      ).called(1);

      // Push a price on ch2
      inCtrl2.add(jsonEncode({"c": "29999.1"}));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [30005, 29999]);

      await sub.cancel();
      await service.close();
      await inCtrl2.close();
    });
  });
}
