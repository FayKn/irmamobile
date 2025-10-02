import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SimpleIconsUtils {
  Map<String, String> icons = {};
  static final SimpleIconsUtils _instance = SimpleIconsUtils._internal();
  factory SimpleIconsUtils() {
    return _instance;
  }
  SimpleIconsUtils._internal();

  static String getIconName(String iconName) {
    return iconName.toLowerCase();
  }

  static String getIconAssetPath(String iconName) {
    final formattedName = getIconName(iconName);
    return 'assets/simple-icons/icons/$formattedName.svg';
  }

  String getIconHexColor(String iconName) {
    // Load icon data if not already loaded, should only happen once
    if (icons.isEmpty) {
      loadIconDataArray();
    }

    final formattedName = getIconName(iconName);
    try {
      return icons[formattedName] ?? '000000';
    } catch (e) {
      return '000000'; // Default to black if not found
    }
  }

  void loadIconDataArray() async {
    try {
      // Load the JSON file assets/simple-icons/data/simple-icons.json
      String data = await rootBundle.loadString('assets/simple-icons/data/simple-icons-fmt.json');

      if (data.isEmpty) {
        debugPrint('Error: Icon data is empty');
        return;
      }
      Map<String, dynamic> jsonResult = json.decode(data);
      icons = jsonResult.map((key, value) => MapEntry(key.toLowerCase(), value.toString()));
    } catch (e) {
      // Handle error
      debugPrint('Error loading icon data: $e');
    }
  }
}
