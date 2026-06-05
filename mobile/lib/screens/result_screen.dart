import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultScreen({super.key, required this.imagePath, required this.result});

  Color get _severityColor {
    switch (result['severity']) {
      case 'High': return const Color(0xFFEF4444);
      case 'Moderate': return const Color(0xFFF59E0B);
      case 'None': return const Color(0xFF10B981);
      default: return const Color(0xFF6B7280);
    }
  }

  Color get _severityBg {
    switch (result['severity']) {
      case 'High': return const Color(0xFFEF4444).withOpacity(0.15);
      case 'Moderate': return const Color(0xFFF59E0B).withOpacity(0.15);
      case 'None': return const Color(0xFF10B981).withOpacity(0.15);
      default: return const Color(0xFF6B7280).withOpacity(0.15);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (result['confidence'] as num).toDouble();
    final disease = result['disease'] as String;
    final symptoms = List<String>.from(result['symptoms'] ?? []);
    final isHealthy = result['severity'] == 'None';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildResultCard(disease, confidence, isHealthy),
                  const SizedBox(height: 16),
                  if (!isHealthy && symptoms.isNotEmpty) ...[
                    _buildSection('Symptoms', Icons.sick_rounded, const Color(0xFFF59E0B), _buildSymptoms(symptoms)),
                    const SizedBox(height: 16),
                  ],
                  _buildSection('Treatment', Icons.medical_services_rounded, const Color(0xFF3B82F6),
                    _buildText(result['treatment'] ?? 'No treatment info available.')),
                  const SizedBox(height: 16),
                  _buildSection('Prevention', Icons.shield_rounded, const Color(0xFF10B981),
                    _buildText(result['prevention'] ?? 'No prevention info available.')),
                  const SizedBox(height: 16),
                  _buildUrgencyBanner(),
                  const SizedBox(height: 24),
                  _buildScanAgainButton(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: const Color(0xFF023E8A),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
      ),
      title: const Text('Analysis Result', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(imagePath), fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String disease, double confidence, bool isHealthy) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diagnosis', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text(disease, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(color: _severityBg, borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        result['severity'] ?? 'Unknown',
                        style: TextStyle(color: _severityColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              CircularPercentIndicator(
                radius: 48,
                lineWidth: 8,
                percent: (confidence / 100).clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${confidence.toStringAsFixed(0)}%',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: _severityColor)),
                    const Text('match', style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8))),
                  ],
                ),
                progressColor: _severityColor,
                backgroundColor: const Color(0xFFF1F5F9),
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14)),
            child: Text(
              result['description'] ?? '',
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 14),
          content,
        ],
      ),
    );
  }

  Widget _buildSymptoms(List<String> symptoms) {
    return Column(
      children: symptoms.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 6, height: 6,
              decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(s, style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.4))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildText(String text) {
    return Text(text, style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.6));
  }

  Widget _buildUrgencyBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _severityBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _severityColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, color: _severityColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(result['urgency'] ?? '',
                style: TextStyle(color: _severityColor, fontWeight: FontWeight.w600, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildScanAgainButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF023E8A), Color(0xFF0077B6)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: const Color(0xFF0077B6).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text('Scan Another Fish', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }
}
