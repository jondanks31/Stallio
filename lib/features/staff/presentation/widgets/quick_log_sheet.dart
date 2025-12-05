import 'package:flutter/material.dart';

import '../../../../core/ui/snackbar_service.dart';
import '../../data/consumable_logs_repository.dart';
import '../../data/staff_repository.dart';

/// Quick log bottom sheet for fast consumable logging.
/// Step 1: Select consumable type
/// Step 2: Select horses and quantities (bulk entry)
class QuickLogSheet extends StatefulWidget {
  const QuickLogSheet({super.key, required this.yardId, this.onLogComplete});

  final String yardId;
  final VoidCallback? onLogComplete;

  @override
  State<QuickLogSheet> createState() => _QuickLogSheetState();
}

class _QuickLogSheetState extends State<QuickLogSheet> {
  final _logsRepository = ConsumableLogsRepository();
  final _staffRepository = StaffRepository();

  // State
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showAllHorses = false;

  // Data
  List<ConsumableTypeInfo> _consumables = [];
  ConsumableTypeInfo? _selectedConsumable;
  List<HorseForLog> _horses = [];
  Map<String, BulkLogEntry> _selectedHorses = {};
  Map<String, double> _lastQuantities = {};

  @override
  void initState() {
    super.initState();
    _loadConsumables();
  }

