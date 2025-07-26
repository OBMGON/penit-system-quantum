import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  // Base URL for the API
  static const String baseUrl = 'https://api.penitsystem-ge.com';

  // API endpoints
  static const String loginEndpoint = '/auth/login';
  static const String inmatesEndpoint = '/inmates';
  static const String hospitalizationsEndpoint = '/hospitalizations';
  static const String alertsEndpoint = '/alerts';
  static const String reportsEndpoint = '/reports';
  static const String usersEndpoint = '/users';
  static const String auditEndpoint = '/audit';
  static const String expensesEndpoint = '/expenses';
  static const String foodEndpoint = '/food';
  static const String documentsEndpoint = '/documents';

  // Headers
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _authHeaders(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  // Generic request method
  static Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = token != null ? _authHeaders(token) : _headers;

      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      return response;
    } catch (e) {
      debugPrint('Error en request $method $endpoint: $e');
      rethrow;
    }
  }

  // Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }

      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Error parsing response: $e');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error ${response.statusCode}');
      } catch (e) {
        throw Exception(
            'Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }

  // Authentication
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await _makeRequest('POST', loginEndpoint, body: {
        'username': username,
        'password': password,
      });

      return _handleResponse(response);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  // Inmates
  static Future<List<Map<String, dynamic>>> getInmates({String? token}) async {
    try {
      final response = await _makeRequest('GET', inmatesEndpoint, token: token);
      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['inmates'] ?? []);
    } catch (e) {
      debugPrint('Get inmates error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createInmate(
      Map<String, dynamic> inmateData,
      {String? token}) async {
    try {
      final response = await _makeRequest('POST', inmatesEndpoint,
          body: inmateData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Create inmate error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateInmate(
      String id, Map<String, dynamic> inmateData,
      {String? token}) async {
    try {
      final response = await _makeRequest('PUT', '$inmatesEndpoint/$id',
          body: inmateData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Update inmate error: $e');
      rethrow;
    }
  }

  static Future<void> deleteInmate(String id, {String? token}) async {
    try {
      final response =
          await _makeRequest('DELETE', '$inmatesEndpoint/$id', token: token);
      _handleResponse(response);
    } catch (e) {
      debugPrint('Delete inmate error: $e');
      rethrow;
    }
  }

  // Hospitalizations
  static Future<List<Map<String, dynamic>>> getHospitalizations(
      {String? token}) async {
    try {
      final response =
          await _makeRequest('GET', hospitalizationsEndpoint, token: token);
      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['hospitalizations'] ?? []);
    } catch (e) {
      debugPrint('Get hospitalizations error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createHospitalization(
      Map<String, dynamic> hospitalizationData,
      {String? token}) async {
    try {
      final response = await _makeRequest('POST', hospitalizationsEndpoint,
          body: hospitalizationData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Create hospitalization error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateHospitalization(
      String id, Map<String, dynamic> hospitalizationData,
      {String? token}) async {
    try {
      final response = await _makeRequest(
          'PUT', '$hospitalizationsEndpoint/$id',
          body: hospitalizationData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Update hospitalization error: $e');
      rethrow;
    }
  }

  static Future<void> deleteHospitalization(String id, {String? token}) async {
    try {
      final response = await _makeRequest(
          'DELETE', '$hospitalizationsEndpoint/$id',
          token: token);
      _handleResponse(response);
    } catch (e) {
      debugPrint('Delete hospitalization error: $e');
      rethrow;
    }
  }

  // Alerts
  static Future<List<Map<String, dynamic>>> getAlerts({String? token}) async {
    try {
      final response = await _makeRequest('GET', alertsEndpoint, token: token);
      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['alerts'] ?? []);
    } catch (e) {
      debugPrint('Get alerts error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createAlert(
      Map<String, dynamic> alertData,
      {String? token}) async {
    try {
      final response = await _makeRequest('POST', alertsEndpoint,
          body: alertData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Create alert error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAlert(
      String id, Map<String, dynamic> alertData,
      {String? token}) async {
    try {
      final response = await _makeRequest('PUT', '$alertsEndpoint/$id',
          body: alertData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Update alert error: $e');
      rethrow;
    }
  }

  static Future<void> deleteAlert(String id, {String? token}) async {
    try {
      final response =
          await _makeRequest('DELETE', '$alertsEndpoint/$id', token: token);
      _handleResponse(response);
    } catch (e) {
      debugPrint('Delete alert error: $e');
      rethrow;
    }
  }

  // Reports
  static Future<List<Map<String, dynamic>>> getReports({String? token}) async {
    try {
      final response = await _makeRequest('GET', reportsEndpoint, token: token);
      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['reports'] ?? []);
    } catch (e) {
      debugPrint('Get reports error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createReport(
      Map<String, dynamic> reportData,
      {String? token}) async {
    try {
      final response = await _makeRequest('POST', reportsEndpoint,
          body: reportData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Create report error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateReport(
      String id, Map<String, dynamic> reportData,
      {String? token}) async {
    try {
      final response = await _makeRequest('PUT', '$reportsEndpoint/$id',
          body: reportData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Update report error: $e');
      rethrow;
    }
  }

  static Future<void> deleteReport(String id, {String? token}) async {
    try {
      final response =
          await _makeRequest('DELETE', '$reportsEndpoint/$id', token: token);
      _handleResponse(response);
    } catch (e) {
      debugPrint('Delete report error: $e');
      rethrow;
    }
  }

  // Users
  static Future<List<Map<String, dynamic>>> getUsers({String? token}) async {
    try {
      final response = await _makeRequest('GET', usersEndpoint, token: token);
      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['users'] ?? []);
    } catch (e) {
      debugPrint('Get users error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData,
      {String? token}) async {
    try {
      final response = await _makeRequest('POST', usersEndpoint,
          body: userData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Create user error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateUser(
      String id, Map<String, dynamic> userData,
      {String? token}) async {
    try {
      final response = await _makeRequest('PUT', '$usersEndpoint/$id',
          body: userData, token: token);
      return _handleResponse(response);
    } catch (e) {
      debugPrint('Update user error: $e');
      rethrow;
    }
  }

  static Future<void> deleteUser(String id, {String? token}) async {
    try {
      final response =
          await _makeRequest('DELETE', '$usersEndpoint/$id', token: token);
      _handleResponse(response);
    } catch (e) {
      debugPrint('Delete user error: $e');
      rethrow;
    }
  }

  // Audit
  static Future<List<Map<String, dynamic>>> getAuditLogs(
      {String? token}) async {
    try {
      final response = await _makeRequest('GET', auditEndpoint, token: token);
      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['logs'] ?? []);
    } catch (e) {
      debugPrint('Get audit logs error: $e');
      rethrow;
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      final response = await _makeRequest('GET', '/health');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check error: $e');
      return false;
    }
  }

  // Upload file
  static Future<Map<String, dynamic>> uploadFile(File file,
      {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', url);

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseData);
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Upload file error: $e');
      rethrow;
    }
  }
}
