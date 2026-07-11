import 'dart:io';
import 'package:flutter/material.dart';
import '../l10n/app_language.dart';
import '../l10n/strings.dart';
import '../l10n/disease_translations.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ResultScreen(
      {super.key, required this.imagePath, required this.result});

  String get _diseaseKey => result['disease'] as String;
  bool get _isHealthy => _diseaseKey == 'Healthy Fish';
  bool get _isConfident => result['is_confident'] == true;
  bool get _isFish => result['is_fish'] != false;
  Map<String, dynamic>? get _bn => diseaseInfoBn[_diseaseKey];

  String _localizedName(bool isBn) {
    if (isBn) return _bn?['name'] as String? ?? _diseaseKey;
    return _diseaseKey;
  }

  String _localizedField(bool isBn, String field) {
    if (isBn && _bn != null) return _bn![field] as String? ?? '';
    return result[field] as String? ?? '';
  }

  List<String> _localizedSymptoms(bool isBn) {
    if (isBn && _bn != null) {
      return List<String>.from(_bn!['symptoms'] ?? []);
    }
    return List<String>.from(result['symptoms'] ?? []);
  }

  Color get _statusColor {
    if (!_isFish) return const Color(0xFF64748B);
    if (!_isConfident) return const Color(0xFFF59E0B);
    if (_isHealthy) return const Color(0xFF10B981);
    return const Color(0xFFEF4444);
  }

  String _statusLabel(bool isBn) {
    if (!_isFish) return S.of('not_fish_title', isBn ? AppLanguage.bn : AppLanguage.en);
    if (!_isConfident) {
      return '${S.of('possible', isBn ? AppLanguage.bn : AppLanguage.en)}: ${_localizedName(isBn)}';
    }
    if (_isHealthy) return S.of('healthy_fish', isBn ? AppLanguage.bn : AppLanguage.en);
    return S.of('disease_found', isBn ? AppLanguage.bn : AppLanguage.en);
  }

  IconData get _statusIcon {
    if (!_isFish) return Icons.image_not_supported_rounded;
    if (!_isConfident) return Icons.help_rounded;
    if (_isHealthy) return Icons.check_circle_rounded;
    return Icons.warning_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLanguage,
      builder: (context, lang, _) {
        final isBn = lang == AppLanguage.bn;
        final disease = _localizedName(isBn);
        final symptoms = _localizedSymptoms(isBn);

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
                      Text(S.of('result', lang),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF023E8A))),
                      const Spacer(),
                      _buildLangToggle(),
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
                                _statusLabel(isBn),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor),
                              ),
                              if (_isFish && _isConfident && !_isHealthy) ...[
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
                              if (_isFish && !_isConfident) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '${result['confidence']}% ${S.of('confidence_note', lang)}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 13,
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
                          title: S.of('what_it_means', lang),
                          body: _isFish
                              ? _localizedField(isBn, 'description')
                              : S.of('not_fish_message', lang),
                        ),

                        // Symptoms (only if sick)
                        if (_isFish && !_isHealthy && symptoms.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _buildListCard(
                            emoji: '🔍',
                            title: S.of('signs_to_look_for', lang),
                            items: symptoms,
                          ),
                        ],

                        if (_isFish) ...[
                          const SizedBox(height: 14),
                          // What to do
                          _buildCard(
                            emoji: _isHealthy ? '✅' : '💊',
                            title: S.of('what_to_do', lang),
                            body: _localizedField(isBn, 'treatment'),
                            highlight: !_isHealthy,
                          ),

                          const SizedBox(height: 14),
                          // How to prevent
                          _buildCard(
                            emoji: '🛡️',
                            title: S.of('how_to_prevent', lang),
                            body: _localizedField(isBn, 'prevention'),
                          ),
                        ],

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
                                    color:
                                        const Color(0xFF0077B6).withOpacity(0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6))
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 24),
                                const SizedBox(width: 10),
                                Text(S.of('check_another', lang),
                                    style: const TextStyle(
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
      },
    );
  }

  Widget _buildLangToggle() {
    Widget segment(String label, AppLanguage value) {
      final active = appLanguage.value == value;
      return GestureDetector(
        onTap: () => appLanguage.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF0077B6) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          segment('EN', AppLanguage.en),
          segment('বাং', AppLanguage.bn),
        ],
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
