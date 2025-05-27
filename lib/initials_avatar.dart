import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  const InitialsAvatar(this.initials, {this.radius = 32, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFD2B48C),
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'OmertaFont',
          fontWeight: FontWeight.bold,
          fontSize: radius,
          color: Colors.black,
        ),
      ),
    );
  }
} 