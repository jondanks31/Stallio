import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/gradient_background.dart';
import '../../../../core/ui/hover_widgets.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../settings/data/settings_repository.dart';
import '../dialogs/consumable_dialog.dart';
import '../dialogs/extra_dialog.dart';
import '../dialogs/invoice_settings_dialogs.dart';
import '../dialogs/package_dialog.dart';
import '../../data/facilities_repository.dart';
import '../dialogs/facility_dialog.dart';
import '../widgets/consumables_section.dart';
import '../widgets/extras_section.dart';
import '../widgets/facilities_section.dart';
import '../widgets/general_section.dart';
import '../widgets/invoicing_section.dart';
import '../widgets/packages_section.dart';

/// Yard management page with sidebar navigation for desktop
/// and stacked sections for mobile.
class YardManagementPage extends StatefulWidget {
  const YardManagementPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<YardManagementPage> createState() => _YardManagementPageState();
}

class _YardManagementPageState extends State<YardManagementPage> {
  final _repository = SettingsRepository();
  final _facilitiesRepository = FacilitiesRepository();
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  int _selectedSection = 0;
  bool _isLoading = true;

  List<ConsumableType> _consumables = [];
  List<Extra> _extras = [];
  List<LiveryPackage> _packages = [];
  List<Facility> _facilities = [];
  InvoiceSettings? _invoiceSettings;
  YardBranding _branding = const YardBranding();

