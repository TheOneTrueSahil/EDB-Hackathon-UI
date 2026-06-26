import 'package:flutter/material.dart';
import '../models/persona.dart';

class PersonaSelector extends StatelessWidget {
  final Persona selectedPersona;
  final ValueChanged<Persona> onPersonaSelected;

  const PersonaSelector({
    super.key,
    required this.selectedPersona,
    required this.onPersonaSelected,
  });

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF006A4E);
    const brandGold = Color(0xFFB59049);
    const backgroundMint = Color(0xFFF0F7F4);

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Text(
              'CHOOSE DEMO CUSTOMER PROFILE (AGENT RETRIEVES THIS DATA)',
              style: TextStyle(
                color: Color(0xFF002C1B),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: Persona.personas.length,
              itemBuilder: (context, index) {
                final persona = Persona.personas[index];
                final isSelected = persona.id == selectedPersona.id;
                
                return GestureDetector(
                  onTap: () => onPersonaSelected(persona),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 190,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? backgroundMint : Colors.grey[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? brandGreen : Colors.grey[300]!,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: brandGreen.withOpacity(0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        // Avatar Initials
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? brandGreen : Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(persona.name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                persona.name,
                                style: TextStyle(
                                  color: const Color(0xFF002C1B),
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                persona.role,
                                style: const TextStyle(
                                  color: brandGold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${persona.savings} Sav | ${persona.income.split(" ")[0]} Inc',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 9,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split('&');
    if (parts.length > 1) {
      // Marcus & Chloe
      return 'M&C';
    }
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : '';
  }
}
