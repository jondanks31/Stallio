import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../data/people_repository.dart';

/// Model for a livery package
class LiveryPackage {
  final String id;
  final String name;
  final double basePrice;

  LiveryPackage({
    required this.id,
    required this.name,
    required this.basePrice,
  });

  factory LiveryPackage.fromJson(Map<String, dynamic> json) {
    return LiveryPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
    );
  }
}

/// Model for an extra service
class ExtraService {
  final String id;
  final String name;
  final double price;
  final String unit;
  final bool isRecurring;

  ExtraService({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.isRecurring,
  });

  factory ExtraService.fromJson(Map<String, dynamic> json) {
    return ExtraService(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      isRecurring: json['is_recurring'] as bool? ?? true,
    );
  }

  /// Convert weekly/daily prices to monthly equivalent
  double get monthlyPrice {
    if (unit.toLowerCase().contains('week')) {
      return price * 4.33; // Average weeks per month
    } else if (unit.toLowerCase().contains('day')) {
      return price * 30.44; // Average days per month
    }
    return price;
  }
}

/// Model for a horse's assigned package
class HorsePackageAssignment {
  final String horseId;
  final String horseName;
  String? packageId;

  HorsePackageAssignment({
    required this.horseId,
    required this.horseName,
    this.packageId,
  });
}

/// Dialog for managing a user's packages and extras
Future<bool?> showManageBillingDialog(
  BuildContext context, {
  required String yardId,
  required YardPerson person,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => _ManageBillingDialog(yardId: yardId, person: person),
  );
}

class _ManageBillingDialog extends StatefulWidget {
  const _ManageBillingDialog({required this.yardId, required this.person});

  final String yardId;
  final YardPerson person;

  @override
  State<_ManageBillingDialog> createState() => _ManageBillingDialogState();
}

