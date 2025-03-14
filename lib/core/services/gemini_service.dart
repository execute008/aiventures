import 'package:aiventures/core/models/story_message.dart';
import 'package:aiventures/core/services/ai_service.dart';

class GeminiService implements AIService {
  // TODO: Add actual Gemini API integration
  
  @override
  Future<String> generateResponse(List<StoryMessage> conversationHistory, String userPrompt) async {
    // Mock implementation until we integrate the actual API
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple response based on the user input
    if (userPrompt.toLowerCase().contains('left')) {
      return "You squeeze through the narrow passage on the left. "
             "As you progress, the tunnel widens into a small chamber filled with "
             "glowing crystals. Their light reveals ancient carvings on the walls, "
             "depicting what appears to be a story of a powerful artifact. "
             "The chamber has two exits - one leading deeper underground and another "
             "that seems to slope upward. Which way do you go?";
    } else if (userPrompt.toLowerCase().contains('right')) {
      return "You venture into the wider tunnel on the right. "
             "The darkness envelops you, but distant echoes suggest a large space ahead. "
             "After walking for several minutes, you emerge into an enormous cavern with "
             "a subterranean lake. The water glows with an ethereal blue light. "
             "You notice a small boat moored at the shore and a narrow path that circles the lake. "
             "What will you do?";
    } else {
      return "You consider your options carefully. The cave seems to respond to your thoughts, "
             "the whispers growing louder. Something about this place feels magical, "
             "as if it's testing you. Will you take the narrow passage to the left or "
             "the wider tunnel to the right?";
    }
  }
  
  @override
  Future<String> generateImage(String description) async {
    // Mock implementation until we integrate the actual API
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real implementation, this would call Imagen API
    // and return a URL to the generated image
    if (description.toLowerCase().contains('crystal')) {
      return "crystal_chamber";
    } else if (description.toLowerCase().contains('lake')) {
      return "cavern_lake";
    } else if (description.toLowerCase().contains('fork')) {
      return "cave_fork";
    } else {
      return "cave_entrance";
    }
  }
}