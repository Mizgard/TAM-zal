// main.dart
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/character_model.dart';
import 'services/character_api_services.dart';
import 'services/character_local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicjalizacja bazy na urządzeniu
  await Hive.initFlutter(); 
  // Otwarcie kontenera na detale postaci
  await Hive.openBox("character_details"); 
  runApp(const RickAndMortyApp());
}

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Architecture',
      theme: ThemeData.dark(), 
      home: const HomeScreen(),
    );
  }
}

// Ekran 1 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Character>> charactersFuture;

  @override
  void initState() {
    super.initState();
    // Pobiera listę postaci przy starcie aplikacji
    charactersFuture = CharacterApiService.fetchCharactersList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rick and Morty Characters")),
      body: FutureBuilder<List<Character>>(
        future: charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Brak postaci do wyświetlenia"));
          }

          final characters = snapshot.data!;

          return ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) {
              final character = characters[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(character.image),
                  ),
                  title: Text(character.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${character.status} - ${character.species}"),
                  onTap: () {
                    // Nawigacja do ekranu szczegółów
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CharacterDetailScreen(characterId: character.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Ekran 2
class CharacterDetailScreen extends StatefulWidget {
  final int characterId;
  const CharacterDetailScreen({required this.characterId, super.key});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  late Future<Character> detailFuture;

  @override
  void initState() {
    super.initState();
    detailFuture = _loadCharacterDetails();
  }
// Obsługa zapytania o szczegóły 
  Future<Character> _loadCharacterDetails() async {
    final cachedCharacter = CharacterLocalDatabase.getCharacterDetails(widget.characterId);
    if (cachedCharacter != null) {
      return cachedCharacter;
    }
    final apiCharacter = await CharacterApiService.fetchSingleCharacterDetails(widget.characterId);

    await CharacterLocalDatabase.saveCharacterDetails(apiCharacter);
    
    return apiCharacter;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Szczegóły postaci")),
      body: FutureBuilder<Character>(
        future: detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Wystąpił błąd: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Nie znaleziono danych."));
          }

          final character = snapshot.data!;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(character.image, height: 250, width: 250, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    character.name, 
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    label: Text(character.status),
                    backgroundColor: character.status == "Alive" 
                        ? Colors.green.shade800 
                        : character.status == "Dead" 
                            ? Colors.red.shade800 
                            : Colors.grey.shade700,
                  ),
                  const SizedBox(height: 24),
                  Text("Gatunek: ${character.species}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Płeć: ${character.gender}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Pochodzenie: ${character.originName}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Lokalizacja: ${character.locationName}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}