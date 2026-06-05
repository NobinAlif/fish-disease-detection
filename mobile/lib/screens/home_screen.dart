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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked == null) return;
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.predictDisease(File(picked.path));
      if (!mounted) return;
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, b) => ResultScreen(imagePath: picked.path, result: result),
          transitionsBuilder: (_, a, b, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed. Make sure the server is awake.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoading() : _buildHome(),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF03045E), Color(0xFF0077B6), Color(0xFF00B4D8)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitRipple(color: Colors.white, size: 80),
            SizedBox(height: 32),
            Text('Analyzing...', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1)),
            SizedBox(height: 8),
            Text('AI is scanning the image', style: TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF03045E), Color(0xFF023E8A), Color(0xFF0077B6)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeroSection(),
                      const SizedBox(height: 36),
                      _buildScanButton(),
                      const SizedBox(height: 16),
                      _buildGalleryButton(),
                      const SizedBox(height: 36),
                      _buildDiseaseGrid(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FishScan AI', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              Text('Disease Detection', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.set_meal_rounded, size: 56, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Detect Fish Disease\nInstantly',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 10),
        Text(
          'Point your camera at a fish to get\nan AI-powered diagnosis in seconds',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () => _pickAndAnalyze(ImageSource.camera),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_rounded, color: Color(0xFF023E8A), size: 26),
            SizedBox(width: 12),
            Text('Scan with Camera', style: TextStyle(color: Color(0xFF023E8A), fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: () => _pickAndAnalyze(ImageSource.gallery),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_rounded, color: Colors.white, size: 26),
            SizedBox(width: 12),
            Text('Upload from Gallery', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseGrid() {
    final diseases = [
      ('🦠', 'Bacterial Red', 'High Risk'),
      ('🧫', 'Aeromoniasis', 'High Risk'),
      ('🐟', 'Gill Disease', 'Moderate'),
      ('🍄', 'Fungal', 'Moderate'),
      ('🐛', 'Parasitic', 'Moderate'),
      ('🦠', 'Viral', 'High Risk'),
      ('✅', 'Healthy', 'Normal'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detectable Conditions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
          ),
          itemCount: diseases.length,
          itemBuilder: (_, i) {
            final d = diseases[i];
            final isHealthy = d.$3 == 'Normal';
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.$1, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 6),
                  Text(d.$2, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isHealthy ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(d.$3, style: TextStyle(color: isHealthy ? Colors.greenAccent : Colors.redAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
