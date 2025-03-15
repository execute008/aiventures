import 'package:aiventures/core/models/story_message.dart';

class AIResponse {
  final String text;
  final String? imagePrompt;
  final List<String>? choices;

  AIResponse({required this.text, this.imagePrompt, this.choices = const []});

  @override
  String toString() {
    return 'AIResponse(text: $text, imagePrompt: $imagePrompt, choices: $choices)';
  }
}

abstract class AIService {
  Future<AIResponse> generateResponse(
    List<StoryMessage> conversationHistory,
    String userPrompt,
  );

  /// Generates an image based on a description
  Future<String> generateImage(String description);
}
