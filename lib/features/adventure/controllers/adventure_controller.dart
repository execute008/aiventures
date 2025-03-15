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
        adventureContext:
            "You are in a fantasy world with magic and ancient mysteries.",
      );

      // Generate initial image
      final imagePrompt = "A mysterious cave entrance with glowing runes and symbols";
      final initialImagePath = await _generateAndUpdateImage(imagePrompt);

      // Get initial story prompt
      const initialPrompt =
          "You find yourself standing at the entrance of a mysterious cave. "
          "The entrance is covered with ancient symbols and glowing runes. "
          "A cool breeze flows from inside, carrying whispers of forgotten tales. "
          "What do you do?";

      // Add initial choices
      final List<String> initialChoices = [
        "Enter the cave cautiously",
        "Examine the symbols on the entrance",
        "Listen carefully to the whispers",
        "Turn back and leave"
      ];

      // Add the AI's initial message with choices and image
      _addMessage(
        content: initialPrompt, 
        isUser: false,
        choices: initialChoices,
        imagePrompt: imagePrompt,
        imagePath: initialImagePath, // Attach the initial image
      );

    } catch (e) {
      // Handle error
      _addMessage(content: "Error starting adventure: ${e.toString()}", isUser: false);
    } finally {
      _setLoading(false);
    }
  }

  // Process user input (free text)
  Future<void> processUserInput(String userInput) async {
    if (userInput.trim().isEmpty) return;

    // Add user message to history
    _addMessage(content: userInput, isUser: true);
    await _generateAIResponse(userInput);
  }

  // Process a selected choice
  Future<void> processChoiceSelection(String choice) async {
    // Add the selected choice as the user's message
    _addMessage(content: choice, isUser: true);
    await _generateAIResponse(choice);
  }

  // Generate AI response based on user input
  Future<void> _generateAIResponse(String userInput) async {
    _setLoading(true);

    try {
      // Generate AI response
      final response = await _aiService.generateResponse(
        _gameState.messages,
        userInput,
      );

      print(response.toString());

      String? generatedImagePath;
      
      // Generate new image if a prompt was provided
      if (response.imagePrompt != null && response.imagePrompt!.isNotEmpty) {
        generatedImagePath = await _generateAndUpdateImage(response.imagePrompt!);
      }

      // Add AI response with any choices returned and the generated image
      _addMessage(
        content: response.text,
        isUser: false,
        choices: response.choices,
        imagePrompt: response.imagePrompt,
        imagePath: generatedImagePath, // Attach image path to message
      );

    } catch (e) {
      print(e);
      _addMessage(content: "Sorry, I encountered an error. Please try again.", isUser: false);
    } finally {
      _setLoading(false);
    }
  }

  // Generate new image or use fallback
  Future<String?> _generateAndUpdateImage(String imagePrompt) async {
    print("ImagePrompt: " + imagePrompt);
    try {
      final imageId = await _aiService.generateImage(imagePrompt);
      _gameState = _gameState.copyWith(currentImageId: imageId);
      return imageId; // Return the image path for attaching to messages
    } catch (e) {
      print('Image generation error: $e');
      // Use a fallback image ID that will display a placeholder
      _gameState = _gameState.copyWith(currentImageId: 'fallback_image');
      return null;
    } finally {
      notifyListeners();
    }
  }

  // Modified _addMessage to include imagePath
  void _addMessage({
    required String content,
    required bool isUser,
    List<String>? choices,
    String? imagePrompt,
    String? imagePath,
  }) {
    final message = StoryMessage(
      content: content, 
      isUser: isUser,
      choices: choices,
      imagePrompt: imagePrompt,
      imagePath: imagePath,
    );

    final updatedMessages = List<StoryMessage>.from(_gameState.messages)..add(message);
    _gameState = _gameState.copyWith(messages: updatedMessages);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
