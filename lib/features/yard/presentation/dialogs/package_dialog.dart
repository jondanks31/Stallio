import 'package:flutter/material.dart';

import '../../../settings/data/settings_repository.dart';

/// Dialog for adding or editing a livery package.
/// Returns true if saved, false if cancelled.
Future<bool> showPackageDialog({
  required BuildContext context,
  required List<ConsumableType> consumables,
  LiveryPackage? existing,
  required TextEditingController nameController,
  required TextEditingController priceController,
  required Set<String> selectedItems,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text(existing == null ? 'Add Package' : 'Edit Package'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  hintText: 'e.g. Full Livery, DIY',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Base Price (per month)',
                  prefixText: '£',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Included Extras',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (consumables.isEmpty)
                Text(
                  'No consumables configured yet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                )
              else
                ...consumables.map(
                  (c) => CheckboxListTile(
                    title: Text(c.name),
                    subtitle: Text(
                      '£${c.pricePerUsageUnit.toStringAsFixed(2)}/${c.usageUnit}',
                    ),
                    value: selectedItems.contains(c.id),
                    onChanged: (checked) {
                      setDialogState(() {
                        if (checked == true) {
                          selectedItems.add(c.id);
                        } else {
                          selectedItems.remove(c.id);
                        }
                      });
                    },
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

/// Dialog for confirming package deletion.
Future<bool> showDeletePackageDialog({
  required BuildContext context,
  required LiveryPackage package,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Package'),
      content: Text('Delete "${package.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
