import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/classroom.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'offline_first_app.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        photoUrl TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        isOnline INTEGER NOT NULL,
        lastSyncTime TEXT,
        userType TEXT NOT NULL,
        classroomId TEXT,
        teacherCode TEXT,
        grade INTEGER,
        teacherId TEXT,
        contactNumber TEXT,
        studentId TEXT
      )
    ''');

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        dueDate TEXT,
        userId TEXT NOT NULL,
        isSynced INTEGER NOT NULL,
        firebaseId TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Classrooms table
    await db.execute('''
      CREATE TABLE classrooms(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        teacherId TEXT NOT NULL,
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        studentIds TEXT NOT NULL,
        pendingStudentIds TEXT NOT NULL,
        lessonIds TEXT NOT NULL,
        quizIds TEXT NOT NULL,
        code TEXT,
        isActive INTEGER NOT NULL,
        isSynced INTEGER NOT NULL,
        firebaseId TEXT,
        FOREIGN KEY (teacherId) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add classrooms table for version 2
      await db.execute('''
        CREATE TABLE classrooms(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          teacherId TEXT NOT NULL,
          description TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          studentIds TEXT NOT NULL,
          pendingStudentIds TEXT NOT NULL,
          lessonIds TEXT NOT NULL,
          quizIds TEXT NOT NULL,
          code TEXT,
          isActive INTEGER NOT NULL,
          isSynced INTEGER NOT NULL,
          firebaseId TEXT,
          FOREIGN KEY (teacherId) REFERENCES users (id)
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add missing user fields for version 3
      await db.execute('ALTER TABLE users ADD COLUMN classroomId TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN teacherCode TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN grade INTEGER');
      await db.execute('ALTER TABLE users ADD COLUMN teacherId TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN contactNumber TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN studentId TEXT');
    }
  }

  // User operations
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'photoUrl': user.photoUrl,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
      'isOnline': user.isOnline ? 1 : 0,
      'lastSyncTime': user.lastSyncTime,
      'userType': user.userType.name,
      'classroomId': user.classroomId,
      'teacherCode': user.teacherCode,
      'grade': user.grade,
      'teacherId': user.teacherId,
      'contactNumber': user.contactNumber,
      'studentId': user.studentId,
    });
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        photoUrl: maps[i]['photoUrl'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        isOnline: maps[i]['isOnline'] == 1,
        lastSyncTime: maps[i]['lastSyncTime'],
        userType:
            (maps[i]['userType'] == 'teacher')
                ? UserType.teacher
                : UserType.student,
        classroomId: maps[i]['classroomId'],
        teacherCode: maps[i]['teacherCode'],
        grade: maps[i]['grade'],
        teacherId: maps[i]['teacherId'],
        contactNumber: maps[i]['contactNumber'],
        studentId: maps[i]['studentId'],
      );
    });
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return User(
        id: maps[0]['id'],
        name: maps[0]['name'],
        email: maps[0]['email'],
        photoUrl: maps[0]['photoUrl'],
        createdAt: DateTime.parse(maps[0]['createdAt']),
        updatedAt: DateTime.parse(maps[0]['updatedAt']),
        isOnline: maps[0]['isOnline'] == 1,
        lastSyncTime: maps[0]['lastSyncTime'],
        userType:
            (maps[0]['userType'] == 'teacher')
                ? UserType.teacher
                : UserType.student,
        classroomId: maps[0]['classroomId'],
        teacherCode: maps[0]['teacherCode'],
        grade: maps[0]['grade'],
        teacherId: maps[0]['teacherId'],
        contactNumber: maps[0]['contactNumber'],
        studentId: maps[0]['studentId'],
      );
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'updatedAt': user.updatedAt.toIso8601String(),
        'isOnline': user.isOnline ? 1 : 0,
        'lastSyncTime': user.lastSyncTime,
        'userType': user.userType.name,
        'classroomId': user.classroomId,
        'teacherCode': user.teacherCode,
        'grade': user.grade,
        'teacherId': user.teacherId,
        'contactNumber': user.contactNumber,
        'studentId': user.studentId,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Task operations
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      'dueDate': task.dueDate?.toIso8601String(),
      'userId': task.userId,
      'isSynced': task.isSynced ? 1 : 0,
      'firebaseId': task.firebaseId,
    });
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[i]['status'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        dueDate:
            maps[i]['dueDate'] != null
                ? DateTime.parse(maps[i]['dueDate'])
                : null,
        userId: maps[i]['userId'],
        isSynced: maps[i]['isSynced'] == 1,
        firebaseId: maps[i]['firebaseId'],
      );
    });
  }

  Future<List<Task>> getTasksByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[i]['status'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        dueDate:
            maps[i]['dueDate'] != null
                ? DateTime.parse(maps[i]['dueDate'])
                : null,
        userId: maps[i]['userId'],
        isSynced: maps[i]['isSynced'] == 1,
        firebaseId: maps[i]['firebaseId'],
      );
    });
  }

  Future<Task?> getTaskById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Task(
        id: maps[0]['id'],
        title: maps[0]['title'],
        description: maps[0]['description'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[0]['status'],
        ),
        createdAt: DateTime.parse(maps[0]['createdAt']),
        updatedAt: DateTime.parse(maps[0]['updatedAt']),
        dueDate:
            maps[0]['dueDate'] != null
                ? DateTime.parse(maps[0]['dueDate'])
                : null,
        userId: maps[0]['userId'],
        isSynced: maps[0]['isSynced'] == 1,
        firebaseId: maps[0]['firebaseId'],
      );
    }
    return null;
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'status': task.status.name,
        'updatedAt': task.updatedAt.toIso8601String(),
        'dueDate': task.dueDate?.toIso8601String(),
        'isSynced': task.isSynced ? 1 : 0,
        'firebaseId': task.firebaseId,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getUnsyncedTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        title: maps[i]['title'],
        description: maps[i]['description'],
        status: TaskStatus.values.firstWhere(
          (e) => e.name == maps[i]['status'],
        ),
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        dueDate:
            maps[i]['dueDate'] != null
                ? DateTime.parse(maps[i]['dueDate'])
                : null,
        userId: maps[i]['userId'],
        isSynced: maps[i]['isSynced'] == 1,
        firebaseId: maps[i]['firebaseId'],
      );
    });
  }

  // Classroom operations
  Future<int> insertClassroom(Classroom classroom) async {
    final db = await database;
    return await db.insert('classrooms', {
      'id': classroom.id,
      'name': classroom.name,
      'teacherId': classroom.teacherId,
      'description': classroom.description,
      'createdAt': classroom.createdAt.toIso8601String(),
      'updatedAt': classroom.updatedAt.toIso8601String(),
      'studentIds': classroom.studentIds.join(','),
      'pendingStudentIds': classroom.pendingStudentIds.join(','),
      'lessonIds': classroom.lessonIds.join(','),
      'quizIds': classroom.quizIds.join(','),
      'code': classroom.code,
      'isActive': classroom.isActive ? 1 : 0,
      'isSynced': 1, // Assume synced when inserted locally
      'firebaseId': classroom.id, // Use same ID for Firebase
    });
  }

  Future<List<Classroom>> getAllClassrooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classrooms');
    return List.generate(maps.length, (i) {
      return Classroom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        teacherId: maps[i]['teacherId'],
        description: maps[i]['description'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        studentIds:
            maps[i]['studentIds'].isNotEmpty
                ? maps[i]['studentIds'].split(',')
                : [],
        pendingStudentIds:
            maps[i]['pendingStudentIds'].isNotEmpty
                ? maps[i]['pendingStudentIds'].split(',')
                : [],
        lessonIds:
            maps[i]['lessonIds'].isNotEmpty
                ? maps[i]['lessonIds'].split(',')
                : [],
        quizIds:
            maps[i]['quizIds'].isNotEmpty ? maps[i]['quizIds'].split(',') : [],
        code: maps[i]['code'],
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  Future<List<Classroom>> getClassroomsByTeacherId(String teacherId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classrooms',
      where: 'teacherId = ?',
      whereArgs: [teacherId],
    );
    return List.generate(maps.length, (i) {
      return Classroom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        teacherId: maps[i]['teacherId'],
        description: maps[i]['description'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        studentIds:
            maps[i]['studentIds'].isNotEmpty
                ? maps[i]['studentIds'].split(',')
                : [],
        pendingStudentIds:
            maps[i]['pendingStudentIds'].isNotEmpty
                ? maps[i]['pendingStudentIds'].split(',')
                : [],
        lessonIds:
            maps[i]['lessonIds'].isNotEmpty
                ? maps[i]['lessonIds'].split(',')
                : [],
        quizIds:
            maps[i]['quizIds'].isNotEmpty ? maps[i]['quizIds'].split(',') : [],
        code: maps[i]['code'],
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }

  Future<List<Classroom>> getClassroomsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('classrooms');

    return maps
        .where((map) {
          String studentIds = map['studentIds'] as String;
          String pendingStudentIds = map['pendingStudentIds'] as String;

          List<String> students =
              studentIds.isNotEmpty ? studentIds.split(',') : [];
          List<String> pendingStudents =
              pendingStudentIds.isNotEmpty ? pendingStudentIds.split(',') : [];

          return students.contains(userId) || pendingStudents.contains(userId);
        })
        .map((map) {
          return Classroom(
            id: map['id'],
            name: map['name'],
            teacherId: map['teacherId'],
            description: map['description'],
            createdAt: DateTime.parse(map['createdAt']),
            updatedAt: DateTime.parse(map['updatedAt']),
            studentIds:
                map['studentIds'].isNotEmpty
                    ? map['studentIds'].split(',')
                    : [],
            pendingStudentIds:
                map['pendingStudentIds'].isNotEmpty
                    ? map['pendingStudentIds'].split(',')
                    : [],
            lessonIds:
                map['lessonIds'].isNotEmpty ? map['lessonIds'].split(',') : [],
            quizIds: map['quizIds'].isNotEmpty ? map['quizIds'].split(',') : [],
            code: map['code'],
            isActive: map['isActive'] == 1,
          );
        })
        .toList();
  }

  Future<Classroom?> getClassroomById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classrooms',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Classroom(
        id: maps[0]['id'],
        name: maps[0]['name'],
        teacherId: maps[0]['teacherId'],
        description: maps[0]['description'],
        createdAt: DateTime.parse(maps[0]['createdAt']),
        updatedAt: DateTime.parse(maps[0]['updatedAt']),
        studentIds:
            maps[0]['studentIds'].isNotEmpty
                ? maps[0]['studentIds'].split(',')
                : [],
        pendingStudentIds:
            maps[0]['pendingStudentIds'].isNotEmpty
                ? maps[0]['pendingStudentIds'].split(',')
                : [],
        lessonIds:
            maps[0]['lessonIds'].isNotEmpty
                ? maps[0]['lessonIds'].split(',')
                : [],
        quizIds:
            maps[0]['quizIds'].isNotEmpty ? maps[0]['quizIds'].split(',') : [],
        code: maps[0]['code'],
        isActive: maps[0]['isActive'] == 1,
      );
    }
    return null;
  }

  Future<Classroom?> getClassroomByCode(String code) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classrooms',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (maps.isNotEmpty) {
      return Classroom(
        id: maps[0]['id'],
        name: maps[0]['name'],
        teacherId: maps[0]['teacherId'],
        description: maps[0]['description'],
        createdAt: DateTime.parse(maps[0]['createdAt']),
        updatedAt: DateTime.parse(maps[0]['updatedAt']),
        studentIds:
            maps[0]['studentIds'].isNotEmpty
                ? maps[0]['studentIds'].split(',')
                : [],
        pendingStudentIds:
            maps[0]['pendingStudentIds'].isNotEmpty
                ? maps[0]['pendingStudentIds'].split(',')
                : [],
        lessonIds:
            maps[0]['lessonIds'].isNotEmpty
                ? maps[0]['lessonIds'].split(',')
                : [],
        quizIds:
            maps[0]['quizIds'].isNotEmpty ? maps[0]['quizIds'].split(',') : [],
        code: maps[0]['code'],
        isActive: maps[0]['isActive'] == 1,
      );
    }
    return null;
  }

  Future<int> updateClassroom(Classroom classroom) async {
    final db = await database;
    return await db.update(
      'classrooms',
      {
        'name': classroom.name,
        'description': classroom.description,
        'updatedAt': classroom.updatedAt.toIso8601String(),
        'studentIds': classroom.studentIds.join(','),
        'pendingStudentIds': classroom.pendingStudentIds.join(','),
        'lessonIds': classroom.lessonIds.join(','),
        'quizIds': classroom.quizIds.join(','),
        'isActive': classroom.isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [classroom.id],
    );
  }

  Future<int> deleteClassroom(String id) async {
    final db = await database;
    return await db.delete('classrooms', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Classroom>> getUnsyncedClassrooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'classrooms',
      where: 'isSynced = ?',
      whereArgs: [0],
    );
    return List.generate(maps.length, (i) {
      return Classroom(
        id: maps[i]['id'],
        name: maps[i]['name'],
        teacherId: maps[i]['teacherId'],
        description: maps[i]['description'],
        createdAt: DateTime.parse(maps[i]['createdAt']),
        updatedAt: DateTime.parse(maps[i]['updatedAt']),
        studentIds:
            maps[i]['studentIds'].isNotEmpty
                ? maps[i]['studentIds'].split(',')
                : [],
        pendingStudentIds:
            maps[i]['pendingStudentIds'].isNotEmpty
                ? maps[i]['pendingStudentIds'].split(',')
                : [],
        lessonIds:
            maps[i]['lessonIds'].isNotEmpty
                ? maps[i]['lessonIds'].split(',')
                : [],
        quizIds:
            maps[i]['quizIds'].isNotEmpty ? maps[i]['quizIds'].split(',') : [],
        code: maps[i]['code'],
        isActive: maps[i]['isActive'] == 1,
      );
    });
  }
}
