import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/classroom.dart';
import '../providers/classroom_provider.dart';
import '../models/user.dart';
import '../models/content.dart';
import '../services/content_service.dart';
import 'dart:io';

class ClassroomDetailsScreen extends StatefulWidget {
  final Classroom classroom;
  const ClassroomDetailsScreen({super.key, required this.classroom});

  @override
  State<ClassroomDetailsScreen> createState() => _ClassroomDetailsScreenState();
}

class _ClassroomDetailsScreenState extends State<ClassroomDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ContentService _contentService = ContentService();
  List<Content> _contentList = [];
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Provider.of<ClassroomProvider>(
      context,
      listen: false,
    ).loadClassroomDetails(widget.classroom.id);
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoadingContent = true);
    try {
      _contentList = await _contentService.getContentByClassroom(
        widget.classroom.id,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load content: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingContent = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassroomProvider>(
      builder: (context, provider, _) {
        final classroom = provider.currentClassroom ?? widget.classroom;
        return Scaffold(
          appBar: AppBar(
            title: Text('Classroom: ${classroom.name}'),
            backgroundColor: Colors.green,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.people), text: 'Students'),
                Tab(icon: Icon(Icons.book), text: 'Content'),
              ],
            ),
          ),
          body:
              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStudentsTab(classroom, provider),
                      _buildContentTab(classroom),
                    ],
                  ),
        );
      },
    );
  }

  Widget _buildStudentsTab(Classroom classroom, ClassroomProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    classroom.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Code: ${classroom.code ?? ''}'),
                  if (classroom.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(classroom.description),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Accepted Students (${provider.acceptedStudents.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          provider.acceptedStudents.isEmpty
              ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No students have joined yet.'),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.acceptedStudents.length,
                itemBuilder: (context, idx) {
                  final student = provider.acceptedStudents[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.alphaBlend(
                          Colors.green.withAlpha((0.1 * 255).toInt()),
                          Colors.white,
                        ),
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text(student.email),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed:
                            () =>
                                _showRemoveStudentDialog(classroom.id, student),
                      ),
                    ),
                  );
                },
              ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.pending, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Pending Requests (${provider.pendingStudents.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          provider.pendingStudents.isEmpty
              ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No pending requests.'),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.pendingStudents.length,
                itemBuilder: (context, idx) {
                  final student = provider.pendingStudents[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.alphaBlend(
                          Colors.orange.withAlpha((0.1 * 255).toInt()),
                          Colors.white,
                        ),
                        child: Text(
                          student.name[0].toUpperCase(),
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                      title: Text(student.name),
                      subtitle: Text(student.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () async {
                              await provider.acceptStudent(
                                classroom.id,
                                student.id,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${student.name} accepted!'),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () async {
                              await provider.rejectStudent(
                                classroom.id,
                                student.id,
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${student.name} rejected.'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildContentTab(Classroom classroom) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Classroom Content',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildContentCard(
            'Lessons',
            'Upload PDF lessons and materials',
            Icons.book,
            Colors.blue,
            () => _showUploadDialog('lesson', ContentType.lesson),
          ),
          const SizedBox(height: 12),
          _buildContentCard(
            'Quizzes',
            'Create and upload quiz materials',
            Icons.quiz,
            Colors.purple,
            () => _showUploadDialog('quiz', ContentType.quiz),
          ),
          const SizedBox(height: 12),
          _buildContentCard(
            'Exercises',
            'Upload practice exercises and worksheets',
            Icons.fitness_center,
            Colors.orange,
            () => _showUploadDialog('exercise', ContentType.exercise),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Recent Content',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (_isLoadingContent)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _isLoadingContent
              ? const Center(child: CircularProgressIndicator())
              : _contentList.isEmpty
              ? const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No content uploaded yet.'),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _contentList.length,
                itemBuilder: (context, index) {
                  final content = _contentList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color.alphaBlend(
                          _getContentColor(
                            content.type,
                          ).withAlpha((0.1 * 255).toInt()),
                          Colors.white,
                        ),
                        child: Icon(
                          _getContentIcon(content.type),
                          color: _getContentColor(content.type),
                        ),
                      ),
                      title: Text(content.title),
                      subtitle: Text(
                        '${content.description}\n${_formatFileSize(content.fileSize)} • ${_formatDate(content.createdAt)}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteContentDialog(content),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color.alphaBlend(
            color.withAlpha((0.1 * 255).toInt()),
            Colors.white,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.add),
        onTap: onTap,
      ),
    );
  }

  void _showRemoveStudentDialog(String classroomId, User student) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Student'),
            content: Text(
              'Are you sure you want to remove ${student.name} from this classroom?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final provider = Provider.of<ClassroomProvider>(
                    context,
                    listen: false,
                  );
                  await provider.removeStudent(classroomId, student.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${student.name} removed from classroom.'),
                    ),
                  );
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  void _showUploadDialog(String contentType, ContentType type) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Upload ${contentType[0].toUpperCase() + contentType.substring(1)}',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter content title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter content description',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _uploadPDFFile(
                      type,
                      titleController.text,
                      descController.text,
                    );
                  },
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose PDF File'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  Future<void> _uploadPDFFile(
    ContentType type,
    String title,
    String description,
  ) async {
    try {
      final result = await _contentService.pickPDFFile();
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);

        final content = await _contentService.createContent(
          classroomId: widget.classroom.id,
          title: title,
          description: description,
          type: type,
          pdfFile: file,
        );

        await _loadContent();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${content.title} uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteContentDialog(Content content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Content'),
            content: Text(
              'Are you sure you want to delete "${content.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await _contentService.deleteContent(content.id);
                    await _loadContent();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${content.title} deleted.')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete: $e')),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
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

  String _formatFileSize(int size) {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
