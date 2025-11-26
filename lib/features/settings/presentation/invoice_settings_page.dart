import 'package:flutter/material.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../data/settings_repository.dart';

/// Page for managing invoice settings
class InvoiceSettingsPage extends StatefulWidget {
  const InvoiceSettingsPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<InvoiceSettingsPage> createState() => _InvoiceSettingsPageState();
}

class _InvoiceSettingsPageState extends State<InvoiceSettingsPage> {
  final _repository = SettingsRepository();
  final _formKey = GlobalKey<FormState>();

  final _bankDetailsController = TextEditingController();
  final _paymentTermsController = TextEditingController();

  int? _billingDay;
  int _cutoffBuffer = 5;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _bankDetailsController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _repository.getInvoiceSettings(widget.yardId);
      if (mounted) {
        setState(() {
          if (settings != null) {
            _bankDetailsController.text = settings.bankDetails ?? '';
            _paymentTermsController.text = settings.paymentTerms ?? '';
            _billingDay = settings.billingDay;
            _cutoffBuffer = settings.cutoffBuffer;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarService.showError(context, 'Failed to load settings');
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final settings = InvoiceSettings(
        yardId: widget.yardId,
        bankDetails: _bankDetailsController.text.trim().isEmpty
            ? null
            : _bankDetailsController.text.trim(),
        paymentTerms: _paymentTermsController.text.trim().isEmpty
            ? null
            : _paymentTermsController.text.trim(),
        billingDay: _billingDay,
        cutoffBuffer: _cutoffBuffer,
      );
      await _repository.upsertInvoiceSettings(settings);
      if (mounted) {
        SnackbarService.showSuccess(context, 'Settings saved');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to save settings');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
                            'Invoice Settings',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Configure billing and payment details',
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
                    : _buildForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        children: [
          // Billing Day
          _buildSectionCard(
            title: 'Billing Schedule',
            icon: Icons.calendar_today_outlined,
            children: [
              Text(
                'Billing Day',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _billingDay,
                decoration: InputDecoration(
                  hintText: 'Select day of month',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: List.generate(28, (i) => i + 1)
                    .map(
                      (day) => DropdownMenuItem(
                        value: day,
                        child: Text('$day${_getDaySuffix(day)} of each month'),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _billingDay = val),
              ),
              const SizedBox(height: 16),
              Text(
                'Cut-off Buffer (days)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _cutoffBuffer.toDouble(),
                      min: 0,
                      max: 14,
                      divisions: 14,
                      label: '$_cutoffBuffer days',
                      onChanged: (val) =>
                          setState(() => _cutoffBuffer = val.round()),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$_cutoffBuffer days',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              Text(
                'Charges logged within this many days before billing will be included in the current invoice.',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bank Details
          _buildSectionCard(
            title: 'Payment Information',
            icon: Icons.account_balance_outlined,
            children: [
              Text(
                'Bank Details',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bankDetailsController,
                decoration: InputDecoration(
                  hintText: 'Account name, sort code, account number',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Terms',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _paymentTermsController,
                decoration: InputDecoration(
                  hintText: 'e.g. Payment due within 14 days',
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Save Button
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save Settings',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFFFFD66B)),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
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
}
