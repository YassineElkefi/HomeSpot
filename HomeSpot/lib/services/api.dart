import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/advert.dart';
import '../models/user.dart';

const _baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://192.168.1.6:3000');
const _tokenKey = 'homespot_token';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class AdvertsResponse {
  final List<Advert> data;
  final AdvertMeta meta;
  AdvertsResponse({required this.data, required this.meta});
}

// ─── Token Storage ────────────────────────────────────────────────────────────

const _storage = FlutterSecureStorage();

Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);
Future<void> clearToken() => _storage.delete(key: _tokenKey);
Future<String?> getToken() => _storage.read(key: _tokenKey);

// ─── Core Request ─────────────────────────────────────────────────────────────

Future<dynamic> _request(
  String path, {
  String method = 'GET',
  Object? body,
  bool isFormData = false,
}) async {
  final token = await getToken();
  final uri = Uri.parse('$_baseUrl$path');

  final headers = <String, String>{
    if (!isFormData) 'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  http.Response response;

  switch (method) {
    case 'POST':
      response = await http.post(uri, headers: headers, body: body);
    case 'PUT':
      response = await http.put(uri, headers: headers, body: body);
    case 'DELETE':
      response = await http.delete(uri, headers: headers);
    default:
      response = await http.get(uri, headers: headers);
  }

  final contentType = response.headers['content-type'] ?? '';
  dynamic responseBody;

  if (contentType.contains('application/json')) {
    responseBody = jsonDecode(response.body);
  } else {
    responseBody = response.body;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    String message = 'Request failed';
    if (responseBody is Map) {
      final msg = responseBody['message'];
      if (msg is List) {
        message = msg.join(', ');
      } else if (msg is String) {
        message = msg;
      }
    } else if (responseBody is String && responseBody.isNotEmpty) {
      message = responseBody;
    }
    throw ApiException(message, response.statusCode);
  }

  return responseBody;
}

Future<dynamic> _multipartRequest(
  String path, {
  required String method,
  required Map<String, String> fields,
  File? imageFile,
}) async {
  final token = await getToken();
  final uri = Uri.parse('$_baseUrl$path');

  final request = http.MultipartRequest(method, uri);

  if (token != null) {
    request.headers['Authorization'] = 'Bearer $token';
  }

  request.fields.addAll(fields);

  if (imageFile != null) {
    final filename = imageFile.path.split('/').last;
    final ext = filename.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'png'  => 'png',
      'gif'  => 'gif',
      'webp' => 'webp',
      _      => 'jpeg',   // jpg, jpeg, heic, etc.
    };
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType('image', mimeType),  // ← multer now sees image/*
    ));
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  final contentType = response.headers['content-type'] ?? '';
  dynamic responseBody;

  if (contentType.contains('application/json')) {
    responseBody = jsonDecode(response.body);
  } else {
    responseBody = response.body;
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    String message = 'Request failed';
    if (responseBody is Map) {
      final msg = responseBody['message'];
      message = msg is List ? msg.join(', ') : (msg as String? ?? message);
    }
    throw ApiException(message, response.statusCode);
  }

  return responseBody;
}

// ─── Auth Endpoints ───────────────────────────────────────────────────────────
Future<({String token, User user})> apiRegister(String name, String email, String password) async {
  final data = await _request(
    '/auth/register',
    method: 'POST',
    body: jsonEncode({'name': name, 'email': email, 'password': password}),
  ) as Map<String, dynamic>;

  await saveToken(data['access_token'] as String);
  return (token: data['access_token'] as String, user: User.fromJson(data['user']));
}

Future<({String token, User user})> apiLogin(String email, String password) async {
  final data = await _request(
    '/auth/login',
    method: 'POST',
    body: jsonEncode({'email': email, 'password': password}),
  ) as Map<String, dynamic>;

  await saveToken(data['access_token'] as String);
  return (token: data['access_token'] as String, user: User.fromJson(data['user'] as Map<String, dynamic>));
}

Future<User> apiGetMe() async {
  final data = await _request('/auth/me') as Map<String, dynamic>;
  return User.fromJson(data);
}

Future<void> apiLogout() async {
  await clearToken();
}

// ─── Advert Endpoints ─────────────────────────────────────────────────────────

Future<AdvertsResponse> apiGetAdverts(AdvertFilters filters) async {
  final params = filters.toQueryParams();
  final query = params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  final path = '/adverts${query.isNotEmpty ? '?$query' : ''}';
  final data = await _request(path) as Map<String, dynamic>;

  return AdvertsResponse(
    data: (data['data'] as List).map((e) => Advert.fromJson(e as Map<String, dynamic>)).toList(),
    meta: AdvertMeta.fromJson(data['meta'] as Map<String, dynamic>),
  );
}

Future<Advert> apiCreateAdvert({
  required Map<String, String> fields,
  File? imageFile,
}) async {
  final data = await _multipartRequest(
    '/adverts',
    method: 'POST',
    fields: fields,
    imageFile: imageFile,
  ) as Map<String, dynamic>;
  return Advert.fromJson(data);
}

Future<Advert> apiUpdateAdvert(
  int id, {
  required Map<String, String> fields,
  File? imageFile,
}) async {
  final data = await _multipartRequest(
    '/adverts/$id',
    method: 'PUT',
    fields: fields,
    imageFile: imageFile,
  ) as Map<String, dynamic>;
  return Advert.fromJson(data);
}

Future<void> apiDeleteAdvert(int id) async {
  await _request('/adverts/$id', method: 'DELETE');
}
