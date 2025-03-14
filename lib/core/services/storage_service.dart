import 'package:aiventures/core/models/adventure.dart';

class StorageService {
  // In a real implementation, this would use Firebase Firestore or local storage
  final Map<String, Adventure> _adventures = {};
  
  // Save an adventure
  Future<void> saveAdventure(Adventure adventure) async {
    _adventures[adventure.id] = adventure;
  }
  
  // Get all adventures
  Future<List<Adventure>> getAdventures() async {
    return _adventures.values.toList();
  }
  
  // Get a specific adventure
  Future<Adventure?> getAdventure(String id) async {
    return _adventures[id];
  }
  
  // Delete an adventure
  Future<void> deleteAdventure(String id) async {
    _adventures.remove(id);
  }
}