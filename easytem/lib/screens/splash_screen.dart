import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';

import '../main.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5000), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      //navigate to home
      Get.off(() => HomeScreen());
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          //app logo
          Positioned(
              left: mq.width * .1,
              top: mq.height * .2,
              width: mq.width * .8,
              child: Image.asset('assets/images/logo.png')),

          //label
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text(
                '2N5 Global Enabler',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.white30, 
                    letterSpacing: 1),
              ))
        ],
      ),
    );
  }
}
