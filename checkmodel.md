# Gemini Models Check Logic
This document contains the logic for checking available Gemini models via REST API. This is useful for debugging API compatibility issues.

## Implementation

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

/// List available Gemini models using REST API
Future<List<String>> listAvailableModels(String apiKey) async {
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final models = data['models'] as List<dynamic>? ?? [];

    final modelNames = models.map((model) => model['name'] as String).toList();
    return modelNames;
  } else {
    throw Exception('Failed to list models: ${response.statusCode}');
  }
}
```

## Usage
```dart
try {
  final models = await listAvailableModels('thekey');
  print('Available models: $models');
} catch (e) {
  print('Error: $e');
}
```