  Future<void> _loadConsumables() async {
    setState(() => _isLoading = true);
    try {
      debugPrint(
        'QuickLogSheet: Loading consumables for yard ${widget.yardId}',
      );
      final consumables = await _logsRepository.getConsumableTypes(
        widget.yardId,
      );
      debugPrint('QuickLogSheet: Loaded ${consumables.length} consumables');
      for (final c in consumables) {
        debugPrint('  - ${c.name} (${c.usageUnit}) @ £${c.pricePerUsageUnit}');
      }
      if (mounted) {
        setState(() {
          _consumables = consumables;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('QuickLogSheet: Error loading consumables: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load consumables');
      }
    }
  }

  Future<void> _loadHorses() async {
    setState(() => _isLoading = true);
    try {
      debugPrint('QuickLogSheet: Loading horses for yard ${widget.yardId}');
      final horses = await _staffRepository.getHorsesForLogging(widget.yardId);
      debugPrint('QuickLogSheet: Loaded ${horses.length} horses');

      // Load last quantities for memory feature
      Map<String, double> lastQuantities = {};
      if (_selectedConsumable != null) {
        lastQuantities = await _logsRepository.getLastQuantities(
          widget.yardId,
          _selectedConsumable!.id,
        );
      }

      if (mounted) {
        setState(() {
          _horses = horses;
          _lastQuantities = lastQuantities;
          _isLoading = false;

          // Pre-select assigned horses with their last quantities
          for (final horse in horses) {
            if (horse.isAssigned) {
              final lastQty = lastQuantities[horse.id] ?? 1;
              _selectedHorses[horse.id] = BulkLogEntry(
                horseId: horse.id,
                horseName: horse.name,
                quantity: lastQty,
              );
            }
          }
        });
      }
    } catch (e) {
      debugPrint('QuickLogSheet: Error loading horses: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load horses');
      }
    }
  }

  void _selectConsumable(ConsumableTypeInfo consumable) {
    setState(() {
      _selectedConsumable = consumable;
      _currentStep = 1;
      _selectedHorses.clear();
    });
    _loadHorses();
  }

  void _toggleHorse(HorseForLog horse) {
    setState(() {
      if (_selectedHorses.containsKey(horse.id)) {
        _selectedHorses.remove(horse.id);
      } else {
        final lastQty = _lastQuantities[horse.id] ?? 1;
        _selectedHorses[horse.id] = BulkLogEntry(
          horseId: horse.id,
          horseName: horse.name,
          quantity: lastQty,
        );
      }
    });
  }

  void _updateQuantity(String horseId, double quantity) {
    if (_selectedHorses.containsKey(horseId)) {
      setState(() {
        _selectedHorses[horseId]!.quantity = quantity;
      });
    }
  }

  void _setAllQuantities(double quantity) {
    setState(() {
      for (final entry in _selectedHorses.values) {
        entry.quantity = quantity;
      }
    });
  }

  double get _totalQuantity {
    return _selectedHorses.values.fold(0, (sum, e) => sum + e.quantity);
  }

  double get _totalPrice {
    if (_selectedConsumable == null) return 0;
    return _totalQuantity * _selectedConsumable!.pricePerUsageUnit;
  }

  Future<void> _submitLogs() async {
    if (_selectedConsumable == null || _selectedHorses.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await _logsRepository.createBulkLogs(
        yardId: widget.yardId,
        consumableTypeId: _selectedConsumable!.id,
        entries: _selectedHorses.values.toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onLogComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        SnackbarService.showError(context, 'Failed to save logs');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 0;
                        _selectedConsumable = null;
                        _selectedHorses.clear();
                      });
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                Expanded(
                  child: Text(
                    _currentStep == 0
                        ? 'Quick Log'
                        : _selectedConsumable?.name ?? 'Select Horses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
          // Content
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _currentStep == 0
                ? _buildConsumableSelector(isDark)
                : _buildHorseSelector(isDark),
          ),
          // Footer (only on step 2)
          if (_currentStep == 1 && !_isLoading)
            _buildFooter(isDark, bottomPadding),
        ],
      ),
    );
  }

  Widget _buildConsumableSelector(bool isDark) {
    if (_consumables.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              const SizedBox(height: 16),
              Text(
                'No consumables configured',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ask your yard owner to set up consumables',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are you logging?',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _consumables.map((consumable) {
              return _buildConsumableChip(consumable, isDark);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConsumableChip(ConsumableTypeInfo consumable, bool isDark) {
    final icon = _getConsumableIcon(consumable.name);

    return GestureDetector(
      onTap: () => _selectConsumable(consumable),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFFFFD66B)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      consumable.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (consumable.brand != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        consumable.brand!,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '£${consumable.pricePerUsageUnit.toStringAsFixed(2)} per ${consumable.usageUnit.toLowerCase()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getConsumableIcon(String name) {
    // Match the icon logic from ConsumableCard
    switch (name.toLowerCase()) {
      case 'hay':
        return Icons.grass;
      case 'haylage':
        return Icons.eco;
      case 'straw':
        return Icons.agriculture;
      case 'shavings':
        return Icons.blur_on;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  Widget _buildHorseSelector(bool isDark) {
    // Filter horses based on toggle
    final displayHorses = _showAllHorses
        ? _horses
        : _horses
              .where((h) => h.isAssigned || _selectedHorses.containsKey(h.id))
              .toList();

    // If no assigned horses and not showing all, show all by default
    final hasAssigned = _horses.any((h) => h.isAssigned);
    final effectiveHorses = (!hasAssigned || _showAllHorses)
        ? _horses
        : displayHorses;

    return Column(
      children: [
        // Toggle and quick set
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Show all toggle
              GestureDetector(
                onTap: () => setState(() => _showAllHorses = !_showAllHorses),
                child: Row(
                  children: [
                    Icon(
                      _showAllHorses
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20,
                      color: const Color(0xFFFFD66B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Show all horses',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Quick set buttons
              if (_selectedHorses.isNotEmpty) ...[
                Text(
                  'Set all:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(width: 8),
                for (final qty in [1, 2, 3])
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GestureDetector(
                      onTap: () => _setAllQuantities(qty.toDouble()),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '$qty',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
        Divider(
          height: 1,
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
        // Horse list
        Expanded(
          child: effectiveHorses.isEmpty
              ? Center(
                  child: Text(
                    'No horses assigned to you',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: effectiveHorses.length,
                  itemBuilder: (context, index) {
                    return _buildHorseRow(effectiveHorses[index], isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHorseRow(HorseForLog horse, bool isDark) {
    final isSelected = _selectedHorses.containsKey(horse.id);
    final entry = _selectedHorses[horse.id];
    final lastQty = _lastQuantities[horse.id];

    return InkWell(
      onTap: () => _toggleHorse(horse),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD66B).withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFFFD66B)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD66B)
                      : (isDark ? Colors.white38 : Colors.black26),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.black87)
                  : null,
            ),
            const SizedBox(width: 12),
            // Horse avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white12 : Colors.grey[200],
              ),
              child: horse.photoUrl != null
                  ? ClipOval(
                      child: Image.network(
                        horse.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.pets,
                          size: 20,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.pets,
                      size: 20,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
            ),
            const SizedBox(width: 12),
            // Horse info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        horse.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (horse.isAssigned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFD66B,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Assigned',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD4A017),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    horse.ownerName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            // Quantity stepper (only if selected)
            if (isSelected && entry != null) ...[
              if (lastQty != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    'Last: ${lastQty.toInt()}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
                ),
              _buildQuantityStepper(horse.id, entry.quantity, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(String horseId, double quantity, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1
                ? () => _updateQuantity(horseId, quantity - 1)
                : null,
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            color: isDark ? Colors.white70 : Colors.black54,
            disabledColor: isDark ? Colors.white24 : Colors.black12,
          ),
          SizedBox(
            width: 32,
            child: Text(
              quantity.toInt().toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _updateQuantity(horseId, quantity + 1),
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_totalQuantity.toInt()} ${_selectedConsumable?.usageUnit ?? 'units'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  '£${_totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selectedHorses.isEmpty || _isSubmitting
                    ? null
                    : _submitLogs,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD66B),
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Log ${_selectedHorses.length} ${_selectedHorses.length == 1 ? 'horse' : 'horses'}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
