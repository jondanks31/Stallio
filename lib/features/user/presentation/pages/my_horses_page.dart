import 'package:flutter/material.dart';

import '../../../horses/data/horse_model.dart';
import '../../../horses/data/horses_repository.dart';
import '../../../horses/presentation/dialogs/horse_dialog.dart';
import '../../data/billing_repository.dart';
import '../widgets/horses/horse_avatar_card.dart';
import '../widgets/horses/horse_care_feed.dart';
import '../widgets/horses/horse_notes_tab.dart';
import '../widgets/horses/horse_selector.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MY HORSES PAGE - Horse management for yard members
// ─────────────────────────────────────────────────────────────────────────────

/// My Horses page for regular yard members.
/// Shows horse selector, avatar, care feed, and tabs for care instructions.
class MyHorsesPage extends StatefulWidget {
  const MyHorsesPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<MyHorsesPage> createState() => _MyHorsesPageState();
}

class _MyHorsesPageState extends State<MyHorsesPage>
    with SingleTickerProviderStateMixin {
  final _repository = HorsesRepository();
  final _billingRepository = BillingRepository();
  late TabController _tabController;

  List<Horse> _horses = [];
  int _selectedHorseIndex = 0;
  bool _isLoading = true;

  // Horse activity
  List<ConsumableCharge> _horseActivity = [];
  bool _activityLoading = false;

  static const _tabs = [
    'Care Feed',
    'Care Instructions',
    'Feed Instructions',
    'Notes',
    'Contacts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadHorses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHorses() async {
    setState(() => _isLoading = true);
    try {
      final horses = await _repository.getMyHorses();
      if (mounted) {
        setState(() {
          _horses = horses;
          _isLoading = false;
          // Reset selection if out of bounds
          if (_selectedHorseIndex >= _horses.length) {
            _selectedHorseIndex = _horses.isEmpty ? 0 : _horses.length - 1;
          }
        });
        // Load activity for selected horse
        _loadHorseActivity();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHorseActivity() async {
    final horse = _selectedHorse;
    if (horse == null) return;

    setState(() => _activityLoading = true);
    try {
      final activity = await _billingRepository.getHorseActivity(horse.id);
      if (mounted) {
        setState(() {
          _horseActivity = activity;
          _activityLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _activityLoading = false);
      }
    }
  }

  Future<void> _addHorse() async {
    final result = await showHorseDialog(context);
    if (result != null) {
      await _loadHorses();
      // Select the newly added horse
      final index = _horses.indexWhere((h) => h.id == result.id);
      if (index >= 0) {
        setState(() => _selectedHorseIndex = index);
      }
    }
  }

  Future<void> _editHorse(Horse horse) async {
    final result = await showHorseDialog(context, horse: horse);
    if (result != null) {
      await _loadHorses();
    }
  }

  Horse? get _selectedHorse =>
      _horses.isNotEmpty && _selectedHorseIndex < _horses.length
      ? _horses[_selectedHorseIndex]
      : null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state - no horses yet
    if (_horses.isEmpty) {
      return HorseSelectorEmptyState(onAddHorse: _addHorse);
    }

    return Column(
      children: [
        // Horse selector pill
        HorseSelector(
          horses: _horses,
          selectedIndex: _selectedHorseIndex,
          onHorseSelected: (index) {
            setState(() => _selectedHorseIndex = index);
            _loadHorseActivity();
          },
          onAddHorse: _addHorse,
        ),
        const SizedBox(height: 24),

        // Horse avatar
        HorseAvatarCard(
          horse: _selectedHorse,
          onTap: _selectedHorse != null
              ? () => _editHorse(_selectedHorse!)
              : null,
          onPhotoUpdated: _loadHorses,
        ),
        const SizedBox(height: 24),

        // Tab bar
        _buildTabBar(isDark),
        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Care Feed
              HorseCareFeed(
                activities: _horseActivity,
                isLoading: _activityLoading,
              ),
              // Care Instructions
              HorseNotesTab(
                horse: _selectedHorse,
                noteType: HorseNoteType.care,
                onUpdated: _loadHorses,
              ),
              // Feed Instructions
              HorseNotesTab(
                horse: _selectedHorse,
                noteType: HorseNoteType.feed,
                onUpdated: _loadHorses,
              ),
              // Notes
              HorseNotesTab(
                horse: _selectedHorse,
                noteType: HorseNoteType.behaviour,
                onUpdated: _loadHorses,
              ),
              // Contacts
              HorseNotesTab(
                horse: _selectedHorse,
                noteType: HorseNoteType.contacts,
                onUpdated: _loadHorses,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, 0.03, 0.92, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black45,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 13,
          ),
          indicator: BoxDecoration(
            color: const Color(0xFFFFD66B),
            borderRadius: BorderRadius.circular(999),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
    );
  }
}
