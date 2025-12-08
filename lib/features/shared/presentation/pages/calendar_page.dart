import 'package:flutter/material.dart';

import '../../../../core/ui/week_calendar.dart';
import '../../../bookings/data/bookings_repository.dart';

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
  final _repository = BookingsRepository();

  bool _isYardView = true;
  bool _isMonthView = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _displayMonth = DateTime.now();

  List<FacilityBooking> _bookings = [];
  List<Facility> _facilities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
    _loadBookings();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _repository.getFacilities(widget.yardId);
      if (mounted) setState(() => _facilities = facilities);
    } catch (e) {
      debugPrint('Error loading facilities: $e');
    }
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = _isYardView
          ? await _repository.getYardBookingsForDate(
              widget.yardId,
              _selectedDate,
            )
          : await _repository.getMyBookings();
      if (mounted) {
        setState(() {
          _bookings = _isYardView
              ? bookings
              : bookings
                    .where((b) => _isSameDay(b.startTime, _selectedDate))
                    .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

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
                      _loadBookings();
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
                      _loadBookings();
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
          onPressed: _facilities.isEmpty ? null : _showBookingDialog,
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookings.isEmpty) {
      return _buildEmptyEventsState(isDark);
    }

    return ListView.separated(
      itemCount: _bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return _buildBookingCard(booking, isDark);
      },
    );
  }

  Widget _buildBookingCard(FacilityBooking booking, bool isDark) {
    // Different colors for different facility types
    final color = const Color(0xFFFFD66B);

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
    );
  }

  Future<void> _showBookingDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Facility? selectedFacility = _facilities.isNotEmpty
        ? _facilities.first
        : null;
    DateTime? selectedSlot;
    List<DateTime> availableSlots = [];
    bool isLoadingSlots = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Load slots when facility is selected
            Future<void> loadSlots() async {
              if (selectedFacility == null) return;
              setDialogState(() => isLoadingSlots = true);
              try {
                final slots = await _repository.getAvailableSlots(
                  selectedFacility!.id,
                  _selectedDate,
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
                      items: _facilities.map((f) {
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
                  onPressed: () => Navigator.pop(context),
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
                            await _repository.createBooking(
                              facilityId: selectedFacility!.id,
                              startTime: selectedSlot!,
                              endTime: endTime,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              _loadBookings();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Booking created!'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
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
