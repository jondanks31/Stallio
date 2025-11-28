import 'package:flutter/material.dart';

/// A week-based calendar widget with day selection.
/// Shows Mon-Sun for the current week with navigation.
class WeekCalendar extends StatefulWidget {
  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.onMonthViewToggle,
    this.showMonthViewToggle = true,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback? onMonthViewToggle;
  final bool showMonthViewToggle;

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _getWeekStart(widget.selectedDate);
  }

  @override
  void didUpdateWidget(WeekCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _weekStart = _getWeekStart(widget.selectedDate);
    }
  }

  /// Get Monday of the week containing the given date
  DateTime _getWeekStart(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(date.year, date.month, date.day - daysFromMonday);
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
    widget.onDateSelected(_weekStart);
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
    widget.onDateSelected(_weekStart);
  }

  void _goToToday() {
    final today = DateTime.now();
    setState(() {
      _weekStart = _getWeekStart(today);
    });
    widget.onDateSelected(today);
  }

  String _getMonthYearLabel() {
    final weekEnd = _weekStart.add(const Duration(days: 6));
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

    if (_weekStart.month == weekEnd.month) {
      return '${months[_weekStart.month - 1]} ${_weekStart.year}';
    } else if (_weekStart.year == weekEnd.year) {
      return '${months[_weekStart.month - 1]} - ${months[weekEnd.month - 1]} ${_weekStart.year}';
    } else {
      return '${months[_weekStart.month - 1]} ${_weekStart.year} - ${months[weekEnd.month - 1]} ${weekEnd.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Header with month/year and navigation
          Row(
            children: [
              // Previous week
              IconButton(
                onPressed: _previousWeek,
                icon: Icon(
                  Icons.chevron_left,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      _getMonthYearLabel(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: _goToToday,
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFFFFD66B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Next week
              IconButton(
                onPressed: _nextWeek,
                icon: Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Week days row
          Row(
            children: List.generate(7, (index) {
              final date = _weekStart.add(Duration(days: index));
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSelected =
                  date.year == widget.selectedDate.year &&
                  date.month == widget.selectedDate.month &&
                  date.day == widget.selectedDate.day;
              final dayNames = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun',
              ];

              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onDateSelected(date),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFD66B)
                          : (isToday
                                ? const Color(0xFFFFD66B).withValues(alpha: 0.2)
                                : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(
                              color: const Color(0xFFFFD66B),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayNames[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.black87
                                : (isDark ? Colors.white54 : Colors.black45),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isSelected || isToday
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.black87
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          // Month view toggle
          if (widget.showMonthViewToggle &&
              widget.onMonthViewToggle != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: widget.onMonthViewToggle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'View full month',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Full month calendar view
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.selectedDate,
    required this.displayMonth,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.onWeekViewToggle,
  });

  final DateTime selectedDate;
  final DateTime displayMonth;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback? onWeekViewToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = DateTime.now();
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
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Calculate days in month
    final firstOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastOfMonth.day;
    final startWeekday = firstOfMonth.weekday; // 1 = Monday

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(displayMonth.year, displayMonth.month - 1),
                ),
                icon: Icon(
                  Icons.chevron_left,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  '${months[displayMonth.month - 1]} ${displayMonth.year}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onMonthChanged(
                  DateTime(displayMonth.year, displayMonth.month + 1),
                ),
                icon: Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day headers
          Row(
            children: dayNames.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final dayOffset =
                      weekIndex * 7 + dayIndex - (startWeekday - 1);
                  final dayNum = dayOffset + 1;
                  final isValidDay = dayNum >= 1 && dayNum <= daysInMonth;

                  if (!isValidDay) {
                    return const Expanded(child: SizedBox(height: 36));
                  }

                  final date = DateTime(
                    displayMonth.year,
                    displayMonth.month,
                    dayNum,
                  );
                  final isToday =
                      date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;
                  final isSelected =
                      date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onDateSelected(date),
                      child: Container(
                        height: 36,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD66B)
                              : (isToday
                                    ? const Color(
                                        0xFFFFD66B,
                                      ).withValues(alpha: 0.2)
                                    : Colors.transparent),
                          shape: BoxShape.circle,
                          border: isToday && !isSelected
                              ? Border.all(
                                  color: const Color(0xFFFFD66B),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.black87
                                  : (isDark ? Colors.white70 : Colors.black54),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          // Week view toggle
          if (onWeekViewToggle != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onWeekViewToggle,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.view_week,
                    size: 16,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'View week',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
