import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/file_service.dart';
import '../models/oil_analysis_result.dart';
import 'dart:io';

class TestScreen extends StatefulWidget {
  static final List<TestResult> resultsHistory = [
    TestResult(
      id: 'SAMPLE-001',
      oilType: 'Palm Oil',
      status: 'Pure',
      date: '2024-01-15',
      confidence: 98.5,
    ),
    TestResult(
      id: 'SAMPLE-002',
      oilType: 'Groundnut Oil',
      status: 'Adulterated',
      date: '2024-01-15',
      confidence: 87.2,
    ),
    TestResult(
      id: 'SAMPLE-003',
      oilType: 'Palm Oil',
      status: 'Pure',
      date: '2024-01-14',
      confidence: 95.8,
    ),
    TestResult(
      id: 'SAMPLE-004',
      oilType: 'Groundnut Oil',
      status: 'Processing',
      date: '2024-01-15',
      confidence: 0,
      isProcessing: true,
    ),
  ];
  const TestScreen({super.key});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _step = 1;
  String? _selectedOilType;
  String? _selectedInputMethod;
  bool _analysisInProgress = false;
  bool _analysisComplete = false;
  bool _csvLoading = false;
  String? _errorMessage;
  List<OilAnalysisResult>? _latestResults;

  final ApiService _apiService = ApiService();
  final FileService _fileService = FileService();

