import 'dart:convert';

import '../index.dart';

class PlantDatabase {
  static const String _plantsKey = 'cached_plants_database';
  static const String _lastUpdateKey = 'plants_last_update';

  static final List<Map<String, dynamic>> _defaultPlants = [
    {
      'name': 'Moringa oleifera',
      'scientific': 'Moringa oleifera Lam.',
      'story': 'In Igbo lore, the moringa tree is known as "the miracle tree" or "mother\'s best friend." According to ancient tales, a wise healer discovered the tree during a great famine. The spirits blessed it with extraordinary powers to heal the weary traveler and nourish the hungry child. Today, it stands as a symbol of resilience and the generous bounty of Mother Earth.',
      'facts': [
        'Moringa leaves contain more vitamin C than oranges!',
        'Every part of the moringa tree is edible and nutritious.',
        'Ancient Egyptians used moringa oil for anointing their pharaohs.',
        'The tree can produce seed pods just 6 months after planting.',
      ],
      'careGuide': {
        'moisturing': 'Water regularly but allow soil to dry between waterings. Drought tolerant once established.',
        'sunlight': 'Full sun - needs at least 6 hours of direct sunlight daily.',
        'soil': 'Well-draining sandy or loamy soil. Tolerates poor soil conditions.',
        'temperature': 'Thrives in warm climates, 65-85°F (18-30°C). Can tolerate light frost.',
      },
    },
    {
      'name': 'Neem Tree',
      'scientific': 'Azadirachta indica',
      'story': 'In Yoruba mythology, the neem tree is revered as a sacred guardian. Legend tells of how the tree once saved an entire village from a terrible plague by offering its bitter leaves to the suffering. The spirits rewarded its compassion by granting it healing powers that could cure any ailment and protect against evil spirits.',
      'facts': [
        'Neem has been used in traditional medicine for over 2,000 years.',
        'All parts of the neem tree have medicinal properties.',
        'Neem oil is a natural pesticide and has antibacterial properties.',
        'In India, neem is known as "the village pharmacy."',
      ],
      'careGuide': {
        'moisturing': 'Moderate watering. Allow top soil to dry between waterings. Drought tolerant.',
        'sunlight': 'Full sun to partial shade. Needs at least 4-6 hours of sunlight.',
        'soil': 'Well-draining soil. Tolerates poor, rocky soil. pH 6.0-8.0.',
        'temperature': 'Tropical to subtropical. Best in 70-90°F (21-32°C). Sensitive to frost.',
      },
    },
    {
      'name': 'Baobab',
      'scientific': 'Adansonia',
      'story': 'The mighty baobab is known as "the tree of life" in African folklore. Ancient Hausa legends speak of how the baobab once offended the gods and was uprooted and replanted upside down as punishment. Despite this, the tree continued to provide food, water, and shelter to all creatures, earning the gods\' forgiveness and becoming a symbol of enduring wisdom.',
      'facts': [
        'Baobab trees can live for over 5,000 years!',
        'They can store up to 120,000 liters of water in their trunks.',
        'Baobab fruit is called "monkey bread" and is rich in vitamin C.',
        'The tree is sometimes called "the pharmacy of the savannah."',
      ],
      'careGuide': {
        'moisturing': 'Very drought tolerant. Water deeply but infrequently. Can survive long dry periods.',
        'sunlight': 'Full sun. Needs maximum sunlight exposure in arid environments.',
        'soil': 'Sandy, well-draining soil. Tolerates poor, rocky soil. Avoid waterlogged areas.',
        'temperature': 'Thrives in hot, dry climates. 80-100°F (27-38°C) ideal.',
      },
    },
    // Add more plants for a richer offline experience
    {
      'name': 'African Tulip Tree',
      'scientific': 'Spathodea campanulata',
      'story': 'Known as the "Flame of the Forest" in African cultures, this magnificent tree symbolizes the fiery spirit of African sunsets and the warmth of community gatherings.',
      'facts': [
        'Produces bright orange-red flowers that resemble flames.',
        'Grows rapidly and can reach 30-40 feet tall.',
        'Attracts birds and butterflies to gardens.',
        'Used in traditional African medicine for various ailments.',
      ],
      'careGuide': {
        'moisturing': 'Regular watering during growth. Drought tolerant once established.',
        'sunlight': 'Full sun to partial shade. Bright, indirect light preferred.',
        'soil': 'Well-draining fertile soil. pH 6.0-7.5.',
        'temperature': 'Tropical climate. 65-85°F (18-30°C).',
      },
    },
    {
      'name': 'Frangipani',
      'scientific': 'Plumeria',
      'story': 'In African coastal cultures, the frangipani represents beauty and resilience. Its delicate flowers that bloom at night symbolize the quiet strength that emerges in darkness.',
      'facts': [
        'Produces fragrant flowers that bloom at night.',
        'Has thick, succulent stems that store water.',
        'Used in traditional lei-making in Pacific cultures.',
        'Contains a milky sap that was used in traditional medicine.',
      ],
      'careGuide': {
        'moisturing': 'Allow soil to dry between waterings. Overwatering causes root rot.',
        'sunlight': 'Full sun. At least 6 hours of direct sunlight daily.',
        'soil': 'Well-draining cactus/succulent soil mix.',
        'temperature': 'Warm climates. 65-90°F (18-32°C). Protect from frost.',
      },
    },
  ];

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPlantsJson = prefs.getString(_plantsKey);
      final lastUpdate = prefs.getString(_lastUpdateKey);

