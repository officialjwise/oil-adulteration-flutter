import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'dashboard_screen.dart';

class DataInputMethodScreen extends StatefulWidget {
  final String selectedOilType;

  const DataInputMethodScreen({super.key, required this.selectedOilType});

  @override
  State<DataInputMethodScreen> createState() => _DataInputMethodScreenState();
}

class _DataInputMethodScreenState extends State<DataInputMethodScreen> {
  String? selectedMethod;

  final List<Map<String, dynamic>> inputMethods = [
    {
      'method': 'Camera Analysis',
      'description': 'Take a photo of your oil sample for instant analysis',
      'icon': Icons.camera_alt,
      'color': Color(0xFF3B82F6),
      'features': ['Quick results', 'Visual inspection', 'Color analysis'],
    },
    {
      'method': 'Spectral Data Upload',
      'description': 'Upload spectroscopic data files for detailed analysis',
      'icon': Icons.upload_file,
      'color': Color(0xFF8B5CF6),
      'features': [
        'High accuracy',
        'Detailed composition',
        'Professional grade',
      ],
    },
    {
      'method': 'Manual Entry',
      'description': 'Enter test results manually from laboratory reports',
      'icon': Icons.edit_note,
      'color': Color(0xFF10B981),
      'features': ['Lab report input', 'Custom parameters', 'Flexible format'],
    },
    {
      'method': 'Sensor Integration',
      'description': 'Connect directly to IoT sensors and monitoring devices',
      'icon': Icons.sensors,
      'color': Color(0xFFF59E0B),
      'features': [
        'Real-time data',
        'Automated collection',
        'Continuous monitoring',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        ),
        title: const Text(
          'Input Method',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B5CE6), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.science, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        widget.selectedOilType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Input Method',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select how you would like to provide your oil analysis data',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),

          // Input methods list
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ListView.builder(
                itemCount: inputMethods.length,
                itemBuilder: (context, index) {
                  final method = inputMethods[index];
                  final isSelected = selectedMethod == method['method'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMethod = method['method'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2B5CE6)
                              : const Color(0xFFE5E7EB),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: method['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                method['icon'],
                                size: 28,
                                color: method['color'],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['method'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF2B5CE6)
                                          : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method['description'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children:
                                        (method['features'] as List<String>)
                                            .map(
                                              (feature) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: method['color']
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  feature,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: method['color'],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),

                            // Selection indicator
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2B5CE6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            else
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (selectedMethod != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B5CE6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2B5CE6).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF2B5CE6),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Selected: $selectedMethod for ${widget.selectedOilType}',
                            style: const TextStyle(
                              color: Color(0xFF2B5CE6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Start Analysis',
                    onPressed: selectedMethod != null
                        ? () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(
                                  oilType: widget.selectedOilType,
                                  inputMethod: selectedMethod!,
                                ),
                              ),
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select an input method to continue',
                                ),
                              ),
                            );
                          },
                    backgroundColor: selectedMethod != null
                        ? const Color(0xFF4A90E2)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
