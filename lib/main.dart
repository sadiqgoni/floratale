import 'index.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlantDatabase.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      setState(() {
        _showOnboarding = !onboardingCompleted;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _showOnboarding = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'FloraTale',
      theme: FloraTaleTheme.lightTheme,
      home: _showOnboarding ? const OnboardingScreen() : const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
