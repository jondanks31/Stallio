import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../data/settings_repository.dart';

/// Page for managing livery packages
class PackagesPage extends StatefulWidget {
  const PackagesPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends State<PackagesPage> {
  final _repository = SettingsRepository();
  final _uuid = const Uuid();

  List<LiveryPackage> _packages = [];
  List<ConsumableType> _consumables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final packages = await _repository.getPackages(widget.yardId);
      final consumables = await _repository.getConsumables(widget.yardId);
      if (mounted) {
        setState(() {
          _packages = packages;
          _consumables = consumables;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load packages');
      }
    }
  }

  Future<void> _showAddEditDialog([LiveryPackage? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing?.basePrice.toStringAsFixed(2) ?? '0.00',
    );

    // Track which consumables are included
    final includedIds = <String>{};
    if (existing != null) {
      for (final item in existing.includedItems) {
        if (item['consumable_id'] != null) {
          includedIds.add(item['consumable_id'] as String);
        }
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Package' : 'Edit Package'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Package Name',
                      hintText: 'e.g. Full Livery, DIY',
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Base Price (monthly)',
                      prefixText: '£',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Included Consumables',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_consumables.isEmpty)
                    Text(
                      'No consumables defined yet. Add some in Consumables settings first.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    )
                  else
                    ..._consumables.map(
                      (c) => CheckboxListTile(
                        title: Text(c.name),
                        subtitle: Text(
                          '£${c.pricePerUsageUnit.toStringAsFixed(2)} per ${c.usageUnit}',
                        ),
                        value: includedIds.contains(c.id),
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              includedIds.add(c.id);
                            } else {
                              includedIds.remove(c.id);
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      final name = nameController.text.trim();
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (name.isEmpty) {
        SnackbarService.showError(context, 'Please enter a package name');
        return;
      }

      // Build included items list
      final includedItems = includedIds
          .map((id) => {'consumable_id': id, 'unlimited': true})
          .toList();

      try {
        if (existing == null) {
          final pkg = LiveryPackage(
            id: _uuid.v4(),
            yardId: widget.yardId,
            name: name,
            basePrice: price,
            includedItems: includedItems,
          );
          await _repository.createPackage(pkg);
          SnackbarService.showSuccess(context, 'Package added');
        } else {
          final pkg = LiveryPackage(
            id: existing.id,
            yardId: existing.yardId,
            name: name,
            basePrice: price,
            includedItems: includedItems,
            version: existing.version,
          );
          await _repository.updatePackage(pkg);
          SnackbarService.showSuccess(context, 'Package updated');
        }
        _loadData();
      } catch (e) {
        SnackbarService.showError(context, 'Failed to save package');
      }
    }
  }

  Future<void> _deletePackage(LiveryPackage pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Are you sure you want to delete "${pkg.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _repository.deletePackage(pkg.id);
        SnackbarService.showSuccess(context, 'Package deleted');
        _loadData();
      } catch (e) {
        SnackbarService.showError(context, 'Failed to delete package');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        foregroundColor: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Livery Packages',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Create packages with bundled services',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _packages.isEmpty
                    ? _buildEmptyState()
                    : _buildList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: const Color(0xFFFFD66B),
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add),
        label: const Text('Add Package'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No packages yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Create livery packages like Full Livery, DIY, etc.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      itemCount: _packages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final pkg = _packages[index];
        final includedCount = pkg.includedItems.length;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '£${pkg.basePrice.toStringAsFixed(2)} / month',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFFFD66B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      includedCount == 0
                          ? 'No included extras'
                          : '$includedCount included extra${includedCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAddEditDialog(pkg),
                icon: const Icon(Icons.edit_outlined, size: 20),
                style: IconButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              IconButton(
                onPressed: () => _deletePackage(pkg),
                icon: const Icon(Icons.delete_outline, size: 20),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.red.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
