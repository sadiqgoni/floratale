import '../index.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens =  [
    HomeScreen(),
    HerbariumScreen(),
    LoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: FloraTaleTheme.primaryGreen,
        unselectedItemColor: FloraTaleTheme.textSecondary,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_florist),
            label: 'Herbarium',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Lore',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 1) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                HerbariumScreen.refreshData(context);
              }
            });
          }
        },
      ),
    );
  }
}
