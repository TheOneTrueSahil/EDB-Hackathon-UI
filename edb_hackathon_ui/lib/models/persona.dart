class Persona {
  final String id;
  final String name;
  final String role;
  final int age;
  final String income;
  final String savings;
  final String financialGoal;
  final String retrievedDataSummary;
  final String initialMessage;

  const Persona({
    required this.id,
    required this.name,
    required this.role,
    required this.age,
    required this.income,
    required this.savings,
    required this.financialGoal,
    required this.retrievedDataSummary,
    required this.initialMessage,
  });

  static List<Persona> get personas => const [
        Persona(
          id: 'sarah',
          name: 'Sarah Jenkins',
          role: 'First-Time Buyer',
          age: 26,
          income: '£32,000 / yr',
          savings: '£6,200',
          financialGoal: 'Wants to purchase a first flat in 2 years.',
          retrievedDataSummary: 'Active Lloyds current account for 5 years. Monthly savings rate is ~£400. No current mortgage or active loan. High likelihood of qualifying for First-Time Buyer programs.',
          initialMessage: 'Hi, I want to start saving for a deposit on a flat. What Lloyds products can help me achieve this, and how much can I borrow?',
        ),
        Persona(
          id: 'david',
          name: 'David Ross',
          role: 'Affluent Retiree',
          age: 67,
          income: '£48,000 pension / yr',
          savings: '£185,000',
          financialGoal: 'Wants stable income, tax-free interest, and wealth preservation.',
          retrievedDataSummary: 'Lloyds Private Banking client. Holds £120,000 in legacy current/savings accounts earning low interest. Interest in Cash ISAs, fixed term bonds, and wealth management services.',
          initialMessage: 'I have some retirement funds sitting in my current account earning very low interest. Can you recommend where to place them for tax efficiency?',
        ),
        Persona(
          id: 'marcus_chloe',
          name: 'Marcus & Chloe',
          role: 'Young Family',
          age: 34,
          income: '£85,000 joint / yr',
          savings: '£22,000',
          financialGoal: 'Home renovation and saving for children\'s university funds.',
          retrievedDataSummary: 'Joint Lloyds Club Account. Outstanding balance on existing Lloyds mortgage: £195k. Holds credit card with Lloyds (balance cleared monthly). Active interest in home improvement loans and Junior ISAs.',
          initialMessage: 'We are planning a loft conversion and want to save some money for our two kids\' future. What are the best options with Lloyds?',
        ),
        Persona(
          id: 'emily',
          name: 'Emily Chen',
          role: 'International Student',
          age: 20,
          income: '£900 / mo allowance',
          savings: '£1,500',
          financialGoal: 'Budgeting, low-cost international transfers, and building credit score.',
          retrievedDataSummary: 'New Lloyds Student Current Account. High frequency of small contactless transactions. Frequent inbound international transfers. Enjoys student perks like free cinema tickets or subscription discounts.',
          initialMessage: 'I am a student and want to start building a credit score in the UK. I also want to save for my summer travels. Any tips?',
        ),
      ];
}
