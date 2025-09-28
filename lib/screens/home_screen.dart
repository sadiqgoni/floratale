import '../index.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final GeminiPlantService _geminiService = GeminiPlantService();
  bool _isProcessing = false;
  bool _isOffline = false;



  Future<void> _takePicture() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, 
      );

      if (image == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      final File imageFile = File(image.path);

      Map<String, dynamic>? plantData;
      bool aiSuccess = false;

      debugPrint('Checking if Gemini is configured: ${_geminiService.isConfigured}');
      
      if (_geminiService.isConfigured) {
        debugPrint('Using Gemini AI for plant identification...');
        plantData = await _geminiService.identifyPlant(imageFile);
        aiSuccess = plantData != null && plantData['error'] == null;
        
        if (aiSuccess) {
          debugPrint('AI identification successful: ${plantData['name']}');
        } else {
          debugPrint('AI identification failed: ${plantData?['error'] ?? 'Unknown error'}');
          debugPrint('Using fallback mock data');
        }
      } else {
        debugPrint('Gemini API key not configured, using mock data');
      }

      // Fallback to mock data if AI fails or is not configured
      if (!aiSuccess) {
        plantData = await _getMockPlantData();
        plantData['identificationMethod'] = 'Mock Database (Offline)';
      }

      if (mounted) {
        setState(() {
          _isOffline = !aiSuccess;
          _isProcessing = false;
        });

        await Future.delayed(const Duration(milliseconds: 100));

        debugPrint('Final _isOffline value: $_isOffline');

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(
                plantImage: File(image.path),
                plantName: plantData!['name']!,
                scientificName: plantData['scientific']!,
                mythicalStory: plantData['myth'] ?? plantData['story']!,
                funFacts: (plantData['facts'] as List<dynamic>).map((fact) => fact.toString()).toList(),
                careGuide: plantData['careGuide'] ?? {
                  'moisturing': 'Moisturing information not available',
                  'sunlight': 'Sunlight information not available', 
                  'soil': 'Soil information not available',
                  'temperature': 'Temperature information not available',
                },
                isOffline: _isOffline,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    } finally {
     
      if (mounted && !_isProcessing) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }


  Future<Map<String, dynamic>> _getMockPlantData() async {
    try {
      final plantData = await PlantDatabase.getRandomPlant();
      return plantData;
    } catch (e) {


      return {
        'name': 'Moringa oleifera',
        'scientific': 'Moringa oleifera Lam.',
        'myth': 'In Igbo lore, the moringa tree is known as "the miracle tree" or "mother\'s best friend." According to ancient tales, a wise healer discovered the tree during a great famine. The spirits blessed it with extraordinary powers to heal the weary traveler and nourish the hungry child.',
        'facts': [
          'Moringa leaves contain more vitamin C than oranges!',
          'Every part of the moringa tree is edible and nutritious.',
          'Ancient Egyptians used moringa oil for anointing their pharaohs.',
        ],
        'careGuide': {
          'moisturing': 'Water regularly but allow soil to dry between waterings.',
          'sunlight': 'Full sun - needs at least 6 hours of direct sunlight daily.',
          'soil': 'Well-draining sandy or loamy soil.',
          'temperature': 'Thrives in warm climates, 65-85°F (18-30°C).',
        },
      };
    }
  }


  Future<void> _refreshDailyPlant() async {
    setState(() {
      // Force refresh of daily plant by incrementing refresh counter
      // This will be handled by the parent widget that manages the daily plant
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FloraTale',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: FloraTaleTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: FloraTaleTheme.earthyBrown.withOpacity(0.3),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDailyPlant,
        color: FloraTaleTheme.primaryGreen,
        child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FloraTaleTheme.background,
                  FloraTaleTheme.lightBrown.withOpacity(0.3),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: OfflineIndicator(isOffline: _isOffline),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: CulturalOverlayPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_florist,
                  size: 120,
                  color: FloraTaleTheme.primaryGreen.withOpacity(0.7),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: FloraTaleTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Tap the camera button below to snap a photo of any plant and discover its name, mythical story, and fun facts!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: FloraTaleTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: LoadingLeaf(size: 80),
            ),
          ),
        ],
      ),
      ),
       floatingActionButton: FloatingActionButton(
         onPressed: _isProcessing ? null : _takePicture,
         backgroundColor: _isProcessing
             ? FloraTaleTheme.textSecondary
             : FloraTaleTheme.accentGreen,
         child: const Icon(
           Icons.camera_alt,
           size: 32,
         ),
       ),
       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class CulturalOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final Path baobabPath = Path();
    final double treeHeight = size.height * 0.3;
    final double treeWidth = size.width * 0.15;
    final double startX = size.width - treeWidth - 20;
    final double startY = size.height * 0.1;

    baobabPath.moveTo(startX + treeWidth * 0.4, startY + treeHeight);
    baobabPath.lineTo(startX + treeWidth * 0.4, startY + treeHeight * 0.6);
    baobabPath.lineTo(startX + treeWidth * 0.6, startY + treeHeight * 0.6);
    baobabPath.lineTo(startX + treeWidth * 0.6, startY + treeHeight);

    baobabPath.moveTo(startX, startY + treeHeight * 0.3);
    baobabPath.lineTo(startX + treeWidth, startY + treeHeight * 0.3);
    baobabPath.lineTo(startX + treeWidth * 0.8, startY + treeHeight * 0.1);
    baobabPath.lineTo(startX + treeWidth * 0.2, startY + treeHeight * 0.1);
    baobabPath.close();

    canvas.drawPath(baobabPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
