import 'dart:io';
import 'package:flutter/material.dart';
import 'package:aiventures/core/models/story_message.dart';
import 'package:aiventures/features/adventure/widgets/full_screen_image_view.dart';

class MessageBubble extends StatelessWidget {
  final StoryMessage message;
  final List<String>? choices;
  final Function(String)? onChoiceSelected;
  
  const MessageBubble({
    super.key, 
    required this.message,
    this.choices,
    this.onChoiceSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: message.isUser 
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: message.isUser 
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          
          // Display image if available in the message
          if (!message.isUser && message.imagePath != null)
            _buildMessageImage(context, message.imagePath!),
          
          // Choices (only shown for AI messages with choices)
          if (!message.isUser && choices != null && choices!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0, right: 8.0, bottom: 8.0),
              child: ChoiceOptions(
                choices: choices!,
                onChoiceSelected: onChoiceSelected,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMessageImage(BuildContext context, String imagePath) {
    final file = File(imagePath);
    
    // Check if file exists
    if (!file.existsSync()) {
      return const SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imagePath),
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 150, // Limit image height in chat
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
                // Small icon to indicate the image is tappable
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(imagePath: imagePath),
      ),
    );
  }
}

class ChoiceOptions extends StatelessWidget {
  final List<String> choices;
  final Function(String)? onChoiceSelected;
  
  const ChoiceOptions({
    super.key,
    required this.choices,
    this.onChoiceSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Choose an option:',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        ...choices.map((choice) => ChoiceButton(
          choice: choice,
          onTap: () => onChoiceSelected?.call(choice),
        )),
      ],
    );
  }
}

class ChoiceButton extends StatelessWidget {
  final String choice;
  final VoidCallback? onTap;
  
  const ChoiceButton({
    super.key,
    required this.choice,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.arrow_right,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    choice,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}