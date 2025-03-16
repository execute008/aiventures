
# AIVentures

AIVentures is a Flutter-based text adventure game powered by AI. The application creates immersive interactive stories where users can make choices and see their adventure unfold with both text and AI-generated images.

## Features

* **AI-powered storytelling** : Uses Google's Gemini 2.0 Flash model to create dynamic narratives that adapt to player choices
* **Image generation** : Integrates with Imagen 3.0 to create visuals that match the current scene in your adventure
* **Interactive choices** : Players can select predefined options or enter free text to continue their story
* **Cross-platform** : Supports iOS, Android, macOS, Windows, Linux, and web

## Technical Overview

* **Architecture** : Feature-based organization with controllers, services, screens and widgets
* **AI Integration** : Firebase VertexAI for both text (Gemini) and image (Imagen) generation
* **UI** : Material Design 3 with custom theming for an immersive dark mode experience
* **State Management** : Uses ChangeNotifier pattern for state management

## Core Components

* **AdventureController** : Manages game state and communication with AI services
* **GeminiService** : Handles prompting and response parsing from the AI
* **StoryImage/MessageBubble** : UI components for displaying the adventure

## Setup Requirements

1. Firebase project with VertexAI API enabled
2. Google Cloud credentials for Gemini and Imagen models
3. Flutter SDK 3.7.0+

## Getting Started

1. Clone the repository
2. Set up Firebase using Firebase CLI: `flutterfire configure`
3. Add your API keys to the config file
4. Run the app: `flutter run`

## Supported Platforms

* iOS 13.0+
* Android API level varies by device
* Windows, macOS, Linux
* Web (limited functionality)

## Future Improvements

* Persistent story saving
* Adventure sharing
* Additional image generation options
* Audio narration
