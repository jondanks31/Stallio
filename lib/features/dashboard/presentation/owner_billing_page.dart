import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/snackbar_service.dart';
import '../../billing/data/invoice_repository.dart';
import '../../billing/presentation/dialogs/edit_invoice_dialog.dart';
import '../../billing/presentation/dialogs/invoice_detail_dialog.dart';
import '../../user/data/billing_repository.dart';

/// Owner Billing page - shows all users' bills for invoicing
class OwnerBillingPage extends StatefulWidget {
  const OwnerBillingPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<OwnerBillingPage> createState() => _OwnerBillingPageState();
}

class _OwnerBillingPageState extends State<OwnerBillingPage>
    with SingleTickerProviderStateMixin {
  final _billingRepository = BillingRepository();
  final _invoiceRepository = InvoiceRepository();

  List<UserBillingSummary> _userBills = [];
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  final Set<String> _expandedUsers = {};

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    debugPrint('OwnerBillingPage: loading data for yard ${widget.yardId}');
    setState(() => _isLoading = true);
    try {
      final bills = await _billingRepository.getAllUsersBilling(widget.yardId);
      final invoices = await _invoiceRepository.getYardInvoices(widget.yardId);
      // Update overdue invoices
      await _invoiceRepository.updateOverdueInvoices(widget.yardId);

      debugPrint(
        'OwnerBillingPage: got ${bills.length} user bills, ${invoices.length} invoices',
      );
      if (mounted) {
        setState(() {
          _userBills = bills;
          _invoices = invoices;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('OwnerBillingPage error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markInvoicePaid(Invoice invoice) async {
    try {
      await _invoiceRepository.markInvoicePaid(invoice.id);
      if (mounted) {
        SnackbarService.showSuccess(context, 'Invoice marked as paid');
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update invoice');
      }
    }
  }

  Future<void> _showInvoiceDetail(Invoice invoice) async {
    await showInvoiceDetailDialog(
      context,
      invoice: invoice,
      isOwnerView: true,
      onMarkPaid: () => _markInvoicePaid(invoice),
      onEdit: () async {
        final changed = await showEditInvoiceDialog(context, invoice: invoice);
        if (changed == true) {
          _loadData();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (cycleStart, cycleEnd) = _billingRepository.getCurrentBillingCycle();

    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: const Color(0xFFFFD66B),
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black87,
            unselectedLabelColor: isDark ? Colors.white54 : Colors.black45,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            dividerHeight: 0,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calculate_outlined, size: 18),
                    const SizedBox(width: 8),
                    const Text('Current Period'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Invoices${_invoices.isNotEmpty ? ' (${_invoices.length})' : ''}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Current Period tab
              RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCycleHeader(isDark, cycleStart, cycleEnd),
                      const SizedBox(height: 24),
                      _buildSummaryStats(isDark),
                      const SizedBox(height: 24),
                      _buildUserBillsList(isDark),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              // Invoices tab
              RefreshIndicator(
                onRefresh: _loadData,
                child: _buildInvoicesTab(isDark),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoicesTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_invoices.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                const SizedBox(height: 16),
                Text(
                  'No invoices yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate invoices from the Current Period tab',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Group invoices by status
    final paidInvoices = _invoices
        .where((i) => i.status == InvoiceStatus.paid)
        .toList();
    final overdueInvoices = _invoices
        .where((i) => i.status == InvoiceStatus.overdue)
        .toList();
    final outstandingInvoices = _invoices
        .where((i) => i.status == InvoiceStatus.issued)
        .toList();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice stats
          _buildInvoiceStats(
            isDark,
            paidInvoices.length,
            outstandingInvoices.length,
            overdueInvoices.length,
          ),
          const SizedBox(height: 24),

          // Overdue section
          if (overdueInvoices.isNotEmpty) ...[
            _buildInvoiceSection(
              'Overdue',
              overdueInvoices,
              isDark,
              Colors.red,
            ),
            const SizedBox(height: 16),
          ],

          // Outstanding section
          if (outstandingInvoices.isNotEmpty) ...[
            _buildInvoiceSection(
              'Outstanding',
              outstandingInvoices,
              isDark,
              Colors.orange,
            ),
            const SizedBox(height: 16),
          ],

          // Paid section
          if (paidInvoices.isNotEmpty) ...[
            _buildInvoiceSection('Paid', paidInvoices, isDark, Colors.green),
          ],

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInvoiceStats(
    bool isDark,
    int paid,
    int outstanding,
    int overdue,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Paid',
            paid.toString(),
            Icons.check_circle_outline,
            isDark,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Outstanding',
            outstanding.toString(),
            Icons.schedule,
            isDark,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Overdue',
            overdue.toString(),
            Icons.warning_amber,
            isDark,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSection(
    String title,
    List<Invoice> invoices,
    bool isDark,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$title (${invoices.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...invoices.map((invoice) => _buildInvoiceCard(invoice, isDark)),
      ],
    );
  }

  Widget _buildInvoiceCard(Invoice invoice, bool isDark) {
    final dateFormat = DateFormat('d MMM');
    final currencyFormat = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        onTap: () => _showInvoiceDetail(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    invoice.status,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getStatusIcon(invoice.status),
                  color: _getStatusColor(invoice.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Invoice info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.userName ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${invoice.invoiceNumber ?? ""} • ${dateFormat.format(invoice.issueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(invoice.totalAmount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (invoice.dueDate != null && !invoice.isPaid)
                    Text(
                      'Due ${dateFormat.format(invoice.dueDate!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: invoice.isOverdue
                            ? Colors.red
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.issued:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.overdue:
        return Colors.red;
      case InvoiceStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Icons.edit_note;
      case InvoiceStatus.issued:
        return Icons.schedule;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.overdue:
        return Icons.warning;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
  }

  Widget _buildCycleHeader(bool isDark, DateTime start, DateTime end) {
    final dateFormat = DateFormat('d MMM');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD66B), Color(0xFFFFB347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Invoicing Period',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${dateFormat.format(start)} - ${dateFormat.format(end)} ${end.year}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_userBills.length} users with horses',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats(bool isDark) {
    final totalRevenue = _userBills.fold<double>(
      0,
      (sum, b) => sum + b.totalCost,
    );
    final totalConsumables = _userBills.fold<double>(
      0,
      (sum, b) => sum + b.consumablesCost,
    );
    final totalPackages = _userBills.fold<double>(
      0,
      (sum, b) => sum + b.packageCost,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Revenue',
            '£${totalRevenue.toStringAsFixed(2)}',
            Icons.payments_outlined,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Consumables',
            '£${totalConsumables.toStringAsFixed(2)}',
            Icons.inventory_2_outlined,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Packages',
            '£${totalPackages.toStringAsFixed(2)}',
            Icons.home_outlined,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    Color? color,
  }) {
    final iconColor = color ?? const Color(0xFFFFD66B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserBillsList(bool isDark) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userBills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              const SizedBox(height: 16),
              Text(
                'No users with horses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Bills',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...(_userBills.map((bill) => _buildUserBillCard(bill, isDark))),
      ],
    );
  }

  Widget _buildUserBillCard(UserBillingSummary bill, bool isDark) {
    final isExpanded = _expandedUsers.contains(bill.oderId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // User header - tappable to expand
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedUsers.remove(bill.oderId);
                } else {
                  _expandedUsers.add(bill.oderId);
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        bill.ownerName.isNotEmpty
                            ? bill.ownerName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD66B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and horse count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.ownerName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${bill.horseBreakdowns.length} horse${bill.horseBreakdowns.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '£${bill.totalCost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if (bill.packageName != null)
                        Text(
                          bill.packageName!,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          // Expanded horse breakdown
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white12
                  : Colors.black.withValues(alpha: 0.08),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package cost
                  if (bill.packageCost > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.home_outlined,
                            size: 16,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bill.packageName ?? 'Livery Package',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                          Text(
                            '£${bill.packageCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Horse breakdowns
                  ...bill.horseBreakdowns.map(
                    (horse) => _buildHorseBreakdown(horse, isDark),
                  ),
                  // Extras
                  if (bill.extras.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Extras',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...bill.extras.map(
                      (extra) => _buildExtraRow(extra, isDark),
                    ),
                  ],
                  // Note: Invoice generation happens at end of billing cycle
                  // or when user is marked as leaving (via People page)
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExtraRow(ExtraCharge extra, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              extra.name,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Text(
            '£${extra.price.toStringAsFixed(2)} ${extra.unit}',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '≈ £${extra.monthlyPrice.toStringAsFixed(2)}/mo',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorseBreakdown(HorseBillingSummary horse, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pets, size: 16, color: const Color(0xFFFFD66B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  horse.horseName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Text(
                '£${horse.consumablesCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          if (horse.charges.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...horse.charges
                .take(5)
                .map(
                  (charge) => Padding(
                    padding: const EdgeInsets.only(left: 24, top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${charge.consumableName} × ${charge.quantity.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ),
                        Text(
                          '£${charge.totalCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (horse.charges.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 4),
                child: Text(
                  '+ ${horse.charges.length - 5} more',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                ),
              ),
          ],
          if (horse.charges.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: Text(
                'No consumables logged',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
