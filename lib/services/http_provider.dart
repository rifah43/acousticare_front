import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:acousticare_front/providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiProvider {
  static const int timeoutDuration = 10;
  
  String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('API_BASE_URL not found in environment variables');
    }
    return url;
  }

  /// Get authentication headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    // Add device ID
    final deviceId = await AuthService.getDeviceId();
    if (deviceId != null) {
      headers['X-Device-ID'] = deviceId;
    }

    return headers;
  }

  Future<http.Response> getRequest(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final headers = await _getAuthHeaders();
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http.get(url, headers: headers)
          .timeout(const Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to make GET request: $e');
    }
  }

  Future<http.Response> postRequest(String endpoint, Map<String, dynamic> data, {Map<String, String>? additionalHeaders}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      print('Making POST request to: $url');
      print('Request body: ${jsonEncode(data)}');
      
      final headers = await _getAuthHeaders();
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: timeoutDuration));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } on FormatException catch (e) {
      throw Exception('Data format error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to make POST request: $e');
    }
  }

  Future<http.Response> putRequest(String endpoint, Map<String, dynamic> data, {Map<String, String>? additionalHeaders}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final headers = await _getAuthHeaders();
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to make PUT request: $e');
    }
  }

  Future<http.Response> deleteRequest(String endpoint, {Map<String, String>? additionalHeaders}) async {
    final url = Uri.parse('$_baseUrl/$endpoint');
    try {
      final headers = await _getAuthHeaders();
      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final response = await http.delete(url, headers: headers)
          .timeout(const Duration(seconds: timeoutDuration));
      return _handleResponse(response);
    } on SocketException catch (e) {
      throw Exception('Network error: Please check your internet connection and server status. (${e.message})');
    } on TimeoutException {
      throw Exception('Request timed out: Server is not responding');
    } catch (e) {
      throw Exception('Failed to make DELETE request: $e');
    }
  }

  Future<http.Response> uploadAudioFile(
  String endpoint,
  File audioFile,
  UserProvider user,
) async {
  final url = Uri.parse('$_baseUrl/$endpoint');
  try {
    // Validate user data
    final currentUser = user.currentUser;
    if (currentUser == null) {
      throw Exception('User not found');
    }

    // Create multipart request
    var request = http.MultipartRequest('POST', url);
    
    // Add auth headers
    final headers = await _getAuthHeaders();
    request.headers.addAll(headers);
    
    // Add demographic data
    request.fields.addAll({
      'user_id': currentUser.id ?? '',
      'gender': currentUser.gender,
      'age': currentUser.age.toString(),
      'bmi': currentUser.bmi.toString(),
    });
    
    // Validate data before adding file
    if (request.fields.values.any((value) => value.isEmpty)) {
      throw Exception('Missing required user data. Please complete your profile.');
    }

    final age = double.tryParse(request.fields['age']!);
    final bmi = double.tryParse(request.fields['bmi']!);
    
    if (age == null || age <= 0 || age > 120) {
      throw Exception('Invalid age value (must be between 1 and 120)');
    }
    if (bmi == null || bmi <= 0 || bmi > 100) {
      throw Exception('Invalid BMI value (must be between 1 and 100)');
    }

    // Add audio file
    if (!await audioFile.exists()) {
      throw Exception('Audio file not found');
    }
    
    if (audioFile.lengthSync() == 0) {
      throw Exception('Audio file is empty');
    }

    request.files.add(await http.MultipartFile.fromPath(
      'audio',
      audioFile.path,
    ));

    // Send request
    final streamedResponse = await request.send().timeout(
      const Duration(seconds: timeoutDuration * 2),
    );
    
    final response = await http.Response.fromStream(streamedResponse);
    
    // Handle response
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        print('Prediction result: ${data['risk_probability']}');
        return response;
      } catch (e) {
        throw Exception('Invalid response format from server');
      }
    } else {
      final error = _parseErrorResponse(response);
      throw Exception(error);
    }
    
  } on SocketException catch (e) {
    throw Exception('Network error: Please check your internet connection. (${e.message})');
  } on TimeoutException {
    throw Exception('Request timed out: Server is not responding');
  } on FormatException catch (e) {
    throw Exception('Invalid data format: ${e.message}');
  } catch (e) {
    throw Exception(e.toString());
  }
}

String _parseErrorResponse(http.Response response) {
  try {
    final body = jsonDecode(response.body);
    return body['error'] ?? body['message'] ?? 'Unknown error occurred';
  } catch (e) {
    return 'Server error (${response.statusCode})';
  }
}
  http.Response _handleResponse(http.Response response) {
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }

    switch (response.statusCode) {
      case 400:
        throw Exception('Bad request: ${_parseErrorMessage(response.body)}');
      case 401:
        throw Exception('Unauthorized: Please log in again');
      case 403:
        throw Exception('Forbidden: You don\'t have permission to access this resource');
      case 404:
        throw Exception('Not found: The requested resource doesn\'t exist');
      case 500:
        throw Exception('Server error: Please try again later');
      default:
        throw Exception('Error ${response.statusCode}: ${_parseErrorMessage(response.body)}');
    }
  }

  String _parseErrorMessage(String body) {
    try {
      final parsed = jsonDecode(body);
      return parsed['message'] ?? parsed['error'] ?? body;
    } catch (e) {
      return body;
    }
  }
}