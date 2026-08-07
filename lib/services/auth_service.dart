import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_groupe_gym/core/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient? _supabaseClient;

  AuthService({this._supabaseClient});

  SupabaseClient get _client => _supabaseClient ?? SupabaseConfig.client;

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
