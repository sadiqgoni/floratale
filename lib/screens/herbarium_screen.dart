import 'dart:convert';
import 'dart:io';
import '../index.dart';

class HerbariumScreen extends StatefulWidget {
  const HerbariumScreen({super.key});

  @override
  State<HerbariumScreen> createState() => _HerbariumScreenState();

  static void refreshData(BuildContext context) {
    final state = context.findAncestorStateOfType<_HerbariumScreenState>();
    state?._loadSavedPlants();
  }
}

class _HerbariumScreenState extends State<HerbariumScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _savedPlants = [];
  List<Map<String, dynamic>> _filteredPlants = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedPlants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes visible again
    _loadSavedPlants();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSavedPlants();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPlants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPlantsJson = prefs.getStringList('saved_plants') ?? [];


      setState(() {
        _savedPlants = savedPlantsJson.map((json) => _parsePlantData(json)).toList();

        _filteredPlants = List.from(_savedPlants);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading saved plants: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _parsePlantData(String json) {
    try {
      final plant = jsonDecode(json) as Map<String, dynamic>;
      
      if (plant['savedAt'] != null) {
        try {
          plant['savedAt'] = DateTime.parse(plant['savedAt']);
        } catch (e) {
          plant['savedAt'] = DateTime.now();
        }
      }

      return {
        'name': plant['name'] ?? 'Unknown Plant',
        'scientificName': plant['scientificName'] ?? '',
        'story': plant['story'] ?? '',
        'facts': plant['facts'] ?? [],
        'careGuide': plant['careGuide'] ?? {},
        'imagePath': plant['imagePath'],
        'savedAt': plant['savedAt'] ?? DateTime.now(),
      };
    } catch (e) {
      return {
        'name': 'Corrupted Plant',
        'scientificName': '',
        'story': 'This plant data was corrupted and could not be loaded.',
        'facts': ['Data corrupted'],
        'careGuide': {},
        'imagePath': null,
        'savedAt': DateTime.now(),
      };
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
      _filterPlants();
    });
  }

  void _filterPlants() {
    if (_searchQuery.isEmpty) {
      _filteredPlants = List.from(_savedPlants);
    } else {
      _filteredPlants = _savedPlants.where((plant) {
        final name = (plant['name'] as String?)?.toLowerCase() ?? '';
        final scientificName = (plant['scientificName'] as String?)?.toLowerCase() ?? '';
        final story = (plant['story'] as String?)?.toLowerCase() ?? '';

        return name.contains(_searchQuery) ||
               scientificName.contains(_searchQuery) ||
               story.contains(_searchQuery);
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredPlants = List.from(_savedPlants);
    });
  }

  Future<void> _refreshPlants() async {
    await _loadSavedPlants();
  }

  Future<void> _removePlant(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _savedPlants.removeAt(index);
      });

      final savedPlantsJson = _savedPlants.map(_plantToJson).toList();

      await prefs.setStringList('saved_plants', savedPlantsJson);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plant removed from collection'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove plant'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _plantToJson(Map<String, dynamic> plant) {
    final plantCopy = Map<String, dynamic>.from(plant);
    if (plantCopy['savedAt'] != null) {
      plantCopy['savedAt'] = plantCopy['savedAt'].toIso8601String();
    }
    return jsonEncode(plantCopy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('My Herbarium'),
            centerTitle: true,
            backgroundColor: FloraTaleTheme.primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            shadowColor: FloraTaleTheme.earthyBrown.withOpacity(0.3),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshPlants,
            color: FloraTaleTheme.primaryGreen,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(FloraTaleTheme.primaryGreen),
                    ),
                  )
                : _savedPlants.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchAndGrid(),
          ),
        ),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: FloraTaleTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_florist,
                size: 64,
                color: FloraTaleTheme.primaryGreen.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Herbarium is Empty',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: FloraTaleTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Start collecting plants by taking photos and saving them to your personal collection!',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: FloraTaleTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndGrid() {
    return Column(
      children: [
        // Header with search
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
            children: [
              const Icon(
                Icons.bookmark,
                color: FloraTaleTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                '${_savedPlants.length} Plant${_savedPlants.length == 1 ? '' : 's'} Collected',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FloraTaleTheme.textPrimary,
                ),
              ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search plants...',
                    hintStyle: const TextStyle(
                      color: FloraTaleTheme.textSecondary,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: FloraTaleTheme.primaryGreen,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: FloraTaleTheme.textSecondary,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: FloraTaleTheme.textPrimary,
                    fontSize: 16,
                  ),
                ),
              ),

              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Found ${_filteredPlants.length} result${_filteredPlants.length == 1 ? '' : 's'} for "${_searchQuery}"',
                  style: const TextStyle(
                    fontSize: 14,
                    color: FloraTaleTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),

        // Plants Grid
        Expanded(
          child: _filteredPlants.isEmpty && _searchQuery.isNotEmpty
              ? _buildNoSearchResults()
              : GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
                  itemCount: _filteredPlants.length,
            itemBuilder: (context, index) {
                    final plant = _filteredPlants[index];
                    // Find the original index for deletion
                    final originalIndex = _savedPlants.indexWhere((p) =>
                      p['name'] == plant['name'] &&
                      p['scientificName'] == plant['scientificName']
                    );
                    return _buildPlantCard(plant, originalIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: FloraTaleTheme.primaryGreen.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No plants found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: FloraTaleTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try searching with different keywords or clear the search to see all plants.',
              style: TextStyle(
                fontSize: 16,
                color: FloraTaleTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FloraTaleTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(Map<String, dynamic> plant, int index) {
    return GestureDetector(
      onTap: () => _showPlantDetails(plant),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: FloraTaleTheme.earthyBrown.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plant Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: plant['imagePath'] != null && File(plant['imagePath']).existsSync()
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.file(
                          File(plant['imagePath']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: FloraTaleTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Icon(
                          Icons.local_florist,
                          size: 48,
                          color: FloraTaleTheme.primaryGreen.withOpacity(0.4),
                        ),
                      ),
              ),
            ),

            // Plant Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant['name'] ?? 'Unknown Plant',
                      style: const TextStyle(
                            fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: FloraTaleTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                        const SizedBox(height: 3),
                    Text(
                      plant['scientificName'] ?? '',
                      style: const TextStyle(
                            fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: FloraTaleTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 11,
                          color: FloraTaleTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                          _formatDate(plant['savedAt']),
                          style: const TextStyle(
                              fontSize: 9,
                            color: FloraTaleTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(index),
                          child: Icon(
                            Icons.delete_outline,
                            size: 14,
                            color: Colors.red.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlantDetails(Map<String, dynamic> plant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Plant Header
                      Text(
                        plant['name'] ?? 'Unknown Plant',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: FloraTaleTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant['scientificName'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: FloraTaleTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Myth
                      if (plant['story'] != null && plant['story'].isNotEmpty) ...[
                        const Text(
                          'Myth',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FloraTaleTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: FloraTaleTheme.lightBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            plant['story'],
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: FloraTaleTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Care Guide
                      if (plant['careGuide'] != null && plant['careGuide'].isNotEmpty) ...[
                        const Text(
                          'Care Guide',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FloraTaleTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: FloraTaleTheme.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: _buildCareGuideItems(plant['careGuide']),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Facts
                      if (plant['facts'] != null && plant['facts'].isNotEmpty) ...[
                        const Text(
                          'Interesting Facts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: FloraTaleTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...plant['facts'].map<Widget>((fact) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: FloraTaleTheme.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 6, right: 12),
                                decoration: const BoxDecoration(
                                  color: FloraTaleTheme.accentGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  fact,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                    color: FloraTaleTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Plant'),
        content: const Text('Are you sure you want to remove this plant from your collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removePlant(index);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  List<Widget> _buildCareGuideItems(Map<String, dynamic> careGuide) {
    final careItems = [
      {'icon': Icons.water_drop_outlined, 'label': 'Moisturing', 'key': 'moisturing'},
      {'icon': Icons.wb_sunny_outlined, 'label': 'Sunlight', 'key': 'sunlight'},
      {'icon': Icons.grass_outlined, 'label': 'Soil', 'key': 'soil'},
      {'icon': Icons.thermostat_outlined, 'label': 'Temperature', 'key': 'temperature'},
    ];

    return careItems.map((item) {
      final value = careGuide[item['key']] ?? 'Not specified';
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item['icon'] as IconData,
              size: 16,
              color: FloraTaleTheme.primaryGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: FloraTaleTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: FloraTaleTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
