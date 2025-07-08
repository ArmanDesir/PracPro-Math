import 'package:flutter/material.dart';

class GameTheme {
  static const Color primary = Color(0xFF7C4DFF);
  static const Color accent = Color(0xFFFFC107);
  static const Color correct = Color(0xFF4CAF50);
  static const Color wrong = Color(0xFFE57373);
  static const Color background = Color(0xFFF3E5F5);
  static const Color tile = Color(0xFFD1C4E9);
  static const Color tileActive = Color(0xFFB39DDB);
  static const Color tileBank = Color(0xFFFFF176);
  static const Color mascot = Color(0xFF00B8D4);

  static const double borderRadius = 18.0;

  static const TextStyle bigNumber = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primary,
    fontFamily: 'ComicNeue',
  );
  static const TextStyle tileText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primary,
    fontFamily: 'ComicNeue',
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'ComicNeue',
  );
  static const TextStyle mascotText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: mascot,
    fontFamily: 'ComicNeue',
  );
  static const TextStyle hintText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: accent,
    fontFamily: 'ComicNeue',
  );
}
