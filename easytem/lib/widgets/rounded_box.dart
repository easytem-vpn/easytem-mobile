import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/location_screen.dart';

class RoundedBox extends StatelessWidget {

  final String country;
  final Widget icon;

  const RoundedBox(
    {super.key,
    required this.country,
    required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => LocationScreen()),
      borderRadius: BorderRadius.circular(20), // For the InkWell ripple effect
      child: Container(
        width: 280,
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 53, 82, 98),
          borderRadius: BorderRadius.circular(25), // Rounded corners
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: icon,
            ),

            Text(
              country,
              style: const TextStyle(
                color: Colors.white30,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ), 
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
          ],
        ),
      ),
    );
  }
}