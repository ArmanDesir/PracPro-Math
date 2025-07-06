import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import 'manage_classrooms_screen.dart';
import 'classroom_details_screen.dart';

class CreateClassroomScreen extends StatelessWidget {
  final String teacherId;
  const CreateClassroomScreen({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final classroomProvider = Provider.of<ClassroomProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Classroom')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Classroom Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  await classroomProvider.createClassroom(
                    name: nameController.text,
                    description: descController.text,
                    teacherId: teacherId,
                  );
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Create'),
            ),
            if (classroomProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  classroomProvider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final GlobalKey _classroomListKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    Provider.of<ClassroomProvider>(
      context,
      listen: false,
    ).loadTeacherClassrooms(authProvider.currentUser?.id ?? '');
  }

  void _scrollToClassrooms() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _classroomListKey.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classroomProvider = Provider.of<ClassroomProvider>(context);
    final teacherId = authProvider.currentUser?.id ?? '';

    final acceptedStudents =
        classroomProvider.teacherClassrooms
            .expand((c) => c.studentIds)
            .toSet()
            .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body:
          classroomProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Quick Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _scrollToClassrooms,
                        child: _buildStatCard(
                          '${classroomProvider.teacherClassrooms.length}',
                          'Classrooms',
                          Colors.blue,
                        ),
                      ),
                      _buildStatCard(
                        '$acceptedStudents',
                        'Students',
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard('23', 'Lessons', Colors.orange),
                      _buildStatCard('8', 'Quizzes', Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Quick Action: Manage Classroom
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.settings, color: Colors.blue),
                      title: const Text(
                        'Manage Classroom',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Create, update, or delete your classrooms',
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ManageClassroomsScreen(),
                          ),
                        );
                        // Reload classrooms after returning
                        Provider.of<ClassroomProvider>(
                          context,
                          listen: false,
                        ).loadTeacherClassrooms(teacherId);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick Action: Add Lesson
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.book, color: Colors.blue),
                      title: const Text(
                        'Add Lesson',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Create engaging math lessons for your students',
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Add Lesson feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Quick Action: Create Quiz
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.quiz, color: Colors.purple),
                      title: const Text(
                        'Create Quiz',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Design interactive quizzes to test knowledge',
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Create Quiz feature coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Classroom cards section
                  const Text(
                    'Your Classrooms',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (classroomProvider.teacherClassrooms.isEmpty)
                    Center(
                      child: Text(
                        'No classrooms yet. Tap "Create Classroom" to add one!',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  else
                    ...classroomProvider.teacherClassrooms.map(
                      (classroom) => Container(
                        key:
                            classroom ==
                                    classroomProvider.teacherClassrooms.first
                                ? _classroomListKey
                                : null,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(
                                Icons.class_,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(
                              classroom.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Code: ${classroom.code ?? ''}\nStudents: ${classroom.studentIds.length}',
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => ClassroomDetailsScreen(
                                        classroom: classroom,
                                      ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  // Accepted Students List
                  const SizedBox(height: 24),
                  const Text(
                    'Accepted Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (classroomProvider.teacherClassrooms
                      .expand((c) => c.studentIds)
                      .isEmpty)
                    Center(
                      child: Text(
                        'No accepted students yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                  else
                    ...classroomProvider.teacherClassrooms
                        .expand((c) => c.studentIds)
                        .toSet()
                        .map(
                          (studentId) => Card(
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.green,
                              ),
                              title: Text('Student ID: $studentId'),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/profile',
                                    arguments: studentId,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                ],
              ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      width: 140,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          color.withAlpha((0.08 * 255).toInt()),
          Colors.white,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.alphaBlend(
            color.withAlpha((0.2 * 255).toInt()),
            Colors.white,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
