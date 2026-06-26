import 'package:flutter/material.dart';
import '../models/persona.dart';
import '../services/agent_service.dart';
import '../widgets/chat_bubble.dart';

class InsightsScreen extends StatefulWidget {
  final Persona persona;
  final String apiUrl;
  final String apiKey;
  // Optionally seed with already-accumulated data
  final Map<String, double> seedSpending;
  final String? seedGoalType;

  const InsightsScreen({
    super.key,
    required this.persona,
    required this.apiUrl,
    required this.apiKey,
    this.seedSpending = const {},
    this.seedGoalType,
  });

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const brandGreen = Color(0xFF006A4E);
  static const deepGreen = Color(0xFF002C1B);
  static const brandGold = Color(0xFFB59049);
  static const lightMint = Color(0xFFF0F7F4);

  bool _isLoadingSpending = false;
  bool _isLoadingGoal = false;
  String? _spendingError;
  String? _goalError;

  Map<String, double> _spending = {};
  String? _rawSpendingResponse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Seed with already-accumulated data
    _spending = Map.from(widget.seedSpending);
    // Auto-fetch on open
    _fetchSpendingInsights();
    _fetchGoalInsights();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Auto-fetch from real API ─────────────────────────────────────────────

  Future<void> _fetchSpendingInsights() async {
    setState(() {
      _isLoadingSpending = true;
      _spendingError = null;
    });

    try {
      final service = AgentService();
      final sessionId =
          'insights_${widget.persona.id}_${DateTime.now().millisecondsSinceEpoch}';

      final prompt =
          'Please verify me as ${widget.persona.id} and then give me a detailed '
          'monthly spending breakdown by category. '
          'List each category as a bullet point with the amount in GBP, '
          'for example: * Groceries: £350.00. Then give me 2-3 actionable tips '
          'to improve my spending habits.';

      final response = await service.sendMessage(
        text: prompt,
        sessionId: sessionId,
        persona: widget.persona,
        history: const [],
        apiUrl: widget.apiUrl,
        apiKey: widget.apiKey,
      );

      final parsed = ChatBubble.parseSpendingInsights(response.text);
      setState(() {
        _rawSpendingResponse = response.text;
        if (parsed.isNotEmpty) {
          _spending = parsed;
        }
        _isLoadingSpending = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSpending = false;
        _spendingError = e.toString();
      });
    }
  }

  Future<void> _fetchGoalInsights() async {
    setState(() {
      _isLoadingGoal = true;
      _goalError = null;
    });
    // Small delay so the two calls don't overlap on the endpoint
    await Future.delayed(const Duration(seconds: 3));

    try {
      final service = AgentService();
      final sessionId =
          'goals_${widget.persona.id}_${DateTime.now().millisecondsSinceEpoch}';

      final prompt =
          'I am customer ${widget.persona.id}. What is my current financial goal '
          'progress and what are the next steps I should take to achieve it?';

      await service.sendMessage(
        text: prompt,
        sessionId: sessionId,
        persona: widget.persona,
        history: const [],
        apiUrl: widget.apiUrl,
        apiKey: widget.apiKey,
      );

      setState(() {
        _isLoadingGoal = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGoal = false;
        _goalError = e.toString();
      });
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightMint,
      appBar: AppBar(
        backgroundColor: deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INSIGHTS DASHBOARD',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Georgia',
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              widget.persona.name,
              style: const TextStyle(
                color: brandGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        actions: [
          if (_isLoadingSpending || _isLoadingGoal)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: brandGold,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh insights',
            onPressed: (_isLoadingSpending || _isLoadingGoal)
                ? null
                : () {
                    _fetchSpendingInsights();
                    _fetchGoalInsights();
                  },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: brandGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.analytics_rounded, size: 18), text: 'SPENDING'),
            Tab(icon: Icon(Icons.flag_rounded, size: 18), text: 'GOALS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSpendingTab(context),
          _buildGoalTab(context),
        ],
      ),
    );
  }

  // ─── SPENDING TAB ─────────────────────────────────────────────────────────

