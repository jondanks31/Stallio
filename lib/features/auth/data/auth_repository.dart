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

  /// Sends a password reset email to the specified address.
  /// User will receive a link to reset their password.
  /// The redirectTo URL must be configured in Supabase dashboard under
  /// Authentication > URL Configuration > Redirect URLs.
  Future<void> sendPasswordResetEmail({
    required String email,
    String? redirectTo,
  }) {
    return _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  User? get currentUser => _client.auth.currentUser;

  /// Checks if the current user's email has been verified.
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  /// Resends the verification email to the specified address.
  /// Used when user hasn't received or lost their verification email.
  Future<ResendResponse> resendVerificationEmail({
    required String email,
    String? redirectTo,
  }) {
    return _client.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo: redirectTo,
    );
  }

  /// Updates the password for the currently authenticated user.
  /// Used after the user clicks the password reset link from their email.
  Future<UserResponse> updatePassword({required String newPassword}) {
    return _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}
