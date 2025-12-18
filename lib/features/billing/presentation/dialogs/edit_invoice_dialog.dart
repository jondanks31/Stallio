import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../data/invoice_repository.dart';

/// Shows dialog to edit an invoice (add/remove/modify line items)
Future<bool?> showEditInvoiceDialog(
  BuildContext context, {
  required Invoice invoice,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => _EditInvoiceDialog(invoice: invoice),
  );
}

class _EditInvoiceDialog extends StatefulWidget {
  const _EditInvoiceDialog({required this.invoice});

  final Invoice invoice;

  @override
  State<_EditInvoiceDialog> createState() => _EditInvoiceDialogState();
}

class _EditInvoiceDialogState extends State<_EditInvoiceDialog> {
  final _invoiceRepository = InvoiceRepository();
  late List<InvoiceLineItem> _lineItems;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _lineItems = List.from(widget.invoice.lineItems);
  }

  Future<void> _addLineItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddLineItemDialog(),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        final newItem = await _invoiceRepository.addLineItem(
          invoiceId: widget.invoice.id,
          lineType: result['lineType'] as LineItemType,
          description: result['description'] as String,
          quantity: result['quantity'] as double,
          unitPrice: result['unitPrice'] as double,
        );
        setState(() {
          _lineItems.add(newItem);
          _hasChanges = true;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          SnackbarService.showError(context, 'Failed to add item');
        }
      }
    }
  }

  Future<void> _editLineItem(InvoiceLineItem item) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddLineItemDialog(existingItem: item),
    );

    if (result != null && mounted) {
      setState(() => _isLoading = true);
      try {
        await _invoiceRepository.updateLineItem(
          lineItemId: item.id,
          description: result['description'] as String,
          quantity: result['quantity'] as double,
          unitPrice: result['unitPrice'] as double,
        );

        final index = _lineItems.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          setState(() {
            _lineItems[index] = item.copyWith(
              description: result['description'] as String,
              quantity: result['quantity'] as double,
              unitPrice: result['unitPrice'] as double,
              totalPrice:
                  (result['quantity'] as double) *
                  (result['unitPrice'] as double),
            );
            _hasChanges = true;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          SnackbarService.showError(context, 'Failed to update item');
        }
      }
    }
  }

  Future<void> _deleteLineItem(InvoiceLineItem item) async {
    final confirmed = await showDeleteConfirmDialog(
      context: context,
      title: 'Delete Line Item',
      message:
          'Are you sure you want to remove "${item.description}" from this invoice?',
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _invoiceRepository.deleteLineItem(item.id);
        setState(() {
          _lineItems.removeWhere((i) => i.id == item.id);
          _hasChanges = true;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          SnackbarService.showError(context, 'Failed to delete item');
        }
      }
    }
  }

  double get _subtotal =>
      _lineItems.fold(0, (sum, item) => sum + item.totalPrice);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(symbol: '£', decimalDigits: 2);

    return Dialog(
      backgroundColor: isDark
          ? BrandColors.dialogBgDark
          : BrandColors.dialogBgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: BrandColors.yellow.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BrandColors.yellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_note,
                      color: BrandColors.yellow,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Invoice',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          widget.invoice.invoiceNumber ?? '',
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
                    onPressed: () => Navigator.of(context).pop(_hasChanges),
                  ),
                ],
              ),
            ),

            // Line items list
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _lineItems.length + 1, // +1 for add button
                      itemBuilder: (context, index) {
                        if (index == _lineItems.length) {
                          return _buildAddButton(isDark);
                        }
                        return _buildLineItemTile(
                          _lineItems[index],
                          isDark,
                          currencyFormat,
                        );
                      },
                    ),
            ),

            // Footer with totals
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[50],
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  Text(
                    currencyFormat.format(_subtotal),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.yellow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemTile(
    InvoiceLineItem item,
    bool isDark,
    NumberFormat currencyFormat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        title: Text(
          item.description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} × ${currencyFormat.format(item.unitPrice)}',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currencyFormat.format(item.totalPrice),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  _editLineItem(item);
                } else if (value == 'delete') {
                  _deleteLineItem(item);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _addLineItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Line Item'),
        style: OutlinedButton.styleFrom(
          foregroundColor: BrandColors.yellow,
          side: BorderSide(color: BrandColors.yellow.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// Dialog for adding or editing a line item
class _AddLineItemDialog extends StatefulWidget {
  const _AddLineItemDialog({this.existingItem});

  final InvoiceLineItem? existingItem;

  @override
  State<_AddLineItemDialog> createState() => _AddLineItemDialogState();
}

class _AddLineItemDialogState extends State<_AddLineItemDialog> {
  late LineItemType _selectedType;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _unitPriceController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.existingItem?.lineType ?? LineItemType.adjustment;
    _descriptionController = TextEditingController(
      text: widget.existingItem?.description ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.existingItem?.quantity.toString() ?? '1',
    );
    _unitPriceController = TextEditingController(
      text: widget.existingItem?.unitPrice.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _save() {
    final description = _descriptionController.text.trim();
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;

    if (description.isEmpty) {
      setState(() => _errorMessage = 'Please enter a description');
      return;
    }
    if (quantity <= 0) {
      setState(() => _errorMessage = 'Please enter a valid quantity');
      return;
    }
    if (unitPrice == 0) {
      setState(() => _errorMessage = 'Please enter a unit price');
      return;
    }

    Navigator.of(context).pop({
      'lineType': _selectedType,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingItem != null;

    return Dialog(
      backgroundColor: isDark
          ? BrandColors.dialogBgDark
          : BrandColors.dialogBgLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Line Item' : 'Add Line Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Type selector (only for new items)
              if (!isEditing) ...[
                Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      [
                        LineItemType.adjustment,
                        LineItemType.credit,
                        LineItemType.consumable,
                        LineItemType.extra,
                      ].map((type) {
                        final isSelected = _selectedType == type;
                        return ChoiceChip(
                          label: Text(type.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedType = type);
                            }
                          },
                          selectedColor: BrandColors.yellow,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black87 : null,
                            fontWeight: isSelected ? FontWeight.w600 : null,
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Description
              TextField(
                controller: _descriptionController,
                decoration: brandedInputDecoration(
                  context: context,
                  label: 'Description',
                  hint: 'e.g., Hay - 2 bales',
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 16),

              // Quantity and Unit Price
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      decoration: brandedInputDecoration(
                        context: context,
                        label: 'Quantity',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _unitPriceController,
                      decoration: brandedInputDecoration(
                        context: context,
                        label: 'Unit Price (£)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                  ),
                ],
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const DialogCancelButton(),
                  const SizedBox(width: 12),
                  DialogPrimaryButton(
                    label: isEditing ? 'Save' : 'Add',
                    onPressed: _save,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
