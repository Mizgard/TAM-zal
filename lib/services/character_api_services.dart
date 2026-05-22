import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

class CharacterApiService {
  static const String _baseUrl = "https://rickandmortyapi.com/api";

  // Pobiera listy postaci dla pierwszego ekranu
  static Future<List<Character>> fetchCharactersList() async {
    final response = await http.get(Uri.parse("$_baseUrl/character"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      // Mapuje listę rezultatów z JSON-a na listę obiektów Character
      return results.map((item) => Character.fromMap(item)).toList();
    } else {
      throw Exception("Nie udało się pobrać listy postaci z API");
    }
  }

  // Pobiera szczegóły konkretnej postaci po jej ID
  static Future<Character> fetchSingleCharacterDetails(int id) async {
    final response = await http.get(Uri.parse("$_baseUrl/character/$id"));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Character.fromMap(data);
    } else {
      throw Exception("Nie udało się pobrać szczegółów postaci o ID: $id");
    }
  }
}