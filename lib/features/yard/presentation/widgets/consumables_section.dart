import 'package:flutter/material.dart';

import '../../../settings/data/settings_repository.dart';
import 'consumable_card.dart';
import 'section_header.dart';

/// Section displaying consumables in a responsive grid.
class ConsumablesSection extends StatelessWidget {
  const ConsumablesSection({
    super.key,
    required this.consumables,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ConsumableType> consumables;
  final VoidCallback onAdd;
  final void Function(ConsumableType) onEdit;
  final void Function(ConsumableType) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Consumables',
          subtitle: '${consumables.length} items configured',
          onAdd: onAdd,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: consumables.isEmpty
              ? const EmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No consumables yet',
                  subtitle: 'Add hay, bedding, and other tracked inventory',
                )
              : ResponsiveCardGrid(
                  itemCount: consumables.length,
                  itemBuilder: (context, index) {
                    final item = consumables[index];
                    return ConsumableCard(
                      item: item,
                      onEdit: () => onEdit(item),
                      onDelete: () => onDelete(item),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
