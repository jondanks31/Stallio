import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../data/settings_repository.dart';

/// Page for managing consumable types (hay, bedding, arena, etc.)
class ConsumablesPage extends StatefulWidget {
  const ConsumablesPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<ConsumablesPage> createState() => _ConsumablesPageState();
}

class _ConsumablesPageState extends State<ConsumablesPage> {
  final _repository = SettingsRepository();
  final _uuid = const Uuid();

  List<ConsumableType> _consumables = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConsumables();
  }

  Future<void> _loadConsumables() async {
    setState(() => _isLoading = true);
    try {
      final items = await _repository.getConsumables(widget.yardId);
      if (mounted) {
        setState(() {
          _consumables = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load consumables');
      }
    }
  }

  Future<void> _showAddEditDialog([ConsumableType? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final stockUnitController = TextEditingController(
      text: existing?.stockUnit ?? '',
    );
    final usageUnitController = TextEditingController(
      text: existing?.usageUnit ?? '',
    );
    final ratioController = TextEditingController(
      text: existing?.ratio.toString() ?? '1',
    );
    final priceController = TextEditingController(
      text: existing?.pricePerUsageUnit.toStringAsFixed(2) ?? '0.00',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Consumable' : 'Edit Consumable'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Hay, Bedding, Arena',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: stockUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Stock Unit',
                        hintText: 'e.g. Bale',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: usageUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Usage Unit',
                        hintText: 'e.g. Slice',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ratioController,
                      decoration: const InputDecoration(
                        labelText: 'Ratio',
                        hintText: 'Usage per stock',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price per usage',
                        prefixText: '£',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Example: 1 Bale = 8 Slices, £0.50 per Slice',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
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
    );

    if (result == true && mounted) {
      final name = nameController.text.trim();
      final stockUnit = stockUnitController.text.trim();
      final usageUnit = usageUnitController.text.trim();
      final ratio = int.tryParse(ratioController.text) ?? 1;
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (name.isEmpty || stockUnit.isEmpty || usageUnit.isEmpty) {
        SnackbarService.showError(context, 'Please fill in all fields');
        return;
      }

      try {
        if (existing == null) {
          // Create new
          final item = ConsumableType(
            id: _uuid.v4(),
            yardId: widget.yardId,
            name: name,
            stockUnit: stockUnit,
            usageUnit: usageUnit,
            ratio: ratio,
            pricePerUsageUnit: price,
          );
          await _repository.createConsumable(item);
          SnackbarService.showSuccess(context, 'Consumable added');
        } else {
          // Update existing
          final item = ConsumableType(
            id: existing.id,
            yardId: existing.yardId,
            name: name,
            stockUnit: stockUnit,
            usageUnit: usageUnit,
            ratio: ratio,
            pricePerUsageUnit: price,
          );
          await _repository.updateConsumable(item);
          SnackbarService.showSuccess(context, 'Consumable updated');
        }
        _loadConsumables();
      } catch (e) {
        SnackbarService.showError(context, 'Failed to save consumable');
      }
    }
  }

  Future<void> _deleteConsumable(ConsumableType item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Consumable'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
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
        await _repository.deleteConsumable(item.id);
        SnackbarService.showSuccess(context, 'Consumable deleted');
        _loadConsumables();
      } catch (e) {
        SnackbarService.showError(context, 'Failed to delete consumable');
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
                            'Consumables',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Manage extras like hay, bedding, arena time',
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
                    : _consumables.isEmpty
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
        label: const Text('Add Consumable'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No consumables yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Add hay, bedding, arena time, and other extras',
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
      itemCount: _consumables.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _consumables[index];
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
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 ${item.stockUnit} = ${item.ratio} ${item.usageUnit}s',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '£${item.pricePerUsageUnit.toStringAsFixed(2)} per ${item.usageUnit}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFFD66B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAddEditDialog(item),
                icon: const Icon(Icons.edit_outlined, size: 20),
                style: IconButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              IconButton(
                onPressed: () => _deleteConsumable(item),
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
