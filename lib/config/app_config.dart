class AppConfig {
  // API keys and configuration
  static const String appName = 'AIVenture';
  static const String appVersion = '1.0.0';
  
  // These would normally come from environment variables or secure storage
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  static const String imagenApiKey = 'YOUR_IMAGEN_API_KEY';
  
  // AI configuration
  static const int maxContextLength = 16; // Maximum number of messages to include in context
  static const int maxTokens = 500; // Maximum response length
  
  // Prompt engineering
  static const String systemPrompt = '''
You are an AI game master for an interactive fantasy text adventure.
Create immersive, detailed responses that build an engaging story world.
Each response should be 2-4 paragraphs and end with a question or choice for the player.
Be creative, descriptive, and adapt to the player's choices.
Maintain continuity with previous exchanges.
Compose an imagePrompt, a vivid description of the scene and/or characters that the player encounters.
''';
}