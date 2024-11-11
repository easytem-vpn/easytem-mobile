import 'package:flutter/material.dart';

import '../main.dart';

//card to represent status in home screen
class HomeCard extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool rtl;

  const HomeCard(
      {super.key,
      required this.title,
      required this.icon,
      this.rtl = false});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
        width: mq.width * .45,
        child: Row(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            //icon
            const SizedBox(width: 20),

            icon,

            //for adding some space
            const SizedBox(width: 6),

            //title
            Text(title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),

          ],
          
        ));
  }
}
