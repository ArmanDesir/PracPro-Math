import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'lesson_view_screen.dart';

class LessonListScreen extends StatelessWidget {
  const LessonListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addition Lessons'),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
        itemCount: additionLessons.length,
        itemBuilder: (context, index) {
          final lesson = additionLessons[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.orange[50],
            child: ListTile(
              title: Text(
                lesson['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                lesson['explanation'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => LessonViewScreen(
                          lessonTitle: lesson['title'],
                          explanation: lesson['explanation'],
                          videoUrl: lesson['videoUrl'],
                          quiz: lesson['quiz'],
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
