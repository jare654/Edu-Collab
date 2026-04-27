import 'dart:convert';
import 'package:flutter/services.dart';

class JsonAssetLoader {
  Future<List<Map<String, dynamic>>> loadList(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final data = jsonDecode(raw);
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List).cast<Map<String, dynamic>>();
    }
    throw FormatException('Unexpected JSON format for $assetPath');
  }
}
