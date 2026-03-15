import 'package:flutter/material.dart';
import 'package:homespot/screens/register_screen.dart';
import 'package:provider/provider.dart';
import '../models/advert.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/main_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/crud_screen.dart';
import '../screens/advert_form_screen.dart';
import '../theme/app_theme.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/main':
        return MaterialPageRoute(
          builder: (_) => const AuthListener(child: MainScreen()),
        );
      case '/crud':
        return MaterialPageRoute(
          builder: (_) => const AuthListener(child: CRUDScreen()),
        );
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/detail':
        final advert = settings.arguments as Advert?;
        if (advert == null) {
          return MaterialPageRoute(builder: (_) => const MainScreen());
        }
        return MaterialPageRoute(builder: (_) => DetailScreen(advert: advert));
      case '/advert-form':
        final advert = settings.arguments as Advert?;
        return MaterialPageRoute(
          builder: (_) => AdvertFormScreen(existing: advert),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen());
    }
  }
}

class RootNavigator extends StatelessWidget {
  const RootNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        return MaterialApp(
          title: 'HomeSpot',
          theme: AppTheme.dark,
          debugShowCheckedModeBanner: false,
          home: const AuthGate(),         // ← stable home, never crashes
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}

/// Watches auth state and navigates imperatively — never causes a rebuild crash.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  void _navigate() {
    final auth = context.read<AuthProvider>();
    final target = auth.isLoggedIn ? '/main' : '/login';
    Navigator.of(context).pushReplacementNamed(target);
  }

  @override
  Widget build(BuildContext context) {
    // Shown for one frame at most while the post-frame callback fires
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class AuthListener extends StatefulWidget {
  final Widget child;
  const AuthListener({super.key, required this.child});

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener> {
  late AuthProvider _auth;   // ← save reference here

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Safe place to read inherited widgets — called before initState completes
    _auth = context.read<AuthProvider>();
  }

  @override
  void initState() {
    super.initState();
    // Listener added after didChangeDependencies runs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _auth.addListener(_onAuthChange);
    });
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChange);  // ← uses saved reference, no context needed
    super.dispose();
  }

  void _onAuthChange() {
    if (!_auth.isLoggedIn && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}