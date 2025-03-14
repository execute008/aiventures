class StoryMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  
  StoryMessage({
    required this.content, 
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}