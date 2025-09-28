import 'dart:convert';
import 'dart:io';
import '../index.dart';
import 'herbarium_screen.dart';

class ResultsScreen extends StatefulWidget {
  final File? plantImage;
  final String plantName;
  final String scientificName;
  final String mythicalStory;
  final List<String> funFacts;
  final Map<String, dynamic>? careGuide;
  final bool isOffline;

  const ResultsScreen({
    super.key,
    this.plantImage,
    required this.plantName,
    required this.scientificName,
    required this.mythicalStory,
    required this.funFacts,
    this.careGuide,
    this.isOffline = false,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkIfPlantIsSaved();
  }

  Future<void> _checkIfPlantIsSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPlantsJson = prefs.getStringList('saved_plants') ?? [];

      final savedPlants = savedPlantsJson.map((json) {
        try {
          return jsonDecode(json) as Map<String, dynamic>;
        } catch (e) {
          return null;
        }
      }).where((plant) => plant != null).toList();

      final isAlreadySaved = savedPlants.any((plant) =>
        plant!['name'] == widget.plantName &&
        plant['scientificName'] == widget.scientificName
      );

      if (mounted) {
        setState(() {
          _isSaved = isAlreadySaved;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNotPlant = widget.plantName.toLowerCase().contains('not a plant');
    
    return Scaffold(
      backgroundColor: FloraTaleTheme.background,
      appBar: AppBar(
        title: Text(isNotPlant ? 'Not a Plant' : widget.plantName),
        backgroundColor: FloraTaleTheme.background,
        foregroundColor: FloraTaleTheme.textPrimary,
        elevation: 0,
        actions: [
          if (!isNotPlant)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _shareStory,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.isOffline)
              const OfflineBanner(
                message: 'You\'re viewing this plant from our offline database. Connect to internet for real-time plant identification and the latest information.',
              ),

            if (isNotPlant)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 48,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Not a Plant Detected',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: FloraTaleTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The image you captured doesn\'t appear to contain a plant. Please try taking a photo of a plant, flower, tree, or leaf for botanical identification.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: FloraTaleTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            if (widget.plantImage != null && !isNotPlant) _buildTopPlantImage(),
            if (!isNotPlant) const SizedBox(height: 24),
            if (!isNotPlant) _buildOverlayCards(),
            if (!isNotPlant) const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPlantImage() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              body: Center(
                child: InteractiveViewer(
                  child: Image.file(widget.plantImage!),
                ),
              ),
            ),
          ),
        );
      },
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Stack(
          children: [
            Image.file(
              widget.plantImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🌿', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.plantName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.scientificName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildOverlayCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
      children: [
          // Story Card
          _buildCard(
            title: 'Myth',
            icon: Icons.auto_stories_outlined,
          child: Text(
            widget.mythicalStory,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: FloraTaleTheme.textPrimary,
            ),
          ),
        ),
          const SizedBox(height: 16),
          
          // Fun Facts Card
          _buildCard(
            title: 'Interesting Facts',
            icon: Icons.lightbulb_outline,
            child: Column(
              children: widget.funFacts.map((fact) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FloraTaleTheme.accentGreen.withOpacity(0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: const BoxDecoration(
                  color: FloraTaleTheme.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  fact,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: FloraTaleTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
            // Care Guide Card
            _buildCareGuideCard(),

            const SizedBox(height: 16),

            // Action Buttons Card
            _buildCard(
              title: 'Actions',
              icon: Icons.touch_app_outlined,
              child: Column(
      children: [
        // Save Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await _toggleSavePlant();
            },
            icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
            label: Text(_isSaved ? 'Saved' : 'Save to Collection'),
            style: ElevatedButton.styleFrom(
              backgroundColor: FloraTaleTheme.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Share Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _shareStory,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Share This Plant'),
            style: OutlinedButton.styleFrom(
              foregroundColor: FloraTaleTheme.primaryGreen,
              side: const BorderSide(color: FloraTaleTheme.primaryGreen),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCareGuideCard() {
    final careGuide = widget.careGuide ?? {};
    if (careGuide.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.eco_outlined,
                color: FloraTaleTheme.accentGreen,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Care Guide',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FloraTaleTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCareItem(Icons.water_drop_outlined, 'Moisturing', careGuide['moisturing'] ?? 'Not specified'),
          const SizedBox(height: 12),
          _buildCareItem(Icons.wb_sunny_outlined, 'Sunlight', careGuide['sunlight'] ?? 'Not specified'),
          const SizedBox(height: 12),
          _buildCareItem(Icons.grass_outlined, 'Soil', careGuide['soil'] ?? 'Not specified'),
          const SizedBox(height: 12),
          _buildCareItem(Icons.thermostat_outlined, 'Temperature', careGuide['temperature'] ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildCareItem(IconData icon, String label, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: FloraTaleTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: FloraTaleTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: FloraTaleTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: FloraTaleTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FloraTaleTheme.primaryGreen.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: FloraTaleTheme.accentGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: FloraTaleTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }


  Future<void> _toggleSavePlant() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_isSaved) {
        // Remove from collection
        final savedPlantsJson = prefs.getStringList('saved_plants') ?? [];

        final savedPlants = savedPlantsJson.map((json) {
          try {
            final decoded = jsonDecode(json);
            return decoded as Map<String, dynamic>;
          } catch (e) {
            return null;
          }
        }).where((plant) => plant != null).toList();

        savedPlants.removeWhere((plant) =>
          plant!['name'] == widget.plantName &&
          plant['scientificName'] == widget.scientificName
        );

        final updatedJson = savedPlants.map((plant) => jsonEncode(plant)).toList();
        await prefs.setStringList('saved_plants', updatedJson);

        setState(() {
          _isSaved = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from collection'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add to collection
        final savedPlantsJson = prefs.getStringList('saved_plants') ?? [];

        final savedPlants = savedPlantsJson.map((json) {
          try {
            final decoded = jsonDecode(json);
            return decoded as Map<String, dynamic>;
          } catch (e) {
            return null;
          }
        }).where((plant) => plant != null).toList();

        final alreadyExists = savedPlants.any((plant) =>
          plant!['name'] == widget.plantName &&
          plant['scientificName'] == widget.scientificName
        );

        if (!alreadyExists) {
          final plantData = _createPlantData();
          savedPlants.add(plantData);
        }

        final updatedJson = savedPlants.map((plant) => jsonEncode(plant)).toList();
        await prefs.setStringList('saved_plants', updatedJson);

        setState(() {
          _isSaved = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved to your collection! 🌿'),
              duration: Duration(seconds: 2),
            ),
          );
          // Refresh herbarium screen to show the newly saved plant
          HerbariumScreen.refreshData(context);
        }
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  Map<String, dynamic> _createPlantData() {
    return {
      'name': widget.plantName,
      'scientificName': widget.scientificName,
      'scientific': widget.scientificName,
      'story': widget.mythicalStory,
      'facts': widget.funFacts,
      'careGuide': widget.careGuide,
      'imagePath': widget.plantImage?.path,
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  void _showErrorMessage(String error) {
    String errorMessage = 'Failed to update collection';
    if (error.contains('permission')) {
      errorMessage = 'Storage permission required';
    } else if (error.contains('disk')) {
      errorMessage = 'Storage space is full';
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _toggleSavePlant,
          ),
        ),
      );
    }
  }

  void _shareStory() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
        content: Text('Share feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}