  Widget _buildSpendingTab(BuildContext context) {
    if (_isLoadingSpending) {
      return _buildLoadingState(
        label: 'Fetching live spending data for ${widget.persona.name}...',
      );
    }
    if (_spendingError != null) {
      return _buildErrorState(
        error: _spendingError!,
        onRetry: _fetchSpendingInsights,
      );
    }
    if (_spending.isEmpty) {
      return _buildEmptyState(
        icon: Icons.analytics_outlined,
        title: 'No Spending Data Found',
        subtitle:
            'The agent could not parse spending categories from the response. '
            'Try refreshing or ask the agent directly about spending.',
        onRetry: _fetchSpendingInsights,
      );
    }

    final double total = _spending.values.fold(0.0, (s, v) => s + v);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(Icons.analytics_rounded, 'LIVE SPENDING ANALYSIS'),
        const SizedBox(height: 8),

        // Live badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: brandGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 6),
                  SizedBox(width: 5),
                  Text(
                    'LIVE FROM AGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: deepGreen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Analyzed Monthly Outgoings',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '£${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._spending.entries.map((entry) {
                      final cat = entry.key;
                      final amt = entry.value;
                      final pct = total > 0 ? amt / total : 0.0;
                      final (icon, color) = _categoryMeta(cat);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(icon, color: color, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(cat,
                                      style: const TextStyle(
                                        color: Color(0xFF2C2C2C),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ),
                                Text(
                                  '£${amt.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: deepGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 7,
                                backgroundColor: const Color(0xFFF4F6F5),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${(pct * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildHabitTipCard(),

        // Show raw agent response as accordion for transparency
        if (_rawSpendingResponse != null) ...[
          const SizedBox(height: 16),
          _buildRawResponseAccordion(_rawSpendingResponse!),
        ],
      ],
    );
  }

  Widget _buildHabitTipCard() {
    final id = widget.persona.id;
    String tipText;
    if (id == 'C001') {
      tipText = 'Save £50/month on dining out to reach your home deposit milestone 3 months earlier.';
    } else if (id == 'C002') {
      tipText = 'Move surplus Classic Account cash into your Cash ISA to maximize tax-free yields.';
    } else if (id == 'C003') {
      tipText = 'Open a Club Lloyds Saver (5.25% AER) and set a £250 monthly transfer to automate savings.';
    } else if (id == 'C004') {
      tipText = 'Explore refinancing options for your £185k mortgage to lower interest expenses.';
    } else {
      tipText = 'Move £9k from Easy Saver into a Stocks & Shares ISA to access long-term market growth.';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brandGold.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: brandGold, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actionable Habit Recommendation',
                  style: TextStyle(
                    color: deepGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tipText,
                  style: const TextStyle(
                    color: Color(0xFF4A4A4A),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawResponseAccordion(String text) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: const Icon(Icons.psychology_outlined, color: brandGreen, size: 18),
          title: const Text(
            'Agent Response (raw)',
            style: TextStyle(
              color: deepGreen,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _categoryMeta(String cat) {
    switch (cat) {
      case 'Rent & Housing':
        return (Icons.home_rounded, brandGreen);
      case 'Utilities & Bills':
        return (Icons.receipt_long_rounded, Colors.orange);
      case 'Groceries':
        return (Icons.shopping_basket_rounded, Colors.teal);
      case 'Telecoms & Internet':
        return (Icons.wifi_rounded, Colors.blue);
      case 'Entertainment & Subs':
        return (Icons.subscriptions_rounded, Colors.purple);
      case 'Travel & Commute':
        return (Icons.directions_bus_rounded, Colors.indigo);
      case 'Dining & Leisure':
        return (Icons.restaurant_rounded, const Color(0xFFD81B60));
      default:
        return (Icons.category_rounded, Colors.grey);
    }
  }

  // ─── GOALS TAB ────────────────────────────────────────────────────────────

  Widget _buildGoalTab(BuildContext context) {
    if (_isLoadingGoal) {
      return _buildLoadingState(
        label: 'Fetching financial goal data for ${widget.persona.name}...',
      );
    }
    if (_goalError != null) {
      return _buildErrorState(
        error: _goalError!,
        onRetry: _fetchGoalInsights,
      );
    }

    final id = widget.seedGoalType ?? widget.persona.id;

    String title;
    String progressStr;
    double progressPct;
    String targetLabel;
    String currentLabel;
    List<Map<String, dynamic>> milestones;

    switch (id) {
      case 'C001':
        title = 'First Home Deposit Tracker';
        progressStr = '48%';
        progressPct = 0.48;
        targetLabel = '£25,000 Deposit Target';
        currentLabel = '£12,000 Saved (Easy Saver)';
        milestones = [
          {'text': 'Verify Customer ID (C001)', 'done': true},
          {'text': 'Establish Stable Income (Acme Corp)', 'done': true},
          {'text': 'Optimize Savings Growth in Cash ISA', 'done': false},
          {'text': 'Apply for Lloyds First Time Buyer Mortgage', 'done': false},
        ];
        break;
      case 'C002':
        title = 'Tax-Free Savings Optimizer';
        progressStr = '27.5%';
        progressPct = 0.275;
        targetLabel = '£20,000 ISA Limit';
        currentLabel = '£5,500 Saved (Cash ISA)';
        milestones = [
          {'text': 'Verify Customer ID (C002)', 'done': true},
          {'text': 'Review Active Cash ISA Balance', 'done': true},
          {'text': 'Maximize Cash ISA Allowances', 'done': false},
          {'text': 'Explore Stocks & Shares ISA Allocation', 'done': false},
        ];
        break;
      case 'C003':
        title = 'Regular Monthly Savings Habit';
        progressStr = '62%';
        progressPct = 0.62;
        targetLabel = '£5,000 Emergency Fund';
        currentLabel = '£3,100 Saved (Classic Account)';
        milestones = [
          {'text': 'Verify Customer ID (C003)', 'done': true},
          {'text': 'Link Lloyds Classic Account (£3.1k)', 'done': true},
          {'text': 'Open Club Lloyds Saver (5.25% AER)', 'done': false},
          {'text': 'Set Up £250/mo Standing Order', 'done': false},
        ];
        break;
      case 'C004':
        title = 'Mortgage Refinancing & Debt Review';
        progressStr = '10%';
        progressPct = 0.10;
        targetLabel = '£185,000 Outstanding Mortgage';
        currentLabel = '£420 Saved (Classic Account)';
        milestones = [
          {'text': 'Verify Customer ID (C004)', 'done': true},
          {'text': 'Review Outstanding Mortgage Balance', 'done': true},
          {'text': 'Apply for Refined Fixed-Rate Mortgage', 'done': false},
          {'text': 'Consolidate Debt with Personal Loan', 'done': false},
        ];
        break;
      default: // C005
        title = 'Savings Growth & Investment Strategy';
        progressStr = '80%';
        progressPct = 0.80;
        targetLabel = '£20,000 Investment Capital';
        currentLabel = '£15,980 Liquid Funds';
        milestones = [
          {'text': 'Verify Customer ID (C005)', 'done': true},
          {'text': 'Review Easy Saver & Classic Account', 'done': true},
          {'text': 'Open Stocks & Shares ISA', 'done': false},
          {'text': 'Build Ready-Made Portfolios Selection', 'done': false},
        ];
    }

    final doneCount = milestones.where((m) => m['done'] == true).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(Icons.flag_rounded, 'FINANCIAL GOAL PIPELINE'),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: brandGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.greenAccent, size: 6),
                  SizedBox(width: 5),
                  Text(
                    'LIVE FROM AGENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: brandGreen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'ACTIVE PLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentLabel,
                          style: const TextStyle(
                            color: Color(0xFF5A5A5A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          progressStr,
                          style: const TextStyle(
                            color: brandGold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF4F6F5),
                        valueColor: const AlwaysStoppedAnimation<Color>(brandGold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        targetLabel,
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                    ),
                    const Divider(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Required Action Milestones',
                          style: TextStyle(
                            color: deepGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: brandGreen.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$doneCount / ${milestones.length} done',
                            style: const TextStyle(
                              color: brandGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...milestones.map((ms) {
                      final done = ms['done'] as bool;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              done
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: done ? brandGreen : Colors.grey[400],
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ms['text'] as String,
                                style: TextStyle(
                                  color: done ? Colors.grey[500] : const Color(0xFF2C2C2C),
                                  fontSize: 13,
                                  decoration: done ? TextDecoration.lineThrough : null,
                                  decorationColor: Colors.grey[400],
                                ),
                              ),
                            ),
                            if (done)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: brandGreen.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('Done',
                                    style: TextStyle(
                                      color: brandGreen,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Persona card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: deepGreen,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(widget.persona.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.persona.name,
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.persona.role}  ·  ${widget.persona.income}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.persona.financialGoal,
                      style: const TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SHARED HELPERS ───────────────────────────────────────────────────────

  Widget _buildLoadingState({required String label}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: brandGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contacting Lloyds Agent...',
              style: TextStyle(
                color: deepGreen,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({required String error, required VoidCallback onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 52, color: Color(0xFFB00020)),
            const SizedBox(height: 16),
            const Text(
              'Could Not Reach Agent',
              style: TextStyle(
                color: deepGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: deepGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: brandGold, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: deepGreen,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return name.isNotEmpty ? name[0] : '';
  }
}
