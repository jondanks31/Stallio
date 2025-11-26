import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../../settings/data/settings_repository.dart';

/// Yard management page with sidebar navigation for desktop
/// and stacked sections for mobile
class YardManagementPage extends StatefulWidget {
  const YardManagementPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<YardManagementPage> createState() => _YardManagementPageState();
}

class _YardManagementPageState extends State<YardManagementPage> {
  final _repository = SettingsRepository();
  final _uuid = const Uuid();

  int _selectedSection = 0;
  bool _isLoading = true;

  List<ConsumableType> _consumables = [];
  List<Extra> _extras = [];
  List<LiveryPackage> _packages = [];
  InvoiceSettings? _invoiceSettings;

  final _sections = const [
    _Section(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Consumables',
      description: 'Tracked inventory items',
    ),
    _Section(
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Extras',
      description: 'Additional chargeable services',
    ),
    _Section(
      icon: Icons.card_giftcard_outlined,
      activeIcon: Icons.card_giftcard,
      label: 'Packages',
      description: 'Livery packages & pricing',
    ),
    _Section(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Invoicing',
      description: 'Billing & payment settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final consumables = await _repository.getConsumables(widget.yardId);
      final extras = await _repository.getExtras(widget.yardId);
      final packages = await _repository.getPackages(widget.yardId);
      final invoiceSettings = await _repository.getInvoiceSettings(
        widget.yardId,
      );

      if (mounted) {
        setState(() {
          _consumables = consumables;
          _extras = extras;
          _packages = packages;
          _invoiceSettings = invoiceSettings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load yard data');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GradientBackground(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sidebar
              Container(
                width: 280,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage Yard',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure your yard services and billing',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ..._sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      final isSelected = _selectedSection == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildSidebarItem(
                          icon: isSelected ? section.activeIcon : section.icon,
                          label: section.label,
                          description: section.description,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedSection = index),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Content area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSectionContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _HoverMenuItem(
      isSelected: isSelected,
      isDark: isDark,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white54 : Colors.black45),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? Colors.white70
                        : (isDark ? Colors.white38 : Colors.black38),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
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
                            'Manage Yard',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Configure services and billing',
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
              // Section tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;
                      final isSelected = _selectedSection == index;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildMobileTab(
                          label: section.label,
                          isSelected: isSelected,
                          onTap: () => setState(() => _selectedSection = index),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildSectionContent(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD66B) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_selectedSection) {
      case 0:
        return _buildConsumablesSection();
      case 1:
        return _buildExtrasSection();
      case 2:
        return _buildPackagesSection();
      case 3:
        return _buildInvoicingSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildConsumablesSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consumables',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${_consumables.length} items configured',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => _showAddEditConsumableDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grid layout - smaller cards
        Expanded(
          child: _consumables.isEmpty
              ? _buildEmptyState(
                  icon: Icons.inventory_2_outlined,
                  title: 'No consumables yet',
                  subtitle: 'Add hay, bedding, and other tracked inventory',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // More columns for smaller cards
                    int crossAxisCount;
                    if (constraints.maxWidth > 900) {
                      crossAxisCount = 5;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 4;
                    } else {
                      crossAxisCount = 2;
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0, // Square cards
                      ),
                      itemCount: _consumables.length,
                      itemBuilder: (context, index) {
                        return _buildConsumableCard(_consumables[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildConsumableCard(ConsumableType item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWeb = MediaQuery.of(context).size.width > 600;

    IconData getIcon() {
      switch (item.name.toLowerCase()) {
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

    return _HoverCard(
      onTap: isWeb ? null : () => _showAddEditConsumableDialog(item),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top row: icon and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    getIcon(),
                    size: 18,
                    color: const Color(0xFFFFD66B),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWeb)
                      _HoverIconButton(
                        icon: Icons.edit_outlined,
                        onTap: () => _showAddEditConsumableDialog(item),
                      ),
                    if (isWeb) const SizedBox(width: 4),
                    _HoverIconButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onTap: () => _deleteConsumable(item),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (item.brand != null)
              Text(
                item.brand!,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              '£${item.pricePerUsageUnit.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              'per ${item.usageUnit.toLowerCase()}',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
            const Spacer(),
            if (item.trackInventory)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: item.currentStock > 5
                      ? Colors.green.withValues(alpha: 0.15)
                      : item.currentStock > 0
                      ? Colors.orange.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.currentStock % 1 == 0 ? item.currentStock.toInt() : item.currentStock.toStringAsFixed(1)} ${item.stockUnit}${item.currentStock == 1 ? '' : 's'} in stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: item.currentStock > 5
                        ? Colors.green[700]
                        : item.currentStock > 0
                        ? Colors.orange[700]
                        : Colors.red[700],
                  ),
                ),
              )
            else
              Text(
                'Not tracked',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtrasSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extras',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${_extras.length} services configured',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => _showAddEditExtraDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _extras.isEmpty
              ? _buildEmptyState(
                  icon: Icons.add_circle_outline,
                  title: 'No extras yet',
                  subtitle: 'Add services like Arena, Rug Change, Feed, etc.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount;
                    if (constraints.maxWidth > 900) {
                      crossAxisCount = 5;
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 4;
                    } else {
                      crossAxisCount = 2;
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: _extras.length,
                      itemBuilder: (context, index) {
                        return _buildExtraCard(_extras[index]);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExtraCard(Extra extra) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWeb = MediaQuery.of(context).size.width > 600;

    IconData getIcon() {
      switch (extra.name.toLowerCase()) {
        case 'arena':
          return Icons.sports_handball;
        case 'rug change':
          return Icons.checkroom;
        case 'feed':
          return Icons.restaurant;
        case 'turnout':
          return Icons.wb_sunny_outlined;
        case 'grooming':
          return Icons.brush;
        case 'exercise':
          return Icons.directions_run;
        case 'medication admin':
          return Icons.medication;
        case 'hold for farrier':
        case 'hold for vet':
          return Icons.medical_services_outlined;
        default:
          return Icons.add_circle_outline;
      }
    }

    return _HoverCard(
      onTap: isWeb ? null : () => _showAddEditExtraDialog(extra),
      color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top row: icon and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    getIcon(),
                    size: 18,
                    color: const Color(0xFFFFD66B),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWeb)
                      _HoverIconButton(
                        icon: Icons.edit_outlined,
                        onTap: () => _showAddEditExtraDialog(extra),
                      ),
                    if (isWeb) const SizedBox(width: 4),
                    _HoverIconButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onTap: () => _deleteExtra(extra),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              extra.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '£${extra.price.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              extra.unit,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
            const Spacer(),
            if (extra.isRecurring)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Recurring',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              )
            else
              Text(
                'One-time',
                style: TextStyle(fontSize: 10, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackagesSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Livery Packages',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '${_packages.length} packages configured',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: () => _showAddEditPackageDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _packages.isEmpty
              ? _buildEmptyState(
                  icon: Icons.card_giftcard_outlined,
                  title: 'No packages yet',
                  subtitle:
                      'Create livery packages like Full Livery, DIY, etc.',
                )
              : ListView.separated(
                  itemCount: _packages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final pkg = _packages[index];
                    return _buildPackageCard(pkg);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPackageCard(LiveryPackage pkg) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final includedCount = pkg.includedItems.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.card_giftcard_outlined,
              size: 20,
              color: Color(0xFFFFD66B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pkg.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '£${pkg.basePrice.toStringAsFixed(2)}/month • $includedCount included extra${includedCount == 1 ? '' : 's'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showAddEditPackageDialog(pkg),
            icon: const Icon(Icons.edit_outlined, size: 18),
            style: IconButton.styleFrom(foregroundColor: Colors.grey),
          ),
          IconButton(
            onPressed: () => _deletePackage(pkg),
            icon: const Icon(Icons.delete_outline, size: 18),
            style: IconButton.styleFrom(
              foregroundColor: Colors.red.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicingSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Settings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Billing schedule card
          _buildSettingCard(
            icon: Icons.calendar_today_outlined,
            title: 'Billing Schedule',
            children: [
              _buildSettingRow(
                label: 'Billing Day',
                value: _invoiceSettings?.billingDay != null
                    ? '${_invoiceSettings!.billingDay}${_getDaySuffix(_invoiceSettings!.billingDay!)} of each month'
                    : 'Not set',
                onEdit: () => _editBillingDay(),
              ),
              const Divider(height: 24),
              _buildSettingRow(
                label: 'Cut-off Buffer',
                value: '${_invoiceSettings?.cutoffBuffer ?? 5} days',
                onEdit: () => _editCutoffBuffer(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Payment info card
          _buildSettingCard(
            icon: Icons.account_balance_outlined,
            title: 'Payment Information',
            children: [
              _buildSettingRow(
                label: 'Bank Details',
                value: _invoiceSettings?.bankDetails ?? 'Not set',
                onEdit: () => _editBankDetails(),
              ),
              const Divider(height: 24),
              _buildSettingRow(
                label: 'Payment Terms',
                value: _invoiceSettings?.paymentTerms ?? 'Not set',
                onEdit: () => _editPaymentTerms(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFFFFD66B)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onEdit, child: const Text('Edit')),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BRANDED DIALOG HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  InputDecoration _brandedInputDecoration({
    required String label,
    String? hint,
    String? prefix,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      filled: true,
      fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _brandedDropdownDecoration({required String label}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _cancelButton() => TextButton(
    onPressed: () => Navigator.pop(context, null),
    child: const Text('Cancel'),
  );

  Widget _primaryButton(String label, {VoidCallback? onPressed}) =>
      FilledButton(
        onPressed: onPressed ?? () => Navigator.pop(context, true),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFFD66B),
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(label),
      );

  Widget _deleteButton() => FilledButton(
    onPressed: () => Navigator.pop(context, true),
    style: FilledButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    child: const Text('Delete'),
  );

  // ─────────────────────────────────────────────────────────────────────────
  // CONSUMABLE DIALOGS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showAddEditConsumableDialog([ConsumableType? existing]) async {
    ConsumablePreset? selectedPreset;
    MeasurementType measureType = MeasurementType.slices;

    // Parse existing data
    if (existing != null) {
      for (final p in ConsumablePreset.values) {
        if (p.displayName == existing.name) {
          selectedPreset = p;
          break;
        }
      }
      // Determine measurement type from existing data
      if (existing.stockUnit.toLowerCase().contains('kg') ||
          existing.stockUnit.toLowerCase().contains('ton')) {
        measureType = MeasurementType.weight;
      }
    }

    final brandController = TextEditingController(text: existing?.brand ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    final priceController = TextEditingController(
      text: existing?.pricePerUsageUnit.toStringAsFixed(2) ?? '0.00',
    );
    final stockController = TextEditingController(
      text: existing?.currentStock.toString() ?? '0',
    );
    final ratioController = TextEditingController(
      text: existing?.ratio.toString() ?? '8',
    );
    String selectedWeightUnit = existing?.stockUnit ?? 'kg';
    String selectedPricePerUnit = existing?.usageUnit ?? 'kg';
    bool trackInventory = existing?.trackInventory ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const charcoal = Color(0xFF1E1E1E);

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isShavings = selectedPreset == ConsumablePreset.shavings;
          final showMeasurementChoice =
              selectedPreset != null && selectedPreset!.supportsSlices;

          return Dialog(
            backgroundColor: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF8F8F8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        existing == null ? 'Add Consumable' : 'Edit Consumable',
                        style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tracked inventory items',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      // Type dropdown
                      DropdownButtonFormField<ConsumablePreset>(
                        value: selectedPreset,
                        decoration: _brandedDropdownDecoration(label: 'Type'),
                        hint: const Text('Select type'),
                        items: ConsumablePreset.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setDialogState(() {
                          selectedPreset = v;
                          if (v != null) {
                            measureType = v.defaultMeasurementType;
                          }
                        }),
                      ),

                      // Shavings brand/description
                      if (isShavings) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: brandController,
                          decoration: _brandedInputDecoration(
                            label: 'Brand (optional)',
                            hint: 'e.g. Bedmax',
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descController,
                          decoration: _brandedInputDecoration(
                            label: 'Description (optional)',
                            hint: 'e.g. Large flakes',
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],

                      // Measurement type selection (for hay, haylage, straw)
                      // Measurement choice - only for items that support slices (not shavings)
                      if (showMeasurementChoice) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Measurement',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children:
                              [
                                MeasurementType.slices,
                                MeasurementType.weight,
                              ].map((type) {
                                final isSelected = measureType == type;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: type != MeasurementType.weight
                                          ? 8
                                          : 0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => setDialogState(
                                        () => measureType = type,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? charcoal
                                              : (isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.08,
                                                      )
                                                    : Colors.white),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? charcoal
                                                : Colors.grey.withValues(
                                                    alpha: 0.2,
                                                  ),
                                          ),
                                        ),
                                        child: Text(
                                          type.displayName,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                            color: isSelected
                                                ? Colors.white
                                                : (isDark
                                                      ? Colors.white70
                                                      : Colors.black54),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],

                      // Slices configuration
                      if (selectedPreset != null &&
                          measureType == MeasurementType.slices) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: ratioController,
                          decoration: _brandedInputDecoration(
                            label: isShavings
                                ? 'Bales per unit'
                                : 'Slices per bale',
                            hint: isShavings ? '1' : 'e.g. 8',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: _brandedInputDecoration(
                            label: isShavings
                                ? 'Price per bale'
                                : 'Price per slice',
                            prefix: '£',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],

                      // Weight configuration
                      if (selectedPreset != null &&
                          measureType == MeasurementType.weight) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stock unit',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: ['kg', 'Ton'].map((unit) {
                                        final isSelected =
                                            selectedWeightUnit == unit;
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () => setDialogState(
                                              () => selectedWeightUnit = unit,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? charcoal
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                unit,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Price per',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: ['1kg', '10kg', '100kg'].map((
                                        unit,
                                      ) {
                                        final isSelected =
                                            selectedPricePerUnit == unit;
                                        return Expanded(
                                          child: GestureDetector(
                                            onTap: () => setDialogState(
                                              () => selectedPricePerUnit = unit,
                                            ),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? charcoal
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                unit,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: _brandedInputDecoration(
                            label: 'Price per $selectedPricePerUnit',
                            prefix: '£',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],

                      // Whole unit configuration (shavings, etc.)
                      if (selectedPreset != null &&
                          measureType == MeasurementType.whole) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: priceController,
                          decoration: _brandedInputDecoration(
                            label: 'Price per bag',
                            prefix: '£',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      // Inventory tracking section
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: trackInventory
                                ? charcoal
                                : Colors.grey.withValues(alpha: 0.2),
                            width: trackInventory ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 20,
                                  color: trackInventory
                                      ? charcoal
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Track Inventory',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        'Monitor stock levels',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: trackInventory,
                                  onChanged: (v) =>
                                      setDialogState(() => trackInventory = v),
                                  activeTrackColor: charcoal.withValues(
                                    alpha: 0.5,
                                  ),
                                  thumbColor: WidgetStateProperty.resolveWith(
                                    (states) =>
                                        states.contains(WidgetState.selected)
                                        ? charcoal
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            if (trackInventory && selectedPreset != null) ...[
                              const SizedBox(height: 14),
                              TextField(
                                controller: stockController,
                                decoration: _brandedInputDecoration(
                                  label: measureType == MeasurementType.weight
                                      ? 'Current Stock ($selectedWeightUnit)'
                                      : measureType == MeasurementType.whole
                                      ? 'Current Stock (bags)'
                                      : 'Current Stock (bales)',
                                  hint: measureType == MeasurementType.whole
                                      ? 'e.g. 10'
                                      : 'e.g. 10 or 10.5',
                                ),
                                keyboardType:
                                    measureType == MeasurementType.whole
                                    ? TextInputType.number
                                    : const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _cancelButton(),
                          const SizedBox(width: 12),
                          _primaryButton(
                            existing == null ? 'Add' : 'Save',
                            onPressed: selectedPreset == null
                                ? null
                                : () {
                                    String stockUnit, usageUnit;
                                    int ratio;

                                    if (measureType == MeasurementType.weight) {
                                      stockUnit = selectedWeightUnit;
                                      usageUnit = selectedPricePerUnit;
                                      ratio = 1; // Weight doesn't use ratio
                                    } else if (measureType ==
                                        MeasurementType.whole) {
                                      // Whole units like shavings bags - not divisible
                                      stockUnit = 'Bag';
                                      usageUnit = 'Bag';
                                      ratio = 1; // 1 bag = 1 bag
                                    } else {
                                      // Slices - divisible (hay, haylage, straw)
                                      stockUnit = 'Bale';
                                      usageUnit = 'Slice';
                                      ratio =
                                          int.tryParse(ratioController.text) ??
                                          8;
                                    }

                                    Navigator.pop(ctx, {
                                      'preset': selectedPreset,
                                      'brand': brandController.text.trim(),
                                      'desc': descController.text.trim(),
                                      'price':
                                          double.tryParse(
                                            priceController.text,
                                          ) ??
                                          0.0,
                                      'stockUnit': stockUnit,
                                      'usageUnit': usageUnit,
                                      'ratio': ratio,
                                      'trackInventory': trackInventory,
                                      'currentStock':
                                          double.tryParse(
                                            stockController.text,
                                          ) ??
                                          0.0,
                                    });
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
      ),
    );

    if (result != null && mounted) {
      final preset = result['preset'] as ConsumablePreset;
      final brand = result['brand'] as String?;
      final desc = result['desc'] as String?;
      final price = result['price'] as double;
      final stockUnit = result['stockUnit'] as String;
      final usageUnit = result['usageUnit'] as String;
      final ratio = result['ratio'] as int;
      final track = result['trackInventory'] as bool;
      final stock = result['currentStock'] as double;

      try {
        final item = ConsumableType(
          id: existing?.id ?? _uuid.v4(),
          yardId: widget.yardId,
          name: preset.displayName,
          stockUnit: stockUnit,
          usageUnit: usageUnit,
          ratio: ratio,
          pricePerUsageUnit: price,
          brand: brand?.isNotEmpty == true ? brand : null,
          description: desc?.isNotEmpty == true ? desc : null,
          trackInventory: track,
          currentStock: stock,
        );
        if (existing == null) {
          await _repository.createConsumable(item);
          if (mounted) SnackbarService.showSuccess(context, 'Consumable added');
        } else {
          await _repository.updateConsumable(item);
          if (mounted)
            SnackbarService.showSuccess(context, 'Consumable updated');
        }
        _loadData();
      } catch (e) {
        if (mounted) SnackbarService.showError(context, 'Failed to save');
      }
    }
  }

  Future<void> _deleteConsumable(ConsumableType item) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8F8F8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Consumable',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Are you sure you want to delete "${item.name}"?'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _cancelButton(),
                  const SizedBox(width: 12),
                  _deleteButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _repository.deleteConsumable(item.id);
        _loadData();
        if (mounted) SnackbarService.showSuccess(context, 'Deleted');
      } catch (e) {
        if (mounted) SnackbarService.showError(context, 'Failed to delete');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXTRAS DIALOGS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showAddEditExtraDialog([Extra? existing]) async {
    ExtraPreset? selectedPreset;
    String? customName;
    if (existing != null) {
      for (final p in ExtraPreset.values) {
        if (p.displayName == existing.name) {
          selectedPreset = p;
          break;
        }
      }
      if (selectedPreset == null) customName = existing.name;
    }

    final customNameController = TextEditingController(text: customName ?? '');
    final unitController = TextEditingController(
      text: existing?.unit ?? 'per session',
    );
    final priceController = TextEditingController(
      text: existing?.price.toStringAsFixed(2) ?? '0.00',
    );
    bool isRecurring = existing?.isRecurring ?? true;
    bool useCustom = customName != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: isDark
              ? const Color(0xFF1E293B)
              : const Color(0xFFF8F8F8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'Add Extra' : 'Edit Extra',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Additional chargeable services',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // Toggle preset/custom - charcoal selection
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => useCustom = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !useCustom
                                  ? const Color(0xFF1E1E1E)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: !useCustom
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Preset',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: !useCustom ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => useCustom = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: useCustom
                                  ? const Color(0xFF1E1E1E)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: useCustom
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Custom',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: useCustom ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!useCustom)
                    DropdownButtonFormField<ExtraPreset>(
                      value: selectedPreset,
                      decoration: _brandedDropdownDecoration(label: 'Service'),
                      hint: const Text('Select service'),
                      items: ExtraPreset.values
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() {
                        selectedPreset = v;
                        if (v != null) unitController.text = v.defaultUnit;
                      }),
                    )
                  else
                    TextField(
                      controller: customNameController,
                      decoration: _brandedInputDecoration(
                        label: 'Service Name',
                        hint: 'e.g. Clipping',
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: unitController,
                    decoration: _brandedInputDecoration(
                      label: 'Unit',
                      hint: 'e.g. per session',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    decoration: _brandedInputDecoration(
                      label: 'Price',
                      prefix: '£',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRecurring
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey.withValues(alpha: 0.2),
                        width: isRecurring ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Can be recurring',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Text(
                                'Add to monthly invoices',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isRecurring,
                          onChanged: (v) =>
                              setDialogState(() => isRecurring = v),
                          activeTrackColor: const Color(
                            0xFF1E1E1E,
                          ).withValues(alpha: 0.5),
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? const Color(0xFF1E1E1E)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _cancelButton(),
                      const SizedBox(width: 12),
                      _primaryButton(
                        existing == null ? 'Add' : 'Save',
                        onPressed: () {
                          final name = useCustom
                              ? customNameController.text.trim()
                              : selectedPreset?.displayName;
                          if (name == null || name.isEmpty) {
                            SnackbarService.showError(
                              ctx,
                              'Please select or enter a service',
                            );
                            return;
                          }
                          Navigator.pop(ctx, {
                            'name': name,
                            'unit': unitController.text.trim(),
                            'price':
                                double.tryParse(priceController.text) ?? 0.0,
                            'isRecurring': isRecurring,
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      try {
        final extra = Extra(
          id: existing?.id ?? _uuid.v4(),
          yardId: widget.yardId,
          name: result['name'] as String,
          price: result['price'] as double,
          unit: result['unit'] as String,
          isRecurring: result['isRecurring'] as bool,
        );
        if (existing == null) {
          await _repository.createExtra(extra);
          if (mounted) SnackbarService.showSuccess(context, 'Extra added');
        } else {
          await _repository.updateExtra(extra);
          if (mounted) SnackbarService.showSuccess(context, 'Extra updated');
        }
        _loadData();
      } catch (e) {
        debugPrint('Error saving extra: $e');
        if (mounted) SnackbarService.showError(context, 'Failed to save: $e');
      }
    }
  }

  Future<void> _deleteExtra(Extra extra) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFFF8F8F8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete Extra',
                style: Theme.of(
                  ctx,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Are you sure you want to delete "${extra.name}"?'),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _cancelButton(),
                  const SizedBox(width: 12),
                  _deleteButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _repository.deleteExtra(extra.id);
        _loadData();
        if (mounted) SnackbarService.showSuccess(context, 'Deleted');
      } catch (e) {
        if (mounted) SnackbarService.showError(context, 'Failed to delete');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PACKAGE DIALOGS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _showAddEditPackageDialog([LiveryPackage? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing?.basePrice.toStringAsFixed(2) ?? '0.00',
    );
    // Extract consumable IDs from existing includedItems
    final existingIds =
        existing?.includedItems
            .map((item) => item['consumable_id'] as String?)
            .whereType<String>()
            .toSet() ??
        <String>{};
    final selectedItems = Set<String>.from(existingIds);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Package' : 'Edit Package'),
          content: SingleChildScrollView(
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
                    labelText: 'Base Price (per month)',
                    prefixText: '£',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Included Extras',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (_consumables.isEmpty)
                  Text(
                    'No consumables configured yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  )
                else
                  ..._consumables.map(
                    (c) => CheckboxListTile(
                      title: Text(c.name),
                      subtitle: Text(
                        '£${c.pricePerUsageUnit.toStringAsFixed(2)}/${c.usageUnit}',
                      ),
                      value: selectedItems.contains(c.id),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            selectedItems.add(c.id);
                          } else {
                            selectedItems.remove(c.id);
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
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
      ),
    );

    if (result == true && mounted) {
      final name = nameController.text.trim();
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (name.isEmpty) {
        SnackbarService.showError(context, 'Please enter a package name');
        return;
      }

      // Convert selected IDs to the expected format
      final includedItemsList = selectedItems
          .map((id) => {'consumable_id': id})
          .toList();

      try {
        if (existing == null) {
          final pkg = LiveryPackage(
            id: _uuid.v4(),
            yardId: widget.yardId,
            name: name,
            basePrice: price,
            includedItems: includedItemsList,
          );
          await _repository.createPackage(pkg);
          if (mounted) SnackbarService.showSuccess(context, 'Package added');
        } else {
          final pkg = LiveryPackage(
            id: existing.id,
            yardId: existing.yardId,
            name: name,
            basePrice: price,
            includedItems: includedItemsList,
          );
          await _repository.updatePackage(pkg);
          if (mounted) SnackbarService.showSuccess(context, 'Package updated');
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          SnackbarService.showError(context, 'Failed to save package');
        }
      }
    }
  }

  Future<void> _deletePackage(LiveryPackage pkg) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Package'),
        content: Text('Delete "${pkg.name}"?'),
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
        _loadData();
        if (mounted) SnackbarService.showSuccess(context, 'Deleted');
      } catch (e) {
        if (mounted) SnackbarService.showError(context, 'Failed to delete');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INVOICE SETTINGS DIALOGS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _editBillingDay() async {
    final controller = TextEditingController(
      text: _invoiceSettings?.billingDay?.toString() ?? '1',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Billing Day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Day of month (1-28)',
                hintText: 'e.g. 1',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Invoices will be generated on this day each month',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final day = int.tryParse(controller.text);
      if (day == null || day < 1 || day > 28) {
        SnackbarService.showError(context, 'Please enter a day between 1-28');
        return;
      }
      await _saveInvoiceSettings(billingDay: day);
    }
  }

  Future<void> _editCutoffBuffer() async {
    final controller = TextEditingController(
      text: (_invoiceSettings?.cutoffBuffer ?? 5).toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cut-off Buffer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Days before billing',
                hintText: 'e.g. 5',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              'Services must be logged this many days before billing to be included',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final buffer = int.tryParse(controller.text);
      if (buffer == null || buffer < 0) {
        SnackbarService.showError(context, 'Please enter a valid number');
        return;
      }
      await _saveInvoiceSettings(cutoffBuffer: buffer);
    }
  }

  Future<void> _editBankDetails() async {
    final controller = TextEditingController(
      text: _invoiceSettings?.bankDetails ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bank Details'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Bank details',
            hintText: 'Account name, sort code, account number',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _saveInvoiceSettings(bankDetails: controller.text.trim());
    }
  }

  Future<void> _editPaymentTerms() async {
    final controller = TextEditingController(
      text: _invoiceSettings?.paymentTerms ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Terms'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Payment terms',
            hintText: 'e.g. Payment due within 14 days',
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _saveInvoiceSettings(paymentTerms: controller.text.trim());
    }
  }

  Future<void> _saveInvoiceSettings({
    int? billingDay,
    int? cutoffBuffer,
    String? bankDetails,
    String? paymentTerms,
  }) async {
    try {
      final settings = InvoiceSettings(
        id: _invoiceSettings?.id,
        yardId: widget.yardId,
        billingDay: billingDay ?? _invoiceSettings?.billingDay,
        cutoffBuffer: cutoffBuffer ?? _invoiceSettings?.cutoffBuffer ?? 5,
        bankDetails: bankDetails ?? _invoiceSettings?.bankDetails,
        paymentTerms: paymentTerms ?? _invoiceSettings?.paymentTerms,
      );

      await _repository.upsertInvoiceSettings(settings);

      _loadData();
      if (mounted) SnackbarService.showSuccess(context, 'Settings saved');
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to save settings');
      }
    }
  }
}

class _Section {
  const _Section({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String description;
}

/// Card with hover effect
class _HoverCard extends StatefulWidget {
  const _HoverCard({required this.child, required this.color, this.onTap});

  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.9)
                : widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          transform: _isHovered
              ? (Matrix4.identity()..setTranslationRaw(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Icon button with hover effect
class _HoverIconButton extends StatefulWidget {
  const _HoverIconButton({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? Colors.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _isHovered ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: baseColor.withValues(alpha: _isHovered ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }
}

/// Sidebar menu item with hover effect
class _HoverMenuItem extends StatefulWidget {
  const _HoverMenuItem({
    required this.child,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final Widget child;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<_HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<_HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Selected state takes priority over hover
    Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = const Color(0xFF1E1E1E); // Charcoal
    } else if (_isHovered) {
      backgroundColor = widget.isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05);
    } else {
      backgroundColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
