import 'dart:io';
import 'package:dio/dio.dart';
import '../models/oil_analysis_result.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _firebaseApiKey =
      'AIzaSyB0m-lgObeiDRpXvlXzmsUwR6jqZtR72fo';
  static String? authToken;

  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);

    // Attach Authorization header if token is present
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Firebase API key to every request
          options.headers['X-Firebase-API-Key'] = _firebaseApiKey;

          if (authToken != null && authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }
          return handler.next(options);
        },
      ),
    );

    // Logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );
  }

  static void setAuthToken(String token) {
    authToken = token;
  }

  static void clearAuthToken() {
    authToken = null;
  }

  /// Check if the backend server is running
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/');
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  /// Sign Up
  Future<ApiResponse<Map<String, dynamic>>> signUp({
    required String name,
    required String email,
    required String password,
    String? organization,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'password': password,
        'api_key': _firebaseApiKey,
      };

      // Only add optional fields if they have values
      if (organization != null && organization.isNotEmpty) {
        data['organization'] = organization;
      }

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phone_number'] = phoneNumber;
      }

      final response = await _dio.post(
        '/auth/signup',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Firebase-API-Key': _firebaseApiKey,
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          setAuthToken(token);
        }
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Sign In
  Future<ApiResponse<Map<String, dynamic>>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/signin',
        data: {
          'email': email,
          'password': password,
          'api_key': _firebaseApiKey,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Firebase-API-Key': _firebaseApiKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final token = data['token'] as String?;
        if (token != null && token.isNotEmpty) {
          setAuthToken(token);
        }
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Upload CSV file and get analysis results
  Future<ApiResponse<List<OilAnalysisResult>>> predictOilAdulteration(
    File csvFile,
    String oilType,
  ) async {
    try {
      // Validate file
      if (!csvFile.existsSync()) {
        return ApiResponse.error('File does not exist');
      }

      final fileName = csvFile.path.split('/').last;
      if (!fileName.toLowerCase().endsWith('.csv')) {
        return ApiResponse.error('Please select a CSV file');
      }

      // Check file size (limit to 10MB)
      final fileSizeInBytes = await csvFile.length();
      const maxSizeInBytes = 10 * 1024 * 1024; // 10MB
      if (fileSizeInBytes > maxSizeInBytes) {
        return ApiResponse.error('File size exceeds 10MB limit');
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(csvFile.path, filename: fileName),
        'oil_type': oilType,
      });

      // Make API request
      final response = await _dio.post(
        '/predict/',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final results = (data['results'] as List)
            .map((json) => OilAnalysisResult.fromJson(json))
            .toList();

        return ApiResponse.success(results);
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Analytics - Recent
  Future<ApiResponse<Map<String, dynamic>>> getRecentAnalytics({
    int days = 7,
    String? oilType,
    String? status,
  }) async {
    try {
      final query = <String, dynamic>{'days': days};
      if (oilType != null && oilType.isNotEmpty) query['oil_type'] = oilType;
      if (status != null && status.isNotEmpty) query['status'] = status;

      final response = await _dio.get(
        '/analytics/recent',
        queryParameters: query,
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data as Map),
        );
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Analytics - Summary
  Future<ApiResponse<Map<String, dynamic>>> getAnalyticsSummary() async {
    try {
      final response = await _dio.get('/analytics/summary');
      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data as Map),
        );
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get User Profile
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _dio.get('/user/profile');
      if (response.statusCode == 200) {
        return ApiResponse.success(
          Map<String, dynamic>.from(response.data as Map),
        );
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return authToken != null && authToken!.isNotEmpty;
  }

  /// Get the current auth token
  static String? getAuthToken() {
    return authToken;
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    String errorMessage;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage =
            'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Request timeout. The file might be too large.';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorData = e.response?.data;

        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please sign in again.';
        } else if (statusCode == 422) {
          errorMessage = 'Invalid input.';
        } else if (statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          // Try to extract detailed error message
          if (errorData is Map && errorData.containsKey('detail')) {
            errorMessage = 'Error: ${errorData['detail']}';
          } else {
            errorMessage = 'Error $statusCode: ${errorData ?? 'Unknown error'}';
          }
        }
        break;
      case DioExceptionType.connectionError:
        errorMessage =
            'Cannot connect to server. Please check if the backend is running.';
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request was cancelled.';
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    print('API Error: $errorMessage');
    if (e.response != null) {
      print('Response data: ${e.response?.data}');
    }

    return ApiResponse.error(errorMessage);
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse._(this.success, this.data, this.error);

  factory ApiResponse.success(T data) => ApiResponse._(true, data, null);
  factory ApiResponse.error(String error) => ApiResponse._(false, null, error);

  bool get isSuccess => success;
  bool get isError => !success;
}
