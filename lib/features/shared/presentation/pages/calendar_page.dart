import 'package:flutter/material.dart';

import '../../../../core/ui/week_calendar.dart';
import '../../../bookings/data/bookings_repository.dart';
import '../../../horses/data/horse_model.dart';
import '../../../horses/data/horses_repository.dart';
import '../widgets/calendar/calendar_common_widgets.dart';
import '../widgets/calendar/facility_booking_widgets.dart';
import '../widgets/calendar/personal_event_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CALENDAR PAGE - Shared calendar for all user roles
// ─────────────────────────────────────────────────────────────────────────────

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

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadData();
  }

  void _onAddPressed() {
    if (_isYardView) {
      _showBookingDialog();
    } else {
      _showPersonalEventDialog();
    }
  }

  Future<void> _showBookingDialog() async {
    await showCreateBookingDialog(
      context: context,
      facilities: _facilities,
      selectedDate: _selectedDate,
      repository: _repository,
      onBookingCreated: _loadData,
    );
  }

  Future<void> _showPersonalEventDialog() async {
    await showCreatePersonalEventDialog(
      context: context,
      selectedDate: _selectedDate,
      horses: _myHorses,
      repository: _repository,
      onEventCreated: _loadData,
    );
  }

  Future<void> _onBookingTap(FacilityBooking booking) async {
    await showBookingDetailDialog(
      context: context,
      booking: booking,
      repository: _repository,
      onBookingCancelled: _loadData,
    );
  }

  Future<void> _onEventTap(PersonalEvent event) async {
    await showEventDetailDialog(
      context: context,
      event: event,
      selectedDate: _selectedDate,
      horses: _myHorses,
      repository: _repository,
      onEventUpdated: _loadData,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                CalendarViewToggle(
                  isYardView: _isYardView,
                  onYardViewSelected: () {
                    setState(() => _isYardView = true);
                    _loadData();
                  },
                  onPersonalViewSelected: () {
                    setState(() => _isYardView = false);
                    _loadData();
                  },
                ),
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
                    onDateSelected: _onDateSelected,
                    onMonthViewToggle: () {
                      setState(() {
                        _isMonthView = true;
                        _displayMonth = _selectedDate;
                      });
                    },
                  ),
                const SizedBox(height: 20),

                // Selected date header
                CalendarDateHeader(
                  selectedDate: _selectedDate,
                  isYardView: _isYardView,
                  onAddPressed: _onAddPressed,
                  addButtonEnabled: _isYardView ? _facilities.isNotEmpty : true,
                ),
                const SizedBox(height: 12),

                // Events list for selected date
                Expanded(child: _buildEventsList()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isYardView) {
      if (_bookings.isEmpty) {
        return CalendarEmptyState(isYardView: _isYardView);
      }
      return ListView.separated(
        itemCount: _bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return FacilityBookingCard(
            booking: booking,
            onTap: () => _onBookingTap(booking),
          );
        },
      );
    } else {
      if (_personalEvents.isEmpty) {
        return CalendarEmptyState(isYardView: _isYardView);
      }
      return ListView.separated(
        itemCount: _personalEvents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final event = _personalEvents[index];
          return PersonalEventCard(
            event: event,
            onTap: () => _onEventTap(event),
          );
        },
      );
    }
  }
}
