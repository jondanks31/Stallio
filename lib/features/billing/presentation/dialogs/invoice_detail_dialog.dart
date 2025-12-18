import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../data/invoice_repository.dart';

/// Shows invoice detail dialog
Future<void> showInvoiceDetailDialog(
  BuildContext context, {
  required Invoice invoice,
  bool isOwnerView = false,
  VoidCallback? onMarkPaid,
  VoidCallback? onEdit,
}) async {
  return showDialog(
    context: context,
    builder: (context) => _InvoiceDetailDialog(
      invoice: invoice,
      isOwnerView: isOwnerView,
      onMarkPaid: onMarkPaid,
      onEdit: onEdit,
    ),
  );
}

class _InvoiceDetailDialog extends StatelessWidget {
  const _InvoiceDetailDialog({
    required this.invoice,
    required this.isOwnerView,
    this.onMarkPaid,
    this.onEdit,
  });

  final Invoice invoice;
  final bool isOwnerView;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Dialog(
      backgroundColor: isDark
          ? BrandColors.dialogBgDark
          : BrandColors.dialogBgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, isDark, dateFormat),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    _buildStatusBadge(isDark),
                    const SizedBox(height: 20),

                    // Period info
                    if (invoice.periodStart != null &&
                        invoice.periodEnd != null)
                      _buildInfoRow(
                        'Billing Period',
                        '${dateFormat.format(invoice.periodStart!)} - ${dateFormat.format(invoice.periodEnd!)}',
                        isDark,
                      ),
                    _buildInfoRow(
                      'Issue Date',
                      dateFormat.format(invoice.issueDate),
                      isDark,
                    ),
                    if (invoice.dueDate != null)
                      _buildInfoRow(
                        'Due Date',
                        dateFormat.format(invoice.dueDate!),
                        isDark,
                        isWarning: invoice.isOverdue,
                      ),
                    const SizedBox(height: 20),

                    // Line items
                    _buildLineItemsSection(isDark, currencyFormat),
                    const SizedBox(height: 20),

                    // Totals
                    _buildTotalsSection(isDark, currencyFormat),
                  ],
                ),
              ),
            ),

            // Footer with actions
            _buildFooter(context, isDark, currencyFormat),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    DateFormat dateFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(invoice.status).withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getStatusColor(invoice.status).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.receipt_long,
              color: _getStatusColor(invoice.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.invoiceNumber ?? 'Invoice',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (invoice.userName != null && isOwnerView)
                  Text(
                    invoice.userName!,
                    style: TextStyle(
                      fontSize: 13,
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
    );
  }

  Widget _buildStatusBadge(bool isDark) {
    final color = _getStatusColor(invoice.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(invoice.status), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            invoice.status.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isWarning
                  ? Colors.red
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsSection(bool isDark, NumberFormat currencyFormat) {
    // Group line items by type
    final packageItems = invoice.lineItems
        .where((i) => i.lineType == LineItemType.package)
        .toList();
    final consumableItems = invoice.lineItems
        .where((i) => i.lineType == LineItemType.consumable)
        .toList();
    final extraItems = invoice.lineItems
        .where((i) => i.lineType == LineItemType.extra)
        .toList();
    final adjustmentItems = invoice.lineItems
        .where(
          (i) =>
              i.lineType == LineItemType.adjustment ||
              i.lineType == LineItemType.credit,
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Line Items',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        if (packageItems.isNotEmpty) ...[
          _buildItemGroup(
            'Livery Package',
            packageItems,
            isDark,
            currencyFormat,
          ),
          const SizedBox(height: 12),
        ],

        if (consumableItems.isNotEmpty) ...[
          _buildItemGroup(
            'Consumables',
            consumableItems,
            isDark,
            currencyFormat,
          ),
          const SizedBox(height: 12),
        ],

        if (extraItems.isNotEmpty) ...[
          _buildItemGroup('Extras', extraItems, isDark, currencyFormat),
          const SizedBox(height: 12),
        ],

        if (adjustmentItems.isNotEmpty) ...[
          _buildItemGroup(
            'Adjustments',
            adjustmentItems,
            isDark,
            currencyFormat,
          ),
        ],

        if (invoice.lineItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No line items',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildItemGroup(
    String title,
    List<InvoiceLineItem> items,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ),
          ...items.map(
            (item) => _buildLineItemRow(item, isDark, currencyFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemRow(
    InvoiceLineItem item,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final isCredit =
        item.lineType == LineItemType.credit || item.totalPrice < 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (item.horseName != null)
                  Text(
                    item.horseName!,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.quantity != 1)
            Text(
              '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} × ${currencyFormat.format(item.unitPrice)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            '${isCredit ? '-' : ''}${currencyFormat.format(item.totalPrice.abs())}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isCredit
                  ? Colors.green
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection(bool isDark, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', invoice.subtotal, isDark, currencyFormat),
          if (invoice.taxAmount > 0)
            _buildTotalRow('Tax', invoice.taxAmount, isDark, currencyFormat),
          if (invoice.discountAmount > 0)
            _buildTotalRow(
              'Discount',
              -invoice.discountAmount,
              isDark,
              currencyFormat,
              isDiscount: true,
            ),
          const Divider(height: 16),
          _buildTotalRow(
            'Total',
            invoice.totalAmount,
            isDark,
            currencyFormat,
            isBold: true,
          ),
          if (invoice.amountPaid > 0 &&
              invoice.amountPaid < invoice.totalAmount) ...[
            _buildTotalRow(
              'Amount Paid',
              invoice.amountPaid,
              isDark,
              currencyFormat,
              isDiscount: true,
            ),
            _buildTotalRow(
              'Balance Due',
              invoice.balanceDue,
              isDark,
              currencyFormat,
              isBold: true,
              isWarning: invoice.isOverdue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount,
    bool isDark,
    NumberFormat currencyFormat, {
    bool isBold = false,
    bool isDiscount = false,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          Text(
            '${isDiscount && amount > 0 ? '-' : ''}${currencyFormat.format(amount.abs())}',
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isWarning
                  ? Colors.red
                  : (isDiscount
                        ? Colors.green
                        : (isDark ? Colors.white : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    final showPayButton = !invoice.isPaid && !isOwnerView;
    final showOwnerActions =
        isOwnerView && invoice.status != InvoiceStatus.cancelled;

    if (!showPayButton && !showOwnerActions) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[50],
        border: Border(
          top: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Row(
        children: [
          if (!invoice.isPaid)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount Due',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  Text(
                    currencyFormat.format(invoice.balanceDue),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: invoice.isOverdue
                          ? Colors.red
                          : BrandColors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          if (showPayButton) ...[
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement payment flow
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment integration coming soon!'),
                  ),
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text('Pay Invoice'),
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.yellow,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          if (showOwnerActions) ...[
            if (onEdit != null)
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit!();
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            const SizedBox(width: 8),
            if (!invoice.isPaid && onMarkPaid != null)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onMarkPaid!();
                },
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark Paid'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.issued:
        return Colors.blue;
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
        return Icons.send;
      case InvoiceStatus.paid:
        return Icons.check_circle;
      case InvoiceStatus.overdue:
        return Icons.warning;
      case InvoiceStatus.cancelled:
        return Icons.cancel;
    }
  }
}
