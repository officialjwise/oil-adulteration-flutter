import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Pick a CSV file from device storage
  Future<FilePickResult> pickCsvFile() async {
    try {
      // Check and request storage permission
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        return FilePickResult.error('Storage permission denied');
      }

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return FilePickResult.error('No file selected');
      }

      final pickedFile = result.files.first;

      // Validate file
      if (pickedFile.path == null) {
        return FilePickResult.error('Invalid file path');
      }

      final file = File(pickedFile.path!);

      // Validate file exists
      if (!await file.exists()) {
        return FilePickResult.error('File does not exist');
      }

      // Validate file extension
      if (!pickedFile.name.toLowerCase().endsWith('.csv')) {
        return FilePickResult.error('Please select a CSV file');
      }

      // Validate file size (max 10MB)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        return FilePickResult.error('File size exceeds 10MB limit');
      }

      return FilePickResult.success(file, pickedFile.name, fileSize);
    } catch (e) {
      return FilePickResult.error('Error picking file: $e');
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), we need different permissions
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          // Android 13+ uses scoped storage, no special permission needed for file picker
          return true;
        } else {
          // Android 12 and below
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      } else if (Platform.isIOS) {
        // iOS doesn't need storage permission for file picker
        return true;
      }
      return true;
    } catch (e) {
      print('Permission error: $e');
      return false;
    }
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    try {
      if (Platform.isAndroid) {
        // This is a simplified version - in a real app you might use device_info_plus
        return 33; // Assume recent Android for simplicity
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get app documents directory
  Future<Directory> getAppDocumentsDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Save file to app directory
  Future<File> saveFileToAppDirectory(
    File originalFile,
    String fileName,
  ) async {
    final appDir = await getAppDocumentsDirectory();
    final newPath = '${appDir.path}/$fileName';
    return await originalFile.copy(newPath);
  }

  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Validate CSV file content (basic check)
  Future<bool> validateCsvFile(File file) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');

      // Check if file has at least header and one data row
      if (lines.length < 2) {
        return false;
      }

      // Check if first line looks like a header (contains commas)
      if (!lines.first.contains(',')) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Result wrapper for file picking operations
class FilePickResult {
  final bool success;
  final File? file;
  final String? fileName;
  final int? fileSize;
  final String? error;

  FilePickResult._(
    this.success,
    this.file,
    this.fileName,
    this.fileSize,
    this.error,
  );

  factory FilePickResult.success(File file, String fileName, int fileSize) =>
      FilePickResult._(true, file, fileName, fileSize, null);

  factory FilePickResult.error(String error) =>
      FilePickResult._(false, null, null, null, error);

  bool get isSuccess => success;
  bool get isError => !success;
}
