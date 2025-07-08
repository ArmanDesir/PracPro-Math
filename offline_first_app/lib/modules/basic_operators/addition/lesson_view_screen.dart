import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'quiz_screen.dart';

class LessonViewScreen extends StatefulWidget {
  final String lessonTitle;
  final String explanation;
  final String videoUrl;
  final List<dynamic> quiz;
  const LessonViewScreen({
    Key? key,
    required this.lessonTitle,
    required this.explanation,
    required this.videoUrl,
    required this.quiz,
  }) : super(key: key);

  @override
  State<LessonViewScreen> createState() => _LessonViewScreenState();
}

class _LessonViewScreenState extends State<LessonViewScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl) ?? '',
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lessonTitle),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.lessonTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(widget.explanation, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
              progressColors: const ProgressBarColors(
                playedColor: Colors.blue,
                handleColor: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.quiz),
              label: const Text('Take Quiz'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => QuizScreen(
                          questions: widget.quiz.cast<Map<String, dynamic>>(),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.videogame_asset),
              label: const Text('Play Game'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: () => Navigator.pushNamed(context, '/addition/games'),
            ),
          ],
        ),
      ),
    );
  }
}
