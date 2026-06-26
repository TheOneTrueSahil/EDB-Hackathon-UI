import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/persona.dart';
import '../models/lloyds_product.dart';
import '../services/agent_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/persona_selector.dart';
import 'insights_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AgentService _agentService = AgentService();

  // Settings State
  String _apiUrl = const String.fromEnvironment(
    'API_URL', 
    defaultValue: 'https://agent-service-3g6pwfy77q-uc.a.run.app/api/chat'
  );
  String _apiKey = const String.fromEnvironment('API_KEY', defaultValue: '');

  late Persona _currentPersona;
  late String _sessionId;
  bool _isGenerating = false;

  // Accumulated insights data for the InsightsScreen
  Map<String, double> _accumulatedSpending = {};
  String? _accumulatedGoalType;

  @override
  void initState() {
    super.initState();
    print('DEBUG: App Booted. Env values:');
    print('   - API_URL: "$_apiUrl"');
    print('   - API_KEY: ${_apiKey.isNotEmpty ? "SET (length: ${_apiKey.length})" : "NOT SET"}');
    
    // Start with the first persona (Sarah Jenkins)
    _currentPersona = Persona.personas.first;
    _setInitialPersonaState(_currentPersona);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Sets up the chat for a new persona: clears chat and sends initial welcome
  void _setInitialPersonaState(Persona persona) {
    _messages.clear();
    _sessionId = 'session_${persona.id}_${DateTime.now().millisecondsSinceEpoch}';
    // Reset accumulated insights when switching personas
    _accumulatedSpending = {};
    _accumulatedGoalType = null;
    
    // Add system-like welcome message showing retrieved database parameters
    _messages.add(ChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Hello! I am your **Lloyds Banking Assistant**.\n\n'
          'I have automatically retrieved your customer profile for **${persona.name}** from the Lloyds secure vault. Here is the background context I am using for our chat:\n\n'
          '*   **Profile Segment**: ${persona.role}\n'
          '*   **DOB**: ${persona.dob}\n'
          '*   **Gender**: ${persona.gender == 'F' ? 'Female' : 'Male'}\n'
          '*   **Phone**: ${persona.phone}\n'
          '*   **Address**: ${persona.address}, ${persona.postcode}\n'
          '*   **Annual Income**: ${persona.income}\n'
          '*   **Current Savings**: ${persona.savings}\n'
          '*   **Stated Goal**: ${persona.financialGoal}\n\n'
          'How can I help you today? You can type a question, or select one of the suggested topics below.',
      sender: MessageSender.agent,
      timestamp: DateTime.now(),
      thinkingSteps: [
        '🔐 Connected to Lloyds Vault API (Secure Oauth2)...',
        '✅ User authenticated: ${persona.name}',
        '📥 Profile data successfully merged with LLM context window.',
      ],
      recommendedProducts: [],
    ));

    setState(() {
      _currentPersona = persona;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Triggered when the user submits a message
  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isGenerating) return;

    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isGenerating = true;
      _inputController.clear();
    });
    _scrollToBottom();

    // Create a temporary "Thinking" placeholder message in the list
    final placeholderId = 'thinking_placeholder';
    final thinkingMsg = ChatMessage(
      id: placeholderId,
      text: 'Analyzing your query against Lloyds product specifications...',
      sender: MessageSender.agent,
      timestamp: DateTime.now(),
      isThinking: true,
      thinkingSteps: ['🔍 Analyzing message for financial goals...'],
    );

    setState(() {
      _messages.add(thinkingMsg);
    });
    _scrollToBottom();

    // Setup progressive thinking steps to make the UI look very alive
    Timer? thinkingTimer;
    List<String> accumulatedSteps = [];
    final List<String> stepsToSimulate = [
      '📡 Connecting to Lloyds Cloud Run API...',
      '🔐 Initiating secure channel (OAuth2)...',
      '📂 Querying Lloyds Secure Vault for ${_currentPersona.name}...',
      '📊 Processing user session $_sessionId...',
      '🧠 Invoking Lloyds Advisor Agent Chain (ADK)...',
      '🛠️ Agent executing reasoning path & product search...',
      '🔄 Consolidating multi-agent responses...',
    ];

    int stepIndex = 0;
    thinkingTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (stepIndex < stepsToSimulate.length && _isGenerating) {
        accumulatedSteps.add(stepsToSimulate[stepIndex]);
        stepIndex++;
        
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == placeholderId);
          if (idx != -1) {
            _messages[idx] = _messages[idx].copyWith(
              text: 'Step $stepIndex: ${stepsToSimulate[stepIndex - 1]}',
              thinkingSteps: List.from(accumulatedSteps),
            );
          }
        });
      } else {
        timer.cancel();
      }
    });

    try {
      final responseMessage = await _agentService.sendMessage(
        text: text,
        persona: _currentPersona,
        sessionId: _sessionId,
        history: _messages,
        apiUrl: _apiUrl,
        apiKey: _apiKey,
      );

      // Stop our timer if it was running
      thinkingTimer.cancel();

      // Extract spending insights and goal type from the response
      final newInsights = ChatBubble.parseSpendingInsights(responseMessage.text);
      final newGoalType = ChatBubble.detectGoalType(responseMessage.text);

      setState(() {
        // Remove the thinking placeholder and insert the actual response
        _messages.removeWhere((m) => m.id == placeholderId);
        _messages.add(responseMessage);
        _isGenerating = false;
        // Accumulate spending data across messages
        newInsights.forEach((cat, amt) {
          _accumulatedSpending[cat] = (_accumulatedSpending[cat] ?? 0) + amt;
        });
        if (newGoalType != null) _accumulatedGoalType = newGoalType;
      });
      _scrollToBottom();
    } catch (e) {
      thinkingTimer.cancel();
      setState(() {
        _messages.removeWhere((m) => m.id == placeholderId);
        _messages.add(ChatMessage(
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
          text: 'An error occurred while connecting to the Lloyds Agent Service. Please check your settings.\n\nError details: $e',
          sender: MessageSender.agent,
          timestamp: DateTime.now(),
          thinkingSteps: ['⚠️ Connection timeout', '❌ HTTP POST failed'],
        ));
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  /// Opens the Product details in a premium bottom sheet dialog
  void _showProductDetails(LloydsProduct product) {
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);
    const brandGold = Color(0xFFB59049);
    const softMint = Color(0xFFF0F7F4);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Product Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: softMint,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: brandGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Text(
                product.name,
                style: const TextStyle(
                  color: deepGreen,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              
              // Rate / Offer Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [brandGreen, deepGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: brandGold,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        product.highlight,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Product Details',
                style: TextStyle(
                  color: deepGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                product.description,
                style: const TextStyle(
                  color: Color(0xFF4E4E4E),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              
              const Text(
                'Key Benefits & Eligibility',
                style: TextStyle(
                  color: deepGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              
              ...product.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: brandGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Color(0xFF3C3C3C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              
              // Final CTA
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening application for ${product.name}...'),
                        backgroundColor: brandGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Apply / Learn More Online',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Retrives suggestion chips tailored to the selected persona
  List<String> _getSuggestionChips() {
    switch (_currentPersona.id) {
      case 'C001':
        return [
          'Please verify me as C001',
          'Show my spending insights',
          'Mortgage options for Alice'
        ];
      case 'C002':
        return [
          'Please verify me as C002',
          'Review my Cash ISA',
          'Tax-efficient savings options'
        ];
      case 'C003':
        return [
          'Please verify me as C003',
          'Regular monthly savers',
          'Emergency fund advice'
        ];
      case 'C004':
        return [
          'Please verify me as C004',
          'Refinance my £185k mortgage',
          'Lloyds personal loan rates'
        ];
      case 'C005':
        return [
          'Please verify me as C005',
          'Optimize my £16k savings',
          'Stocks & Shares ISA details'
        ];
      default:
        return ['Verify customer ID', 'Lloyds savings products', 'Mortgage calculator'];
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);
    const brandGold = Color(0xFFB59049);
    
    final suggestionChips = _getSuggestionChips();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: deepGreen,
        elevation: 1,
        title: Row(
          children: [
            // Circular Logo Layout mimicking Lloyds Banking Group icon
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: brandGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LLOYDS BANKING GROUP',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Georgia',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const Text(
                  'Agent Demo (Live Cloud Run)',
                  style: TextStyle(
                    color: brandGold,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Insights Dashboard button
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: brandGold),
            tooltip: 'Spending & Goals Dashboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InsightsScreen(
                    persona: _currentPersona,
                    apiUrl: _apiUrl,
                    apiKey: _apiKey,
                    seedSpending: Map.from(_accumulatedSpending),
                    seedGoalType: _accumulatedGoalType ?? _currentPersona.id,
                  ),
                ),
              );
            },
          ),
          // Config gear
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            tooltip: 'Configure Endpoint',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    initialApiUrl: _apiUrl,
                    initialApiKey: _apiKey,
                    onSaved: (url, key) {
                      setState(() {
                        _apiUrl = url;
                        _apiKey = key;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Persona Selection Header
          PersonaSelector(
            selectedPersona: _currentPersona,
            onPersonaSelected: (persona) {
              if (_isGenerating) return; // Prevent switching while agent is working
              _setInitialPersonaState(persona);
            },
          ),
          
          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  message: message,
                  onProductExplore: _showProductDetails,
                );
              },
            ),
          ),
          
          // Custom Bottom Row (Suggestion Chips + Input Field)
          SafeArea(
            child: Column(
              children: [
                // Suggestion chips
                if (!_isGenerating && suggestionChips.isNotEmpty)
                  Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: suggestionChips.length,
                      itemBuilder: (context, index) {
                        final chipText = suggestionChips[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ActionChip(
                            label: Text(
                              chipText,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: brandGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            backgroundColor: brandGreen.withOpacity(0.06),
                            side: BorderSide(color: brandGreen.withOpacity(0.2), width: 0.8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onPressed: () => _handleSubmitted(chipText),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Text Input Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  controller: _inputController,
                                  decoration: const InputDecoration(
                                    hintText: 'Ask the Lloyds Advisor...',
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 4,
                                  minLines: 1,
                                  onSubmitted: _handleSubmitted,
                                  enabled: !_isGenerating,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send Floating Action Button
                      FloatingActionButton.small(
                        onPressed: _isGenerating
                            ? null
                            : () => _handleSubmitted(_inputController.text),
                        backgroundColor: _isGenerating ? Colors.grey : brandGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        child: const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
