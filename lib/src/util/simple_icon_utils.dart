import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SimpleIconsUtils {
  List<Map<String, String>> icons = [];
  static final SimpleIconsUtils _instance = SimpleIconsUtils._internal();
  factory SimpleIconsUtils() {
    return _instance;
  }
  SimpleIconsUtils._internal();

  Future<void>? _initFuture;

  Future<void> init() {
    _initFuture ??= loadIconDataArray();
    return _initFuture!;
  }

  static String getIconName(String iconName) {
    return iconName
        .toLowerCase();
  }

  static String getIconAssetPath(String iconName) {
    final formattedName = getIconName(iconName);
    return 'assets/simple-icons/icons/$formattedName.svg';
  }

  String getIconHexColor(String iconName) {
    final formattedName = getIconName(iconName);
    try {
      final iconData = icons.firstWhere((icon) => icon['name']!.toLowerCase() == formattedName);
      return iconData['hex'] ?? '000000';
    } catch (e) {
      return '000000'; // Default to black if not found
    }
  }

  Future<void> loadIconDataArray() async {
    try {
      // Load the JSON file assets/simple-icons/data/simple-icons.json
      String data = await rootBundle.loadString('assets/simple-icons/data/simple-icons.json');
      // Parse the JSON data in a separate isolate to avoid blocking the main thread and improve performance
      final parsed = await compute(parseIconData, data);
      icons = parsed;
    } catch (e) {
      // Handle error
      debugPrint('Error loading icon data: $e');
    }
  }
}

// Top-level parser function must be a top-level or static function to be used with compute.
Future<List<Map<String, String>>> parseIconData(String data) async {
  debugPrint('Loading icon data...');
  final jsonResult = json.decode(data) as List<dynamic>;
  return jsonResult
      .map((icon) => {
            'name': icon['title'] as String,
            'hex': icon['hex'] as String,
          })
      .toList();
}


