import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultScreen(
      {super.key, required this.imagePath, required this.result});

  bool get _isHealthy => result['severity'] == 'None';
  bool get _isUnknown => result['severity'] == 'Unknown';

  Color get _statusColor {
    if (_isHealthy) return const Color(0xFF10B981);
    if (_isUnknown) return const Color(0xFF6B7280);
    return const Color(0xFFEF4444);
  }

  String get _statusLabel {
    if (_isHealthy) return 'Healthy Fish';
    if (_isUnknown) return 'Not Sure';
    return 'Disease Found';
  }

  IconData get _statusIcon {
    if (_isHealthy) return Icons.check_circle_rounded;
    if (_isUnknown) return Icons.help_rounded;
    return Icons.warning_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final disease = result['disease'] as String;
    final symptoms = List<String>.from(result['symptoms'] ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFF023E8A), size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Result',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF023E8A))),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    // Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(File(imagePath),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 20),

                    // BIG status verdict
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(_statusIcon, color: _statusColor, size: 56),
                          const SizedBox(height: 12),
                          Text(
                            _statusLabel,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _statusColor),
                          ),
                          if (!_isHealthy && !_isUnknown) ...[
                            const SizedBox(height: 4),
                            Text(
                              disease,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // What it means
                    _buildCard(
                      emoji: '📋',
                      title: 'What it means',
                      body: result['description'] ?? '',
                    ),

                    // Symptoms (only if sick)
                    if (!_isHealthy && symptoms.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _buildListCard(
                        emoji: '🔍',
                        title: 'Signs to look for',
                        items: symptoms,
                      ),
                    ],

                    const SizedBox(height: 14),
                    // What to do
                    _buildCard(
                      emoji: _isHealthy ? '✅' : '💊',
                      title: 'What to do',
                      body: result['treatment'] ?? '',
                      highlight: !_isHealthy,
                    ),

                    const SizedBox(height: 14),
                    // How to prevent
                    _buildCard(
                      emoji: '🛡️',
                      title: 'How to prevent',
                      body: result['prevention'] ?? '',
                    ),

                    const SizedBox(height: 24),

                    // Scan again
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077B6),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF0077B6).withOpacity(0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6))
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(width: 10),
                            Text('Check Another Fish',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String emoji,
    required String title,
    required String body,
    bool highlight = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: highlight
            ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 10),
          Text(body,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF475569), height: 1.6)),
        ],
      ),
    );
  }

  Widget _buildListCard({
    required String emoji,
    required String title,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: Color(0xFF0077B6), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(s,
                            style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF475569),
                                height: 1.4))),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
