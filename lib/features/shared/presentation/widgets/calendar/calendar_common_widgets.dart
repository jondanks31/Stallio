import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR COMMON WIDGETS - Shared UI components for calendar views
// ─────────────────────────────────────────────────────────────────────────────

/// Toggle between Yard and Personal calendar views
class CalendarViewToggle extends StatelessWidget {
  const CalendarViewToggle({
    super.key,
    required this.isYardView,
    required this.onYardViewSelected,
    required this.onPersonalViewSelected,
  });

  final bool isYardView;
  final VoidCallback onYardViewSelected;
  final VoidCallback onPersonalViewSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleButton(
              label: 'Yard',
              isSelected: isYardView,
              onTap: onYardViewSelected,
              isDark: isDark,
            ),
            _ToggleButton(
              label: 'Personal',
              isSelected: !isYardView,
              onTap: onPersonalViewSelected,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD66B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? Colors.black87
                : (isDark ? Colors.white54 : Colors.black45),
          ),
        ),
      ),
    );
  }
}

/// Header showing selected date with add button
class CalendarDateHeader extends StatelessWidget {
  const CalendarDateHeader({
    super.key,
    required this.selectedDate,
    required this.isYardView,
    required this.onAddPressed,
    this.addButtonEnabled = true,
  });

  final DateTime selectedDate;
  final bool isYardView;
  final VoidCallback onAddPressed;
  final bool addButtonEnabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dateLabel = isToday
        ? 'Today'
        : '${dayNames[selectedDate.weekday - 1]}, ${selectedDate.day} ${months[selectedDate.month - 1]}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              isYardView ? 'Yard events & bookings' : 'Personal events',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: addButtonEnabled ? onAddPressed : null,
          icon: const Icon(Icons.add, size: 18),
          label: Text(isYardView ? 'Book' : 'Add Event'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFD66B),
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }
}

/// Empty state when no events exist for selected date
class CalendarEmptyState extends StatelessWidget {
  const CalendarEmptyState({super.key, required this.isYardView});

  final bool isYardView;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isYardView ? Icons.event_available : Icons.calendar_today,
            size: 48,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            'No events',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isYardView
                ? 'No yard events or bookings for this day'
                : 'No personal events for this day',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Detail row used in booking/event detail dialogs
class CalendarDetailRow extends StatelessWidget {
  const CalendarDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              Text(
                value,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
