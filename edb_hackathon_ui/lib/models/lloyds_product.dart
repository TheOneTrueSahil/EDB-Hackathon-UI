class LloydsProduct {
  final String id;
  final String name;
  final String category;
  final String highlight;
  final String description;
  final List<String> features;
  final String applyUrl;

  const LloydsProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.highlight,
    required this.description,
    required this.features,
    this.applyUrl = 'https://www.lloydsbank.com',
  });

  factory LloydsProduct.fromJson(Map<String, dynamic> json) {
    final rawId = json['product_id'] ?? json['id'] ?? '';
    final rawName = json['product_name'] ?? json['name'] ?? '';
    final rawCategory = json['product_type'] ?? json['category'] ?? '';
    final rawDescription = json['description'] ?? '';
    
    // Format a nice highlight based on interest rate or existing highlight
    String rawHighlight = '';
    if (json['interest_rate'] != null) {
      final rate = json['interest_rate'];
      if (rate is num && rate > 0) {
        rawHighlight = '$rate% Interest Rate';
      } else if (rawCategory.toLowerCase().contains('mortgage')) {
        rawHighlight = rate is num ? '$rate% Fixed Rate' : 'Competitive Rates';
      } else if (rawCategory.toLowerCase().contains('loan')) {
        rawHighlight = rate is num ? '$rate% APR Representative' : 'Flexible Terms';
      } else if (rawCategory.toLowerCase().contains('card')) {
        rawHighlight = rate is num ? '$rate% APR Representative' : 'Cashback Rewards';
      } else {
        rawHighlight = 'No Monthly Fee';
      }
    } else {
      rawHighlight = json['highlight'] ?? '';
    }

    // Features can be parsed or we can generate them from description/defaults
    List<String> rawFeatures = [];
    if (json.containsKey('features') && json['features'] is List) {
      rawFeatures = List<String>.from(json['features']);
    } else {
      rawFeatures = _generateDefaultFeatures(rawId, rawCategory, rawDescription);
    }

    final rawApplyUrl = json['apply_url'] ?? json['applyUrl'] ?? 'https://www.lloydsbank.com';

    return LloydsProduct(
      id: rawId,
      name: rawName,
      category: rawCategory,
      highlight: rawHighlight,
      description: rawDescription,
      features: rawFeatures,
      applyUrl: rawApplyUrl,
    );
  }

  static List<String> _generateDefaultFeatures(String id, String category, String description) {
    if (id == 'PROD_CURRENT_CLASSIC') {
      return ['No monthly account fee', 'Contactless Visa debit card', 'Lloyds Bank Smart Benefits', '24/7 Mobile Banking app access'];
    }
    if (id == 'PROD_CURRENT_CLUB') {
      return ['1.50% AER on balances up to £5,000', 'Choice of yearly lifestyle benefit (e.g. Disney+)', 'Fee-free UK ATM cash withdrawals', 'Access to exclusive saver accounts'];
    }
    if (id == 'PROD_CURRENT_SILVER') {
      return ['European multi-trip travel insurance', 'AA breakdown cover included', 'Mobile phone insurance', 'Fee-free debit card usage abroad'];
    }
    if (id == 'PROD_CURRENT_GOLD') {
      return ['Worldwide travel insurance', 'Mobile phone insurance', 'AA breakdown cover with Roadside Assist', 'Exclusive credit card offers'];
    }
    if (id == 'PROD_SAVINGS_EASY') {
      return ['1.50% AER variable interest rate', 'Instant access to your money', 'Manage online, in app, or in branch', 'Open with as little as £1'];
    }
    if (id == 'PROD_SAVINGS_CLUB_SAVER') {
      return ['5.25% AER interest rate', 'Exclusively for Club Lloyds members', 'Save between £25 and £400 monthly', 'Unlimited instant access withdrawals'];
    }
    if (id == 'PROD_SAVINGS_FIXED_1YR') {
      return ['Guaranteed 4.50% AER for 12 months', 'Fixed interest rate lock-in', 'Interest paid monthly or annually', 'No withdrawals permitted during the term'];
    }
    if (id == 'PROD_SAVINGS_FIXED_2YR') {
      return ['Guaranteed 4.25% AER for 24 months', 'Fixed rate protection for 2 years', 'Interest paid monthly or annually', 'Ideal for longer-term savings goals'];
    }
    if (id == 'PROD_SAVINGS_CHILD') {
      return ['3.15% AER variable interest', 'Specifically for ages 11 to 15', 'Card and mobile app for kids', 'Teaches smart money management habits'];
    }
    if (id == 'PROD_ISA_CASH') {
      return ['4.00% AER tax-free variable rate', 'Save up to £20,000 tax-free yearly', 'Instant access to cash when needed', 'Easy transfers from other providers'];
    }
    if (id == 'PROD_ISA_FIXED_1YR') {
      return ['4.30% AER tax-free guaranteed rate', 'Fixed interest rate for 12 months', 'Protect savings from income tax', 'Early withdrawal subject to fee'];
    }
    if (id == 'PROD_ISA_INVESTMENT') {
      return ['Tax-efficient Stocks & Shares ISA', 'Invest from £20/month or £100 lump sum', 'Wide range of funds and ready-made portfolios', 'Capital at risk - values can go down or up'];
    }
    if (id == 'PROD_MORTGAGE_FIXED') {
      return ['Fixed interest rate of 4.75%', 'Secure monthly payments for peace of mind', 'Overpayment allowances up to 10% yearly', 'Dedicated mortgage expert guidance'];
    }
    if (id == 'PROD_MORTGAGE_FTB') {
      return ['4.99% fixed rate mortgage', 'Tailored specifically for first-time buyers', 'Low deposit requirements (down to 5%)', '£500 cashback for Club Lloyds members'];
    }
    if (id == 'PROD_CARD_PLATINUM') {
      return ['22.9% APR representative variable', '0% interest on balance transfers for intro period', '0% interest on purchases for intro period', 'Lloyds Bank Smart Benefits cashback'];
    }
    if (id == 'PROD_CARD_CHOICE') {
      return ['19.9% APR representative variable', 'Flexible rewards or cashback on daily spend', 'Low annual rates & fees', 'Contactless and Apple/Google Pay ready'];
    }
    if (id == 'PROD_LOAN_PERSONAL') {
      return ['6.9% APR representative variable', 'Borrow £1,000 to £50,000', 'Fixed monthly repayments over 1-7 years', 'No penalty for early settlement options'];
    }
    return ['No monthly fee options', 'Manage easily in our secure app', 'Lloyds Bank support and protection', 'Quick online application'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'highlight': highlight,
      'description': description,
      'features': features,
      'apply_url': applyUrl,
    };
  }
}
