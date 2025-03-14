import 'package:aiventures/core/models/story_message.dart';

class GameState {
  final List<StoryMessage> messages;
  final String currentImageId;
  final String adventureContext;
  
  GameState({
    List<StoryMessage>? messages,
    this.currentImageId = '',
    this.adventureContext = '',
  }) : messages = messages ?? [];
  
  GameState copyWith({
    List<StoryMessage>? messages,
    String? currentImageId,
    String? adventureContext,
  }) {
    return GameState(
      messages: messages ?? this.messages,
      currentImageId: currentImageId ?? this.currentImageId,
      adventureContext: adventureContext ?? this.adventureContext,
    );
  }
}