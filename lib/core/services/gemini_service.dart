import 'dart:convert';
import 'dart:io';

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
    final model = FirebaseVertexAI.instance.imagenModel(
      model: 'imagen-3.0-fast-generate-001',
      generationConfig: ImagenGenerationConfig(
        numberOfImages: 1,
        aspectRatio: ImagenAspectRatio.landscape16x9,
        imageFormat: ImagenFormat.jpeg(compressionQuality: 90),
        addWatermark: false,
      ),
    );

    final response = await model.generateImages(prompt);

    // If fewer images were generated than were requested,
    // then `filteredReason` will describe the reason they were filtered out
    if (response.filteredReason != null) {
      print('Images filtered: ${response.filteredReason}');
    }

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
      throw Exception('Failed to generate image');
    }
  }
}
