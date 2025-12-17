import 'package:flutter/material.dart';

import '../../../../horses/data/horse_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE SELECTOR - Dropdown pill for selecting horses
// ─────────────────────────────────────────────────────────────────────────────

/// Horse selector pill with dropdown and add button
class HorseSelector extends StatelessWidget {
  const HorseSelector({
    super.key,
    required this.horses,
    required this.selectedIndex,
    required this.onHorseSelected,
    required this.onAddHorse,
  });

  final List<Horse> horses;
  final int selectedIndex;
  final ValueChanged<int> onHorseSelected;
  final VoidCallback onAddHorse;

  Horse? get _selectedHorse =>
      horses.isNotEmpty && selectedIndex < horses.length
      ? horses[selectedIndex]
      : null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Horse selector dropdown
            PopupMenuButton<int>(
              onSelected: onHorseSelected,
              offset: const Offset(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              itemBuilder: (context) => [
                for (int i = 0; i < horses.length; i++)
                  PopupMenuItem<int>(
                    value: i,
                    child: Row(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 18,
                          color: i == selectedIndex
                              ? const Color(0xFFFFD66B)
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          horses[i].name,
                          style: TextStyle(
                            fontWeight: i == selectedIndex
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedHorse?.name ?? 'Select horse',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Add horse button
            GestureDetector(
              onTap: onAddHorse,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when user has no horses
class HorseSelectorEmptyState extends StatelessWidget {
  const HorseSelectorEmptyState({super.key, required this.onAddHorse});

  final VoidCallback onAddHorse;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 64, color: Color(0xFFFFD66B)),
            ),
            const SizedBox(height: 24),
            Text(
              'No horses yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first horse to get started',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAddHorse,
              icon: const Icon(Icons.add),
              label: const Text('Add Horse'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
