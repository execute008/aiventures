import 'package:flutter/material.dart';
import 'package:aiventures/core/models/story_message.dart';
import 'package:aiventures/core/models/game_state.dart';
import 'package:aiventures/core/services/ai_service.dart';
import 'package:aiventures/core/services/gemini_service.dart';

class AdventureController extends ChangeNotifier {
  final AIService _aiService;
  GameState _gameState = GameState();
  bool _isLoading = false;
  
  AdventureController({AIService? aiService}) 
      : _aiService = aiService ?? GeminiService();
  
  // Getters
  List<StoryMessage> get messages => _gameState.messages;
  String get currentImage => _gameState.currentImageId;
  bool get isLoading => _isLoading;
  
  // Start a new adventure
  Future<void> startAdventure() async {
    _setLoading(true);
    
    // Reset game state
    _gameState = GameState();
    
    try {
      // Setup initial adventure context
      _gameState = _gameState.copyWith(
        adventureContext: "You are in a fantasy world with magic and ancient mysteries."
      );
      
      // Get initial story prompt
      const initialPrompt = "You find yourself standing at the entrance of a mysterious cave. "
                           "The entrance is covered with ancient symbols and glowing runes. "
                           "A cool breeze flows from inside, carrying whispers of forgotten tales. "
                           "What do you do?";
      
      // Add the AI's initial message
      _addMessage(initialPrompt, false);
      
      // Generate initial image
      final imageId = await _aiService.generateImage("A mysterious cave entrance with glowing runes and symbols");
      _gameState = _gameState.copyWith(currentImageId: imageId);
    } catch (e) {
      // Handle error
      _addMessage("Error starting adventure: ${e.toString()}", false);
    } finally {
      _setLoading(false);
    }
  }
  
  // Process user input
  Future<void> processUserInput(String userInput) async {
    if (userInput.trim().isEmpty) return;
    
    // Add user message to history
    _addMessage(userInput, true);
    _setLoading(true);
    
    try {
      // Generate AI response
      final response = await _aiService.generateResponse(
        _gameState.messages, 
        userInput
      );
      
      // Add AI response
      _addMessage(response, false);
      
      // Generate new image based on the response
      final imageId = await _aiService.generateImage(response);
      _gameState = _gameState.copyWith(currentImageId: imageId);
    } catch (e) {
      _addMessage("Sorry, I encountered an error. Please try again.", false);
    } finally {
      _setLoading(false);
    }
  }
  
  void _addMessage(String content, bool isUser) {
    final updatedMessages = List<StoryMessage>.from(_gameState.messages)
      ..add(StoryMessage(content: content, isUser: isUser));
    
    _gameState = _gameState.copyWith(messages: updatedMessages);
    notifyListeners();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}