import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import 'data_input_method_screen.dart';

class OilTypeSelectionScreen extends StatefulWidget {
  const OilTypeSelectionScreen({super.key});

  @override
  State<OilTypeSelectionScreen> createState() => _OilTypeSelectionScreenState();
}

class _OilTypeSelectionScreenState extends State<OilTypeSelectionScreen> {
  String? selectedOilType;

  final List<Map<String, dynamic>> oilTypes = [
    {
      'type': 'Engine Oil',
      'description': 'Motor vehicle engine lubricants',
      'icon': Icons.directions_car,
      'color': Color(0xFF3B82F6),
    },
    {
      'type': 'Hydraulic Oil',
      'description': 'Hydraulic system fluids',
      'icon': Icons.build,
      'color': Color(0xFF8B5CF6),
    },
    {
      'type': 'Gear Oil',
      'description': 'Transmission and differential oils',
      'icon': Icons.settings,
      'color': Color(0xFF10B981),
    },
    {
      'type': 'Turbine Oil',
      'description': 'Gas and steam turbine lubricants',
      'icon': Icons.wind_power,
      'color': Color(0xFFF59E0B),
    },
    {
      'type': 'Compressor Oil',
      'description': 'Air and gas compressor lubricants',
      'icon': Icons.air,
      'color': Color(0xFFEF4444),
    },
    {
      'type': 'Transformer Oil',
      'description': 'Electrical transformer insulating oil',
      'icon': Icons.electrical_services,
      'color': Color(0xFF6366F1),
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
          'Select Oil Type',
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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2B5CE6), Color(0xFF1E40AF)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.science,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose Your Oil Type',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select the type of oil you want to analyze for the most accurate results',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),

          // Oil types grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: oilTypes.length,
                itemBuilder: (context, index) {
                  final oilType = oilTypes[index];
                  final isSelected = selectedOilType == oilType['type'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOilType = oilType['type'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: oilType['color'].withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                oilType['icon'],
                                size: 30,
                                color: oilType['color'],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              oilType['type'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF2B5CE6)
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              oilType['description'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
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
                              ),
                            ],
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
                if (selectedOilType != null)
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
                            'Selected: $selectedOilType',
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
                    text: 'Continue',
                    onPressed: selectedOilType != null
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DataInputMethodScreen(
                                  selectedOilType: selectedOilType!,
                                ),
                              ),
                            );
                          }
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select an oil type to continue',
                                ),
                              ),
                            );
                          },
                    backgroundColor: selectedOilType != null
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