class _ManageBillingDialogState extends State<_ManageBillingDialog> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;
  bool _isSaving = false;

  List<LiveryPackage> _packages = [];
  List<ExtraService> _extras = [];
  List<HorsePackageAssignment> _horseAssignments = [];
  Set<String> _selectedExtras = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load available packages
      final packagesResponse = await _supabase
          .from('livery_packages')
          .select('id, name, base_price')
          .eq('yard_id', widget.yardId)
          .eq('is_active', true)
          .order('base_price');

      _packages = (packagesResponse as List)
          .map((p) => LiveryPackage.fromJson(p))
          .toList();

      // Load available extras
      final extrasResponse = await _supabase
          .from('extras')
          .select('id, name, price, unit, is_recurring')
          .eq('yard_id', widget.yardId)
          .order('name');

      _extras = (extrasResponse as List)
          .map((e) => ExtraService.fromJson(e))
          .toList();

      // Load current horse package assignments
      final horseIds = widget.person.horses.map((h) => h.id).toList();
      if (horseIds.isNotEmpty) {
        final now = DateTime.now().toIso8601String();
        final assignmentsResponse = await _supabase
            .from('user_packages')
            .select('horse_id, package_id')
            .eq('yard_id', widget.yardId)
            .inFilter('horse_id', horseIds)
            .lte('effective_from', now)
            .or('effective_to.is.null,effective_to.gte.$now');

        final assignmentMap = <String, String>{};
        for (final a in assignmentsResponse as List) {
          assignmentMap[a['horse_id'] as String] = a['package_id'] as String;
        }

        _horseAssignments = widget.person.horses.map((h) {
          return HorsePackageAssignment(
            horseId: h.id,
            horseName: h.name,
            packageId: assignmentMap[h.id],
          );
        }).toList();
      }

      // Load current user extras
      final now = DateTime.now().toIso8601String();
      final userExtrasResponse = await _supabase
          .from('user_extras')
          .select('extra_id')
          .eq('yard_id', widget.yardId)
          .eq('user_id', widget.person.id)
          .lte('effective_from', now)
          .or('effective_to.is.null,effective_to.gte.$now');

      _selectedExtras = (userExtrasResponse as List)
          .map((e) => e['extra_id'] as String)
          .toSet();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading billing data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load billing data');
      }
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final now = DateTime.now();
      final oderId = widget.person.id;

      // Update horse packages
      for (final assignment in _horseAssignments) {
        // First, end any existing package for this horse
        await _supabase
            .from('user_packages')
            .update({'effective_to': now.toIso8601String()})
            .eq('yard_id', widget.yardId)
            .eq('horse_id', assignment.horseId)
            .isFilter('effective_to', null);

        // Then, if a package is selected, create new assignment
        if (assignment.packageId != null) {
          await _supabase.from('user_packages').insert({
            'yard_id': widget.yardId,
            'user_id': oderId,
            'horse_id': assignment.horseId,
            'package_id': assignment.packageId,
            'effective_from': now.toIso8601String(),
          });
        }
      }

      // Update user extras
      // First, get current extras
      final currentExtrasResponse = await _supabase
          .from('user_extras')
          .select('id, extra_id')
          .eq('yard_id', widget.yardId)
          .eq('user_id', oderId)
          .isFilter('effective_to', null);

      final currentExtras = <String, String>{};
      for (final e in currentExtrasResponse as List) {
        currentExtras[e['extra_id'] as String] = e['id'] as String;
      }

      // End extras that were removed
      for (final extraId in currentExtras.keys) {
        if (!_selectedExtras.contains(extraId)) {
          await _supabase
              .from('user_extras')
              .update({'effective_to': now.toIso8601String()})
              .eq('id', currentExtras[extraId]!);
        }
      }

      // Add new extras
      for (final extraId in _selectedExtras) {
        if (!currentExtras.containsKey(extraId)) {
          await _supabase.from('user_extras').insert({
            'yard_id': widget.yardId,
            'user_id': oderId,
            'extra_id': extraId,
            'effective_from': now.toIso8601String(),
          });
        }
      }

      if (mounted) {
        SnackbarService.showSuccess(context, 'Billing updated successfully');
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint('Error saving billing: $e');
      if (mounted) {
        setState(() => _isSaving = false);
        SnackbarService.showError(context, 'Failed to save changes');
      }
    }
  }

  double get _totalMonthly {
    double total = 0;

    // Sum package costs
    for (final assignment in _horseAssignments) {
      if (assignment.packageId != null) {
        final pkg = _packages.firstWhere(
          (p) => p.id == assignment.packageId,
          orElse: () => LiveryPackage(id: '', name: '', basePrice: 0),
        );
        total += pkg.basePrice;
      }
    }

    // Sum extras costs (converted to monthly)
    for (final extraId in _selectedExtras) {
      final extra = _extras.firstWhere(
        (e) => e.id == extraId,
        orElse: () => ExtraService(
          id: '',
          name: '',
          price: 0,
          unit: '',
          isRecurring: false,
        ),
      );
      if (extra.isRecurring) {
        total += extra.monthlyPrice;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BrandColors.yellow.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BrandColors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: BrandColors.yellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Billing',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          widget.person.fullName ?? widget.person.email ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Horse Packages Section
                          if (_horseAssignments.isNotEmpty) ...[
                            _buildSectionHeader(
                              'Horse Packages',
                              'Assign a livery package to each horse',
                              Icons.pets,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ..._horseAssignments.map((assignment) {
                              return _buildHorsePackageRow(assignment, isDark);
                            }),
                            const SizedBox(height: 24),
                          ],

                          // Extras Section
                          if (_extras.isNotEmpty) ...[
                            _buildSectionHeader(
                              'Extras',
                              'Additional services (charged per user, not per horse)',
                              Icons.add_circle_outline,
                              isDark,
                            ),
                            const SizedBox(height: 12),
                            ..._extras.where((e) => e.isRecurring).map((extra) {
                              return _buildExtraRow(extra, isDark);
                            }),
                          ],

                          // Empty state
                          if (_horseAssignments.isEmpty && _extras.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black26,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No horses or extras to configure',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            // Footer with total and save button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[50],
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Monthly total
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimated Monthly',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                        Text(
                          '£${_totalMonthly.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BrandColors.yellow,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrandColors.yellow,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black54,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: BrandColors.yellow),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorsePackageRow(HorsePackageAssignment assignment, bool isDark) {
    // Package is selected via dropdown

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Horse icon and name
          Icon(
            Icons.pets,
            size: 18,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              assignment.horseName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          // Package dropdown
          DropdownButton<String?>(
            value: assignment.packageId,
            hint: Text(
              'No package',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 13,
              ),
            ),
            underline: const SizedBox(),
            isDense: true,
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  'No package',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ),
              ..._packages.map((pkg) {
                return DropdownMenuItem<String?>(
                  value: pkg.id,
                  child: Text(
                    '${pkg.name} (£${pkg.basePrice.toStringAsFixed(0)})',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                assignment.packageId = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExtraRow(ExtraService extra, bool isDark) {
    final isSelected = _selectedExtras.contains(extra.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedExtras.remove(extra.id);
            } else {
              _selectedExtras.add(extra.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? BrandColors.yellow.withValues(alpha: 0.15)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey[50]),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? BrandColors.yellow.withValues(alpha: 0.5)
                  : (isDark
                        ? Colors.white12
                        : Colors.black.withValues(alpha: 0.08)),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected
                      ? BrandColors.yellow
                      : (isDark ? Colors.white12 : Colors.white),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? BrandColors.yellow
                        : (isDark ? Colors.white24 : Colors.black26),
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.black87)
                    : null,
              ),
              const SizedBox(width: 12),
              // Extra details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      extra.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '£${extra.price.toStringAsFixed(2)} ${extra.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              // Monthly equivalent
              Text(
                '≈ £${extra.monthlyPrice.toStringAsFixed(2)}/mo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
