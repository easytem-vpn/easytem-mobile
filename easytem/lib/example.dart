import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:openvpn_flutter/openvpn_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late OpenVPN engine;
  VpnStatus? status;
  String? stage;
  bool _granted = true;
  @override
  void initState() {
    engine = OpenVPN(
      onVpnStatusChanged: (data) {
        setState(() {
          status = data;
        });
      },
      onVpnStageChanged: (data, raw) {
        setState(() {
          stage = raw;
        });
      },
    );

    engine.initialize(
      groupIdentifier: "E26GU732TG.id.laskarmedia.easytem",
      providerBundleIdentifier: "id.laskarmedia.easytem.VPNExtension",
      localizedDescription: "VPN by Nizwar",
      lastStage: (stage) {
        setState(() {
          this.stage = stage.name;
        });
      },
      lastStatus: (status) {
        setState(() {
          this.status = status;
        });
      },
    );
    super.initState();
  }

  Future<void> initPlatformState() async {
    String config = "";

    config = await rootBundle.loadString('assets/vpn/prod.ovpn');

    engine.connect(
      config,
      "Brasil",
      username: defaultVpnUsername,
      password: defaultVpnPassword,
      //certIsRequired: true,
    );
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Easy Tem'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(stage?.toString() ?? VPNStage.disconnected.toString()),
              Text(status?.toJson().toString() ?? ""),
              TextButton(
                child: const Text("Start"),
                onPressed: () {
                  initPlatformState();
                },
              ),
              TextButton(
                child: const Text("STOP"),
                onPressed: () {
                  engine.disconnect();
                },
              ),
              if (Platform.isAndroid)
                TextButton(
                  child: Text(_granted ? "Granted" : "Request Permission"),
                  onPressed: () {
                    engine.requestPermissionAndroid().then((value) {
                      setState(() {
                        _granted = value;
                      });
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

const String defaultVpnUsername = "vpnuser";
const String defaultVpnPassword = "vpnuser";

//"103795854"/Germany
//"670841355"/Turkey
//"908636944"/UK
//"392348522"/USA
//"660336267"/Italy