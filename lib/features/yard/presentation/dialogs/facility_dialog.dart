import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../data/facilities_repository.dart';

/// Shows a dialog to add or edit a facility.
/// Returns the facility data if saved, null if cancelled.
Future<Map<String, dynamic>?> showFacilityDialog({
  required BuildContext context,
  Facility? existing,
}) async {
  final nameController = TextEditingController(text: existing?.name ?? '');
  final descController = TextEditingController(
    text: existing?.description ?? '',
  );
  final slotController = TextEditingController(
    text: existing?.slotDurationMinutes.toString() ?? '30',
  );
  final advanceController = TextEditingController(
    text: existing?.advanceBookingDays.toString() ?? '14',
  );
  final maxBookingsController = TextEditingController(
    text: existing?.maxDailyBookingsPerUser?.toString() ?? '',
  );

  FacilityType selectedType = existing?.type ?? FacilityType.indoorArena;
  bool isActive = existing?.isActive ?? true;

  final isDark = Theme.of(context).brightness == Brightness.dark;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          backgroundColor: isDark ? BrandColors.dialogBgDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: BrandColors.yellow.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fence,
                            color: BrandColors.yellow,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                existing == null
                                    ? 'Add Facility'
                                    : 'Edit Facility',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                              ),
                              Text(
                                'Configure bookable amenity',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: Icon(
                            Icons.close,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Facility type
                    Text(
                      'Facility Type',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FacilityType.values.map((type) {
                        final isSelected = selectedType == type;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? BrandColors.yellow.withValues(alpha: 0.2)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.grey.withValues(alpha: 0.1)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? BrandColors.yellow
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              type.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? (isDark ? Colors.white : Colors.black87)
                                    : (isDark
                                          ? Colors.white54
                                          : Colors.black45),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Facility Name',
                        hintText: 'e.g. Main Indoor Arena',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        hintText: 'Additional details about this facility',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Booking settings
                    Text(
                      'Booking Settings',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: slotController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Slot Duration',
                              suffixText: 'min',
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: advanceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Advance Booking',
                              suffixText: 'days',
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: maxBookingsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Max Daily Bookings Per User (optional)',
                        hintText: 'Leave empty for unlimited',
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active toggle
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.pause_circle,
                            color: isActive ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  isActive
                                      ? 'Users can book this facility'
                                      : 'Hidden from booking',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isActive,
                            onChanged: (v) =>
                                setDialogState(() => isActive = v),
                            activeColor: BrandColors.yellow,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              return;
                            }
                            Navigator.pop(ctx, {
                              'type': selectedType,
                              'name': nameController.text.trim(),
                              'description': descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                              'slotDuration':
                                  int.tryParse(slotController.text) ?? 30,
                              'advanceBookingDays':
                                  int.tryParse(advanceController.text) ?? 14,
                              'maxDailyBookings':
                                  maxBookingsController.text.trim().isEmpty
                                  ? null
                                  : int.tryParse(maxBookingsController.text),
                              'isActive': isActive,
                            });
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: BrandColors.yellow,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            existing == null ? 'Add Facility' : 'Save',
                          ),
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

  nameController.dispose();
  descController.dispose();
  slotController.dispose();
  advanceController.dispose();
  maxBookingsController.dispose();

  return result;
}
