import 'dart:io';
import 'package:dio/dio.dart';
import '../models/oil_analysis_result.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000'; // For emulator
  // For real device, use: 'http://192.168.1.50:8000' (replace with your IP)

  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.sendTimeout = const Duration(seconds: 60);

    // Add interceptors for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ),
    );
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

  /// Upload CSV file and get analysis results
  Future<ApiResponse<List<OilAnalysisResult>>> predictOilAdulteration(
    File csvFile,
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
        if (statusCode == 422) {
          errorMessage = 'Invalid file format or data.';
        } else if (statusCode == 500) {
          errorMessage = 'Server error. Please try again later.';
        } else {
          errorMessage =
              'Error $statusCode: ${errorData?['detail'] ?? 'Unknown error'}';
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
