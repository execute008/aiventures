class StoryMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? choices;
  final String? imagePrompt;
  final String? imagePath;
  
  StoryMessage({
    required this.content, 
    required this.isUser,
    DateTime? timestamp,
    this.choices,
    this.imagePrompt,
    this.imagePath,
  }) : timestamp = timestamp ?? DateTime.now();
}