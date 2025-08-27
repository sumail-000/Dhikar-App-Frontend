import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'services/api_client.dart';
import 'profile_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Initialize fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start fade animation
    _fadeController.forward();

    // After splash, gate by auth token
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
      }
      // Validate token via /auth/me
      final resp = await ApiClient.instance.me();
      if (!mounted) return;
      if (resp.ok) {
        if (mounted) {
          context.read<ProfileProvider?>()?.setFromMap(resp.data as Map<String, dynamic>);
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        await ApiClient.instance.clearToken();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: 440,
        height: 956,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF251629), const Color(0xFF4C3B6E)]
                : [const Color(0xFF163832), const Color(0xFF235347)],
          ),
        ),
        child: Stack(
          children: [
            // Background image (bottom layer)
            Positioned.fill(
              child: Opacity(
                opacity: isDarkMode ? 0.5 : 1.0,
                child: Image.asset(
                  'assets/background_elements/3_background.png',
                  width: 440,
                  height: 956,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Center Arabic text (Bismillah) with fade-in animation (middle layer)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 24,
              right: 24,
              child: Center(
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Image.asset(
                        'assets/splash/﷽.png',
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Top left decorative elements (lanterns) - front layer
            Positioned(
              top: 0,
              left: 20,
              child: Image.asset(
                isDarkMode
                    ? 'assets/background_elements/1.png'
                    : 'assets/background_elements/1_LE.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),

            // Bottom mosque silhouette - front layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                isDarkMode
                    ? 'assets/background_elements/2.png'
                    : 'assets/background_elements/2_LE.png',
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
