class Persona {
  final String id;
  final String name;
  final String dob;
  final String postcode;
  final String address;
  final int age;
  final String gender;
  final String phone;
  final String role;
  final String income;
  final String savings;
  final String financialGoal;
  final String retrievedDataSummary;
  final String initialMessage;

  const Persona({
    required this.id,
    required this.name,
    required this.dob,
    required this.postcode,
    required this.address,
    required this.age,
    required this.gender,
    required this.phone,
    required this.role,
    required this.income,
    required this.savings,
    required this.financialGoal,
    required this.retrievedDataSummary,
    required this.initialMessage,
  });

  static List<Persona> get personas => const [
        Persona(
          id: 'C001',
          name: 'Alice Thornton',
          dob: '1985-03-12',
          postcode: 'SW1A 1AA',
          address: '10 Downing Street, London',
          age: 39,
          gender: 'F',
          phone: '07700900001',
          role: 'Savings Accumulator',
          income: '£38,400 / yr',
          savings: '£14,450.75',
          financialGoal: 'Explore mortgage options and optimize savings growth.',
          retrievedDataSummary: 'Customer ID: C001. Address: 10 Downing Street, London, SW1A 1AA. Active Classic Account (£2,450.75) and Easy Saver (£12,000.00). Receives stable monthly salary of £3,200.00 from Acme Corp.',
          initialMessage: 'Hi, I am Alice Thornton. Please verify my customer ID C001 and recommend mortgage products or savings optimizations based on my profile.',
        ),
        Persona(
          id: 'C002',
          name: 'Bob Hargreaves',
          dob: '1972-07-24',
          postcode: 'EC1A 1BB',
          address: '1 Barbican, London',
          age: 52,
          gender: 'M',
          phone: '07700900002',
          role: 'Tax-Efficient Investor',
          income: '£55,000 / yr',
          savings: '£6,350.20',
          financialGoal: 'Optimize cash savings for tax efficiency and inflation defense.',
          retrievedDataSummary: 'Customer ID: C002. Address: 1 Barbican, London, EC1A 1BB. Holds Classic Account (£850.20) and Cash ISA (£5,500.00). Interest in Cash ISAs & Stocks & Shares.',
          initialMessage: 'Hello, Bob here. I would like to log in as C002, review my Cash ISA, and find more tax-efficient savings options with Lloyds.',
        ),
        Persona(
          id: 'C003',
          name: 'Clara Nguyen',
          dob: '1990-11-05',
          postcode: 'M1 1AE',
          address: '1 Piccadilly, Manchester',
          age: 34,
          gender: 'F',
          phone: '07700900003',
          role: 'Regular Savings Builder',
          income: '£45,000 / yr',
          savings: '£3,100.50',
          financialGoal: 'Establish emergency reserves and high-yield regular savings.',
          retrievedDataSummary: 'Customer ID: C003. Address: 1 Piccadilly, Manchester, M1 1AE. Holds Classic Account with £3,100.50. High savings capacity. Focus on automated savings.',
          initialMessage: 'Hi, I am Clara Nguyen. Please verify me as C003. I want to build a regular savings habit. What high-yield accounts can you recommend?',
        ),
        Persona(
          id: 'C004',
          name: 'David Okonkwo',
          dob: '1968-01-30',
          postcode: 'B1 1BB',
          address: '1 Corporation Street, Birmingham',
          age: 56,
          gender: 'M',
          phone: '07700900004',
          role: 'Active Mortgage Holder',
          income: '£60,000 / yr',
          savings: '£420.10',
          financialGoal: 'Manage mortgage refinancing, check lower interest rates, and loan consolidation.',
          retrievedDataSummary: 'Customer ID: C004. Address: 1 Corporation Street, Birmingham, B1 1BB. Holds Classic Account (£420.10) and Fixed Rate Mortgage (-£185,000.00). High interest load.',
          initialMessage: 'Hello, I am David Okonkwo. Please load my profile for C004. I want to review refinancing options for my outstanding £185k mortgage.',
        ),
        Persona(
          id: 'C005',
          name: 'Evelyn Marchetti',
          dob: '1995-06-18',
          postcode: 'EH1 1YZ',
          address: '1 Royal Mile, Edinburgh',
          age: 29,
          gender: 'F',
          phone: '07700900005',
          role: 'Young Wealth Builder',
          income: '£35,000 / yr',
          savings: '£15,980.00',
          financialGoal: 'Grow liquid capital, open cash ISAs, and explore stock market investing.',
          retrievedDataSummary: 'Customer ID: C005. Address: 1 Royal Mile, Edinburgh, EH1 1YZ. Active Classic Account (£6,780.00) and Easy Saver (£9,200.00). Strong cash accumulation.',
          initialMessage: 'Hi, this is Evelyn Marchetti. Please verify C005. I have around £16k in cash and want to explore growing it or investing via Stocks & Shares ISAs.',
        ),
      ];
}
