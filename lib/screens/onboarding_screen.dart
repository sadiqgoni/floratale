import '../index.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Discover Nigeria\'s\nPlant Heritage',
      subtitle: 'Explore the rich botanical diversity of Nigeria through the lens of our cultural heritage and traditional knowledge.',
      imagePath: 'nature_heritage',
      backgroundColor: FloraTaleTheme.primaryGreen.withOpacity(0.1),
    ),
    OnboardingPageData(
      title: 'Ancient Stories &\nModern Science',
      subtitle: 'Learn fascinating folklore and traditional uses while discovering scientific facts about Nigeria\'s medicinal plants.',
      imagePath: 'stories_science',
      backgroundColor: FloraTaleTheme.accentGreen.withOpacity(0.1),
    ),
    OnboardingPageData(
      title: 'Snap, Identify &\nSave Plants',
      subtitle: 'Take photos of plants, get instant identification, and build your personal collection of Nigeria\'s botanical treasures.',
      imagePath: 'camera_collection',
      backgroundColor: FloraTaleTheme.earthyBrown.withOpacity(0.1),
    ),
    OnboardingPageData(
      title: 'Grow Your\nKnowledge',
      subtitle: 'Access care guides, growing tips, and cultivation advice to bring Nigeria\'s plant heritage into your own garden.',
      imagePath: 'grow_knowledge',
      backgroundColor: FloraTaleTheme.ochre.withOpacity(0.1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: FloraTaleTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageData page) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            page.backgroundColor,
            Colors.white,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
                width: 2,
              ),
            ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  _getImagePath(page.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(page.imagePath),
                ),
              ),
          ),

          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: FloraTaleTheme.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: FloraTaleTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Page indicators
        Row(
          children: List.generate(
            _pages.length,
            (index) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? FloraTaleTheme.primaryGreen
                    : FloraTaleTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        // Navigation buttons
        Row(
          children: [
            if (_currentPage > 0)
              TextButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text(
                  'Back',
                  style: TextStyle(
                    color: FloraTaleTheme.primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(width: 20),

            ElevatedButton(
              onPressed: _currentPage == _pages.length - 1
                  ? _completeOnboarding
                  : () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: FloraTaleTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getImagePath(String imagePath) {
    switch (imagePath) {
      case 'nature_heritage':
        return 'assets/images/onboarding_1.png';
      case 'stories_science':
        return 'assets/images/onboarding_2.png';
      case 'camera_collection':
        return 'assets/images/onboarding_3.png';
      case 'grow_knowledge':
        return 'assets/images/onboarding_4.png';
      default:
        return 'assets/images/onboarding_1.png';
    }
  }

  IconData _getPageIcon(String imagePath) {
    switch (imagePath) {
      case 'nature_heritage':
        return Icons.nature;
      case 'stories_science':
        return Icons.menu_book;
      case 'camera_collection':
        return Icons.camera_alt;
      case 'grow_knowledge':
        return Icons.eco;
      default:
        return Icons.local_florist;
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (e) {
      // Proceed to main navigation even if persisting fails
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(),
      ),
    );
  }

  Widget _buildFallbackIcon(String imagePath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getPageIcon(imagePath),
          size: 80,
          color: FloraTaleTheme.primaryGreen,
        ),
        const SizedBox(height: 20),
        Text(
          imagePath.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: FloraTaleTheme.textSecondary,
            letterSpacing: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '404 NOT FOUND',
          style: TextStyle(
            fontSize: 12,
            color: FloraTaleTheme.textSecondary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color backgroundColor;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.backgroundColor,
  });
}
