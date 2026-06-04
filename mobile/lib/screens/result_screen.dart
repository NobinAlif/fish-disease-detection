import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  Color get _severityColor {
    switch (result['severity']) {
      case 'High':
        return Colors.red;
      case 'Moderate':
        return Colors.orange;
      case 'None':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get _severityIcon {
    switch (result['severity']) {
      case 'High':
        return Icons.warning_rounded;
      case 'Moderate':
        return Icons.info_rounded;
      case 'None':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (result['confidence'] as num).toDouble();
    final disease = result['disease'] as String;
    final symptoms = List<String>.from(result['symptoms'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('Analysis Result'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fish image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Disease name + severity badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(_severityIcon, color: _severityColor, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          disease,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF023E8A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          result['severity'] ?? 'Unknown',
                          style: TextStyle(
                            color: _severityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Confidence bar
                  CircularPercentIndicator(
                    radius: 55,
                    lineWidth: 10,
                    percent: (confidence / 100).clamp(0.0, 1.0),
                    center: Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0077B6),
                      ),
                    ),
                    header: const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Confidence',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    progressColor: const Color(0xFF0077B6),
                    backgroundColor: const Color(0xFFE0F2FE),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    result['description'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Symptoms
            if (symptoms.isNotEmpty) ...[
              _buildCard(
                title: 'Symptoms',
                icon: Icons.sick_rounded,
                iconColor: Colors.orange,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: symptoms
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ',
                                    style:
                                        TextStyle(color: Color(0xFF0077B6))),
                                Expanded(
                                  child: Text(s,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Treatment
            _buildCard(
              title: 'Treatment',
              icon: Icons.medical_services_rounded,
              iconColor: Colors.blue,
              child: Text(
                result['treatment'] ?? 'No treatment info available.',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),

            // Prevention
            _buildCard(
              title: 'Prevention',
              icon: Icons.shield_rounded,
              iconColor: Colors.green,
              child: Text(
                result['prevention'] ?? 'No prevention info available.',
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 12),

            // Urgency
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _severityColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: _severityColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      result['urgency'] ?? '',
                      style: TextStyle(
                        color: _severityColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Scan again button
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Another Fish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF023E8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
