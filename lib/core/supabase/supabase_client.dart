import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  const SupabaseManager._();

  static SupabaseClient get client => Supabase.instance.client;
}