  static const _sections = [
    _Section(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'General',
      description: 'Yard branding & settings',
    ),
    _Section(
      icon: Icons.fence_outlined,
      activeIcon: Icons.fence,
      label: 'Facilities',
      description: 'Arenas, walkers & amenities',
    ),
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
      final facilities = await _facilitiesRepository.getFacilities(
        widget.yardId,
      );
      final invoiceSettings = await _repository.getInvoiceSettings(
        widget.yardId,
      );

      // Load branding
      final yardData = await _supabase
          .from('yards')
          .select('logo_type, logo_text, logo_url')
          .eq('id', widget.yardId)
          .single();
      final branding = YardBranding.fromJson(yardData);

      if (mounted) {
        setState(() {
          _consumables = consumables;
          _extras = extras;
          _packages = packages;
          _facilities = facilities;
          _invoiceSettings = invoiceSettings;
          _branding = branding;
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

    return HoverMenuItem(
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
          color: isSelected ? BrandColors.yellow : Colors.white,
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
        return GeneralSection(
          yardId: widget.yardId,
          branding: _branding,
          onBrandingChanged: (branding) {
            setState(() => _branding = branding);
          },
        );
      case 1:
        return FacilitiesSection(
          facilities: _facilities,
          onAdd: () => _handleAddEditFacility(),
          onEdit: (facility) => _handleAddEditFacility(facility),
          onDelete: _handleDeleteFacility,
          onToggleActive: _handleToggleFacilityActive,
        );
      case 2:
        return ConsumablesSection(
          consumables: _consumables,
          onAdd: () => _handleAddEditConsumable(),
          onEdit: (item) => _handleAddEditConsumable(item),
          onDelete: _handleDeleteConsumable,
        );
      case 3:
        return ExtrasSection(
          extras: _extras,
          onAdd: () => _handleAddEditExtra(),
          onEdit: (extra) => _handleAddEditExtra(extra),
          onDelete: _handleDeleteExtra,
        );
      case 4:
        return PackagesSection(
          packages: _packages,
          onAdd: () => _handleAddEditPackage(),
          onEdit: (pkg) => _handleAddEditPackage(pkg),
          onDelete: _handleDeletePackage,
        );
      case 5:
        return InvoicingSection(
          settings: _invoiceSettings,
          onEditBillingDay: _handleEditBillingDay,
          onEditCutoffBuffer: _handleEditCutoffBuffer,
          onEditBankDetails: _handleEditBankDetails,
          onEditPaymentTerms: _handleEditPaymentTerms,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FACILITY HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleAddEditFacility([Facility? existing]) async {
    final result = await showFacilityDialog(
      context: context,
      existing: existing,
    );

    if (result != null && mounted) {
      try {
        final facility = Facility(
          id: existing?.id ?? _uuid.v4(),
          yardId: widget.yardId,
          name: result['name'] as String,
          type: result['type'] as FacilityType,
          description: result['description'] as String?,
          slotDurationMinutes: result['slotDuration'] as int,
          maxDailyBookingsPerUser: result['maxDailyBookings'] as int?,
          advanceBookingDays: result['advanceBookingDays'] as int,
          isActive: result['isActive'] as bool,
          createdAt: existing?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (existing == null) {
          await _facilitiesRepository.createFacility(facility);
          if (mounted) SnackbarService.showSuccess(context, 'Facility added');
        } else {
          await _facilitiesRepository.updateFacility(facility);
          if (mounted) SnackbarService.showSuccess(context, 'Facility updated');
        }
        _loadData();
      } catch (e) {
        if (mounted) {
          SnackbarService.showError(context, 'Failed to save facility');
        }
      }
    }
  }

  Future<void> _handleDeleteFacility(Facility facility) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Facility'),
        content: Text('Are you sure you want to delete "${facility.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _facilitiesRepository.deleteFacility(facility.id);
        if (!mounted) return;
        SnackbarService.showSuccess(context, 'Facility deleted');
        _loadData();
      } catch (e) {
        if (!mounted) return;
        SnackbarService.showError(context, 'Failed to delete facility');
      }
    }
  }

  Future<void> _handleToggleFacilityActive(Facility facility) async {
    try {
      final updated = Facility(
        id: facility.id,
        yardId: facility.yardId,
        name: facility.name,
        type: facility.type,
        description: facility.description,
        slotDurationMinutes: facility.slotDurationMinutes,
        maxDailyBookingsPerUser: facility.maxDailyBookingsPerUser,
        advanceBookingDays: facility.advanceBookingDays,
        isActive: !facility.isActive,
        createdAt: facility.createdAt,
        updatedAt: DateTime.now(),
      );
      await _facilitiesRepository.updateFacility(updated);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          facility.isActive ? 'Facility deactivated' : 'Facility activated',
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update facility');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CONSUMABLE HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleAddEditConsumable([ConsumableType? existing]) async {
    final result = await showConsumableDialog(
      context: context,
      existing: existing,
    );

    if (result != null && mounted) {
      final preset = result['preset'] as ConsumablePreset;
      try {
        final item = ConsumableType(
          id: existing?.id ?? _uuid.v4(),
          yardId: widget.yardId,
          name: preset.displayName,
          stockUnit: result['stockUnit'] as String,
          usageUnit: result['usageUnit'] as String,
          ratio: result['ratio'] as int,
          pricePerUsageUnit: result['price'] as double,
          brand: (result['brand'] as String?)?.isNotEmpty == true
              ? result['brand'] as String
              : null,
          description: (result['desc'] as String?)?.isNotEmpty == true
              ? result['desc'] as String
              : null,
          trackInventory: result['trackInventory'] as bool,
          currentStock: result['currentStock'] as double,
        );

        if (existing == null) {
          await _repository.createConsumable(item);
          if (mounted) SnackbarService.showSuccess(context, 'Consumable added');
        } else {
          await _repository.updateConsumable(item);
          if (mounted) {
            SnackbarService.showSuccess(context, 'Consumable updated');
          }
        }
        _loadData();
      } catch (e) {
        if (mounted) SnackbarService.showError(context, 'Failed to save');
      }
    }
  }

  Future<void> _handleDeleteConsumable(ConsumableType item) async {
    final confirm = await showDeleteConfirmDialog(
      context: context,
      title: 'Delete Consumable',
      message: 'Are you sure you want to delete "${item.name}"?',
    );

    if (confirm && mounted) {
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
  // EXTRA HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleAddEditExtra([Extra? existing]) async {
    final result = await showExtraDialog(context: context, existing: existing);

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

  Future<void> _handleDeleteExtra(Extra extra) async {
    final confirm = await showDeleteConfirmDialog(
      context: context,
      title: 'Delete Extra',
      message: 'Are you sure you want to delete "${extra.name}"?',
    );

    if (confirm && mounted) {
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
  // PACKAGE HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleAddEditPackage([LiveryPackage? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing?.basePrice.toStringAsFixed(2) ?? '0.00',
    );
    final existingIds =
        existing?.includedItems
            .map((item) => item['consumable_id'] as String?)
            .whereType<String>()
            .toSet() ??
        <String>{};
    final selectedItems = Set<String>.from(existingIds);

    final result = await showPackageDialog(
      context: context,
      consumables: _consumables,
      existing: existing,
      nameController: nameController,
      priceController: priceController,
      selectedItems: selectedItems,
    );

    if (result && mounted) {
      final name = nameController.text.trim();
      final price = double.tryParse(priceController.text) ?? 0.0;

      if (name.isEmpty) {
        SnackbarService.showError(context, 'Please enter a package name');
        return;
      }

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

  Future<void> _handleDeletePackage(LiveryPackage pkg) async {
    final confirm = await showDeletePackageDialog(
      context: context,
      package: pkg,
    );

    if (confirm && mounted) {
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
  // INVOICE SETTINGS HANDLERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _handleEditBillingDay() async {
    final day = await showBillingDayDialog(
      context: context,
      currentDay: _invoiceSettings?.billingDay,
    );

    if (day != null) {
      await _saveInvoiceSettings(billingDay: day);
    } else if (mounted) {
      SnackbarService.showError(context, 'Please enter a day between 1-28');
    }
  }

  Future<void> _handleEditCutoffBuffer() async {
    final buffer = await showCutoffBufferDialog(
      context: context,
      currentBuffer: _invoiceSettings?.cutoffBuffer ?? 5,
    );

    if (buffer != null) {
      await _saveInvoiceSettings(cutoffBuffer: buffer);
    } else if (mounted) {
      SnackbarService.showError(context, 'Please enter a valid number');
    }
  }

  Future<void> _handleEditBankDetails() async {
    final details = await showBankDetailsDialog(
      context: context,
      currentDetails: _invoiceSettings?.bankDetails,
    );

    if (details != null) {
      await _saveInvoiceSettings(bankDetails: details);
    }
  }

  Future<void> _handleEditPaymentTerms() async {
    final terms = await showPaymentTermsDialog(
      context: context,
      currentTerms: _invoiceSettings?.paymentTerms,
    );

    if (terms != null) {
      await _saveInvoiceSettings(paymentTerms: terms);
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
