import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import 'login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.childWhenAuthenticated});

  final Widget childWhenAuthenticated;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final SupabaseClient _client;
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _client = SupabaseManager.client;
    _authStream = _client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authStream,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        _client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) {
          return const LoginPage();
        }
        return widget.childWhenAuthenticated;
      },
    );
  }
}
