import 'dart:async';

import '../models/vpn_config.dart';
import 'package:openvpn_flutter/openvpn_flutter.dart';

class VpnEngine {
  static late OpenVPN engine;
  
  // Singleton instance
  static final VpnEngine _instance = VpnEngine._internal();
  factory VpnEngine() => _instance;
  VpnEngine._internal();

  static Future<void> initialize() async {
    engine = OpenVPN(
      onVpnStatusChanged: (data) {
        _statusController.add(data);
      },
      onVpnStageChanged: (stage, raw) {
        _stageController.add(raw);
      },
    );

    await engine.initialize(
      groupIdentifier: "easytem.2N5.vpn",
      providerBundleIdentifier: "easytem.2N5.VPNExtension",
      localizedDescription: "VPN by EasyTEM",
      lastStage: (stage) => _stageController.add(stage.name),
      lastStatus: (status) => _statusController.add(status),
    );
  }

  // Stream controllers for status and stage
  static final _statusController = StreamController<VpnStatus?>.broadcast();
  static final _stageController = StreamController<String>.broadcast();

  // Expose streams
  static Stream<VpnStatus?> vpnStatusSnapshot() => _statusController.stream;
  static Stream<String> vpnStageSnapshot() => _stageController.stream;

  // Connect method
  static Future<void> startVpn(VpnConfig config) async {

    await engine.connect(
      config.config,
      config.country,
      username: config.username,
      password: config.password,
    );
  }

  // Disconnect method
  static Future<void> stopVpn() async {
    engine.disconnect();
  }

  // Clean up resources
  static void dispose() {
    _statusController.close();
    _stageController.close();
  }

  static const String vpnConnected = "connected";
  static const String vpnDisconnected = "disconnected";
  static const String vpnWaitConnection = "wait_connection";
  static const String vpnAuthenticating = "authenticating";
  static const String vpnReconnect = "reconnect";
  static const String vpnNoConnection = "no_connection";
  static const String vpnConnecting = "connecting";
  static const String vpnPrepare = "prepare";
  static const String vpnDenied = "denied";
}
