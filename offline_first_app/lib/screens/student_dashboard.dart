import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom.dart';
import '../models/user.dart';
import 'student_classroom_screen.dart';
import 'join_classroom_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      if (user != null) {
        // Load student's classroom
        Provider.of<ClassroomProvider>(
          context,
          listen: false,
        ).loadStudentClassroom(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final classroomProvider = Provider.of<ClassroomProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: Colors.blue,
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    _buildWelcomeBanner(user?.name ?? 'Student'),
                    const SizedBox(height: 24),

                    // Quick Stats
                    _buildQuickStats(classroomProvider, user),
                    const SizedBox(height: 24),

                    // Classroom Status
                    _buildClassroomStatus(classroomProvider, user),
                    const SizedBox(height: 24),

                    // Quick Actions
                    _buildQuickActions(classroomProvider, user),
                    const SizedBox(height: 24),

                    // Recent Activity
                    _buildRecentActivity(),
                  ],
                ),
              ),
    );
  }

  Widget _buildWelcomeBanner(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, $name!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ready to learn and grow?',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ClassroomProvider classroomProvider, User? user) {
    final classroom = classroomProvider.currentClassroom;
    final contentCount =
        classroom != null ? 0 : 0; // TODO: Get actual content count

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(classroom != null ? '1' : '0', 'Classroom', Colors.blue),
        _buildStatCard(contentCount.toString(), 'Content', Colors.green),
        _buildStatCard('0', 'Completed', Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      width: 100,
      height: 80,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildClassroomStatus(
    ClassroomProvider classroomProvider,
    User? user,
  ) {
    final classroom = classroomProvider.currentClassroom;

    if (user?.classroomId == null) {
      return _buildNoClassroomCard();
    }

    if (classroom == null) {
      return _buildLoadingClassroomCard();
    }

    if (classroom.pendingStudentIds.contains(user!.id)) {
      return _buildPendingStatusCard(classroom);
    }

    if (classroom.studentIds.contains(user.id)) {
      return _buildActiveClassroomCard(classroom);
    }

    return _buildNoClassroomCard();
  }

  Widget _buildNoClassroomCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.class_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Classroom Joined',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join a classroom to start learning',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinClassroomScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Join Classroom'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingClassroomCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildPendingStatusCard(Classroom classroom) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.pending, size: 48, color: Colors.orange[600]),
            const SizedBox(height: 16),
            Text(
              'Pending Approval',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for teacher to accept your request to join "${classroom.name}"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange[600]),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: Colors.orange[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[600]!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveClassroomCard(Classroom classroom) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 48, color: Colors.green[600]),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classroom.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Classroom Code: ${classroom.code ?? ''}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => StudentClassroomScreen(classroom: classroom),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Enter Classroom'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ClassroomProvider classroomProvider, User? user) {
    final classroom = classroomProvider.currentClassroom;
    final hasActiveClassroom =
        classroom != null &&
        user != null &&
        classroom.studentIds.contains(user.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (!hasActiveClassroom)
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.blue),
              title: const Text('Join Classroom'),
              subtitle: const Text('Enter a classroom code to join'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JoinClassroomScreen(),
                  ),
                );
              },
            ),
          )
        else ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: const Text('View Lessons'),
              subtitle: const Text('Access your learning materials'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StudentClassroomScreen(classroom: classroom),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.orange[50],
            child: ListTile(
              leading: const Icon(Icons.calculate, color: Colors.orange),
              title: const Text('Basic Operators'),
              subtitle: const Text('Practice Addition, Subtraction, and more!'),
              onTap: () {
                Navigator.pushNamed(context, '/addition');
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz, color: Colors.purple),
              title: const Text('Take Quizzes'),
              subtitle: const Text('Test your knowledge'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => StudentClassroomScreen(classroom: classroom),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.history, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No recent activity',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your learning progress will appear here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
