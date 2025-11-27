import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../settings/data/settings_repository.dart';

/// Dialog for adding or editing a consumable.
/// Returns a Map with consumable data if saved, null if cancelled.
Future<Map<String, dynamic>?> showConsumableDialog({
  required BuildContext context,
  ConsumableType? existing,
}) async {
  ConsumablePreset? selectedPreset;
  MeasurementType measureType = MeasurementType.slices;

  // Parse existing data
  if (existing != null) {
    for (final p in ConsumablePreset.values) {
      if (p.displayName == existing.name) {
        selectedPreset = p;
        break;
      }
    }
    // Determine measurement type from existing data
    if (existing.stockUnit.toLowerCase().contains('kg') ||
        existing.stockUnit.toLowerCase().contains('ton')) {
      measureType = MeasurementType.weight;
    }
  }

  final brandController = TextEditingController(text: existing?.brand ?? '');
  final descController = TextEditingController(
    text: existing?.description ?? '',
  );
  final priceController = TextEditingController(
    text: existing?.pricePerUsageUnit.toStringAsFixed(2) ?? '0.00',
  );
  final stockController = TextEditingController(
    text: existing?.currentStock.toString() ?? '0',
  );
  final ratioController = TextEditingController(
    text: existing?.ratio.toString() ?? '8',
  );
  String selectedWeightUnit = existing?.stockUnit ?? 'kg';
  String selectedPricePerUnit = existing?.usageUnit ?? 'kg';
  bool trackInventory = existing?.trackInventory ?? false;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<Map<String, dynamic>?>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final isShavings = selectedPreset == ConsumablePreset.shavings;
        final showMeasurementChoice =
            selectedPreset != null && selectedPreset!.supportsSlices;

        return Dialog(
          backgroundColor: isDark
              ? BrandColors.dialogBgDark
              : BrandColors.dialogBgLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existing == null ? 'Add Consumable' : 'Edit Consumable',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tracked inventory items',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 20),

                    // Type dropdown
                    DropdownButtonFormField<ConsumablePreset>(
                      initialValue: selectedPreset,
                      decoration: brandedDropdownDecoration(
                        context: ctx,
                        label: 'Type',
                      ),
                      hint: const Text('Select type'),
                      items: ConsumablePreset.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() {
                        selectedPreset = v;
                        if (v != null) {
                          measureType = v.defaultMeasurementType;
                        }
                      }),
                    ),

                    // Shavings brand/description
                    if (isShavings) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: brandController,
                        decoration: brandedInputDecoration(
                          context: ctx,
                          label: 'Brand (optional)',
                          hint: 'e.g. Bedmax',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        decoration: brandedInputDecoration(
                          context: ctx,
                          label: 'Description (optional)',
                          hint: 'e.g. Large flakes',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],

                    // Measurement type selection (for hay, haylage, straw)
                    if (showMeasurementChoice) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Measurement',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children:
                            [
                              MeasurementType.slices,
                              MeasurementType.weight,
                            ].map((type) {
                              final isSelected = measureType == type;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: type != MeasurementType.weight
                                        ? 8
                                        : 0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => setDialogState(
                                      () => measureType = type,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? BrandColors.charcoal
                                            : (isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.08,
                                                    )
                                                  : Colors.white),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected
                                              ? BrandColors.charcoal
                                              : Colors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                        ),
                                      ),
                                      child: Text(
                                        type.displayName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark
                                                    ? Colors.white70
                                                    : Colors.black54),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],

                    // Slices configuration
                    if (selectedPreset != null &&
                        measureType == MeasurementType.slices) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: ratioController,
                        decoration: brandedInputDecoration(
                          context: ctx,
                          label: isShavings
                              ? 'Bales per unit'
                              : 'Slices per bale',
                          hint: isShavings ? '1' : 'e.g. 8',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        decoration: brandedInputDecoration(
                          context: ctx,
                          label: isShavings
                              ? 'Price per bale'
                              : 'Price per slice',
                          prefix: '£',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],

                    // Weight configuration
                    if (selectedPreset != null &&
                        measureType == MeasurementType.weight) ...[
                      const SizedBox(height: 16),
                      _buildWeightConfig(
                        ctx: ctx,
                        isDark: isDark,
                        selectedWeightUnit: selectedWeightUnit,
                        selectedPricePerUnit: selectedPricePerUnit,
                        onWeightUnitChanged: (unit) =>
                            setDialogState(() => selectedWeightUnit = unit),
                        onPricePerUnitChanged: (unit) =>
                            setDialogState(() => selectedPricePerUnit = unit),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        decoration: brandedInputDecoration(
                          context: ctx,
                          label: 'Price per $selectedPricePerUnit',
                          prefix: '£',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],

                    // Whole unit configuration (shavings, etc.)
                    if (selectedPreset != null &&
                        measureType == MeasurementType.whole) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        decoration: brandedInputDecoration(
                          context: ctx,
                          label: 'Price per bag',
                          prefix: '£',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    // Inventory tracking section
                    _buildInventorySection(
                      ctx: ctx,
                      isDark: isDark,
                      trackInventory: trackInventory,
                      selectedPreset: selectedPreset,
                      measureType: measureType,
                      selectedWeightUnit: selectedWeightUnit,
                      stockController: stockController,
                      onTrackInventoryChanged: (v) =>
                          setDialogState(() => trackInventory = v),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const DialogCancelButton(),
                        const SizedBox(width: 12),
                        DialogPrimaryButton(
                          label: existing == null ? 'Add' : 'Save',
                          onPressed: selectedPreset == null
                              ? null
                              : () {
                                  String stockUnit, usageUnit;
                                  int ratio;

                                  if (measureType == MeasurementType.weight) {
                                    stockUnit = selectedWeightUnit;
                                    usageUnit = selectedPricePerUnit;
                                    ratio = 1;
                                  } else if (measureType ==
                                      MeasurementType.whole) {
                                    stockUnit = 'Bag';
                                    usageUnit = 'Bag';
                                    ratio = 1;
                                  } else {
                                    stockUnit = 'Bale';
                                    usageUnit = 'Slice';
                                    ratio =
                                        int.tryParse(ratioController.text) ?? 8;
                                  }

                                  Navigator.pop(ctx, {
                                    'preset': selectedPreset,
                                    'brand': brandController.text.trim(),
                                    'desc': descController.text.trim(),
                                    'price':
                                        double.tryParse(priceController.text) ??
                                        0.0,
                                    'stockUnit': stockUnit,
                                    'usageUnit': usageUnit,
                                    'ratio': ratio,
                                    'trackInventory': trackInventory,
                                    'currentStock':
                                        double.tryParse(stockController.text) ??
                                        0.0,
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
        );
      },
    ),
  );
}

Widget _buildWeightConfig({
  required BuildContext ctx,
  required bool isDark,
  required String selectedWeightUnit,
  required String selectedPricePerUnit,
  required ValueChanged<String> onWeightUnitChanged,
  required ValueChanged<String> onPricePerUnitChanged,
}) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock unit',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['kg', 'Ton'].map((unit) {
                  final isSelected = selectedWeightUnit == unit;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onWeightUnitChanged(unit),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BrandColors.charcoal
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unit,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price per',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['1kg', '10kg', '100kg'].map((unit) {
                  final isSelected = selectedPricePerUnit == unit;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onPricePerUnitChanged(unit),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? BrandColors.charcoal
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unit,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildInventorySection({
  required BuildContext ctx,
  required bool isDark,
  required bool trackInventory,
  required ConsumablePreset? selectedPreset,
  required MeasurementType measureType,
  required String selectedWeightUnit,
  required TextEditingController stockController,
  required ValueChanged<bool> onTrackInventoryChanged,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: trackInventory
            ? BrandColors.charcoal
            : Colors.grey.withValues(alpha: 0.2),
        width: trackInventory ? 2 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 20,
              color: trackInventory ? BrandColors.charcoal : Colors.grey,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track Inventory',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    'Monitor stock levels',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: trackInventory,
              onChanged: onTrackInventoryChanged,
              activeTrackColor: BrandColors.charcoal.withValues(alpha: 0.5),
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? BrandColors.charcoal
                    : null,
              ),
            ),
          ],
        ),
        if (trackInventory && selectedPreset != null) ...[
          const SizedBox(height: 14),
          TextField(
            controller: stockController,
            decoration: brandedInputDecoration(
              context: ctx,
              label: measureType == MeasurementType.weight
                  ? 'Current Stock ($selectedWeightUnit)'
                  : measureType == MeasurementType.whole
                  ? 'Current Stock (bags)'
                  : 'Current Stock (bales)',
              hint: measureType == MeasurementType.whole
                  ? 'e.g. 10'
                  : 'e.g. 10 or 10.5',
            ),
            keyboardType: measureType == MeasurementType.whole
                ? TextInputType.number
                : const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ],
    ),
  );
}
