import 'package:flutter/material.dart';

import '../../../../core/ui/week_calendar.dart';

/// Shared calendar page for all user roles.
/// Shows yard events and personal events with toggle between views.
/// Default view is week-based with option to switch to month view.
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  bool _isYardView = true;
  bool _isMonthView = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _displayMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 1100 : double.infinity,
            ),
            child: Column(
              children: [
                // View toggle (Yard / Personal)
                _buildViewToggle(isDark),
                const SizedBox(height: 20),

                // Calendar widget
                if (_isMonthView)
                  MonthCalendar(
                    selectedDate: _selectedDate,
                    displayMonth: _displayMonth,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _displayMonth = date;
                      });
                    },
                    onMonthChanged: (month) {
                      setState(() => _displayMonth = month);
                    },
                    onWeekViewToggle: () {
                      setState(() => _isMonthView = false);
                    },
                  )
                else
                  WeekCalendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                    },
                    onMonthViewToggle: () {
                      setState(() {
                        _isMonthView = true;
                        _displayMonth = _selectedDate;
                      });
                    },
                  ),
                const SizedBox(height: 20),

                // Selected date header
                _buildSelectedDateHeader(isDark),
                const SizedBox(height: 12),

                // Events list for selected date
                Expanded(child: _buildEventsList(isDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewToggle(bool isDark) {
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
            _buildToggleButton('Yard', _isYardView, () {
              setState(() => _isYardView = true);
            }, isDark),
            _buildToggleButton('Personal', !_isYardView, () {
              setState(() => _isYardView = false);
            }, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(
    String label,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
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

  Widget _buildSelectedDateHeader(bool isDark) {
    final today = DateTime.now();
    final isToday =
        _selectedDate.year == today.year &&
        _selectedDate.month == today.month &&
        _selectedDate.day == today.day;

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
        : '${dayNames[_selectedDate.weekday - 1]}, ${_selectedDate.day} ${months[_selectedDate.month - 1]}';

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
              _isYardView ? 'Yard events & bookings' : 'Personal events',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: () {
            // TODO: Add event / booking
          },
          icon: const Icon(Icons.add, size: 18),
          label: Text(_isYardView ? 'Book' : 'Add Event'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFD66B),
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildEventsList(bool isDark) {
    // Placeholder - will be populated with real events
    final events = <_EventItem>[];

    if (events.isEmpty) {
      return _buildEmptyEventsState(isDark);
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event, isDark);
      },
    );
  }

  Widget _buildEventCard(_EventItem event, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.time,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
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
    );
  }

  Widget _buildEmptyEventsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isYardView ? Icons.event_available : Icons.calendar_today,
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
            _isYardView
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

/// Event item model for display
class _EventItem {
  final String title;
  final String time;
  final Color color;

  const _EventItem({
    required this.title,
    required this.time,
    required this.color,
  });
}
