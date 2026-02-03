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
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void delayAndNavigateHomeScreen() {
    _timer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (timer) => Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteNames.app, (route) => false),
    );
  }

  @override
  void initState() {
    super.initState();

    /// Fetch initial Contacts or wake up the server
    context.read<ContactsCubit>().fetchContacts();
    // delayAndNavigateHomeScreen();

    /// Animation Setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

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
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Text(
              "JLP Group Myanmar",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
