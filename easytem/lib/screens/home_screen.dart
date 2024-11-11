import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../main.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import '../widgets/rounded_box.dart';
import 'network_test_screen.dart';

import 'package:openvpn_flutter/openvpn_flutter.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VpnEngine.initialize();
    });
  }

  final _controller = Get.put(HomeController());

  String _formatBytes(String bytes) {
    try {
      final numBytes = double.parse(bytes.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (numBytes < 1024) return '${numBytes.toStringAsFixed(2)} B';
      if (numBytes < 1024 * 1024) return '${(numBytes / 1024).toStringAsFixed(2)} KB';
      if (numBytes < 1024 * 1024 * 1024) return '${(numBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      if (numBytes < 1024 * 1024 * 1024 * 1024) return '${(numBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
      return '${(numBytes / (1024 * 1024 * 1024 * 1024)).toStringAsFixed(2)} TB';
    } catch (e) {
      return '0 B';
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.sizeOf(context);

    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      if (_controller.vpnState.value != event) {
        _controller.vpnState.value = event;
      }
    }, onError: (e) {
      print("VPN state error: $e");
    });

    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.text_justifyleft),
        title: const Text('Easy TEM'),
        actions: [
          IconButton(
              padding: const EdgeInsets.only(right: 8),
              onPressed: () => Get.to(() => const NetworkTestScreen()),
              icon: const Icon(
                CupertinoIcons.question_circle,
                size: 27,
              )),
        ],
      ),

      //body
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        //vpn button
        Obx(() => _vpnButton()),

        StreamBuilder<VpnStatus?>(
            initialData: VpnStatus(),
            stream: VpnEngine.vpnStatusSnapshot(),
            builder: (context, snapshot) => Container(
                  width: double.infinity,
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //download
                    HomeCard(
                        title: _formatBytes(snapshot.data?.byteIn ?? '0'),
                        icon: const Icon(Icons.arrow_downward,
                              size: 38, color: Colors.greenAccent),
                        rtl: true,
                        ),

                    //upload
                    HomeCard(
                        title: _formatBytes(snapshot.data?.byteOut ?? '0'),
                        icon: const Icon(Icons.arrow_upward,
                              size: 38, color: Colors.redAccent),
                        ),
                  ],
                ),
          )),

        Center(
          child: Container(
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
              Image.asset(
              'assets/images/world_map.png',
                fit: BoxFit.cover,
              ),
              CustomPaint(
                painter: _controller.locationPainter,
                size: const Size(double.infinity, 200),
              ),
              ],
            ),
          ),
        ),

        Obx(
        () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //country flag
              RoundedBox(
                  country: _controller.vpn.value.countryLong.isEmpty
                      ? 'Country'
                      : _controller.vpn.value.countryLong,

                  icon: _controller.vpn.value.countryShort.isEmpty
                  ? const Icon(Icons.vpn_lock_rounded, size: 45, color: Colors.white60)
                  : Image.asset('assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png',
                    width: 45,
                    height:25,
                  )
                ),
            ],
          ),
        ),

        const SizedBox(height: 10)
          
      ]),
    );
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () => _controller.connectToVpn(),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.1)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 4),
                        //icon
                        Obx(() => CountDownTimer(
                                  startTimer:
                                  _controller.vpnState.value == VpnEngine.vpnConnected)),

                        const SizedBox(height: 2),

                        //text
                        Text(
                          _controller.getButtonText,
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        Container(
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 3, 32, 48)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),

        ],
      );

}
