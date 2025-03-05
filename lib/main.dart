import 'package:aiventures/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AIVentureApp());
}

class AIVentureApp extends StatelessWidget {
  const AIVentureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIVenture',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Merriweather',
      ),
      home: const AdventureScreen(title: 'AIVenture'),
    );
  }
}

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({super.key, required this.title});

  final String title;

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen> {
  final List<StoryMessage> _storyMessages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? _currentImage;
  
  @override
  void initState() {
    super.initState();
    _startAdventure();
  }
  
  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _startAdventure() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate loading time (replace with actual API call later)
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _storyMessages.add(
        StoryMessage(
          content: "You find yourself standing at the entrance of a mysterious cave. "
                 "The entrance is covered with ancient symbols and glowing runes. "
                 "A cool breeze flows from inside, carrying whispers of forgotten tales. "
                 "What do you do?",
          isUser: false,
        ),
      );
      _currentImage = "cave_entrance"; // This would be a generated image URL in the future
      _isLoading = false;
    });
    
    _scrollToBottom();
  }
  
  Future<void> _sendUserInput() async {
    if (_inputController.text.trim().isEmpty) return;
    
    final userInput = _inputController.text;
    _inputController.clear();
    
    setState(() {
      _storyMessages.add(StoryMessage(content: userInput, isUser: true));
      _isLoading = true;
    });
    
    _scrollToBottom();
    
    // Simulate API call delay (replace with actual Gemini API call)
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock response (will be replaced with actual Gemini response)
    String aiResponse = "As you approach the cave entrance, the symbols begin to glow brighter. "
                       "You feel a strange energy surrounding you, almost guiding you inward. "
                       "The whispers grow louder, but you can't quite make out the words. "
                       "The path splits in two directions - a narrow passage to the left and "
                       "a wider, darker tunnel to the right. Where will you go?";
    
    setState(() {
      _storyMessages.add(StoryMessage(content: aiResponse, isUser: false));
      _currentImage = "cave_fork"; // This would be a generated image URL in the future
      _isLoading = false;fl
    });
    
    _scrollToBottom();
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
            onPressed: _isLoading ? null : _startAdventure,
            tooltip: 'Restart Adventure',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentImage != null)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.black26,
                    alignment: Alignment.center,
                    child: Text(
                      "[Image will be generated here using Imagen]",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _storyMessages.length,
              itemBuilder: (context, index) {
                final message = _storyMessages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'What will you do?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    maxLines: 1,
                    enabled: !_isLoading,
                    onSubmitted: (_) => _sendUserInput(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendUserInput,
                  tooltip: 'Send',
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StoryMessage {
  final String content;
  final bool isUser;
  
  StoryMessage({required this.content, required this.isUser});
}

class MessageBubble extends StatelessWidget {
  final StoryMessage message;
  
  const MessageBubble({super.key, required this.message});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
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
    );
  }
}
