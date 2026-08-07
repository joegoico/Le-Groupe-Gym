import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureLocalStorage extends LocalStorage {
  final FlutterSecureStorage storage;
  final String _storageKey;

  SecureLocalStorage({
    this.storage = const FlutterSecureStorage(),
    this._storageKey = 'supabase_auth_token',
  });

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async {
    return await storage.containsKey(key: _storageKey);
  }

  @override
  Future<String?> accessToken() async {
    return await storage.read(key: _storageKey);
  }

  @override
  Future<void> removePersistedSession() async {
    await storage.delete(key: _storageKey);
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await storage.write(key: _storageKey, value: persistSessionString);
  }
}
