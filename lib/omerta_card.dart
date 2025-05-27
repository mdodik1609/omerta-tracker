import 'package:flutter/material.dart';
import 'initials_avatar.dart';

class OmertaCard extends StatelessWidget {
  final String title;
  final String initials;
  final int value;
  final String description;
  final double width;
  final double height;

  const OmertaCard({
    required this.title,
    required this.initials,
    required this.value,
    required this.description,
    this.width = 110,
    this.height = 170,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: const Color(0xFFD2B48C),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                '$value',
                style: TextStyle(
                  fontFamily: 'OmertaFont',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(child: InitialsAvatar(initials, radius: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OmertaFont',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OmertaFont',
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 