import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/classroom_provider.dart';
import 'models/user.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'modules/basic_operators/addition/addition_screen.dart';
import 'modules/basic_operators/addition/lesson_list_screen.dart';
import 'modules/basic_operators/addition/quiz_screen.dart';
import 'modules/basic_operators/addition/game_screen.dart';
import 'modules/basic_operators/addition/mock_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ClassroomProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PracPro',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const AuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(userType: UserType.student),
          '/home': (context) => const HomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/addition': (context) => const AdditionScreen(),
          '/addition/lessons': (context) => const LessonListScreen(),
          '/addition/quiz':
              (context) => QuizScreen(
                questions:
                    additionLessons[0]['quiz'].cast<Map<String, dynamic>>(),
              ),
          '/addition/games': (context) => const GameScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        return const WelcomeScreen();
      },
    );
  }
}
