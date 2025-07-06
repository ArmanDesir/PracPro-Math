import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart' as app_model;

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentId = ModalRoute.of(context)?.settings.arguments as String?;
    final authProvider = Provider.of<AuthProvider>(context);
    if (studentId == null) {
      final user = authProvider.currentUser;
      if (user == null) {
        return const Scaffold(
          body: Center(child: Text('No user data available.')),
        );
      }
      final isTeacher = user.userType == app_model.UserType.teacher;
      return _ProfileScaffold(user: user, isTeacher: isTeacher);
    } else {
      return FutureBuilder<app_model.User?>(
        future: authProvider.getUserById(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) {
            return const Scaffold(
              body: Center(child: Text('No user data available.')),
            );
          }
          final isTeacher = user.userType == app_model.UserType.teacher;
          return _ProfileScaffold(user: user, isTeacher: isTeacher);
        },
      );
    }
  }
}

class _ProfileScaffold extends StatelessWidget {
  final app_model.User user;
  final bool isTeacher;
  const _ProfileScaffold({required this.user, required this.isTeacher});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  isTeacher ? Icons.person : Icons.school,
                  size: 48,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!isTeacher) ...[
              _ProfileField(
                label: 'Student ID',
                value: user.studentId ?? 'N/A',
              ),
              const SizedBox(height: 16),
            ],
            _ProfileField(
              label: isTeacher ? 'Name' : 'Full Name',
              value: user.name,
            ),
            const SizedBox(height: 16),
            _ProfileField(
              label: 'Contact Number',
              value: user.contactNumber ?? 'N/A',
            ),
            const SizedBox(height: 16),
            _ProfileField(label: 'Email', value: user.email),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileField({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
