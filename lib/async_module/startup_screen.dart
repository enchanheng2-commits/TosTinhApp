import 'dart:math' as math;

import 'package:flutter/material.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    final introCurve = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(introCurve);
    _scaleAnimation = Tween<double>(begin: 0.84, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(introCurve);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FF),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFEFCFF), Color(0xFFF7EEFF), Color(0xFFEEDCFF)],
          ),
        ),
        child: Stack(
          children: [
            const _AtmosphereOrb(
              alignment: Alignment(-0.95, -1.0),
              size: 280,
              color: Color(0xFFE7C9FF),
            ),
            const _AtmosphereOrb(
              alignment: Alignment(1.05, -0.2),
              size: 220,
              color: Color(0xFFD5B1FF),
            ),
            const _AtmosphereOrb(
              alignment: Alignment(-0.9, 1.0),
              size: 240,
              color: Color(0xFFF2D8FF),
            ),
            const _GlowBlob(
              alignment: Alignment(-1.05, -0.95),
              color: Color(0xFFD8B3FF),
              size: 200,
            ),
            const _GlowBlob(
              alignment: Alignment(1.05, 0.85),
              color: Color(0xFFC59DFF),
              size: 180,
            ),
            const _GlowBlob(
              alignment: Alignment(0.85, -0.15),
              color: Color(0xFFE7C3FF),
              size: 110,
            ),
            Positioned(
              left: -60,
              top: 220,
              child: Transform.rotate(
                angle: -0.35,
                child: Container(
                  width: 220,
                  height: 420,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(90),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              'Tos Tinh',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                    color: colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 320,
                                        height: 220,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white.withValues(
                                                alpha: 0.36,
                                              ),
                                              Colors.white.withValues(alpha: 0),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Image.asset(
                                        'lib/assets/tostinh_logo.png',
                                        width: 280,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Preparing your storefront',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF281E3F),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Curating products and restoring your session.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: const Color(0xFF6D5A83),
                                    height: 1.4,
                                  ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: 220,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  minHeight: 10,
                                  valueColor: AlwaysStoppedAnimation(
                                    colorScheme.primary,
                                  ),
                                  backgroundColor: const Color(
                                    0xFFE9DBFF,
                                  ).withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Loading...',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: const Color(0xFF7A4DFF),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ],
                        ),
                      ),
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
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: math.pi / 7,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.42),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AtmosphereOrb extends StatelessWidget {
  const _AtmosphereOrb({
    required this.alignment,
    required this.size,
    required this.color,
  });

  final Alignment alignment;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.55),
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}
