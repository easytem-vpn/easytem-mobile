import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;

  final vpnState = VpnEngine.vpnDisconnected.obs;

  final locationPainter = LocationPainter();

  void connectToVpn() async {
    if (vpn.value.openVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Change Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      //data = const Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      //config = const Utf8Decoder().convert(data);
      final vpnConfig = VpnConfig(
          country: vpn.value.countryLong,
          username: vpn.value.username,
          password: vpn.value.password,
          config: vpn.value.openVPNConfigDataBase64);

      locationPainter.update(true);
      await VpnEngine.startVpn(vpnConfig);
    } else {
      locationPainter.update(false);
      await VpnEngine.stopVpn();
    }
  }

  // vpn buttons color
  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.red;

      case VpnEngine.vpnConnected:
        return Colors.green;

      default:
        return Colors.orangeAccent;
    }
  }

  // vpn button text
  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'START';

      case VpnEngine.vpnConnected:
        return 'STOP';

      default:
        return 'WAITING';
    }
  }
}

class LocationPainter extends CustomPainter {
  final List<double> brasil = [0.33, 0.53];
  final notifier = ValueNotifier<bool>(false);
  bool isConnected;

  LocationPainter({this.isConnected = false})
      : super(repaint: ValueNotifier<bool>(false));

  void update(bool isConnected) {
    this.isConnected = isConnected;
    notifier.value = !notifier.value;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isConnected
          ? Colors.lightGreenAccent
          : const Color.fromARGB(255, 53, 82, 98)
      ..style = PaintingStyle.fill;

    // Adjust these coordinates based on your desired location
    // x: 0.0 to 1.0 (left to right)
    // y: 0.0 to 1.0 (top to bottom)
    final double x = size.width * brasil[0]; // Center horizontally
    final double y = size.height * brasil[1]; // Center vertically

    // Draw a circle point
    canvas.drawCircle(Offset(x, y), 4, paint);
  }

  @override
  bool shouldRepaint(covariant LocationPainter oldDelegate) {
    return oldDelegate.isConnected != isConnected;
  }
}
