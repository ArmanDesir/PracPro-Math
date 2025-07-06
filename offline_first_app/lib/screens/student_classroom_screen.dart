import 'package:flutter/material.dart';
import '../models/classroom.dart';
import '../models/content.dart';
import '../services/content_service.dart';

class StudentClassroomScreen extends StatefulWidget {
  final Classroom classroom;
  const StudentClassroomScreen({super.key, required this.classroom});

  @override
  State<StudentClassroomScreen> createState() => _StudentClassroomScreenState();
}

class _StudentClassroomScreenState extends State<StudentClassroomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentService _contentService = ContentService();
  List<Content> _contentList = [];
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoadingContent = true);
    try {
      _contentList = await _contentService.getContentByClassroom(
        widget.classroom.id,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load content: $e')));
    } finally {
      setState(() => _isLoadingContent = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Classroom: ${widget.classroom.name}'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.book), text: 'Lessons'),
            Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
            Tab(icon: Icon(Icons.fitness_center), text: 'Exercises'),
          ],
        ),
      ),
      body:
          _isLoadingContent
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildContentTab(ContentType.lesson, 'Lessons'),
                  _buildContentTab(ContentType.quiz, 'Quizzes'),
                  _buildContentTab(ContentType.exercise, 'Exercises'),
                ],
              ),
    );
  }

  Widget _buildContentTab(ContentType contentType, String title) {
    final filteredContent =
        _contentList.where((content) => content.type == contentType).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Classroom info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.classroom.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Code: ${widget.classroom.code ?? ''}'),
                  if (widget.classroom.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.classroom.description),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Content list
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredContent.length} items',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (filteredContent.isEmpty)
            _buildEmptyState(contentType)
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredContent.length,
              itemBuilder: (context, index) {
                final content = filteredContent[index];
                return _buildContentCard(content);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ContentType contentType) {
    IconData icon;
    String message;
    Color color;

    switch (contentType) {
      case ContentType.lesson:
        icon = Icons.book_outlined;
        message = 'No lessons uploaded yet';
        color = Colors.blue;
        break;
      case ContentType.quiz:
        icon = Icons.quiz_outlined;
        message = 'No quizzes available yet';
        color = Colors.purple;
        break;
      case ContentType.exercise:
        icon = Icons.fitness_center_outlined;
        message = 'No exercises assigned yet';
        color = Colors.orange;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: Color.alphaBlend(
                color.withAlpha((0.5 * 255).toInt()),
                Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your teacher will upload content here soon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(Content content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.alphaBlend(
            _getContentColor(content.type).withAlpha((0.1 * 255).toInt()),
            Colors.white,
          ),
          child: Icon(
            _getContentIcon(content.type),
            color: _getContentColor(content.type),
          ),
        ),
        title: Text(
          content.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(content.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.file_present, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatFileSize(content.fileSize),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(content.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _downloadContent(content),
        ),
      ),
    );
  }

  void _downloadContent(Content content) {
    // TODO: Implement PDF download/viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${content.title}...'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // TODO: Open PDF viewer
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('PDF viewer coming soon!')));
          },
        ),
      ),
    );
  }

  Color _getContentColor(ContentType type) {
    switch (type) {
      case ContentType.lesson:
        return Colors.blue;
      case ContentType.quiz:
        return Colors.purple;
      case ContentType.exercise:
        return Colors.orange;
    }
  }

  IconData _getContentIcon(ContentType type) {
    switch (type) {
      case ContentType.lesson:
        return Icons.book;
      case ContentType.quiz:
        return Icons.quiz;
      case ContentType.exercise:
        return Icons.fitness_center;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
