import 'package:aiventures/core/models/story_message.dart';

abstract class AIService {
  /// Generates a response based on the conversation history
  Future<String> generateResponse(List<StoryMessage> conversationHistory, String userPrompt);
  
  /// Generates an image based on a description
  Future<String> generateImage(String description);
}