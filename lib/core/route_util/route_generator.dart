import 'package:flutter/material.dart';
import '../../app.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/pin_auth_screen.dart';
import '../../ui/screens/splash_screen.dart';
import 'route_names.dart';

class RouteGenerator {
  static Route<T>? onGenerateRoute<T>(RouteSettings settings) {
    debugPrint("🟢navigate To -> ${settings.name}");
    switch (settings.name) {
      case RouteNames.splashScreen:
        return _navigateRoute(
          settings: settings,
          builder: (context) {
            return const SplashScreen();
          },
        );
      case RouteNames.app:
        return _navigateRoute(
          settings: settings,
          builder: (context) {
            return const CheyNgarApplication();
          },
        );
      case RouteNames.loginScreen:
        return _navigateRoute(
          settings: settings,
          builder: (context) {
            return const PinAuthScreen();
            // return const LoginScreen();
          },
        );
      default:
        return _navigateRoute(
          settings: settings,
          builder: (context) => const NoRouteScreen(),
        );
    }
  }

  static Route<T>? _navigateRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}

class NoRouteScreen extends StatelessWidget {
  const NoRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Oop!..")),
      body: Center(
        child: Card.filled(
          child: Column(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "404!",
                style: TextStyle(color: Colors.red, fontSize: 50),
              ),
              const Text(
                "Page Not Found",
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.2,
                ),
                title: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Back"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
