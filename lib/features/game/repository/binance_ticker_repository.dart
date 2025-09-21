import 'dart:async';

abstract class BinanceTickerRepository {
  final _controller = StreamController<int>.broadcast();

  Stream<int> get priceIntStream => _controller.stream;

  void connect();

  Future<void> close();
}
