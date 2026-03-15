import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/styled_input.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;
  String? _emailError;
  String? _passwordError;

  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    String? emailErr;
    String? passErr;
    if (!_emailCtrl.text.contains('@')) emailErr = 'Enter a valid email';
    if (_passwordCtrl.text.length < 6) {
      passErr = 'Password must be at least 6 characters';
    }
    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });
    return emailErr == null && passErr == null;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;
    try {
      await context.read<AuthProvider>().signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      // ← Add this: navigate on success
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/main', (_) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Something wrong happened, please try again later!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background geometry
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Fine grid pattern (decorative)
          const Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: GridPaper(
                color: AppColors.primary,
                divisions: 1,
                subdivisions: 1,
                interval: 40,
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Column(
                    children: [
                      // ── Logo ──
                      Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              boxShadow: AppShadows.goldGlow,
                            ),
                            child: const Center(
                              child: Text(
                                '⌂',
                                style: TextStyle(
                                  fontSize: 34,
                                  color: AppColors.background,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'HOMESPOT',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 1,
                                width: 24,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'TUNISIA PREMIER REAL ESTATE',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textMuted,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 1,
                                width: 24,
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // ── Card ──
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                          boxShadow: AppShadows.large,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gold accent top bar
                            Container(
                              height: 2,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to your account',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            StyledInput(
                              label: 'Email Address',
                              controller: _emailCtrl,
                              placeholder: 'your@email.com',
                              keyboardType: TextInputType.emailAddress,
                              error: _emailError,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            StyledInput(
                              label: 'Password',
                              controller: _passwordCtrl,
                              placeholder: '• • • • • • • •',
                              obscureText: !_showPassword,
                              error: _passwordError,
                              rightIcon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onRightIconPress: () =>
                                  setState(() => _showPassword = !_showPassword),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            GradientButton(
                              label: 'Sign In',
                              onPress: _handleLogin,
                              loading: loading,
                              size: ButtonSize.lg,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?  ",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.of(context).pushNamed('/register'),
                            child: const Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}