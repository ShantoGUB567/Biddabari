import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  final RxBool isOnline = true.obs;
  final RxBool hasCheckedInitialState = false.obs;

  // Stream controller to notify listeners when connection is restored
  final _onReconnectedController = StreamController<void>.broadcast();
  Stream<void> get onReconnected => _onReconnectedController.stream;

  Future<ConnectivityService> init() async {
    await _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
    return this;
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results, isInitialCheck: true);
    } catch (e) {
      debugPrint('Connectivity initial check error: $e');
      isOnline.value = true; // Fallback to optimistic online
    } finally {
      hasCheckedInitialState.value = true;
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results, {bool isInitialCheck = false}) {
    final wasOffline = !isOnline.value;
    final currentlyOnline = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );

    isOnline.value = currentlyOnline;

    // If transitioned from offline to online and it's not the initial check, emit reconnected event
    if (!isInitialCheck && wasOffline && currentlyOnline) {
      debugPrint('[ConnectivityService] Connection restored! Triggering auto-retry.');
      _onReconnectedController.add(null);
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    _onReconnectedController.close();
    super.onClose();
  }
}
