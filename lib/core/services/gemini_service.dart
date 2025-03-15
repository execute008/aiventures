import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:aiventures/config/app_config.dart';
import 'package:aiventures/core/models/story_message.dart';
import 'package:aiventures/core/services/ai_service.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:path_provider/path_provider.dart';

class GeminiService implements AIService {
  @override
  Future<AIResponse> generateResponse(
    List<StoryMessage> conversationHistory,
    String userPrompt,
  ) async {
    try {
      final model = FirebaseVertexAI.instance.generativeModel(
        model: 'gemini-2.0-flash',
        systemInstruction: Content.system(AppConfig.systemPrompt),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'text': Schema.string(),
              'choices': Schema.array(items: Schema.string()),
              'imagePrompt': Schema.string(),
            },
          ),
        ),
      );

      final List<Content> promptContents = [];

      if (conversationHistory.isNotEmpty) {
        promptContents.add(Content.text("--- CONVERSATION HISTORY ---"));

        for (final message in conversationHistory) {
          // Make sure we distinguish between player and AI clearly
          final role = message.isUser ? "PLAYER" : "ADVENTURE_MASTER";
          promptContents.add(Content.text("$role: ${message.content}"));
        }

        promptContents.add(Content.text("--- END OF HISTORY ---"));
      }

      // Add current user prompt
      promptContents.add(Content.text("PLAYER: $userPrompt"));

      promptContents.add(Content.text(
        """
        INSTRUCTIONS:
        1. Respond as the adventure master, continuing the story based on the player's action.
        2. Your response should be engaging and descriptive but not too long.
        3. Stick to the JSON Schema provided for the response.:
        {
          "text": "Your response text here.",
          "choices": ["Choice 1", "Choice 2", "Choice 3"],
          "imagePrompt": "A vivid description of the scene or characters."
        }
        4. Make sure each choice is direct, actionable, and NO QUESTIONS in choices.
        5. Vary the choices to give players interesting options.
        6. The imagePrompt should vividly describe a scene that represents the current situation.
        7. DO NOT include any text outside the JSON object.
        """
      ));

      final response = (await model.generateContent(promptContents)).text;

      if (response == null) {
        throw Exception("Failed to generate response");
      }

      final data = json.decode(response);

      if (data == null) {
        throw Exception("Failed to decode response");
      }

      return AIResponse(
        text: data['text'],
        choices: List<String>.from(data['choices']),
        imagePrompt: data['imagePrompt'],
      );
    } catch (e) {
      print('Error: $e');
      return AIResponse(
        text:
            "Something mysterious happened and the adventure couldn't continue. Let's try a different path.",
        choices: [
          "Try again",
          "Start a new adventure",
          "Explore another direction",
        ],
        imagePrompt: "A mysterious magical disturbance in a fantasy setting",
      );
    }
  }

  @override
  Future<String> generateImage(String prompt) async {
    // Maximum number of retries
    const int maxRetries = 3;
    
    // Try Vertex AI first, with multiple retries
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('Attempting to generate image with Vertex AI (Attempt $attempt of $maxRetries)');
        return await _generateImageWithVertexAI(prompt);
      } catch (e) {
        print('Vertex AI image generation failed on attempt $attempt: $e');
        
        // If this is the last attempt, try the fallback
        if (attempt == maxRetries) {
          print('All Vertex AI attempts failed, using fallback image generator');
          return await _generateFallbackImage(prompt);
        }
        
        // Otherwise, wait a moment and try again
        await Future.delayed(Duration(seconds: 1 * attempt)); // Progressive backoff
      }
    }
    
    // This should never happen due to the loop structure, but just in case
    return await _generateFallbackImage(prompt);
  }

  Future<String> _generateImageWithVertexAI(String prompt) async {
    try {
      final model = FirebaseVertexAI.instance.imagenModel(
        model: 'imagen-3.0-fast-generate-001',
        generationConfig: ImagenGenerationConfig(
          numberOfImages: 1,
          aspectRatio: ImagenAspectRatio.landscape16x9,
          imageFormat: ImagenFormat.jpeg(compressionQuality: 90),
          addWatermark: false,
        ),
      );

      // Set a timeout to prevent hanging if the API has issues
      final response = await model.generateImages(prompt).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Image generation timed out');
        },
      );
      
      if (response.images.isNotEmpty) {
        // Get the first generated image
        final image = response.images.first;

        // Save the image to local file system
        final directory = await getApplicationDocumentsDirectory();
        final filename = 'imagen_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = '${directory.path}/$filename';

        // Create file and write bytes
        final file = File(filePath);
        await file.writeAsBytes(image.bytesBase64Encoded);

        // Return the file path as image ID
        return filePath;
      } else {
        // If no image was generated, throw an exception
        throw Exception('No images were generated');
      }
    } catch (e) {
      print('Error in Vertex AI image generation: $e');
      rethrow;
    }
  }

  Future<String> _generateFallbackImage(String prompt) async {
    try {
      // Create a placeholder image
      final directory = await getApplicationDocumentsDirectory();
      final filename = 'fallback_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${directory.path}/$filename';
      
      // Determine what kind of image to generate based on the prompt
      final imageBytes = await _createImageFromPrompt(prompt);
      
      // Save the generated image
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);
      
      return filePath;
    } catch (e) {
      print('Fallback image generation failed: $e');
      throw Exception('Failed to generate fallback image');
    }
  }

  Future<Uint8List> _createImageFromPrompt(String prompt) async {
    // Get a sample image from assets based on keywords in the prompt
    final lowerPrompt = prompt.toLowerCase();
    
    // Load and return a preset image from assets
    String assetPath;
    
    if (lowerPrompt.contains('cave') || lowerPrompt.contains('dungeon')) {
      assetPath = 'assets/placeholders/cave.jpg';
    } else if (lowerPrompt.contains('forest') || lowerPrompt.contains('tree')) {
      assetPath = 'assets/placeholders/forest.jpg';
    } else if (lowerPrompt.contains('water') || lowerPrompt.contains('lake')) {
      assetPath = 'assets/placeholders/water.jpg';
    } else if (lowerPrompt.contains('crystal') || lowerPrompt.contains('gem')) {
      assetPath = 'assets/placeholders/crystal.jpg';
    } else if (lowerPrompt.contains('monster') || lowerPrompt.contains('creature')) {
      assetPath = 'assets/placeholders/monster.jpg';
    } else {
      assetPath = 'assets/placeholders/default.jpg';
    }
    
    // Try to load asset
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('Failed to load asset: $e');
      // If asset loading fails, generate a simple colored image
      return _createColoredImageWithText(480, 320, prompt);
    }
  }

  Uint8List _createColoredImageWithText(int width, int height, String prompt) {
    // For this fallback implementation, we'll need to implement
    // a method to create a colored image with text
    // Since this is complex to do in pure Dart, we'll just create
    // a solid color for now
    
    final List<int> buffer = List<int>.filled(width * height * 4, 0);
    
    // Choose color based on prompt
    int r, g, b;
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('cave') || lowerPrompt.contains('dark')) {
      r = 30; g = 40; b = 50; // Dark blue
    } else if (lowerPrompt.contains('forest')) {
      r = 20; g = 80; b = 30; // Green
    } else if (lowerPrompt.contains('water')) {
      r = 30; g = 50; b = 120; // Blue
    } else if (lowerPrompt.contains('fire') || lowerPrompt.contains('lava')) {
      r = 150; g = 30; b = 10; // Red
    } else if (lowerPrompt.contains('crystal')) {
      r = 40; g = 120; b = 140; // Cyan
    } else {
      r = 60; g = 60; b = 100; // Default purple
    }
    
    // Fill the buffer with the color
    for (int i = 0; i < width * height; i++) {
      final index = i * 4;
      buffer[index] = r;
      buffer[index + 1] = g;
      buffer[index + 2] = b;
      buffer[index + 3] = 255; // Alpha
    }
    
    return Uint8List.fromList(buffer);
  }
}
