import 'lloyds_product.dart';

enum MessageSender { user, agent }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String> thinkingSteps;
  final List<LloydsProduct> recommendedProducts;
  final bool isThinking;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.thinkingSteps = const [],
    this.recommendedProducts = const [],
    this.isThinking = false,
  });

  ChatMessage copyWith({
    String? text,
    List<String>? thinkingSteps,
    List<LloydsProduct>? recommendedProducts,
    bool? isThinking,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      thinkingSteps: thinkingSteps ?? this.thinkingSteps,
      recommendedProducts: recommendedProducts ?? this.recommendedProducts,
      isThinking: isThinking ?? this.isThinking,
    );
  }
}
