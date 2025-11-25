import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:stallio/data/local/app_database.dart';
import 'package:stallio/features/auth/presentation/auth_gate.dart';
import 'package:stallio/features/dashboard/presentation/owner_dashboard_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lktcpeupxzdciheyuhhh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrdGNwZXVweHpkY2loZXl1aGhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNzg0MDAsImV4cCI6MjA3ODY1NDQwMH0.lVuzcjYYI_9VvWdgymSnzKk3x6gOAPbHLAftjIN5PPo',
  );

  final database = AppDatabase();
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stallio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthGate(childWhenAuthenticated: OwnerDashboardPage()),
    );
  }
}
