import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/screens/home_screen.dart';
import 'features/admin/screens/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Initialize Firebase when configured
  // await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: CampusWayfinderApp(),
    ),
  );
}

class CampusWayfinderApp extends StatelessWidget {
  const CampusWayfinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Wayfinder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}
