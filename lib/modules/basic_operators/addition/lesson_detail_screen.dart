import 'package:flutter/material.dart';

class LessonDetailScreen extends StatelessWidget {
  final String lessonTitle;
  final String explanation;
  final String videoUrl;
  const LessonDetailScreen({
    Key? key,
    required this.lessonTitle,
    required this.explanation,
    required this.videoUrl,
  }) : super(key: key);
  // ... existing code ...
}
