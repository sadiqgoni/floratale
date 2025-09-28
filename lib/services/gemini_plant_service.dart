import 'dart:convert';
import 'dart:typed_data';
import '../index.dart';

class GeminiPlantService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_GEMINI_API_KEY_HERE');
      
  late final GenerativeModel _model;

  GeminiPlantService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );
  }

  Future<Map<String, dynamic>?> identifyPlant(File imageFile) async {
    try {
      debugPrint('Starting plant identification with Gemini AI...');

    final Uint8List imageBytes = await imageFile.readAsBytes();

      const String prompt = '''
Analyze this image and identify if it contains a plant. Focus on Nigerian plants and traditional knowledge.

IMPORTANT: If this image does NOT show a plant (e.g., shows a person, object, animal, building, etc.) or if you cannot clearly identify a plant in the image, respond with:
{
  "name": "Not a plant",
  "scientific": "This image does not contain a plant",
  "confidence": "High",
  "myth": "This image does not contain a plant that can be identified for botanical lore.",
  "facts": ["This image does not show a plant"],
  "traditionalUses": [],
  "region": "N/A - No plant detected",
  "culturalSignificance": "N/A - No plant detected",
  "isNigerian": false,
  "isPlant": false
}

If this IS a plant, please respond in JSON format with the following structure:
{
  "name": "Common name of the plant",
  "scientific": "Scientific name",
  "confidence": "High/Medium/Low confidence level",
  "story": "Traditional Nigerian folklore or cultural story about this plant (2-3 sentences)",
  "facts": [
    "Interesting fact 1 about the plant",
    "Interesting fact 2 about the plant",
    "Interesting fact 3 about the plant"
  ],
  "traditionalUses": [
    "Traditional Nigerian use 1",
    "Traditional Nigerian use 2", 
    "Traditional Nigerian use 3"
  ],
  "region": "Nigerian regions where this plant is commonly found",
  "culturalSignificance": "Brief description of cultural importance in Nigerian communities",
  "isNigerian": true/false
}

Focus on:
1. Nigerian traditional medicine and folklore
2. Cultural significance in Yoruba, Igbo, Hausa communities
3. Traditional uses in Nigerian cuisine or medicine
4. Regional distribution across Nigeria
5. Local names in Nigerian languages if known

If this is not a plant commonly found in Nigeria, set "isNigerian" to false and provide general information, but still try to relate it to similar Nigerian plants if possible.
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {

        String responseText = response.text!;

        responseText = _extractJsonFromResponse(responseText);

        final Map<String, dynamic> plantData = jsonDecode(responseText) as Map<String, dynamic>;

        plantData['name'] = plantData['name'] ?? 'Unknown Plant';
        plantData['scientific'] = plantData['scientific'] ?? 'Scientific name not available';
        plantData['myth'] = plantData['myth'] ?? plantData['story'] ?? 'Traditional myth not available for this plant.';
        plantData['facts'] = plantData['facts'] ?? [];
        plantData['region'] = plantData['region'] ?? 'Various regions across Nigeria';
        plantData['culturalSignificance'] = plantData['culturalSignificance'] ?? 'Cultural significance information not available';

        if (plantData['imageUrl'] != null && plantData['imageUrl'].toString().isNotEmpty) {
          plantData['imagePath'] = plantData['imageUrl'];
          plantData['isNetworkImage'] = true;
        } else {
          plantData['imagePath'] = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Botanical_illustration_placeholder.svg/512px-Botanical_illustration_placeholder.svg.png';
          plantData['isNetworkImage'] = true;
        }

        plantData['identificationMethod'] = 'Gemini AI';
        plantData['timestamp'] = DateTime.now().toIso8601String();
        plantData['imageProcessed'] = true;

        return plantData;
      } else {
        debugPrint('No response received from Gemini AI');
        return null;
      }
    } catch (e) {
      debugPrint('Error identifying plant: $e');
      return _createFallbackResponse(e.toString());
    }
  }

  /// Extract JSON from Gemini response (removes markdown formatting if present)
  String _extractJsonFromResponse(String response) {
    // Remove markdown code blocks if present
    if (response.contains('```json')) {
      final start = response.indexOf('```json') + 7;
      final end = response.lastIndexOf('```');
      if (end > start) {
        response = response.substring(start, end).trim();
      }
    } else if (response.contains('```')) {
      final start = response.indexOf('```') + 3;
      final end = response.lastIndexOf('```');
      if (end > start) {
        response = response.substring(start, end).trim();
      }
    }

    // Find the first { and last } to extract JSON
    final firstBrace = response.indexOf('{');
    final lastBrace = response.lastIndexOf('}');

    if (firstBrace != -1 && lastBrace != -1 && lastBrace > firstBrace) {
      response = response.substring(firstBrace, lastBrace + 1);
    }

    return response.trim();
  }

  /// Create a fallback response when AI identification fails
  Map<String, dynamic> _createFallbackResponse(String error) {
    return {
      'name': 'Unknown Plant',
      'scientific': 'Species not identified',
      'confidence': 'Low',
      'story':
          'This plant could not be identified automatically. Many Nigerian plants have rich cultural histories waiting to be discovered through traditional knowledge and botanical research.',
      'facts': [
        'Nigeria has over 7,000 plant species',
        'Traditional plant knowledge is passed down through generations',
        'Many plants have multiple uses in Nigerian culture'
      ],
      'traditionalUses': [
        'Identification required for traditional uses',
        'Consult local botanists or traditional healers',
        'Document findings to preserve knowledge'
      ],
      'region': 'Various regions across Nigeria',
      'culturalSignificance':
          'Plant identification needed to determine cultural significance',
      'isNigerian': true,
      'identificationMethod': 'Gemini AI (Failed)',
      'timestamp': DateTime.now().toIso8601String(),
      'imageProcessed': false,
      'error': error,
    };
  }

  /// Get the plant of the day based on current date
  Future<Map<String, dynamic>> getDailyPlant([int refreshCounter = 0]) async {
    try {

      // Create a seed based on current date + refresh counter for variety
      final now = DateTime.now();
      final dayOfYear = now.day + now.month * 31 + now.year * 365 + refreshCounter;

      // Use the day seed to create a consistent prompt
      final prompt = '''
I need a plant for today's daily lore. Please provide information about a Nigerian plant.

Since today is day number $dayOfYear in the year, please provide information about:

${_getPlantForDay(dayOfYear)}

Please respond in JSON format with the following structure:
{
  "name": "Common name of the plant",
  "scientific": "Scientific name",
  "myth": "Traditional Nigerian myth, folklore or legendary story about this plant (2-3 sentences)",
  "facts": [
    "Fascinating fact 1 about the plant",
    "Fascinating fact 2 about the plant", 
    "Fascinating fact 3 about the plant",
    "Fascinating fact 4 about the plant"
  ],
  "region": "Nigerian regions where this plant is commonly found",
  "culturalSignificance": "Brief description of cultural importance in Nigerian communities",
  "imageUrl": "Direct URL to a high-quality image of this plant (search online for real plant photos)"
}

Focus on:
1. Nigerian traditional myths and folklore
2. Cultural significance in Yoruba, Igbo, Hausa communities
3. Regional distribution across Nigeria
4. Local names in Nigerian languages if known
5. Find a real image URL for this plant from online sources

CRITICAL: You MUST provide a valid imageUrl. Search online and provide a direct HTTP/HTTPS link to a real photograph of this plant from reliable sources like:
- Botanical websites (botanicalgarden.org, etc.)
- Wikipedia/Wikimedia Commons
- Educational institutions
- Scientific databases
- Plant identification websites

The imageUrl field is MANDATORY and must be a working URL to a real plant photo. Do not leave it empty or provide placeholder text.
''';

      final response = await _model.generateContent([
        Content.text(prompt)
      ]);

      if (response.text != null && response.text!.isNotEmpty) {

        // Extract JSON from the response
        String responseText = response.text!;
        responseText = _extractJsonFromResponse(responseText);

        // Parse JSON
        final Map<String, dynamic> plantData = jsonDecode(responseText);

        // Ensure all required fields have default values
        plantData['name'] = plantData['name'] ?? 'Unknown Plant';
        plantData['scientific'] = plantData['scientific'] ?? 'Scientific name not available';
        plantData['myth'] = plantData['myth'] ?? plantData['story'] ?? 'Traditional myth not available for this plant.';
        plantData['facts'] = plantData['facts'] ?? [];
        plantData['region'] = plantData['region'] ?? 'Various regions across Nigeria';
        plantData['culturalSignificance'] = plantData['culturalSignificance'] ?? 'Cultural significance information not available';

        // Handle image URL from AI - prioritize network images
        if (plantData['imageUrl'] != null && plantData['imageUrl'].toString().isNotEmpty) {
          plantData['imagePath'] = plantData['imageUrl'];
          plantData['isNetworkImage'] = true;
        } else {
          // If AI didn't provide imageUrl, use a generic botanical placeholder
          plantData['imagePath'] = 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Botanical_illustration_placeholder.svg/512px-Botanical_illustration_placeholder.svg.png';
          plantData['isNetworkImage'] = true;
        }

        // Add metadata
        plantData['isDailyPlant'] = true;
        plantData['date'] = now.toIso8601String().split('T')[0];
        plantData['generatedBy'] = 'Gemini AI';

        return plantData;

      } else {
        debugPrint('No response received from Gemini AI for daily plant');
        return _createDailyPlantFallback();
      }

    } catch (e) {
      debugPrint('Error getting daily plant: $e');
      return _createDailyPlantFallback();
    }
  }

  /// Get plant name for a given day number
  String _getPlantForDay(int dayOfYear) {
    final plants = [
      'Moringa oleifera (the miracle tree)',
      'Neem tree (Azadirachta indica)', 
      'Baobab (Adansonia)',
      'African tulip tree (Spathodea campanulata)',
      'Frangipani (Plumeria)',
      'Bitter leaf (Vernonia amygdalina)',
      'Scent leaf (Ocimum gratissimum)',
      'Plantain tree (Musa paradisiaca)',
      'Palm tree (Elaeis guineensis)',
      'Cashew tree (Anacardium occidentale)',
      'Mango tree (Mangifera indica)',
      'Breadfruit tree (Artocarpus altilis)',
      'Kola nut tree (Cola nitida)',
      'Shea tree (Vitellaria paradoxa)',
      'Iroko tree (Milicia excelsa)',
    ];
    
    return plants[dayOfYear % plants.length];
  }

  /// Create fallback daily plant when AI fails
  Map<String, dynamic> _createDailyPlantFallback() {
    final now = DateTime.now();
    final dayOfYear = now.day + now.month * 31 + now.year * 365;

    final plants = [
      {
        'name': 'Moringa oleifera',
        'scientific': 'Moringa oleifera Lam.',
        'myth': 'In Igbo lore, the moringa tree is known as "the miracle tree" or "mother\'s best friend." According to ancient tales, a wise healer discovered the tree during a great famine. The spirits blessed it with extraordinary powers to heal the weary traveler and nourish the hungry child.',
        'facts': [
          'Moringa leaves contain more vitamin C than oranges!',
          'Every part of the moringa tree is edible and nutritious.',
          'Ancient Egyptians used moringa oil for anointing their pharaohs.',
          'The tree can survive in harsh conditions and drought.'
        ],
        'region': 'Northern Nigeria, Sahel Region',
        'culturalSignificance': 'Symbol of resilience and the generous bounty of Mother Earth',
        'generatedBy': 'Fallback Database',
        'isFallback': true,
        'imagePath': 'assets/images/moringa_oleifera.png',
        'isNetworkImage': false,
      },
      {
        'name': 'Neem Tree',
        'scientific': 'Azadirachta indica',
        'myth': 'In Yoruba mythology, the neem tree is revered as a sacred guardian. Legend tells of how the tree once saved an entire village from a terrible plague by offering its bitter leaves to the suffering.',
        'facts': [
          'Neem has been used in traditional medicine for over 2,000 years.',
          'All parts of the neem tree have medicinal properties.',
          'Neem oil is a natural pesticide and has antibacterial properties.',
          'Known as "the village pharmacy" in traditional communities.'
        ],
        'region': 'Throughout Nigeria, especially North',
        'culturalSignificance': 'Known as "the village pharmacy" with healing powers',
        'generatedBy': 'Fallback Database',
        'isFallback': true,
        'imagePath': 'assets/images/neem_tree.png',
        'isNetworkImage': false,
      },
      {
        'name': 'Baobab',
        'scientific': 'Adansonia',
        'myth': 'The mighty baobab is known as "the tree of life" in African folklore. Ancient Hausa legends speak of how the baobab once offended the gods and was uprooted and replanted upside down as punishment.',
        'facts': [
          'Baobab trees can live for over 5,000 years!',
          'They can store up to 120,000 liters of water in their trunks.',
          'Baobab fruit is called "monkey bread" and is rich in vitamin C.',
          'The tree is sometimes called "the pharmacy of the savannah."'
        ],
        'region': 'Northern Nigeria, Savannah Regions',
        'culturalSignificance': 'Symbol of enduring wisdom and life-giving properties',
        'generatedBy': 'Fallback Database',
        'isFallback': true,
        'imagePath': 'assets/images/baobab.png',
        'isNetworkImage': false,
      },
      {
        'name': 'African Tulip Tree',
        'scientific': 'Spathodea campanulata',
        'myth': 'Known as the "Flame of the Forest" in African cultures, this magnificent tree symbolizes the fiery spirit of African sunsets and the warmth of community gatherings.',
        'facts': [
          'Produces bright orange-red flowers that resemble flames.',
          'Grows rapidly and can reach 30-40 feet tall.',
          'Attracts birds and butterflies to gardens.',
          'The flowers are used in traditional ceremonies across West Africa.'
        ],
        'region': 'Southern Nigeria, Rainforest Areas',
        'culturalSignificance': 'Symbol of beauty and the vibrant spirit of African landscapes',
        'generatedBy': 'Fallback Database',
        'isFallback': true,
        'imagePath': 'assets/images/african_tulip_tree.png',
        'isNetworkImage': false,
      },
      {
        'name': 'Frangipani',
        'scientific': 'Plumeria',
        'myth': 'In African coastal cultures, the frangipani represents beauty and resilience. Its delicate flowers that bloom at night symbolize the quiet strength that emerges in darkness.',
        'facts': [
          'Produces fragrant flowers that bloom at night.',
          'Has thick, succulent stems that store water.',
          'Used in traditional lei-making in Pacific cultures.',
          'The milky sap was traditionally used for medicinal purposes.'
        ],
        'region': 'Coastal Nigeria, Tropical Regions',
        'culturalSignificance': 'Symbol of beauty and resilience in coastal communities',
        'generatedBy': 'Fallback Database',
        'isFallback': true,
        'imagePath': 'assets/images/frangipani.png',
        'isNetworkImage': false,
      }
    ];

    final selectedPlant = plants[dayOfYear % plants.length];

    // Add metadata
    selectedPlant['isDailyPlant'] = true;
    selectedPlant['date'] = now.toIso8601String().split('T')[0];
    selectedPlant['identificationMethod'] = 'Fallback Database';

    // Ensure imagePath exists (already added above, but just in case)
    if (!selectedPlant.containsKey('imagePath')) {
      selectedPlant['imagePath'] = 'assets/images/${selectedPlant['name'].toString().toLowerCase().replaceAll(' ', '_')}.png';
    }

    return selectedPlant;
  }

  /// Test the Gemini API connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await _model.generateContent([
        Content.text('Hello! Can you identify plants? Please respond with "YES, I can identify plants" if working.')
      ]);

      if (response.text != null && response.text!.isNotEmpty) {
        return {
          'success': true,
          'message': 'Gemini API connection successful',
          'response': response.text,
        };
      } else {
        return {
          'success': false,
          'message': 'No response from Gemini API',
          'response': null,
        };
      }
    } catch (e) {
      String errorMessage = 'Connection failed';
      if (e.toString().contains('API_KEY_INVALID') || e.toString().contains('invalid')) {
        errorMessage = 'Invalid API key - please check your key';
      } else if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Permission denied - check API permissions';
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        errorMessage = 'Quota exceeded - try again later';
      }

      return {
        'success': false,
        'message': errorMessage,
        'error': e.toString(),
      };
    }
  }



  /// Check if API key is configured
  bool get isConfigured =>
      _apiKey != 'YOUR_GEMINI_API_KEY_HERE' &&
      _apiKey.isNotEmpty &&
      _apiKey.startsWith('AIza');
}
