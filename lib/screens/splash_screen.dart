import 'dart:async';
import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import '../services/api_service.dart';
import 'bottom_nav_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _animationController.forward();
    _startLoading();
  }

  void _startLoading() {
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        progress += 0.02;
      });
      if (progress >= 1.0) {
        timer.cancel();
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            // Check if user is authenticated
            if (ApiService.isAuthenticated()) {
              // If authenticated, go to the dashboard with bottom navigation
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BottomNavScaffold(),
                ),
              );
            } else {
              // If not authenticated, go to the welcome screen for login
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
              );
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2B5CE6), Color(0xFF1E40AF), Color(0xFFEAB308)],
            stops: [0.0, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated logo container
              ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(38), // 0.15
                    shape: BoxShape.circle,
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.science, size: 60, color: Colors.white),
                      Positioned(
                        top: 15,
                        right: 20,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 24,
                          color: Color(0xFFEAB308),
                        ),
                      ),
                      Positioned(
                        bottom: 25,
                        left: 20,
                        child: Icon(
                          Icons.opacity,
                          size: 20,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // App title
              const Text(
                'OilGuard AI',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Advanced Oil Quality Analysis',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),

              const Spacer(),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withAlpha(77), // 0.3
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFEAB308),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Loading text
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on, color: Color(0xFFEAB308), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Loading Spectroscopic Models...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(
                        (((progress * 3 - index).clamp(0.3, 1.0)) * 255)
                            .toInt(),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
