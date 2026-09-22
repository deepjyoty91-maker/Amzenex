import 'dart:async';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
  void toggleSimulatedOffline(bool isOffline);
  bool get isSimulatedOffline;
}

class NetworkInfoImpl implements NetworkInfo {
  bool _simulatedOffline = false;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async {
    return !_simulatedOffline;
  }

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  void toggleSimulatedOffline(bool isOffline) {
    _simulatedOffline = isOffline;
    _controller.add(!_simulatedOffline);
  }

  @override
  bool get isSimulatedOffline => _simulatedOffline;

  void dispose() {
    _controller.close();
  }
}