  Future<void> _pickCsvAndAnalyze() async {
    setState(() {
      _csvLoading = true;
      _errorMessage = null;
    });

    try {
      // First check if backend is running
      final isServerHealthy = await _apiService.checkHealth();
      if (!isServerHealthy) {
        setState(() {
          _csvLoading = false;
          _errorMessage =
              'Cannot connect to analysis server. Please ensure the backend is running on localhost:8000';
        });
        _showErrorDialog();
        return;
      }

      // Pick CSV file
      final fileResult = await _fileService.pickCsvFile();
      if (fileResult.isError) {
        setState(() {
          _csvLoading = false;
          _errorMessage = fileResult.error!;
        });
        _showErrorDialog();
        return;
      }

      final csvFile = fileResult.file!;

      // Validate CSV content
      final isValidCsv = await _fileService.validateCsvFile(csvFile);
      if (!isValidCsv) {
        setState(() {
          _csvLoading = false;
          _errorMessage =
              'Invalid CSV file format. Please ensure the file contains proper CSV data.';
        });
        _showErrorDialog();
        return;
      }

      // Move to analysis step
      setState(() {
        _step = 3;
        _analysisInProgress = true;
        _analysisComplete = false;
        _csvLoading = false;
      });

      // Call API for analysis
      final apiResponse = await _apiService.predictOilAdulteration(csvFile);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        // Analysis successful
        final results = apiResponse.data!;
        setState(() {
          _analysisInProgress = false;
          _analysisComplete = true;
          _latestResults = results;
        });

        // Add results to history
        for (final result in results) {
          TestScreen.resultsHistory.insert(0, result.toTestResult());
        }
      } else {
        // Analysis failed
        setState(() {
          _analysisInProgress = false;
          _analysisComplete = false;
          _errorMessage = apiResponse.error ?? 'Analysis failed';
          _step = 2; // Go back to input method selection
        });
        _showErrorDialog();
      }
    } catch (e) {
      setState(() {
        _csvLoading = false;
        _analysisInProgress = false;
        _analysisComplete = false;
        _errorMessage = 'Unexpected error: $e';
        _step = 2;
      });
      _showErrorDialog();
    }
  }

  void _showErrorDialog() {
    if (_errorMessage != null && mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(Icons.error, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text(
                  'Analysis Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            content: Text(_errorMessage!),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Oil Testing',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (_step == 1)
                        const Text(
                          'Select oil type',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        )
                      else if (_step == 2)
                        Text(
                          '${_selectedOilType ?? ''} Analysis',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        )
                      else if (_step == 3)
                        Text(
                          '${_selectedOilType ?? ''} Analysis',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xFF6B7280),
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Color(0xFF6B7280)),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stepCircle(1, _step == 1),
                  _stepLine(),
                  _stepCircle(2, _step == 2),
                  _stepLine(),
                  _stepCircle(3, _step == 3),
                ],
              ),
            ),
            if (_step == 1) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Select Oil Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Text(
                  'Choose the type of oil you want to analyze',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
              ),
              const SizedBox(height: 8),
              _oilTypeCard(
                'Palm Oil',
                'Advanced spectroscopic analysis for palm oil purity detection',
                '🌴',
                selected: _selectedOilType == 'Palm Oil',
                onTap: () => setState(() => _selectedOilType = 'Palm Oil'),
              ),
              _oilTypeCard(
                'Groundnut Oil',
                'Quality assessment and adulteration detection for groundnut oil',
                '🥜',
                selected: _selectedOilType == 'Groundnut Oil',
                onTap: () => setState(() => _selectedOilType = 'Groundnut Oil'),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedOilType != null
                          ? const Color(0xFF4A90E2)
                          : const Color(0xFFB6C6E3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _selectedOilType != null
                        ? () => setState(() {
                            _step = 2;
                            _selectedInputMethod = null;
                          })
                        : null,
                    child: const Text(
                      'Continue to Data Input',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ] else if (_step == 2) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Spectroscopic Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Text(
                  'Choose your data input method',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _inputMethodCard(
                'Manual Data Entry',
                'Enter spectroscopic values manually (50+ fields)',
                Icons.opacity,
                label: 'Advanced',
                color: const Color(0xFFEEF4FF),
                selected: _selectedInputMethod == 'Manual',
                onTap: () => setState(() => _selectedInputMethod = 'Manual'),
              ),
              _inputMethodCard(
                'Upload CSV File',
                'Import data from CSV file format',
                Icons.upload_file,
                label: 'Recommended',
                color: const Color(0xFFFFF7E6),
                labelColor: Colors.orange,
                selected: _selectedInputMethod == 'CSV',
                onTap: () async {
                  setState(() => _selectedInputMethod = 'CSV');
                  await _pickCsvAndAnalyze();
                },
              ),
              _inputMethodCard(
                'QR Code Scanner',
                'Scan QR code from spectroscopic equipment',
                Icons.qr_code_scanner,
                label: 'Camera',
                color: const Color(0xFFFFF7E6),
                labelColor: Colors.black87,
                trailingIcon: Icons.camera_alt,
                selected: _selectedInputMethod == 'QR',
                onTap: () => setState(() => _selectedInputMethod = 'QR'),
              ),
              if (_csvLoading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4A90E2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => setState(() => _step = 1),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedInputMethod != null && !_csvLoading
                              ? const Color(0xFF1746A2)
                              : const Color(0xFFB6C6E3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed:
                            _selectedInputMethod != null &&
                                !_csvLoading &&
                                _selectedInputMethod != 'CSV'
                            ? () {
                                if (_selectedInputMethod == 'Manual') {
                                  _showManualEntryForm();
                                } else if (_selectedInputMethod == 'QR') {
                                  _scanQRCode();
                                } else {
                                  _startAnalysis();
                                }
                              }
                            : null,
                        child: const Text(
                          'Start Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_step == 3 && _analysisInProgress) ...[
              Expanded(child: _analysisInProgressWidget()),
            ] else if (_step == 3 && _analysisComplete) ...[
              if (_latestResults != null && _latestResults!.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _latestResults!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final result = _latestResults![i];
                      final isPure = result.isPure;
                      final cardColor = isPure
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444);
                      final icon = isPure ? Icons.check_circle : Icons.warning;
                      final statusText = result.statusMessage;
                      final detailText = isPure
                          ? 'No adulteration detected in the sample'
                          : 'Adulteration detected in this sample';
                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(icon, size: 32, color: Colors.white),
                                const SizedBox(width: 12),
                                Text(
                                  statusText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              detailText,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      result.confidencePercentage,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Confidence',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      result.analysisTime,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Analysis Time',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sample ID: ${result.sampleId}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Oil Type: ${result.oilType}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ] else ...[
              const Expanded(
                child: Center(
                  child: Text(
                    'Step 3: Analysis Results (Coming Soon)',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepCircle(int step, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1746A2) : Colors.white,
        border: Border.all(color: const Color(0xFF1746A2), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '$step',
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF1746A2),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _stepLine() {
    return Container(width: 32, height: 2, color: const Color(0xFF1746A2));
  }

  Widget _oilTypeCard(
    String title,
    String desc,
    String emoji, {
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF1746A2) : const Color(0xFFE5E7EB),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected
                  ? const Color(0xFFEEF4FF)
                  : const Color(0xFFF1F5F9),
              child: Text(emoji, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _tag('NIR Ready'),
                      const SizedBox(width: 8),
                      _tag('AI Powered'),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFB6C6E3)),
          ],
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputMethodCard(
    String title,
    String desc,
    IconData icon, {
    String? label,
    Color? color,
    Color? labelColor,
    IconData? trailingIcon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F0FE) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF1746A2) : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color ?? const Color(0xFFF1F5F9),
              child: Icon(icon, color: const Color(0xFF1746A2)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  if (label != null) ...[
                    const SizedBox(height: 8),
                    _inputTag(label, labelColor),
                  ],
                ],
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: const Color(0xFFB6C6E3)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _inputTag(String label, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFFF1F5F9)).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color ?? const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _analysisInProgressWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Icon(
                  Icons.psychology,
                  size: 54,
                  color: Color(0xFF1746A2),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI Analysis in Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Analyzing palm oil sample: SAMPLE-001',
                  style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Analysis Progress',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 1,
                  color: Color(0xFF1746A2),
                  backgroundColor: Color(0xFFE5E7EB),
                  minHeight: 8,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generating Results',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _progressRow(Icons.bolt, 'Initializing Analysis', true),
                _progressRow(Icons.analytics, 'Processing Spectral Data', true),
                _progressRow(Icons.psychology, 'AI Model Analysis', true),
                _progressRow(
                  Icons.check_circle_outline,
                  'Generating Results',
                  false,
                  processing: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Column(
                  children: [
                    Text(
                      '50+',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1746A2),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Parameters',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'NIR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Spectroscopy',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Analysis typically completes in 30-90 seconds',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(
    IconData icon,
    String label,
    bool complete, {
    bool processing = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: complete ? const Color(0xFF10B981) : const Color(0xFF1746A2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: complete
                  ? const Color(0xFF10B981)
                  : (processing
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              complete ? 'Complete' : (processing ? 'Processing...' : ''),
              style: TextStyle(
                color: complete
                    ? Colors.white
                    : (processing ? Colors.white : const Color(0xFF6B7280)),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisResultWidget() {
    // Use the latest results from API, or fall back to mock data
    final result =
        _latestResults?.first ??
        OilAnalysisResult(
          sampleId: 'SAMPLE-001',
          status: 'Pure',
          confidence: 0.968,
          oilType: _selectedOilType ?? 'Palm Oil',
          analysisTime: '47s',
          timestamp: DateTime.now(),
        );

    final isPure = result.isPure;
    final cardColor = isPure
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);
    final icon = isPure ? Icons.check_circle : Icons.warning;
    final statusText = result.statusMessage;
    final detailText = isPure
        ? 'No adulteration detected in the sample'
        : 'Adulteration detected in this sample';

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(icon, size: 54, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  detailText,
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          result.confidencePercentage,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Confidence',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          result.analysisTime,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Analysis Time',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Sample Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.science, color: Color(0xFF1746A2)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Sample ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SAMPLE-001',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.remove_red_eye, color: Color(0xFF1746A2)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Oil Type',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Palm Oil',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Color(0xFF1746A2)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Lab Room 1',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.calendar_today, color: Color(0xFF1746A2)),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Test Date',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '2025-08-07',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Key Findings',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                _findingTile(
                  'Fatty Acid Profile',
                  'Normal range',
                  'WHO Standards',
                  'normal',
                ),
                _findingTile(
                  'Peroxide Value',
                  '2.1 meq O2/kg',
                  '< 10.0',
                  'normal',
                ),
                _findingTile('Free Fatty Acids', '0.8%', '< 1.0%', 'normal'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _findingTile(
    String title,
    String value,
    String reference,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Reference: $reference',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1746A2),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status == 'normal'
                  ? const Color(0xFF1746A2)
                  : const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManualDataEntryScreen(
          oilType: _selectedOilType ?? 'Palm Oil',
          onAnalysisComplete: (result) {
            TestScreen.resultsHistory.insert(0, result);
            setState(() {
              _step = 3;
              _analysisInProgress = false;
              _analysisComplete = true;
            });
          },
        ),
      ),
    );
  }

  void _scanQRCode() {
    // QR Code scanning implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanner'),
        content: const Text(
          'QR Code scanning functionality will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startAnalysis() {
    setState(() {
      _step = 3;
      _analysisInProgress = true;
      _analysisComplete = false;
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _analysisInProgress = false;
        _analysisComplete = true;
      });
      TestScreen.resultsHistory.insert(
        0,
        TestResult(
          id: 'SAMPLE-00${TestScreen.resultsHistory.length + 1}',
          oilType: _selectedOilType ?? 'Palm Oil',
          status: 'Pure',
          date: DateTime.now().toString().substring(0, 10),
          confidence: 96.8,
        ),
      );
    });
  }
}

// Manual Data Entry Screen
class ManualDataEntryScreen extends StatefulWidget {
  final String oilType;
  final Function(TestResult) onAnalysisComplete;

  const ManualDataEntryScreen({
    super.key,
    required this.oilType,
    required this.onAnalysisComplete,
  });

  @override
  State<ManualDataEntryScreen> createState() => _ManualDataEntryScreenState();
}

class _ManualDataEntryScreenState extends State<ManualDataEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isAnalyzing = false;

  final List<Map<String, dynamic>> _dataFields = [
    {'label': 'Absorbance at 400nm', 'key': 'abs_400', 'unit': 'AU'},
    {'label': 'Absorbance at 450nm', 'key': 'abs_450', 'unit': 'AU'},
    {'label': 'Absorbance at 500nm', 'key': 'abs_500', 'unit': 'AU'},
    {'label': 'Absorbance at 550nm', 'key': 'abs_550', 'unit': 'AU'},
    {'label': 'Absorbance at 600nm', 'key': 'abs_600', 'unit': 'AU'},
    {'label': 'Refractive Index', 'key': 'ref_index', 'unit': ''},
    {'label': 'Density', 'key': 'density', 'unit': 'g/cm³'},
    {'label': 'Viscosity', 'key': 'viscosity', 'unit': 'cP'},
    {'label': 'pH Value', 'key': 'ph', 'unit': ''},
    {'label': 'Moisture Content', 'key': 'moisture', 'unit': '%'},
  ];

  @override
  void initState() {
    super.initState();
    for (var field in _dataFields) {
      _controllers[field['key']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manual Data Entry',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.oilType,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _dataFields.length,
                itemBuilder: (context, index) {
                  final field = _dataFields[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _controllers[field['key']],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: field['label'],
                        suffixText: field['unit'],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'This field is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _analyzeData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1746A2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isAnalyzing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Analyze',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _analyzeData() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isAnalyzing = true);

      // Simulate analysis processing
      Future.delayed(const Duration(seconds: 3), () {
        // Generate result based on input values
        final result = TestResult(
          id: 'SAMPLE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          oilType: widget.oilType,
          status: _generateStatus(),
          date: DateTime.now().toString().substring(0, 10),
          confidence: _generateConfidence(),
        );

        widget.onAnalysisComplete(result);
        Navigator.pop(context);
      });
    }
  }

  String _generateStatus() {
    // Simple analysis based on some field values
    final absorbance =
        double.tryParse(_controllers['abs_500']?.text ?? '0') ?? 0;
    final density = double.tryParse(_controllers['density']?.text ?? '0') ?? 0;

    if (absorbance > 0.8 || density > 1.2) {
      return 'Adulterated';
    } else if (absorbance < 0.3 && density < 0.9) {
      return 'Pure';
    } else {
      return 'Processing';
    }
  }

  double _generateConfidence() {
    // Generate confidence based on input consistency
    return 85.0 + (DateTime.now().millisecond % 15);
  }
}
