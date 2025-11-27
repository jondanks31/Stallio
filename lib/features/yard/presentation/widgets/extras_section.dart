import 'package:flutter/material.dart';

import '../../../settings/data/settings_repository.dart';
import 'extra_card.dart';
import 'section_header.dart';

/// Section displaying extras in a responsive grid.
class ExtrasSection extends StatelessWidget {
  const ExtrasSection({
    super.key,
    required this.extras,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Extra> extras;
  final VoidCallback onAdd;
  final void Function(Extra) onEdit;
  final void Function(Extra) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Extras',
          subtitle: '${extras.length} services configured',
          onAdd: onAdd,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: extras.isEmpty
              ? const EmptyState(
                  icon: Icons.add_circle_outline,
                  title: 'No extras yet',
                  subtitle: 'Add services like Arena, Rug Change, Feed, etc.',
                )
              : ResponsiveCardGrid(
                  itemCount: extras.length,
                  itemBuilder: (context, index) {
                    final extra = extras[index];
                    return ExtraCard(
                      extra: extra,
                      onEdit: () => onEdit(extra),
                      onDelete: () => onDelete(extra),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
