import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/ui/branded_dialog.dart';
import '../../../../../core/ui/snackbar_service.dart';
import '../../../../bookings/data/bookings_repository.dart';
import 'calendar_common_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FACILITY BOOKING WIDGETS - Card and dialogs for yard facility bookings
// ─────────────────────────────────────────────────────────────────────────────

/// Card displaying a facility booking
class FacilityBookingCard extends StatelessWidget {
  const FacilityBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  final FacilityBooking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const color = Color(0xFFFFD66B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.facilityName ?? 'Facility',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        booking.timeRange,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      if (booking.userName != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                        Text(
                          booking.userName!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows booking detail dialog with option to cancel own bookings
/// Returns true if booking was cancelled
Future<bool> showBookingDetailDialog({
  required BuildContext context,
  required FacilityBooking booking,
  required BookingsRepository repository,
  required VoidCallback onBookingCancelled,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;
  final isOwnBooking = booking.userId == currentUserId;

  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: isDark
          ? BrandColors.dialogBgDark
          : BrandColors.dialogBgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: BrandColors.yellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      size: 24,
                      color: Color(0xFFE5B800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      booking.facilityName ?? 'Facility Booking',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Details
              CalendarDetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: booking.timeRange,
              ),
              const SizedBox(height: 12),
              CalendarDetailRow(
                icon: Icons.calendar_month,
                label: 'Date',
                value:
                    '${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}',
              ),
              if (booking.userName != null) ...[
                const SizedBox(height: 12),
                CalendarDetailRow(
                  icon: Icons.person_outline,
                  label: 'Booked by',
                  value: booking.userName!,
                ),
              ],
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                CalendarDetailRow(
                  icon: Icons.notes,
                  label: 'Notes',
                  value: booking.notes!,
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const DialogCancelButton(label: 'Close'),
                  if (isOwnBooking) ...[
                    const SizedBox(width: 12),
                    DialogDeleteButton(
                      label: 'Cancel Booking',
                      onPressed: () => Navigator.pop(ctx, 'cancel'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  if (result == 'cancel') {
    if (!context.mounted) return false;
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Cancel Booking',
      message:
          'Are you sure you want to cancel this booking for ${booking.facilityName}? This cannot be undone.',
    );
    if (confirmed) {
      try {
        await repository.cancelBooking(booking.id);
        onBookingCancelled();
        if (!context.mounted) return true;
        SnackbarService.showSuccess(context, 'Booking cancelled');
        return true;
      } catch (e) {
        if (!context.mounted) return false;
        SnackbarService.showError(context, 'Failed to cancel booking');
      }
    }
  }
  return false;
}

/// Shows dialog to create a new facility booking
Future<bool> showCreateBookingDialog({
  required BuildContext context,
  required List<Facility> facilities,
  required DateTime selectedDate,
  required BookingsRepository repository,
  required VoidCallback onBookingCreated,
}) async {
  if (facilities.isEmpty) return false;

  final isDark = Theme.of(context).brightness == Brightness.dark;

  Facility? selectedFacility = facilities.first;
  DateTime? selectedSlot;
  List<DateTime> availableSlots = [];
  bool isLoadingSlots = false;

  final created = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          // Load slots when facility is selected
          Future<void> loadSlots() async {
            if (selectedFacility == null) return;
            setDialogState(() => isLoadingSlots = true);
            try {
              final slots = await repository.getAvailableSlots(
                selectedFacility!.id,
                selectedDate,
                selectedFacility!.slotDurationMinutes,
              );
              setDialogState(() {
                availableSlots = slots;
                isLoadingSlots = false;
                selectedSlot = slots.isNotEmpty ? slots.first : null;
              });
            } catch (e) {
              setDialogState(() => isLoadingSlots = false);
            }
          }

          // Load initial slots
          if (availableSlots.isEmpty &&
              !isLoadingSlots &&
              selectedFacility != null) {
            loadSlots();
          }

          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Book Facility',
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Facility selector
                  Text(
                    'Facility',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Facility>(
                    value: selectedFacility,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white10 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: facilities.map((f) {
                      return DropdownMenuItem(value: f, child: Text(f.name));
                    }).toList(),
                    onChanged: (f) {
                      setDialogState(() {
                        selectedFacility = f;
                        availableSlots = [];
                        selectedSlot = null;
                      });
                      loadSlots();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Time slot selector
                  Text(
                    'Time Slot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingSlots)
                    const Center(child: CircularProgressIndicator())
                  else if (availableSlots.isEmpty)
                    Text(
                      'No available slots for this day',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    )
                  else
                    SizedBox(
                      height: 150,
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2.5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: availableSlots.length,
                        itemBuilder: (context, index) {
                          final slot = availableSlots[index];
                          final isSelected = selectedSlot == slot;
                          final timeStr =
                              '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                          return GestureDetector(
                            onTap: () {
                              setDialogState(() => selectedSlot = slot);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFD66B)
                                    : (isDark
                                          ? Colors.white10
                                          : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(8),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFFFD66B),
                                        width: 2,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                timeStr,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.black87
                                      : (isDark
                                            ? Colors.white70
                                            : Colors.black54),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
              FilledButton(
                onPressed: selectedSlot == null
                    ? null
                    : () async {
                        try {
                          final endTime = selectedSlot!.add(
                            Duration(
                              minutes: selectedFacility!.slotDurationMinutes,
                            ),
                          );
                          await repository.createBooking(
                            facilityId: selectedFacility!.id,
                            startTime: selectedSlot!,
                            endTime: endTime,
                          );
                          if (!context.mounted) return;
                          Navigator.pop(context, true);
                          onBookingCreated();
                          SnackbarService.showSuccess(
                            context,
                            'Booking confirmed',
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          SnackbarService.showError(
                            context,
                            'Failed to create booking',
                          );
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD66B),
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Book'),
              ),
            ],
          );
        },
      );
    },
  );

  return created ?? false;
}
