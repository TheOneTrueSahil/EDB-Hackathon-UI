import 'package:flutter/material.dart';
import '../models/persona.dart';

class InsightsScreen extends StatefulWidget {
  final Persona persona;
  final Map<String, double> spendingInsights;
  final String? goalType;

  const InsightsScreen({
    super.key,
    required this.persona,
    required this.spendingInsights,
    this.goalType,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            Tab(
              icon: Icon(Icons.analytics_rounded, size: 18),
              text: 'SPENDING ANALYSIS',
            ),
            Tab(
              icon: Icon(Icons.flag_rounded, size: 18),
              text: 'FINANCIAL GOALS',
            ),
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

  // ─── SPENDING TAB ────────────────────────────────────────────────────────────

  Widget _buildSpendingTab(BuildContext context) {
    if (widget.spendingInsights.isEmpty) {
      return _buildEmptyState(
        icon: Icons.analytics_outlined,
        title: 'No Spending Data Yet',
        subtitle:
            'Ask the assistant about your spending habits or request a breakdown to populate this view.',
      );
    }

    final spending = widget.spendingInsights;
    final double total =
        spending.values.fold(0.0, (sum, val) => sum + val);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        _buildSectionHeader(
            Icons.analytics_rounded, 'SPENDING ANALYSIS & BREAKDOWN'),
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
              // Card header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      'Analyzed Outgoings (Monthly)',
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
                    ...spending.entries.map((entry) {
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
                                  child: Text(
                                    cat,
                                    style: const TextStyle(
                                      color: Color(0xFF2C2C2C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
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
        _buildHabitTipCard(context),
      ],
    );
  }

  Widget _buildHabitTipCard(BuildContext context) {
    final id = widget.persona.id;
    String tipText;
    if (id == 'C001') {
      tipText =
          'Save £50/month on dining out to reach your home deposit milestone 3 months earlier.';
    } else if (id == 'C002') {
      tipText =
          'Move surplus Classic Account cash into your Cash ISA to maximize tax-free yields.';
    } else if (id == 'C003') {
      tipText =
          'Open a Club Lloyds Saver (5.25% AER) and set a £250 monthly transfer to automate savings.';
    } else if (id == 'C004') {
      tipText =
          'Explore refinancing options for your £185k mortgage to lower interest expenses.';
    } else {
      tipText =
          'Move £9k from Easy Saver into a Stocks & Shares ISA to access long-term market growth.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: brandGold.withValues(alpha: 0.35), width: 0.8),
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

  // ─── FINANCIAL GOALS TAB ─────────────────────────────────────────────────────

  Widget _buildGoalTab(BuildContext context) {
    final goalType = widget.goalType ?? widget.persona.id;

    String title;
    String progressStr;
    double progressPct;
    String targetLabel;
    String currentLabel;
    List<Map<String, dynamic>> milestones;

    switch (goalType) {
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
        const SizedBox(height: 12),

        // Progress card
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                    // Progress metrics
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
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(brandGold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        targetLabel,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                        ),
                      ),
                    ),

                    const Divider(height: 28),

                    // Milestones header with progress badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Required Action Milestones',
                          style: TextStyle(
                            color: deepGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
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
                                  color: done
                                      ? Colors.grey[500]
                                      : const Color(0xFF2C2C2C),
                                  fontSize: 13,
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
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
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    color: brandGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
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

        // Persona summary card
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
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

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  Widget _buildEmptyState(
      {required IconData icon,
      required String title,
      required String subtitle}) {
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
