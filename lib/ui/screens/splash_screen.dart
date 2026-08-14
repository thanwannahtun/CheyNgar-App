import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/extensions/navigator_extension.dart';
import 'package:flutter/material.dart';
import '../../../core/env.dart';
import '../../../core/route_util/route_names.dart';
import '../../../data/share_preference.dart';
import '../../bloc/contacts/contacts_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double>
  _shimmerSlide; // Drives the theater flashlight beam sweep
  late Animation<double> _letterSpacing; // Dynamic horizontal layout expander

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// Fetch initial Contacts or wake up the server
    context.read<ContactsCubit>().fetchContacts();
    // delayAndNavigateHomeScreen();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200), // Longer cinematic duration
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.linearToEaseOut),
      ),
    );

    // Moves the studio specular light flare from left (-2.0) to right (+2.0)
    _shimmerSlide = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeInOut),
      ),
    );

    _letterSpacing = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.fastLinearToSlowEaseIn),
      ),
    );

    _controller.forward();

    /// Navigate based on token existence

    Future.delayed(const Duration(seconds: 3), () async {
      // await SharePreference.instance.remove(Env.accessToken);

      if (!mounted) return;
      final token = await SharePreference.instance.getString(Env.accessToken);
      if (!mounted) {
        return;
      }

      if (token != null) {
        context.pushNamedAndRemoveUntil(RouteNames.app, (_) => false);
      } else {
        context.pushNamedAndRemoveUntil(RouteNames.loginScreen, (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF070A12,
      ), // Cinematic deep obsidian darkroom base
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient background theater light beam backdrop
          AnimatedBuilder(
            animation: _scale,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8 * _scale.value,
                    colors: [
                      const Color(0xFF1E3A8A).withValues(
                        alpha: 0.15,
                      ), // Deep blue anamorphic flare glow
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // Foreground Animated Metallic Typography
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: const [
                            Color(0xFFE2E8F0), // Platinum
                            Color(0xFF94A3B8), // Brushed Aluminum
                            Colors.white, // Pure Specular Reflection Highlight
                            Color(0xFF475569), // Dark Chrome
                            Color(0xFFE2E8F0), // Platinum
                          ],
                          stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                          transform: GradientTransformSlide(
                            _shimmerSlide.value,
                          ),
                        ).createShader(bounds);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "NaYa",
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 64,
                                  letterSpacing: _letterSpacing.value,
                                  height: 1.0,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "MYANMAR",
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  letterSpacing: _letterSpacing.value * 1.2,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom vector transformation class to offset gradient projections without external plugins
class GradientTransformSlide extends GradientTransform {
  final double dx;
  const GradientTransformSlide(this.dx);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * dx, 0.0, 0.0);
  }
}
