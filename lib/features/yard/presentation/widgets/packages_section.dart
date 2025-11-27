import 'package:flutter/material.dart';

import '../../../settings/data/settings_repository.dart';
import 'package_card.dart';
import 'section_header.dart';

/// Section displaying livery packages in a list.
class PackagesSection extends StatelessWidget {
  const PackagesSection({
    super.key,
    required this.packages,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<LiveryPackage> packages;
  final VoidCallback onAdd;
  final void Function(LiveryPackage) onEdit;
  final void Function(LiveryPackage) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Livery Packages',
          subtitle: '${packages.length} packages configured',
          onAdd: onAdd,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: packages.isEmpty
              ? const EmptyState(
                  icon: Icons.card_giftcard_outlined,
                  title: 'No packages yet',
                  subtitle:
                      'Create livery packages like Full Livery, DIY, etc.',
                )
              : ListView.separated(
                  itemCount: packages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final pkg = packages[index];
                    return PackageCard(
                      package: pkg,
                      onEdit: () => onEdit(pkg),
                      onDelete: () => onDelete(pkg),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
