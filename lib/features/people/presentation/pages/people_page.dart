import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../billing/data/invoice_repository.dart';
import '../../../staff/presentation/pages/team_assignments_page.dart';
import '../../data/people_repository.dart';
import '../dialogs/invite_dialog.dart';
import '../dialogs/manage_billing_dialog.dart';
import '../widgets/people_stats_bar.dart';
import '../widgets/person_row.dart';

/// People management page - displays all yard members and invites.
class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key, required this.yardId});

  final String yardId;

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  final _repository = PeopleRepository();
  final _invoiceRepository = InvoiceRepository();

  List<YardPerson> _people = [];
  Map<String, int> _counts = {'active': 0, 'invited': 0, 'pending': 0};
  bool _isLoading = true;
  String _searchQuery = '';
  YardRole? _roleFilter;
  PersonStatus? _statusFilter;
  String? _expandedPersonId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final people = await _repository.getPeopleInYard(widget.yardId);
      final counts = await _repository.getPeopleCounts(widget.yardId);
      if (mounted) {
        setState(() {
          _people = people;
          _counts = counts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading people: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load people');
      }
    }
  }

  List<YardPerson> get _filteredPeople {
    return _people.where((person) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName =
            person.fullName?.toLowerCase().contains(query) ?? false;
        final matchesEmail =
            person.email?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesEmail) return false;
      }

      // Role filter
      if (_roleFilter != null && person.role != _roleFilter) return false;

      // Status filter
      if (_statusFilter != null && person.status != _statusFilter) return false;

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme, isDark, isDesktop),
            const SizedBox(height: 24),

            // Stats bar
            PeopleStatsBar(
              activeCount: _counts['active'] ?? 0,
              invitedCount: _counts['invited'] ?? 0,
            ),
            const SizedBox(height: 24),

            // Filters and search
            _buildFiltersRow(theme, isDark, isDesktop),
            const SizedBox(height: 16),

            // Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPeopleTable(theme, isDark, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark, bool isDesktop) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'People',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(height: 4),
                Text(
                  'Manage your yard members and invites',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Team / Directory / Org Chat buttons
            if (isDesktop) ...[
              _buildHeaderButton(
                'Team',
                Icons.groups_outlined,
                isDark,
                onTap: () => _showTeamAssignments(),
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                'Directory',
                Icons.folder_outlined,
                isDark,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _buildHeaderButton(
                'Insights',
                Icons.insights_outlined,
                isDark,
                onTap: () {},
              ),
              const SizedBox(width: 16),
            ],
            // Add button
            FilledButton.icon(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.add, size: 18),
              label: Text(isDesktop ? 'Invite' : ''),
              style: FilledButton.styleFrom(
                backgroundColor: BrandColors.yellow,
                foregroundColor: Colors.black87,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 12,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderButton(
    String label,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow(ThemeData theme, bool isDark, bool isDesktop) {
    if (!isDesktop) {
      // Mobile: Stack filters and search vertically
      return Column(
        children: [
          Row(
            children: [
              _buildFilterChip(
                label: 'Role',
                value: _roleFilter?.displayName,
                onTap: () => _showRoleFilterMenu(),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'Status',
                value: _statusFilter?.displayName,
                onTap: () => _showStatusFilterMenu(),
                isDark: isDark,
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Role filter
        _buildFilterChip(
          label: 'Role',
          value: _roleFilter?.displayName,
          onTap: () => _showRoleFilterMenu(),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        // Status filter
        _buildFilterChip(
          label: 'Status',
          value: _statusFilter?.displayName,
          onTap: () => _showStatusFilterMenu(),
          isDark: isDark,
        ),
        const Spacer(),
        // Search
        SizedBox(
          width: 250,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.view_column_outlined),
            style: IconButton.styleFrom(
              foregroundColor: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export',
            style: IconButton.styleFrom(
              foregroundColor: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    String? value,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value != null
              ? BrandColors.yellow.withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value != null
                ? BrandColors.yellow
                : (isDark ? Colors.white12 : Colors.black12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value ?? label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: value != null ? FontWeight.w600 : FontWeight.normal,
                color: value != null
                    ? BrandColors.charcoal
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: value != null
                  ? BrandColors.charcoal
                  : (isDark ? Colors.white54 : Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleTable(ThemeData theme, bool isDark, bool isDesktop) {
    final filtered = _filteredPeople;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _people.isEmpty ? 'No people yet' : 'No results found',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _people.isEmpty
                  ? 'Invite team members and customers to get started'
                  : 'Try adjusting your filters',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          // Table header
          if (isDesktop) _buildTableHeader(theme, isDark),
          // Table rows
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.05),
              ),
              itemBuilder: (context, index) {
                final person = filtered[index];
                final isExpanded = _expandedPersonId == person.id;
                return PersonRow(
                  person: person,
                  isExpanded: isExpanded,
                  isDesktop: isDesktop,
                  onTap: () => setState(() {
                    _expandedPersonId = isExpanded ? null : person.id;
                  }),
                  onEdit: () => _editPerson(person),
                  onResendInvite: person.status == PersonStatus.invited
                      ? () => _resendInvite(person)
                      : null,
                  onRemove: () => _removePerson(person),
                  onSetLeavingDate: () => _showSetLeavingDateDialog(person),
                  onClearLeavingDate: () => _clearLeavingDate(person),
                  onGenerateFinalInvoice: () => _generateFinalInvoice(person),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(ThemeData theme, bool isDark) {
    final headerStyle = theme.textTheme.labelSmall?.copyWith(
      color: isDark ? Colors.white54 : Colors.black45,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
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
          // Checkbox placeholder
          const SizedBox(width: 40),
          Expanded(flex: 2, child: Text('Name', style: headerStyle)),
          Expanded(flex: 1, child: Text('Role', style: headerStyle)),
          Expanded(flex: 1, child: Text('Package', style: headerStyle)),
          Expanded(flex: 1, child: Text('Horses', style: headerStyle)),
          Expanded(flex: 1, child: Text('Stable No.', style: headerStyle)),
          Expanded(flex: 1, child: Text('Contact', style: headerStyle)),
          Expanded(flex: 1, child: Text('Vet', style: headerStyle)),
          Expanded(flex: 1, child: Text('Status', style: headerStyle)),
          // Actions placeholder
          const SizedBox(width: 80),
        ],
      ),
    );
  }

  void _showRoleFilterMenu() {
    showMenu<YardRole?>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 200, 0, 0),
      items: [
        const PopupMenuItem(value: null, child: Text('All Roles')),
        ...YardRole.values.map(
          (role) => PopupMenuItem(value: role, child: Text(role.displayName)),
        ),
      ],
    ).then((value) {
      if (value != _roleFilter) {
        setState(() => _roleFilter = value);
      }
    });
  }

  void _showStatusFilterMenu() {
    showMenu<PersonStatus?>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 200, 0, 0),
      items: [
        const PopupMenuItem(value: null, child: Text('All Statuses')),
        ...PersonStatus.values.map(
          (status) =>
              PopupMenuItem(value: status, child: Text(status.displayName)),
        ),
      ],
    ).then((value) {
      if (value != _statusFilter) {
        setState(() => _statusFilter = value);
      }
    });
  }

  Future<void> _showInviteDialog() async {
    final result = await showInviteDialog(
      context: context,
      yardId: widget.yardId,
    );

    if (result != null && mounted) {
      SnackbarService.showSuccess(
        context,
        'Invite sent! Code: ${result.inviteCode}',
      );
      _loadData();
    }
  }

  Future<void> _editPerson(YardPerson person) async {
    // Only show billing management for users with horses
    if (person.role == YardRole.user && person.status == PersonStatus.active) {
      final result = await showManageBillingDialog(
        context,
        yardId: widget.yardId,
        person: person,
      );
      if (result == true) {
        _loadData();
      }
    } else {
      SnackbarService.showInfo(context, 'Edit person coming soon');
    }
  }

  Future<void> _resendInvite(YardPerson person) async {
    try {
      final invite = await _repository.resendInvite(person.id);
      if (mounted) {
        SnackbarService.showSuccess(
          context,
          'Invite resent! New code: ${invite.inviteCode}',
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to resend invite');
      }
    }
  }

  void _showTeamAssignments() {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TeamAssignmentsPage(yardId: widget.yardId),
            ),
          ),
        );
      },
    );
  }

  Future<void> _removePerson(YardPerson person) async {
    final confirm = await showDeleteConfirmDialog(
      context: context,
      title: person.status == PersonStatus.invited
          ? 'Revoke Invite'
          : 'Remove Person',
      message: person.status == PersonStatus.invited
          ? 'Are you sure you want to revoke the invite for ${person.email}?'
          : 'Are you sure you want to remove ${person.fullName ?? person.email} from the yard?',
    );

    if (confirm && mounted) {
      try {
        if (person.status == PersonStatus.invited) {
          await _repository.revokeInvite(person.id);
        } else {
          await _repository.removePerson(person.id);
        }
        if (!mounted) return;
        SnackbarService.showSuccess(context, 'Removed successfully');
        _loadData();
      } catch (e) {
        if (!mounted) return;
        SnackbarService.showError(context, 'Failed to remove');
      }
    }
  }

  Future<void> _showSetLeavingDateDialog(YardPerson person) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default to 2 weeks from now
    final initialDate = DateTime.now().add(const Duration(days: 14));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select leaving date for ${person.fullName ?? person.email}',
      confirmText: 'Set Leaving Date',
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: BrandColors.yellow,
              onPrimary: Colors.black87,
              surface: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && mounted) {
      try {
        await _repository.setLeavingDate(person.id, selectedDate);
        if (!mounted) return;
        SnackbarService.showSuccess(
          context,
          'Leaving date set for ${person.fullName ?? person.email}',
        );
        _loadData();
      } catch (e) {
        if (!mounted) return;
        SnackbarService.showError(context, 'Failed to set leaving date');
      }
    }
  }

  Future<void> _clearLeavingDate(YardPerson person) async {
    final confirm = await showDeleteConfirmDialog(
      context: context,
      title: 'Cancel Departure',
      message:
          'Are you sure you want to cancel the scheduled departure for ${person.fullName ?? person.email}?',
    );

    if (confirm && mounted) {
      try {
        await _repository.clearLeavingDate(person.id);
        if (!mounted) return;
        SnackbarService.showSuccess(context, 'Departure cancelled');
        _loadData();
      } catch (e) {
        if (!mounted) return;
        SnackbarService.showError(context, 'Failed to cancel departure');
      }
    }
  }

  Future<void> _generateFinalInvoice(YardPerson person) async {
    if (person.leavingDate == null) {
      SnackbarService.showError(context, 'No leaving date set');
      return;
    }

    final confirm = await showDeleteConfirmDialog(
      context: context,
      title: 'Generate Final Invoice',
      message:
          'Generate a pro-rated final invoice for ${person.fullName ?? person.email}?\n\nThis will include package costs pro-rated to ${person.leavingDate!.day}/${person.leavingDate!.month} and any consumables for this period.',
    );

    if (confirm && mounted) {
      try {
        final invoice = await _invoiceRepository.generateFinalInvoice(
          yardId: widget.yardId,
          userId: person.id,
          leavingDate: person.leavingDate!,
        );

        // Update the user's leaving status and final invoice reference
        await _repository.updateLeavingStatus(
          person.id,
          LeavingStatus.pendingPayment,
          finalInvoiceId: invoice.id,
        );

        if (!mounted) return;
        SnackbarService.showSuccess(
          context,
          'Final invoice generated: £${invoice.totalAmount.toStringAsFixed(2)}',
        );
        _loadData();
      } catch (e) {
        if (!mounted) return;
        SnackbarService.showError(context, 'Failed to generate invoice: $e');
      }
    }
  }
}
