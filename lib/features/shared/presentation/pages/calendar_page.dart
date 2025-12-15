import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../../core/ui/week_calendar.dart';
import '../../../bookings/data/bookings_repository.dart';
import '../../../horses/data/horse_model.dart';
import '../../../horses/data/horses_repository.dart';

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
  final _horsesRepository = HorsesRepository();

  bool _isYardView = true;
  bool _isMonthView = false;
  DateTime _selectedDate = DateTime.now();
  DateTime _displayMonth = DateTime.now();

  List<FacilityBooking> _bookings = [];
  List<PersonalEvent> _personalEvents = [];
  List<Facility> _facilities = [];
  List<Horse> _myHorses = [];
  Set<DateTime> _markedDates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
    _loadMyHorses();
    _loadData();
  }

  Future<void> _loadMyHorses() async {
    try {
      final horses = await _horsesRepository.getMyHorses();
      if (mounted) setState(() => _myHorses = horses);
    } catch (e) {
      debugPrint('Error loading horses: $e');
    }
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _repository.getFacilities(widget.yardId);
      if (mounted) setState(() => _facilities = facilities);
    } catch (e) {
      debugPrint('Error loading facilities: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_isYardView) {
        final bookings = await _repository.getYardBookingsForDate(
          widget.yardId,
          _selectedDate,
        );
        if (mounted) {
          setState(() {
            _bookings = bookings;
            _isLoading = false;
          });
        }
      } else {
        final events = await _repository.getPersonalEventsForDate(
          _selectedDate,
        );
        if (mounted) {
          setState(() {
            _personalEvents = events;
            _isLoading = false;
          });
        }
      }
      // Load marked dates for calendar indicators
      await _loadMarkedDates();
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMarkedDates() async {
    try {
      final Set<DateTime> dates = {};
      if (_isYardView) {
        // Get all bookings for the user to mark dates
        final bookings = await _repository.getMyBookings(
          includePast: false,
          limit: 100,
        );
        for (final booking in bookings) {
          dates.add(
            DateTime(
              booking.startTime.year,
              booking.startTime.month,
              booking.startTime.day,
            ),
          );
        }
      } else {
        // Get all personal events to mark dates
        final events = await _repository.getMyPersonalEvents(
          includePast: false,
          limit: 100,
        );
        for (final event in events) {
          dates.add(
            DateTime(
              event.eventDate.year,
              event.eventDate.month,
              event.eventDate.day,
            ),
          );
        }
      }
      if (mounted) {
        setState(() => _markedDates = dates);
      }
    } catch (e) {
      debugPrint('Error loading marked dates: $e');
    }
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
                    markedDates: _markedDates,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _displayMonth = date;
                      });
                      _loadData();
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
                    markedDates: _markedDates,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                      _loadData();
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
              _loadData();
            }, isDark),
            _buildToggleButton('Personal', !_isYardView, () {
              setState(() => _isYardView = false);
              _loadData();
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
          onPressed: _isYardView
              ? (_facilities.isEmpty ? null : _showBookingDialog)
              : _showPersonalEventDialog,
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

    if (_isYardView) {
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
    } else {
      if (_personalEvents.isEmpty) {
        return _buildEmptyEventsState(isDark);
      }
      return ListView.separated(
        itemCount: _personalEvents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final event = _personalEvents[index];
          return _buildPersonalEventCard(event, isDark);
        },
      );
    }
  }

  Widget _buildBookingCard(FacilityBooking booking, bool isDark) {
    // Different colors for different facility types
    final color = const Color(0xFFFFD66B);

    return GestureDetector(
      onTap: () => _showBookingDetailDialog(booking),
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

  Future<void> _showBookingDetailDialog(FacilityBooking booking) async {
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
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: booking.timeRange,
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.calendar_month,
                  label: 'Date',
                  value:
                      '${booking.startTime.day}/${booking.startTime.month}/${booking.startTime.year}',
                  isDark: isDark,
                ),
                if (booking.userName != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.person_outline,
                    label: 'Booked by',
                    value: booking.userName!,
                    isDark: isDark,
                  ),
                ],
                if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.notes,
                    label: 'Notes',
                    value: booking.notes!,
                    isDark: isDark,
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
      final confirmed = await showDeleteConfirmDialog(
        context: context,
        title: 'Cancel Booking',
        message:
            'Are you sure you want to cancel this booking for ${booking.facilityName}? This cannot be undone.',
      );
      if (confirmed) {
        try {
          await _repository.cancelBooking(booking.id);
          _loadData();
          if (mounted) {
            SnackbarService.showSuccess(context, 'Booking cancelled');
          }
        } catch (e) {
          if (mounted) {
            SnackbarService.showError(context, 'Failed to cancel booking');
          }
        }
      }
    }
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
                              _loadData();
                              SnackbarService.showSuccess(
                                context,
                                'Booking confirmed',
                              );
                            }
                          } catch (e) {
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
  }

  Widget _buildEmptyEventsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildPersonalEventCard(PersonalEvent event, bool isDark) {
    return GestureDetector(
      onTap: () => _showEventDetailDialog(event),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                event.eventType.icon,
                size: 20,
                color: const Color(0xFFE5B800),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.displayTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        event.timeString,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      if (event.horseName != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                        ),
                        Text(
                          event.horseName!,
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

  Future<void> _showEventDetailDialog(PersonalEvent event) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: BrandColors.yellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        event.eventType.icon,
                        size: 24,
                        color: const Color(0xFFE5B800),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.displayTitle,
                            style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.eventType.displayName,
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black45,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Event details
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: event.timeString,
                  isDark: isDark,
                ),
                if (event.horseName != null) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.pets,
                    label: 'Horse',
                    value: event.horseName!,
                    isDark: isDark,
                  ),
                ],
                if (event.notes != null && event.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.notes,
                    label: 'Notes',
                    value: event.notes!,
                    isDark: isDark,
                  ),
                ],
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(ctx, 'delete'),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(ctx, 'edit'),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: BrandColors.yellow,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

    if (result == 'delete') {
      final confirmed = await showDeleteConfirmDialog(
        context: context,
        title: 'Delete Event',
        message:
            'Are you sure you want to delete "${event.displayTitle}"? This cannot be undone.',
      );
      if (confirmed) {
        try {
          await _repository.deletePersonalEvent(event.id);
          _loadData();
          if (mounted) SnackbarService.showSuccess(context, 'Event deleted');
        } catch (e) {
          if (mounted)
            SnackbarService.showError(context, 'Failed to delete event');
        }
      }
    } else if (result == 'edit') {
      _showEditEventDialog(event);
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
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

  Future<void> _showEditEventDialog(PersonalEvent event) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    PersonalEventType selectedType = event.eventType;
    Horse? selectedHorse = _myHorses
        .where((h) => h.id == event.horseId)
        .firstOrNull;
    TimeOfDay? selectedTime = event.eventTime;
    final titleController = TextEditingController(text: event.title ?? '');
    final notesController = TextEditingController(text: event.notes ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark
                  ? BrandColors.dialogBgDark
                  : BrandColors.dialogBgLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Event',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // Event type selector
                        Text(
                          'Event Type',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PersonalEventType.values.map((type) {
                            final isSelected = selectedType == type;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedType = type);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? BrandColors.yellow
                                      : (isDark
                                            ? Colors.white10
                                            : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type.icon,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.black87
                                          : (isDark
                                                ? Colors.white54
                                                : Colors.black45),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      type.displayName,
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
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Time selector
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setDialogState(() => selectedTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedTime != null
                                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Select time (optional)',
                                  style: TextStyle(
                                    color: selectedTime != null
                                        ? (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                        : (isDark
                                              ? Colors.white38
                                              : Colors.black38),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Horse selector
                        if (_myHorses.isNotEmpty) ...[
                          Text(
                            'Horse (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Horse?>(
                            value: selectedHorse,
                            decoration: brandedDropdownDecoration(
                              context: context,
                              label: '',
                            ),
                            hint: Text(
                              'No horse selected',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            items: [
                              DropdownMenuItem<Horse?>(
                                value: null,
                                child: Text(
                                  'No horse selected',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              ..._myHorses.map(
                                (h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(h.name),
                                ),
                              ),
                            ],
                            onChanged: (h) {
                              setDialogState(() => selectedHorse = h);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Custom title
                        TextField(
                          controller: titleController,
                          decoration: brandedInputDecoration(
                            context: context,
                            label: 'Custom Title (optional)',
                            hint: 'e.g., Front shoes only',
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        TextField(
                          controller: notesController,
                          maxLines: 2,
                          decoration: brandedInputDecoration(
                            context: context,
                            label: 'Notes (optional)',
                            hint: 'Any additional notes...',
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const DialogCancelButton(),
                            const SizedBox(width: 12),
                            DialogPrimaryButton(
                              label: 'Save',
                              onPressed: () async {
                                // Capture values before async gap
                                final title = titleController.text.isNotEmpty
                                    ? titleController.text
                                    : null;
                                final notes = notesController.text.isNotEmpty
                                    ? notesController.text
                                    : null;
                                Navigator.pop(context);
                                try {
                                  await _repository.updatePersonalEvent(
                                    eventId: event.id,
                                    eventType: selectedType,
                                    eventTime: selectedTime,
                                    horseId: selectedHorse?.id,
                                    title: title,
                                    notes: notes,
                                  );
                                  if (mounted) {
                                    _loadData();
                                    SnackbarService.showSuccess(
                                      context,
                                      'Event updated',
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    SnackbarService.showError(
                                      context,
                                      'Failed to update event',
                                    );
                                  }
                                }
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
        );
      },
    );

    titleController.dispose();
    notesController.dispose();
  }

  Future<void> _showPersonalEventDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    PersonalEventType selectedType = PersonalEventType.farrier;
    Horse? selectedHorse;
    TimeOfDay? selectedTime;
    final titleController = TextEditingController();
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: isDark
                  ? BrandColors.dialogBgDark
                  : BrandColors.dialogBgLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Personal Event',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 20),
                        // Event type selector
                        Text(
                          'Event Type',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PersonalEventType.values.map((type) {
                            final isSelected = selectedType == type;
                            return GestureDetector(
                              onTap: () {
                                setDialogState(() => selectedType = type);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFFD66B)
                                      : (isDark
                                            ? Colors.white10
                                            : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type.icon,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.black87
                                          : (isDark
                                                ? Colors.white54
                                                : Colors.black45),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      type.displayName,
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
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Time selector
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? TimeOfDay.now(),
                            );
                            if (time != null) {
                              setDialogState(() => selectedTime = time);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  selectedTime != null
                                      ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Select time (optional)',
                                  style: TextStyle(
                                    color: selectedTime != null
                                        ? (isDark
                                              ? Colors.white
                                              : Colors.black87)
                                        : (isDark
                                              ? Colors.white38
                                              : Colors.black38),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Horse selector (optional)
                        if (_myHorses.isNotEmpty) ...[
                          Text(
                            'Horse (optional)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<Horse?>(
                            value: selectedHorse,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white10
                                  : Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            hint: Text(
                              'No horse selected',
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            ),
                            items: [
                              DropdownMenuItem<Horse?>(
                                value: null,
                                child: Text(
                                  'No horse selected',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                              ..._myHorses.map(
                                (h) => DropdownMenuItem(
                                  value: h,
                                  child: Text(h.name),
                                ),
                              ),
                            ],
                            onChanged: (h) {
                              setDialogState(() => selectedHorse = h);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Custom title (optional)
                        Text(
                          'Custom Title (optional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Front shoes only',
                            filled: true,
                            fillColor: isDark
                                ? Colors.white10
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes (optional)
                        Text(
                          'Notes (optional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Any additional notes...',
                            filled: true,
                            fillColor: isDark
                                ? Colors.white10
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const DialogCancelButton(),
                            const SizedBox(width: 12),
                            DialogPrimaryButton(
                              label: 'Add Event',
                              onPressed: () async {
                                // Capture values before async gap
                                final title = titleController.text.isNotEmpty
                                    ? titleController.text
                                    : null;
                                final notes = notesController.text.isNotEmpty
                                    ? notesController.text
                                    : null;
                                Navigator.pop(context);
                                try {
                                  await _repository.createPersonalEvent(
                                    eventType: selectedType,
                                    eventDate: _selectedDate,
                                    eventTime: selectedTime,
                                    horseId: selectedHorse?.id,
                                    title: title,
                                    notes: notes,
                                  );
                                  if (mounted) {
                                    _loadData();
                                    SnackbarService.showSuccess(
                                      context,
                                      'Event added',
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    SnackbarService.showError(
                                      context,
                                      'Failed to add event',
                                    );
                                  }
                                }
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
        );
      },
    );

    titleController.dispose();
    notesController.dispose();
  }
}
