import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';

class AuthRepository {
  AuthRepository();

  SupabaseClient get _client => SupabaseManager.client;

  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange.map((event) => event);
  }

  Session? get currentSession => _client.auth.currentSession;

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
