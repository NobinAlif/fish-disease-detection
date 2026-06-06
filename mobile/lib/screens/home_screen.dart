import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
      requestFullMetadata: false,
    );
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.predictDisease(File(picked.path));
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) =>
              ResultScreen(imagePath: picked.path, result: result),
          transitionsBuilder: (_, a, b, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      body: _isLoading ? _buildLoading() : _buildHome(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCube(color: Color(0xFF0077B6), size: 50),
          SizedBox(height: 28),
          Text(
            'Checking your fish...',
            style: TextStyle(
                fontSize: 18,
                color: Color(0xFF023E8A),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Simple header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077B6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.set_meal_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'FishScan',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF023E8A)),
                ),
              ],
            ),

            const Spacer(flex: 2),

            // Big friendly illustration circle
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE1F0FA),
                ),
                child: const Icon(Icons.set_meal_rounded,
                    size: 90, color: Color(0xFF0077B6)),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Take a photo of\nyour fish',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF023E8A),
                height: 1.25,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We will check if it is healthy or sick,\nand tell you what to do.',
              style: TextStyle(
                  fontSize: 16, color: Color(0xFF64748B), height: 1.5),
            ),

            const Spacer(flex: 3),

            // PRIMARY action — big camera button
            _buildBigButton(
              icon: Icons.camera_alt_rounded,
              label: 'Open Camera',
              filled: true,
              onTap: () => _pickAndAnalyze(ImageSource.camera),
            ),
            const SizedBox(height: 14),
            // SECONDARY action
            _buildBigButton(
              icon: Icons.photo_library_rounded,
              label: 'Choose from Gallery',
              filled: false,
              onTap: () => _pickAndAnalyze(ImageSource.gallery),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton({
    required IconData icon,
    required String label,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFF0077B6) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: filled
              ? null
              : Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: filled
              ? [
                  BoxShadow(
                      color: const Color(0xFF0077B6).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: filled ? Colors.white : const Color(0xFF0077B6),
                size: 26),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : const Color(0xFF023E8A),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
