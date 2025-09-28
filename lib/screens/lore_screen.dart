import '../index.dart';

class LoreScreen extends StatefulWidget {
  const LoreScreen({super.key});

  @override
  State<LoreScreen> createState() => _LoreScreenState();
}

class _LoreScreenState extends State<LoreScreen> {
  final _geminiService = GeminiPlantService();
  Map<String, dynamic>? _dailyPlant;
  bool _isLoading = true;
  int _refreshCounter = 0; 

  @override
  void initState() {
    super.initState();
    _loadDailyPlant();
  }

  Future<void> _loadDailyPlant() async {
    setState(() {
      _isLoading = true;
    });

    if (_geminiService.isConfigured) {
      final aiPlant = await _geminiService.getDailyPlant(_refreshCounter);
      setState(() {
        _dailyPlant = aiPlant;
        _isLoading = false;
      });
      return;
    }

    final fallbackPlant = await _getFallbackDailyPlant();
    setState(() {
      _dailyPlant = fallbackPlant;
      _isLoading = false;
    });
  }

  Future<void> _refreshDailyPlant() async {
    _refreshCounter++;
    await _loadDailyPlant();
  }

  Future<Map<String, dynamic>> _getFallbackDailyPlant() async {
    final plants = await PlantDatabase.getCachedPlants();

    if (plants.isNotEmpty) {
      final today = DateTime.now();
      final dayOfYear = today.day + today.month * 31 + today.year * 365;
      final plantIndex = dayOfYear % plants.length;
      final selectedPlant = plants[plantIndex];

      return {
        'name': selectedPlant['name'],
        'scientific': selectedPlant['scientific'] ?? '',
        'story': selectedPlant['story'] ?? '',
        'facts': selectedPlant['facts'] ?? [],
        'traditionalUses': [],
        'region': 'Various regions across Nigeria',
        'imagePath': 'assets/images/${selectedPlant['name'].toString().toLowerCase().replaceAll(' ', '_')}.png',
        'generatedBy': 'Mock Database (Offline)',
        'isFallback': true,
      };
    }

    return _getHardcodedFallback();
  }

  Map<String, dynamic> _getHardcodedFallback() {
    return {
      'name': 'Moringa oleifera',
      'scientific': 'Moringa oleifera Lam.',
      'story': 'In Igbo lore, the moringa tree is known as "the miracle tree" or "mother\'s best friend." According to ancient tales, a wise healer discovered the tree during a great famine. The spirits blessed it with extraordinary powers to heal the weary traveler and nourish the hungry child.',
      'facts': [
        'Moringa leaves contain more vitamin C than oranges!',
        'Every part of the moringa tree is edible and nutritious.',
        'Ancient Egyptians used moringa oil for anointing their pharaohs.'
      ],
      'traditionalUses': [
        'Used in soups and stews for nutrition',
        'Leaves consumed as vegetables',
        'Seeds used for water purification'
      ],
      'region': 'Northern Nigeria, Sahel Region',
      'culturalSignificance': 'Symbol of resilience and the generous bounty of Mother Earth',
      'generatedBy': 'Hardcoded Fallback',
      'isFallback': true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lore of the Day'),
        centerTitle: true,
        backgroundColor: FloraTaleTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: FloraTaleTheme.earthyBrown.withOpacity(0.3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshDailyPlant,
            tooltip: 'Get new plant',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              FloraTaleTheme.background,
              FloraTaleTheme.lightBrown.withOpacity(0.1),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingLeaf(size: 80),
               
                  ],
                ),
              )
            : _dailyPlant != null
                ? _buildDailyLoreView()
                : _buildEmptyState(),
      ),
    );
  }

  Widget _buildDailyLoreView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Plant Name and Scientific Name
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Text(
                  _dailyPlant!['name'] ?? 'Unknown Plant',
                  textAlign: TextAlign.center,
              style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                color: FloraTaleTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
                  _dailyPlant!['scientific'] ?? 'Scientific name not available',
                  textAlign: TextAlign.center,
              style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                color: FloraTaleTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: FloraTaleTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _dailyPlant!['region'] ?? 'Various regions across Nigeria',
                    style: const TextStyle(
                      fontSize: 14,
                      color: FloraTaleTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
          ],
        ),
      ),

          const SizedBox(height: 24),

          // Myth Section
          if ((_dailyPlant!['myth'] ?? _dailyPlant!['story'] ?? '').isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        color: FloraTaleTheme.primaryGreen,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Myth',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: FloraTaleTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _dailyPlant!['myth'] ?? _dailyPlant!['story'] ?? 'Traditional myth not available for this plant.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: FloraTaleTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],


          // Interesting Facts Section
          if (_dailyPlant!['facts'] != null && (_dailyPlant!['facts'] as List).isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: FloraTaleTheme.primaryGreen,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Fascinating Facts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: FloraTaleTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...(_dailyPlant!['facts'] as List<dynamic>? ?? []).map<Widget>((fact) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FloraTaleTheme.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          decoration: const BoxDecoration(
                            color: FloraTaleTheme.accentGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            fact?.toString() ?? 'Fact not available',
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: FloraTaleTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: FloraTaleTheme.primaryGreen.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No plant lore available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: FloraTaleTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to load today\'s featured plant. Please try again later.',
              style: TextStyle(
                fontSize: 16,
                color: FloraTaleTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}

