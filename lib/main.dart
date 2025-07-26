import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'auth/student_provider.dart';
import 'auth/auth_wrapper.dart';
import 'auth/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentProvider(),
      child: MaterialApp(
        title: 'Sri Eshwar Student App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.lightBlue,
            primary: Color(0xFF87CEEB), // Sky blue
            secondary: Color(0xFF5CACEE), // Slightly darker sky blue
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF87CEEB),
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => AuthWrapper(),
          '/login': (_) => LoginScreen(),
          '/profile': (_) => ProfileScreen(),
          '/announcements': (_) => AnnouncementsScreen(),
          '/home': (_) => HomeScreen(),
        },
      ),
    );
  }
}
