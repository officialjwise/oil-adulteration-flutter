class OilAnalysisResult {
  final String sampleId;
  final String status;
  final double confidence;
  final String oilType;
  final String analysisTime;
  final DateTime timestamp;

  OilAnalysisResult({
    required this.sampleId,
    required this.status,
    required this.confidence,
    required this.oilType,
    required this.analysisTime,
    required this.timestamp,
  });

  factory OilAnalysisResult.fromJson(Map<String, dynamic> json) {
    return OilAnalysisResult(
      sampleId: json['sample_id'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      oilType: json['oil_type'] ?? 'Unknown',
      analysisTime: json['analysis_time'] ?? '0s',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sample_id': sampleId,
      'status': status,
      'confidence': confidence,
      'oil_type': oilType,
      'analysis_time': analysisTime,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to TestResult format used in the app
  TestResult toTestResult() {
    return TestResult(
      id: sampleId,
      oilType: oilType,
      status: status,
      date: timestamp.toString().substring(0, 10),
      confidence: confidence * 100, // Convert to percentage
      isProcessing: false,
    );
  }

  /// Get confidence as percentage string
  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  /// Check if oil is pure
  bool get isPure => status.toLowerCase() == 'pure';

  /// Check if oil is adulterated
  bool get isAdulterated => status.toLowerCase() == 'adulterated';

  /// Get status color
  String get statusColor {
    if (isPure) return '#22C55E'; // Green
    if (isAdulterated) return '#EF4444'; // Red
    return '#F59E0B'; // Orange for unknown
  }

  /// Get user-friendly status message
  String get statusMessage {
    if (isPure) return 'Oil is Pure';
    if (isAdulterated) return 'Adulteration detected';
    return 'Analysis Complete';
  }
}

/// Import TestResult class that's already used in the app
class TestResult {
  final String id;
  final String oilType;
  final String status;
  final String date;
  final double confidence;
  final bool isProcessing;

  TestResult({
    required this.id,
    required this.oilType,
    required this.status,
    required this.date,
    required this.confidence,
    this.isProcessing = false,
  });
}
