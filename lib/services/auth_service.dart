import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'buildhome_api_client.dart';

class AuthUser {
  const AuthUser({required this.id, required this.phone, this.name});

  final int id;
  final String phone;
  final String? name;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      phone: json['phone'] as String,
      name: json['name'] as String?,
    );
  }
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _tokenKey = 'auth_token';

  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

  static String get _baseUrl => BuildhomeApiClient.baseUrl;
  static const _timeout = Duration(seconds: 10);

  String? _cachedToken;

  Future<void> init() async {
    _cachedToken = await _storage.read(key: _tokenKey);
  }

  bool get isLoggedIn => _cachedToken != null;

  String? get token => _cachedToken;

  /// POST /api/v1/auth/send-otp
  /// Returns OTP code in non-prod (for dev use).
  Future<String?> sendOtp(String phone) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/send-otp'),
          headers: _publicHeaders(),
          body: jsonEncode({'phone': phone}),
        )
        .timeout(_timeout);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseError(body),
      );
    }

    // Returns dev OTP when not in production
    return body['otp'] as String?;
  }

  /// POST /api/v1/auth/verify-otp
  /// Returns [AuthUser] and persists token to secure storage.
  Future<AuthUser> verifyOtp({
    required String phone,
    required String otp,
    String? name,
  }) async {
    final payload = <String, dynamic>{'phone': phone, 'otp': otp};
    if (name != null && name.isNotEmpty) payload['name'] = name;

    final response = await _client
        .post(
          Uri.parse('$_baseUrl/auth/verify-otp'),
          headers: _publicHeaders(),
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseError(body),
      );
    }

    final token = body['token'] as String;
    await _storage.write(key: _tokenKey, value: token);
    _cachedToken = token;

    return AuthUser.fromJson(body['user'] as Map<String, dynamic>);
  }

  /// POST /api/v1/auth/logout
  Future<void> logout() async {
    if (_cachedToken == null) return;

    try {
      await _client
          .post(
            Uri.parse('$_baseUrl/auth/logout'),
            headers: _authHeaders(),
          )
          .timeout(_timeout);
    } on Exception {
      // Ignore network errors during logout
    }

    await _storage.delete(key: _tokenKey);
    _cachedToken = null;
  }

  Map<String, String> _publicHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, String> _authHeaders() => {
        ..._publicHeaders(),
        if (_cachedToken != null) 'Authorization': 'Bearer $_cachedToken',
      };

  String _parseError(Map<String, dynamic> body) {
    if (body['message'] != null) return body['message'] as String;
    final errors = body['errors'] as Map<String, dynamic>?;
    if (errors != null) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) return first.first as String;
    }
    return 'Lỗi không xác định';
  }
}
