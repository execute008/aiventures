import 'package:flutter/material.dart';
import 'package:aiventures/core/models/story_message.dart';
import 'package:aiventures/features/adventure/controllers/adventure_controller.dart';
import 'package:aiventures/features/adventure/widgets/message_bubble.dart';
import 'package:aiventures/features/adventure/widgets/story_image.dart';
import 'package:aiventures/features/adventure/widgets/input_bar.dart';

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({super.key, required this.title});

  final String title;

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  late final AdventureController _controller;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _controller = AdventureController();
    _controller.addListener(_handleControllerUpdate);
    _startAdventure();
  }
  
  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    _controller.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _handleControllerUpdate() {
    setState(() {});
    _scrollToBottom();
  }
  
  Future<void> _startAdventure() async {
    await _controller.startAdventure();
  }
  
  Future<void> _sendUserInput() async {
    if (_inputController.text.trim().isEmpty) return;
    
    final userInput = _inputController.text;
    _inputController.clear();
    
    await _controller.processUserInput(userInput);
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.isLoading ? null : _startAdventure,
            tooltip: 'Restart Adventure',
          ),
        ],
      ),
      body: Column(
        children: [
          // Story image at the top
          if (_controller.currentImage.isNotEmpty)
            StoryImage(imageId: _controller.currentImage),
          
          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _controller.messages.length,
              itemBuilder: (context, index) {
                final message = _controller.messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          
          // Loading indicator
          if (_controller.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          
          // Input field
          InputBar(
            controller: _inputController,
            isLoading: _controller.isLoading,
            onSend: _sendUserInput,
          ),
        ],
      ),
    );
  }
}