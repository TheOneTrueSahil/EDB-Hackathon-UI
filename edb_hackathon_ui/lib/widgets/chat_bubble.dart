import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../models/lloyds_product.dart';
import 'product_card.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;
  final Function(LloydsProduct)? onProductExplore;

  const ChatBubble({
    super.key,
    required this.message,
    this.onProductExplore,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  bool _isThinkingExpanded = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    // Automatically expand thinking steps for the active/loading message
    if (widget.message.isThinking) {
      _isThinkingExpanded = true;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == MessageSender.user;
    
    // Lloyds Brand Colors
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);
    const brandGold = Color(0xFFB59049);
    const lightGrey = Color(0xFFF4F6F5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agent Avatar
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: deepGreen,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          
          // Bubble Body
          Expanded(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender label & time
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        isUser ? 'You' : 'Lloyds Banking Assistant',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isUser ? Colors.grey[600] : deepGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(widget.message.timestamp),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actual Text / Bubble Card
                if (widget.message.isThinking)
                  _buildThinkingBubble(context)
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? brandGreen : lightGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            widget.message.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              height: 1.4,
                            ),
                          )
                        : MarkdownBody(
                            data: widget.message.text,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                color: Color(0xFF2C2C2C),
                                fontSize: 14.5,
                                height: 1.45,
                              ),
                              h3: const TextStyle(
                                color: deepGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.6,
                              ),
                              listBullet: const TextStyle(
                                color: brandGreen,
                                fontSize: 14.5,
                              ),
                              strong: const TextStyle(
                                color: deepGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),

                // Collapsible Thinking Accordion (For Agent messages that have thinking logs)
                if (!isUser && widget.message.thinkingSteps.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildThinkingAccordion(context),
                ],

                // Recommended Products Carousel (For Agent messages that have recommended products)
                if (!isUser && widget.message.recommendedProducts.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildProductsCarousel(context),
                ],
              ],
            ),
          ),
          
          // User Avatar
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: brandGold.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: brandGold,
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.person_rounded,
                  color: deepGreen,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a typing indicator block with animated dots and current thinking step
  Widget _buildThinkingBubble(BuildContext context) {
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.zero,
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(
          color: brandGreen.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _pulseController,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: brandGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Lloyds Agent is analyzing...',
                style: TextStyle(
                  color: deepGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.message.text.isNotEmpty ? widget.message.text : 'Accessing secure customer vaults...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the collapsible thinking step list component
  Widget _buildThinkingAccordion(BuildContext context) {
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);
    const brandGold = Color(0xFFB59049);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          // Accordion Header
          InkWell(
            onTap: () {
              setState(() {
                _isThinkingExpanded = !_isThinkingExpanded;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: _isThinkingExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: brandGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.psychology_outlined,
                    color: brandGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AGENT REASONING PIPELINE',
                      style: TextStyle(
                        color: deepGreen.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: brandGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.message.thinkingSteps.length} steps',
                      style: const TextStyle(
                        color: brandGreen,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Collapsible Content
          if (_isThinkingExpanded)
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.message.thinkingSteps.length,
                itemBuilder: (context, index) {
                  final step = widget.message.thinkingSteps[index];
                  final isLast = index == widget.message.thinkingSteps.length - 1;
                  
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left line & indicator node
                        Column(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: step.contains('⚠️') 
                                    ? Colors.amber 
                                    : (step.contains('✅') || step.contains('[DB]') ? brandGreen : brandGold),
                                shape: BoxShape.circle,
                              ),
                            ),
                            if (!isLast)
                              Expanded(
                                child: Container(
                                  width: 1.5,
                                  color: Colors.grey[300],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        
                        // Step Content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              step,
                              style: TextStyle(
                                color: Colors.grey[750] ?? const Color(0xFF4A4A4A),
                                fontSize: 11,
                                height: 1.3,
                                fontFamily: 'Courier', // monospace code trace style
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a horizontal list carousel of recommended Lloyds products
  Widget _buildProductsCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFFB59049),
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'RECOMMENDED LLOYDS PRODUCTS FOR YOU',
                style: TextStyle(
                  color: Color(0xFF002C1B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 340,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.message.recommendedProducts.length,
            itemBuilder: (context, index) {
              final product = widget.message.recommendedProducts[index];
              return ProductCard(
                product: product,
                onApplyPressed: () {
                  if (widget.onProductExplore != null) {
                    widget.onProductExplore!(product);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
