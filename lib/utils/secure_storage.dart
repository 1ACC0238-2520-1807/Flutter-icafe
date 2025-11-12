import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();
  static const _key = 'jwt';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  static Future<String?> readToken() async {
    return await _storage.read(key: _key);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _key);
  }

  static Future<String> extractEmailFromToken(String token) async {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Token inválido');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final json = jsonDecode(payload);
    return json['sub'];
  }
}
