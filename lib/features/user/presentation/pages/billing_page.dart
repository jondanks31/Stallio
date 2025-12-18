import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../billing/data/invoice_repository.dart';
import '../../../billing/presentation/dialogs/invoice_detail_dialog.dart';
import '../../data/billing_repository.dart';

/// Billing page for regular yard members.
/// Shows current billing cycle, running total, breakdown, and invoice history.
class BillingPage extends StatefulWidget {
  const BillingPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<BillingPage> createState() => _BillingPageState();
}

class _BillingPageState extends State<BillingPage> {
  final _billingRepository = BillingRepository();
  final _invoiceRepository = InvoiceRepository();
  BillingSummary? _summary;
  List<Invoice> _invoices = [];
  bool _isLoading = true;
  bool _showConsumableDetails = false;

  @override
  void initState() {
    super.initState();
    _loadBilling();
  }

  Future<void> _loadBilling() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _billingRepository.getBillingSummary(widget.yardId);
      final invoices = await _invoiceRepository.getUserInvoices(widget.yardId);
      if (mounted) {
        setState(() {
          _summary = summary;
          _invoices = invoices;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading billing: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showInvoice(Invoice invoice) {
    showInvoiceDetailDialog(context, invoice: invoice, isOwnerView: false);
  }

  /// Get the current period's pending invoice (if any)
  Invoice? get _currentPeriodInvoice {
    if (_invoices.isEmpty || _summary == null) return null;

    // Find invoice for current billing period that's not paid
    return _invoices.cast<Invoice?>().firstWhere(
      (inv) =>
          inv != null &&
          inv.status != InvoiceStatus.paid &&
          inv.status != InvoiceStatus.cancelled &&
          inv.periodStart?.month == _summary!.cycleStart.month &&
          inv.periodStart?.year == _summary!.cycleStart.year,
      orElse: () => null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingInvoice = _currentPeriodInvoice;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current cycle card
          _buildCurrentCycleCard(isDark, pendingInvoice),
          const SizedBox(height: 20),

          // Pay Now button if invoice ready
          if (pendingInvoice != null) ...[
            _buildPayNowCard(isDark, pendingInvoice),
            const SizedBox(height: 20),
          ],

          // Running total / Invoice total
          _buildRunningTotal(isDark, pendingInvoice),
          const SizedBox(height: 20),

          // Breakdown
          _buildBreakdown(isDark),
          const SizedBox(height: 20),

          // Invoice history
          _buildInvoiceHistory(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPayNowCard(bool isDark, Invoice invoice) {
    final currencyFormat = NumberFormat.currency(symbol: '£', decimalDigits: 2);
    final isOverdue = invoice.isOverdue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isOverdue ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOverdue ? Icons.warning : Icons.receipt_long,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOverdue ? 'Payment Overdue' : 'Invoice Ready',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOverdue ? Colors.red : Colors.green.shade700,
                  ),
                ),
                Text(
                  'Amount due: ${currencyFormat.format(invoice.balanceDue)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showInvoice(invoice),
            style: ElevatedButton.styleFrom(
              backgroundColor: isOverdue ? Colors.red : const Color(0xFFFFD66B),
              foregroundColor: isOverdue ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCycleCard(bool isDark, Invoice? pendingInvoice) {
    final dateFormat = DateFormat('d MMM');
    final hasInvoice = pendingInvoice != null;
    final isOverdue = pendingInvoice?.isOverdue ?? false;

    // Calculate default billing cycle (1st to last day of current month)
    final now = DateTime.now();
    final defaultStart = DateTime(now.year, now.month, 1);
    final defaultEnd = DateTime(
      now.year,
      now.month + 1,
      0,
    ); // Last day of month

    // Use invoice period dates if available, otherwise use billing cycle
    final periodStart = hasInvoice && pendingInvoice.periodStart != null
        ? pendingInvoice.periodStart!
        : (_summary?.cycleStart ?? defaultStart);
    final periodEnd = hasInvoice && pendingInvoice.periodEnd != null
        ? pendingInvoice.periodEnd!
        : (_summary?.cycleEnd ?? defaultEnd);

    // Status badge configuration
    String statusText;
    Color statusBgColor;
    Color statusTextColor;

    if (isOverdue) {
      statusText = 'Overdue';
      statusBgColor = Colors.red;
      statusTextColor = Colors.white;
    } else if (hasInvoice) {
      statusText = 'Invoice Ready';
      statusBgColor = Colors.green;
      statusTextColor = Colors.white;
    } else {
      statusText = 'In Progress';
      statusBgColor = Colors.black.withValues(alpha: 0.1);
      statusTextColor = Colors.black87;
    }

    // Due date text
    String dueDateText;
    if (hasInvoice && pendingInvoice.dueDate != null) {
      dueDateText = isOverdue
          ? 'Was due: ${DateFormat('d MMMM yyyy').format(pendingInvoice.dueDate!)}'
          : 'Due: ${DateFormat('d MMMM yyyy').format(pendingInvoice.dueDate!)}';
    } else {
      final nextMonth = DateTime(periodEnd.year, periodEnd.month + 1, 5);
      dueDateText =
          'Invoice due: ${DateFormat('d MMMM yyyy').format(nextMonth)}';
    }

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasInvoice ? 'Invoice Period' : 'Current Billing Cycle',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${dateFormat.format(periodStart)} - ${dateFormat.format(periodEnd)} ${periodEnd.year}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dueDateText,
            style: TextStyle(
              fontSize: 13,
              color: isOverdue
                  ? Colors.red.shade800
                  : Colors.black.withValues(alpha: 0.6),
              fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunningTotal(bool isDark, Invoice? pendingInvoice) {
    final hasInvoice = pendingInvoice != null;
    final total = hasInvoice
        ? pendingInvoice.totalAmount
        : (_summary?.totalCost ?? 0);
    final isLoading = _isLoading;

    // Dynamic text based on invoice state
    final headerText = hasInvoice ? 'Invoice Total' : 'Estimated Bill So Far';
    final footerText = hasInvoice
        ? 'Your invoice has been generated and is ready for payment'
        : 'Based on your package and consumables used so far';
    final icon = hasInvoice ? Icons.receipt : Icons.trending_up;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                headerText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isLoading ? '£--' : '£${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  hasInvoice ? 'due' : 'this month',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            footerText,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(bool isDark) {
    final packageCost = _summary?.packageCost ?? 0;
    final packageName = _summary?.packageName ?? 'Livery Package';
    final consumablesCost = _summary?.consumablesCost ?? 0;
    final extrasCost = _summary?.extrasCost ?? 0;
    final total = _summary?.totalCost ?? 0;
    final charges = _summary?.consumableCharges ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildBreakdownItem(
            packageName,
            '£${packageCost.toStringAsFixed(2)}',
            Icons.home_outlined,
            isDark,
          ),
          const Divider(height: 24),
          _buildBreakdownItem(
            'Extras',
            '£${extrasCost.toStringAsFixed(2)}',
            Icons.add_circle_outline,
            isDark,
            isExpandable: false,
          ),
          const Divider(height: 24),
          GestureDetector(
            onTap: charges.isNotEmpty
                ? () => setState(
                    () => _showConsumableDetails = !_showConsumableDetails,
                  )
                : null,
            child: _buildBreakdownItem(
              'Consumables (${charges.length})',
              '£${consumablesCost.toStringAsFixed(2)}',
              Icons.inventory_2_outlined,
              isDark,
              isExpandable: charges.isNotEmpty,
              isExpanded: _showConsumableDetails,
            ),
          ),
          // Consumable details
          if (_showConsumableDetails && charges.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: charges.take(10).map((charge) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${charge.horseName} - ${charge.consumableName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        Text(
                          '${charge.quantity.toStringAsFixed(1)} ${charge.unit}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '£${charge.totalCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            if (charges.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${charges.length - 10} more entries',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  '£${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label,
    String amount,
    IconData icon,
    bool isDark, {
    bool isExpandable = false,
    bool isExpanded = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        if (isExpandable) ...[
          const SizedBox(width: 8),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 20,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ],
      ],
    );
  }

  Widget _buildInvoiceHistory(bool isDark) {
    final dateFormat = DateFormat('d MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice History',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        if (_invoices.isEmpty)
          // Empty state
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
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
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No invoices yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your invoice history will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Invoice list
          ..._invoices.map(
            (invoice) =>
                _buildInvoiceCard(invoice, isDark, dateFormat, currencyFormat),
          ),
      ],
    );
  }

  Widget _buildInvoiceCard(
    Invoice invoice,
    bool isDark,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: InkWell(
        onTap: () => _showInvoice(invoice),
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
                      invoice.invoiceNumber ?? 'Invoice',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      dateFormat.format(invoice.issueDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              // Amount and status
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        invoice.status,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      invoice.status.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(invoice.status),
                      ),
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
}
