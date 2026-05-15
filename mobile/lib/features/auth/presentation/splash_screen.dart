import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _slideAnim;

  bool _minDelayPassed = false;
  bool _authResolved = false;
  AuthState? _resolvedState;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Minimum splash display time — animation plays fully before navigating
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _minDelayPassed = true;
      _tryNavigate();
    });
  }

  void _tryNavigate() {
    if (!_minDelayPassed || !_authResolved || !mounted) return;
    if (_resolvedState is AuthAuthenticated) {
      context.go('/services');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (ctx, state) {
        if (state is AuthAuthenticated ||
            state is AuthUnauthenticated ||
            state is AuthFailure) {
          _authResolved = true;
          _resolvedState = state;
          _tryNavigate();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                AnimatedBuilder(
                  animation: _slideAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _slideAnim.value),
                    child: FadeTransition(opacity: _fadeAnim, child: child),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'MenteCart',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'SMART SERVICES',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                          letterSpacing: 4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}