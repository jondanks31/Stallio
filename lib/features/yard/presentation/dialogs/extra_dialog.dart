import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../settings/data/settings_repository.dart';

/// Dialog for adding or editing an extra service.
/// Returns a Map with extra data if saved, null if cancelled.
Future<Map<String, dynamic>?> showExtraDialog({
  required BuildContext context,
  Extra? existing,
}) async {
  ExtraPreset? selectedPreset;
  String? customName;
  if (existing != null) {
    for (final p in ExtraPreset.values) {
      if (p.displayName == existing.name) {
        selectedPreset = p;
        break;
      }
    }
    if (selectedPreset == null) customName = existing.name;
  }

  final customNameController = TextEditingController(text: customName ?? '');
  final unitController = TextEditingController(
    text: existing?.unit ?? 'per session',
  );
  final priceController = TextEditingController(
    text: existing?.price.toStringAsFixed(2) ?? '0.00',
  );
  bool isRecurring = existing?.isRecurring ?? true;
  bool useCustom = customName != null;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => Dialog(
        backgroundColor: isDark
            ? BrandColors.dialogBgDark
            : BrandColors.dialogBgLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  existing == null ? 'Add Extra' : 'Edit Extra',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Additional chargeable services',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 20),
                // Toggle preset/custom
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => useCustom = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !useCustom
                                ? BrandColors.charcoal
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !useCustom
                                  ? BrandColors.charcoal
                                  : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'Preset',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: !useCustom ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(() => useCustom = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: useCustom
                                ? BrandColors.charcoal
                                : (isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: useCustom
                                  ? BrandColors.charcoal
                                  : Colors.grey.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'Custom',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: useCustom ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!useCustom)
                  DropdownButtonFormField<ExtraPreset>(
                    initialValue: selectedPreset,
                    decoration: brandedDropdownDecoration(
                      context: ctx,
                      label: 'Service',
                    ),
                    hint: const Text('Select service'),
                    items: ExtraPreset.values
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.displayName),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setDialogState(() {
                      selectedPreset = v;
                      if (v != null) unitController.text = v.defaultUnit;
                    }),
                  )
                else
                  TextField(
                    controller: customNameController,
                    decoration: brandedInputDecoration(
                      context: ctx,
                      label: 'Service Name',
                      hint: 'e.g. Clipping',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: unitController,
                  decoration: brandedInputDecoration(
                    context: ctx,
                    label: 'Unit',
                    hint: 'e.g. per session',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: brandedInputDecoration(
                    context: ctx,
                    label: 'Price',
                    prefix: '£',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecurring
                          ? BrandColors.charcoal
                          : Colors.grey.withValues(alpha: 0.2),
                      width: isRecurring ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Can be recurring',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Add to monthly invoices',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: isRecurring,
                        onChanged: (v) => setDialogState(() => isRecurring = v),
                        activeTrackColor: BrandColors.charcoal.withValues(
                          alpha: 0.5,
                        ),
                        thumbColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? BrandColors.charcoal
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const DialogCancelButton(),
                    const SizedBox(width: 12),
                    DialogPrimaryButton(
                      label: existing == null ? 'Add' : 'Save',
                      onPressed: () {
                        final name = useCustom
                            ? customNameController.text.trim()
                            : selectedPreset?.displayName;
                        if (name == null || name.isEmpty) {
                          SnackbarService.showError(
                            ctx,
                            'Please select or enter a service',
                          );
                          return;
                        }
                        Navigator.pop(ctx, {
                          'name': name,
                          'unit': unitController.text.trim(),
                          'price': double.tryParse(priceController.text) ?? 0.0,
                          'isRecurring': isRecurring,
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
