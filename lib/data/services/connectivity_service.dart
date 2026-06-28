import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service untuk monitor koneksi network
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  StreamController<bool>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get onConnectivityChanged {
    _controller ??= StreamController<bool>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    return _controller!.stream;
  }

  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _controller?.add(!results.contains(ConnectivityResult.none));
    });
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Check current connectivity status
  Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _controller?.close();
  }
}
