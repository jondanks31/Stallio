import 'package:flutter/material.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../settings/data/settings_repository.dart';

/// Section displaying invoice settings.
class InvoicingSection extends StatelessWidget {
  const InvoicingSection({
    super.key,
    required this.settings,
    required this.onEditBillingDay,
    required this.onEditCutoffBuffer,
    required this.onEditBankDetails,
    required this.onEditPaymentTerms,
  });

  final InvoiceSettings? settings;
  final VoidCallback onEditBillingDay;
  final VoidCallback onEditCutoffBuffer;
  final VoidCallback onEditBankDetails;
  final VoidCallback onEditPaymentTerms;

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

  @override
  Widget build(BuildContext context) {
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
          _SettingCard(
            icon: Icons.calendar_today_outlined,
            title: 'Billing Schedule',
            children: [
              _SettingRow(
                label: 'Billing Day',
                value: settings?.billingDay != null
                    ? '${settings!.billingDay}${_getDaySuffix(settings!.billingDay!)} of each month'
                    : 'Not set',
                onEdit: onEditBillingDay,
              ),
              const Divider(height: 24),
              _SettingRow(
                label: 'Cut-off Buffer',
                value: '${settings?.cutoffBuffer ?? 5} days',
                onEdit: onEditCutoffBuffer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Payment info card
          _SettingCard(
            icon: Icons.account_balance_outlined,
            title: 'Payment Information',
            children: [
              _SettingRow(
                label: 'Bank Details',
                value: settings?.bankDetails ?? 'Not set',
                onEdit: onEditBankDetails,
              ),
              const Divider(height: 24),
              _SettingRow(
                label: 'Payment Terms',
                value: settings?.paymentTerms ?? 'Not set',
                onEdit: onEditPaymentTerms,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
                  color: BrandColors.yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: BrandColors.yellow),
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
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
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
}
