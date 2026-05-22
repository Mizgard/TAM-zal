import 'package:hive_ce/hive.dart';
import '../models/character_model.dart';

class CharacterLocalDatabase {
  // Pobiera instancję boksu otwartego w funkcji main()
  static Box get _box => Hive.box("character_details");

  // Sprawdza, czy szczegóły danej postaci znajdują się już w bazie Hive
  static Character? getCharacterDetails(int id) {
    final rawData = _box.get(id);
    if (rawData == null) return null;
    
    // Jeśli dane istnieją, mapuje je z powrotem na obiekt klasy Character
    return Character.fromMap(Map<String, dynamic>.from(rawData));
  }

  // Zapisuje szczegóły postaci do Hive pod kluczem równym jej ID
  static Future<void> saveCharacterDetails(Character character) async {
    await _box.put(character.id, character.toMap());
  }
}