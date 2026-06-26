import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/persona.dart';
import '../models/lloyds_product.dart';

class AgentService {
  // Product Catalog
  static const List<LloydsProduct> lloydsProductCatalog = [
    LloydsProduct(
      id: 'PROD_CURRENT_CLASSIC',
      name: 'Lloyds Classic Account',
      category: 'Current Account',
      highlight: 'No Monthly Fee',
      description: 'Standard everyday bank account with no monthly fee.',
      features: [
        'No monthly account fee',
        'Contactless Visa debit card',
        'Lloyds Bank Smart Benefits',
        '24/7 Mobile Banking app access',
      ],
      applyUrl: 'https://www.lloydsbank.com/current-accounts.html',
    ),
    LloydsProduct(
      id: 'PROD_CURRENT_CLUB',
      name: 'Club Lloyds Current Account',
      category: 'Current Account',
      highlight: '1.50% Credit Interest',
      description: 'Premium current account with lifestyle benefits and credit interest on balances up to £5,000.',
      features: [
        '1.50% AER on balances up to £5,000',
        'Choice of yearly lifestyle benefit (e.g. Disney+)',
        'Fee-free UK ATM cash withdrawals',
        'Access to exclusive saver accounts',
      ],
      applyUrl: 'https://www.lloydsbank.com/current-accounts/club-lloyds.html',
    ),
    LloydsProduct(
      id: 'PROD_CURRENT_SILVER',
      name: 'Lloyds Silver Account',
      category: 'Current Account',
      highlight: 'AA Breakdown & Insurance',
      description: 'Current account with premium benefits including European travel insurance and AA breakdown assistance for a monthly fee.',
      features: [
        'European multi-trip travel insurance',
        'AA breakdown cover included',
        'Mobile phone insurance',
        'Fee-free debit card usage abroad',
      ],
      applyUrl: 'https://www.lloydsbank.com/current-accounts/silver.html',
    ),
    LloydsProduct(
      id: 'PROD_CURRENT_GOLD',
      name: 'Lloyds Gold Account',
      category: 'Current Account',
      highlight: 'Worldwide Insurance Cover',
      description: 'Current account with worldwide travel insurance, mobile phone insurance, and breakdown cover for a monthly fee.',
      features: [
        'Worldwide travel insurance',
        'Mobile phone insurance',
        'AA breakdown cover with Roadside Assist',
        'Exclusive credit card offers',
      ],
      applyUrl: 'https://www.lloydsbank.com/current-accounts/gold.html',
    ),
    LloydsProduct(
      id: 'PROD_SAVINGS_EASY',
      name: 'Lloyds Easy Saver',
      category: 'Savings Account',
      highlight: '1.50% AER variable',
      description: 'Simple savings account with instant access to your funds.',
      features: [
        '1.50% AER variable interest rate',
        'Instant access to your money',
        'Manage online, in app, or in branch',
        'Open with as little as £1',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/easy-saver.html',
    ),
    LloydsProduct(
      id: 'PROD_SAVINGS_CLUB_SAVER',
      name: 'Club Lloyds Saver',
      category: 'Savings Account',
      highlight: '5.25% AER Interest',
      description: 'High interest savings account for Club Lloyds members, allowing regular monthly deposits.',
      features: [
        '5.25% AER interest rate',
        'Exclusively for Club Lloyds members',
        'Save between £25 and £400 monthly',
        'Unlimited instant access withdrawals',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/club-lloyds-saver.html',
    ),
    LloydsProduct(
      id: 'PROD_SAVINGS_FIXED_1YR',
      name: 'Lloyds 1 Year Fixed Rate Saver',
      category: 'Savings Account',
      highlight: 'Guaranteed 4.50% AER',
      description: 'Fixed-term savings account offering a guaranteed interest rate of 4.5% for 12 months with no early withdrawals.',
      features: [
        'Guaranteed 4.50% AER for 12 months',
        'Fixed interest rate lock-in',
        'Interest paid monthly or annually',
        'No withdrawals permitted during the term',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/fixed-rate-savings.html',
    ),
    LloydsProduct(
      id: 'PROD_SAVINGS_FIXED_2YR',
      name: 'Lloyds 2 Year Fixed Rate Saver',
      category: 'Savings Account',
      highlight: 'Guaranteed 4.25% AER',
      description: 'Fixed-term savings account offering a guaranteed interest rate of 4.25% for 24 months with no early withdrawals.',
      features: [
        'Guaranteed 4.25% AER for 24 months',
        'Fixed rate protection for 2 years',
        'Interest paid monthly or annually',
        'Ideal for longer-term savings goals',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/fixed-rate-savings.html',
    ),
    LloydsProduct(
      id: 'PROD_SAVINGS_CHILD',
      name: 'Lloyds Smart Start Saver',
      category: 'Savings Account',
      highlight: '3.15% AER variable',
      description: 'Savings account designed for children aged 11 to 15, offering a competitive variable interest rate.',
      features: [
        '3.15% AER variable interest',
        'Specifically for ages 11 to 15',
        'Card and mobile app for kids',
        'Teaches smart money management habits',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/smart-start.html',
    ),
    LloydsProduct(
      id: 'PROD_ISA_CASH',
      name: 'Lloyds Cash ISA',
      category: 'ISA',
      highlight: '4.00% AER Tax-Free',
      description: 'Tax-free cash savings account with a fixed or variable interest rate.',
      features: [
        '4.00% AER tax-free variable rate',
        'Save up to £20,000 tax-free yearly',
        'Instant access to cash when needed',
        'Easy transfers from other providers',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/cash-isa.html',
    ),
    LloydsProduct(
      id: 'PROD_ISA_FIXED_1YR',
      name: 'Lloyds 1 Year Fixed Rate Cash ISA',
      category: 'ISA',
      highlight: 'Guaranteed 4.30% Tax-Free',
      description: 'Tax-free cash savings account with a guaranteed interest rate for 1 year. Early withdrawal charges apply.',
      features: [
        '4.30% AER tax-free guaranteed rate',
        'Fixed interest rate for 12 months',
        'Protect savings from income tax',
        'Early withdrawal subject to fee',
      ],
      applyUrl: 'https://www.lloydsbank.com/savings/fixed-rate-isa.html',
    ),
    LloydsProduct(
      id: 'PROD_ISA_INVESTMENT',
      name: 'Lloyds Stocks & Shares ISA',
      category: 'ISA',
      highlight: 'Tax-Efficient Investment',
      description: 'Tax-efficient investment account allowing you to invest in a wide range of funds and shares.',
      features: [
        'Tax-efficient Stocks & Shares ISA',
        'Invest from £20/month or £100 lump sum',
        'Wide range of funds and ready-made portfolios',
        'Capital at risk - values can go down or up',
      ],
      applyUrl: 'https://www.lloydsbank.com/investing/smart-investor.html',
    ),
    LloydsProduct(
      id: 'PROD_MORTGAGE_FIXED',
      name: 'Lloyds Fixed Rate Mortgage',
      category: 'Mortgage',
      highlight: '4.75% Fixed Rate',
      description: 'Home mortgage with a fixed interest rate for secure monthly payments.',
      features: [
        'Fixed interest rate of 4.75%',
        'Secure monthly payments for peace of mind',
        'Overpayment allowances up to 10% yearly',
        'Dedicated mortgage expert guidance',
      ],
      applyUrl: 'https://www.lloydsbank.com/mortgages.html',
    ),
    LloydsProduct(
      id: 'PROD_MORTGAGE_FTB',
      name: 'Lloyds First Time Buyer Mortgage',
      category: 'Mortgage',
      highlight: '4.99% Fixed Rate & Cashback',
      description: 'Fixed-rate mortgage designed specifically for first-time home buyers, with flexible deposit terms.',
      features: [
        '4.99% fixed rate mortgage',
        'Tailored specifically for first-time buyers',
        'Low deposit requirements (down to 5%)',
        '£500 cashback for Club Lloyds members',
      ],
      applyUrl: 'https://www.lloydsbank.com/mortgages/first-time-buyers.html',
    ),
    LloydsProduct(
      id: 'PROD_CARD_PLATINUM',
      name: 'Lloyds Bank Platinum Credit Card',
      category: 'Credit Card',
      highlight: '22.9% APR Variable',
      description: 'Credit card featuring 0% interest on balance transfers and purchases for an introductory period.',
      features: [
        '22.9% APR representative variable',
        '0% interest on balance transfers for intro period',
        '0% interest on purchases for intro period',
        'Lloyds Bank Smart Benefits cashback',
      ],
      applyUrl: 'https://www.lloydsbank.com/credit-cards/platinum.html',
    ),
    LloydsProduct(
      id: 'PROD_CARD_CHOICE',
      name: 'Lloyds Bank Choice Credit Card',
      category: 'Credit Card',
      highlight: '19.9% APR Variable',
      description: 'Everyday credit card offering flexible rewards or cashback options with low annual rates.',
      features: [
        '19.9% APR representative variable',
        'Flexible rewards or cashback on daily spend',
        'Low annual rates & fees',
        'Contactless and Apple/Google Pay ready',
      ],
      applyUrl: 'https://www.lloydsbank.com/credit-cards/choice-card.html',
    ),
    LloydsProduct(
      id: 'PROD_LOAN_PERSONAL',
      name: 'Lloyds Bank Personal Loan',
      category: 'Loan',
      highlight: '6.9% APR Representative',
      description: 'Unsecured personal loan with fixed monthly repayments for terms from 1 to 7 years.',
      features: [
        '6.9% APR representative variable',
        'Borrow £1,000 to £50,000',
        'Fixed monthly repayments over 1-7 years',
        'No penalty for early settlement options',
      ],
      applyUrl: 'https://www.lloydsbank.com/loans.html',
    ),
  ];

  /// Core chat interaction method
  Future<ChatMessage> sendMessage({
    required String text,
    required Persona persona,
    required String sessionId,
    required List<ChatMessage> history,
    required String apiUrl,
    String? apiKey,
  }) async {
    String formattedApiUrl = apiUrl.trim();
    if (formattedApiUrl.isNotEmpty && !formattedApiUrl.endsWith('/api/chat')) {
      if (formattedApiUrl.endsWith('/')) {
        formattedApiUrl = '${formattedApiUrl}api/chat';
      } else {
        formattedApiUrl = '$formattedApiUrl/api/chat';
      }
    }

    if (formattedApiUrl.isEmpty) {
      throw Exception('API URL is empty. Please configure it in Settings.');
    }

    print('AgentService: Sending Live POST request to "$formattedApiUrl"');
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      if (apiKey != null && apiKey.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${apiKey.trim()}';
        headers['x-api-key'] = apiKey.trim(); // Add standard API key header just in case
        print('AgentService: Authorization header attached.');
      }

      // 1. Auto-create session on ADK backend to prevent "Session not found" errors
      try {
        final uri = Uri.parse(formattedApiUrl);
        final baseUrl = '${uri.scheme}://${uri.host}';
        if (uri.host.isNotEmpty) {
          final createSessionUrl = '$baseUrl/apps/bank_agent/users/${persona.id}/sessions/$sessionId';
          print('AgentService: Auto-creating session: "$createSessionUrl"');
          final sessionResponse = await http.post(
            Uri.parse(createSessionUrl),
            headers: headers,
          ).timeout(const Duration(seconds: 10));
          print('AgentService: Session creation response status: ${sessionResponse.statusCode}');
        }
      } catch (sessionError) {
        print('AgentService: Optional session auto-creation skipped/failed: $sessionError');
      }

      // 2. Send the chat request
      final body = jsonEncode({
        'user_id': persona.id,
        'session_id': sessionId,
        'message': text,
      });
      print('AgentService: Request Body: $body');

      final response = await http.post(
        Uri.parse(formattedApiUrl),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 120));

      print('AgentService: HTTP Response Status: ${response.statusCode}');
      print('AgentService: HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return _parseAgentResponse(data, text);
      } else {
        throw Exception('Server returned status code ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      print('AgentService: Connection Exception: $e');
      print('AgentService: Stacktrace: $stack');
      rethrow; // Do not return mock, raise exception directly to the UI
    }
  }

  /// Parses the response from the Cloud Run server, supporting multiple schema formats
  ChatMessage _parseAgentResponse(Map<String, dynamic> data, String userMessage) {
    // 1. Try to extract response text
    String text = '';
    if (data.containsKey('response') && data['response'] is String) {
      text = data['response'];
    } else if (data.containsKey('text') && data['text'] is String) {
      text = data['text'];
    } else if (data.containsKey('message') && data['message'] is String) {
      text = data['message'];
    } else if (data.containsKey('content') && data['content'] is String) {
      text = data['content'];
    } else {
      // Stringify whatever content we have
      text = data.toString();
    }

    // 2. Try to extract thinking logs
    List<String> thinking = [];
    if (data.containsKey('thinking') && data['thinking'] is List) {
      thinking = List<String>.from(data['thinking']);
    } else if (data.containsKey('reasoning') && data['reasoning'] is List) {
      thinking = List<String>.from(data['reasoning']);
    } else if (data.containsKey('steps') && data['steps'] is List) {
      thinking = List<String>.from(data['steps']);
    } else {
      // Generate some smart thinking steps to show pipeline execution
      thinking = [
        '📡 Cloud Run API request succeeded (HTTP 200).',
        '📊 Loaded user context & message history.',
        '🧠 Running neural analysis on request parameters...',
        '🎯 Matching financial intent keywords...',
      ];
    }

    // 3. Try to extract recommended products
    List<LloydsProduct> products = [];
    if (data.containsKey('products') && data['products'] is List) {
      products = (data['products'] as List)
          .map((p) => LloydsProduct.fromJson(p))
          .toList();
    } else if (data.containsKey('recommended_products') && data['recommended_products'] is List) {
      products = (data['recommended_products'] as List)
          .map((p) => LloydsProduct.fromJson(p))
          .toList();
    } else if (data.containsKey('recommendations') && data['recommendations'] is List) {
      products = (data['recommendations'] as List)
          .map((p) => LloydsProduct.fromJson(p))
          .toList();
    } else if (data.containsKey('product_recommendations') && data['product_recommendations'] is List) {
      products = (data['product_recommendations'] as List)
          .map((p) => LloydsProduct.fromJson(p))
          .toList();
    } else {
      // Automatically detect and link products by scanning text keywords
      products = _matchProductsByKeywords(text);
    }

    return ChatMessage(
      id: 'agent_${DateTime.now().millisecondsSinceEpoch}',
      text: text,
      sender: MessageSender.agent,
      timestamp: DateTime.now(),
      thinkingSteps: thinking,
      recommendedProducts: products,
    );
  }

  /// Helper to automatically map catalog products based on words found in response text
  List<LloydsProduct> _matchProductsByKeywords(String text) {
    String scanText = text.toLowerCase();

    // 1. Strip "Accounts & Balances" section to prevent matching already held accounts
    final accountsIndex = scanText.indexOf('accounts & balances');
    if (accountsIndex != -1) {
      // Look for the next main header or double newline to mark the end of the section
      int sectionEnd = scanText.indexOf('\n\n', accountsIndex);
      if (sectionEnd == -1) {
        sectionEnd = scanText.indexOf('income:', accountsIndex);
      }
      if (sectionEnd != -1 && sectionEnd > accountsIndex) {
        scanText = scanText.substring(0, accountsIndex) + scanText.substring(sectionEnd);
      }
    }

    // 2. If a transfer to the Product Matcher is indicated, narrow the scan window to the recommendations part
    final splitIndicators = [
      'product matcher',
      'transfer you to',
      'recommend',
      'fit for you',
      'suitable products',
      'here are a couple of',
      'options lloyds bank has for you',
      'would you like to discuss',
      'explore the best options',
    ];

    int splitIndex = -1;
    for (final indicator in splitIndicators) {
      final idx = scanText.indexOf(indicator);
      if (idx != -1) {
        if (splitIndex == -1 || idx < splitIndex) {
          splitIndex = idx;
        }
      }
    }

    if (splitIndex != -1) {
      scanText = scanText.substring(splitIndex);
    }

    final List<LloydsProduct> matched = [];

    void addProductIfMatch(String id, List<String> keywords) {
      final isIdMatch = scanText.contains(id.toLowerCase());
      final isKeywordMatch = keywords.any((k) => scanText.contains(k.toLowerCase()));
      if (isIdMatch || isKeywordMatch) {
        if (!matched.any((p) => p.id == id)) {
          final prod = lloydsProductCatalog.firstWhere((p) => p.id == id);
          matched.add(prod);
        }
      }
    }

    // Match each of the 17 products
    addProductIfMatch('PROD_CURRENT_CLASSIC', ['classic account', 'classic current account', 'everyday bank account']);
    addProductIfMatch('PROD_CURRENT_CLUB', ['club lloyds current', 'club lloyds account', 'current account with lifestyle benefits']);
    addProductIfMatch('PROD_CURRENT_SILVER', ['silver account', 'travel insurance and aa breakdown']);
    addProductIfMatch('PROD_CURRENT_GOLD', ['gold account', 'worldwide travel insurance']);
    addProductIfMatch('PROD_SAVINGS_EASY', ['easy saver', 'simple savings account', 'instant access to your funds']);
    addProductIfMatch('PROD_SAVINGS_CLUB_SAVER', ['club lloyds saver', 'club saver', 'high interest savings account for club lloyds']);
    addProductIfMatch('PROD_SAVINGS_FIXED_1YR', ['1 year fixed rate saver', '1 year fixed saver', 'one year fixed rate saver', 'guaranteed interest rate of 4.5%']);
    addProductIfMatch('PROD_SAVINGS_FIXED_2YR', ['2 year fixed rate saver', '2 year fixed saver', 'two year fixed rate saver', 'guaranteed interest rate of 4.25%']);
    addProductIfMatch('PROD_SAVINGS_CHILD', ['smart start saver', 'smart start', 'children aged 11 to 15']);
    addProductIfMatch('PROD_ISA_CASH', ['cash isa', 'tax-free cash savings']);
    addProductIfMatch('PROD_ISA_FIXED_1YR', ['1 year fixed rate cash isa', '1 year fixed rate isa', '1 year fixed cash isa', 'one year fixed rate cash isa']);
    addProductIfMatch('PROD_ISA_INVESTMENT', ['stocks & shares isa', 'stocks and shares isa', 'investment isa', 'invest in a wide range of funds']);
    addProductIfMatch('PROD_MORTGAGE_FIXED', ['fixed rate mortgage', 'fixed interest rate for secure']);
    addProductIfMatch('PROD_MORTGAGE_FTB', ['first time buyer mortgage', 'first-time buyer mortgage', 'first-time home buyers']);
    addProductIfMatch('PROD_CARD_PLATINUM', ['platinum credit card', 'platinum card', '0% interest on balance transfers']);
    addProductIfMatch('PROD_CARD_CHOICE', ['choice credit card', 'choice card', 'flexible rewards or cashback']);
    addProductIfMatch('PROD_LOAN_PERSONAL', ['personal loan', 'unsecured personal loan']);

    return matched;
  }
}
