
class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final String originName;
  final String locationName;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    required this.originName,
    required this.locationName,
  });

  // Konwersja z formatu Map (używane przy pobieraniu z Hive / API)
  factory Character.fromMap(Map<String, dynamic> map) {
    return Character(
      id: map['id'] as int,
      name: map['name'] as String,
      status: map['status'] as String,
      species: map['species'] as String,
      gender: map['gender'] as String,
      image: map['image'] as String,
      // API zwraca origin i location jako zagnieżdżone obiekty, wyciąga z nich tylko 'name'
      originName: map['origin'] is Map ? map['origin']['name'] : map['originName'] as String,
      locationName: map['location'] is Map ? map['location']['name'] : map['locationName'] as String,
    );
  }

  // Konwersja obiektu na Mapę (potrzebne do zapisu w Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'image': image,
      'originName': originName,
      'locationName': locationName,
    };
  }
}