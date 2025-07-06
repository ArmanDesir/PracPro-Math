import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/classroom_provider.dart';
import '../models/classroom.dart';
import 'create_classroom_screen.dart';
import 'classroom_details_screen.dart';

class ManageClassroomsScreen extends StatelessWidget {
  const ManageClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classroomProvider = Provider.of<ClassroomProvider>(context);
    final teacherId =
        Provider.of<ClassroomProvider>(
              context,
              listen: false,
            ).teacherClassrooms.isNotEmpty
            ? classroomProvider.teacherClassrooms.first.teacherId
            : '';
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Classrooms')),
      body:
          classroomProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : classroomProvider.teacherClassrooms.isEmpty
              ? Center(
                child: Text(
                  'No classrooms yet. Tap + to create one!',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: classroomProvider.teacherClassrooms.length,
                itemBuilder: (context, index) {
                  final classroom = classroomProvider.teacherClassrooms[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: const Icon(Icons.class_, color: Colors.green),
                      ),
                      title: Text(
                        classroom.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              // Edit classroom (show dialog)
                              await _showEditClassroomDialog(
                                context,
                                classroomProvider,
                                classroom,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Delete Classroom'),
                                      content: const Text(
                                        'Are you sure you want to delete this classroom?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.pop(context, true),
                                          child: const Text(
                                            'Delete',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                              if (confirm == true) {
                                await classroomProvider.deleteClassroom(
                                  classroom.id,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Create Classroom'),
        onPressed: () async {
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateClassroomScreen(teacherId: teacherId),
            ),
          );
          if (created == true) {
            Provider.of<ClassroomProvider>(
              context,
              listen: false,
            ).loadTeacherClassrooms(teacherId);
          }
        },
      ),
    );
  }

  Future<void> _showEditClassroomDialog(
    BuildContext context,
    ClassroomProvider provider,
    Classroom classroom,
  ) async {
    final nameController = TextEditingController(text: classroom.name);
    final descController = TextEditingController(text: classroom.description);
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Classroom'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Classroom Name',
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await provider.updateClassroom(
                    classroom.copyWith(
                      name: nameController.text,
                      description: descController.text,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
