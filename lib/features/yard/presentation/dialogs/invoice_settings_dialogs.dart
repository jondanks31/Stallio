import 'package:flutter/material.dart';

/// Dialog for editing billing day.
Future<int?> showBillingDayDialog({
  required BuildContext context,
  int? currentDay,
}) async {
  final controller = TextEditingController(text: currentDay?.toString() ?? '1');

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

  if (result == true) {
    final day = int.tryParse(controller.text);
    if (day != null && day >= 1 && day <= 28) {
      return day;
    }
  }
  return null;
}

/// Dialog for editing cutoff buffer.
Future<int?> showCutoffBufferDialog({
  required BuildContext context,
  int currentBuffer = 5,
}) async {
  final controller = TextEditingController(text: currentBuffer.toString());

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

  if (result == true) {
    final buffer = int.tryParse(controller.text);
    if (buffer != null && buffer >= 0) {
      return buffer;
    }
  }
  return null;
}

/// Dialog for editing bank details.
Future<String?> showBankDetailsDialog({
  required BuildContext context,
  String? currentDetails,
}) async {
  final controller = TextEditingController(text: currentDetails ?? '');

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

  if (result == true) {
    return controller.text.trim();
  }
  return null;
}

/// Dialog for editing payment terms.
Future<String?> showPaymentTermsDialog({
  required BuildContext context,
  String? currentTerms,
}) async {
  final controller = TextEditingController(text: currentTerms ?? '');

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

  if (result == true) {
    return controller.text.trim();
  }
  return null;
}