      if (cachedPlantsJson == null || lastUpdate == null) {
        await _cachePlantsDatabase();
      } else {
        final now = DateTime.now();
        final lastUpdateDate = DateTime.parse(lastUpdate);
        final daysSinceUpdate = now.difference(lastUpdateDate).inDays;

        if (daysSinceUpdate > 30) {
          await _cachePlantsDatabase();
        }
      }
    } catch (e) {
      debugPrint('Error initializing plant database: $e');
    }
  }

  static Future<void> _cachePlantsDatabase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plantsJson = jsonEncode(_defaultPlants);
      await prefs.setString(_plantsKey, plantsJson);
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error caching plant database: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getCachedPlants() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPlantsJson = prefs.getString(_plantsKey);

      if (cachedPlantsJson != null) {
        final List<dynamic> decoded = jsonDecode(cachedPlantsJson);
        return decoded.map((plant) => plant as Map<String, dynamic>).toList();
      }

      await _cachePlantsDatabase();
      return _defaultPlants;
    } catch (e) {
      debugPrint('Error loading cached plants: $e');
      return _defaultPlants;
    }
  }

  static Future<Map<String, dynamic>> getRandomPlant() async {
    final plants = await getCachedPlants();
    if (plants.isEmpty) {
      return _defaultPlants[0];
    }

    final randomIndex = DateTime.now().second % plants.length;
    return plants[randomIndex];
  }

  static Future<List<Map<String, dynamic>>> searchPlants(String query) async {
    if (query.isEmpty) {
      return await getCachedPlants();
    }

    final plants = await getCachedPlants();
    final searchTerm = query.toLowerCase();

    return plants.where((plant) {
      final name = (plant['name'] as String?)?.toLowerCase() ?? '';
      final scientific = (plant['scientific'] as String?)?.toLowerCase() ?? '';

      return name.contains(searchTerm) || scientific.contains(searchTerm);
    }).toList();
  }

  static Future<Map<String, dynamic>?> getPlantByName(String name) async {
    final plants = await getCachedPlants();
    try {
      return plants.firstWhere(
        (plant) => plant['name'].toString().toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_plantsKey);
      await prefs.remove(_lastUpdateKey);
      debugPrint('Cleared plant database cache');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedPlantsJson = prefs.getString(_plantsKey);
      final lastUpdate = prefs.getString(_lastUpdateKey);

      final plantCount = cachedPlantsJson != null
          ? (jsonDecode(cachedPlantsJson) as List).length
          : 0;

      return {
        'plantCount': plantCount,
        'lastUpdate': lastUpdate,
        'isCached': cachedPlantsJson != null,
      };
    } catch (e) {
      return {
        'plantCount': 0,
        'lastUpdate': null,
        'isCached': false,
      };
    }
  }
}
