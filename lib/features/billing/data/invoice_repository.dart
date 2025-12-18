import 'package:supabase_flutter/supabase_flutter.dart';

/// Invoice status enum
enum InvoiceStatus {
  draft,
  issued,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.issued:
        return 'Issued';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  static InvoiceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'issued':
        return InvoiceStatus.issued;
      case 'paid':
        return InvoiceStatus.paid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.issued;
    }
  }
}

/// Invoice line item type
enum LineItemType {
  package,
  consumable,
  extra,
  adjustment,
  credit;

  String get displayName {
    switch (this) {
      case LineItemType.package:
        return 'Livery Package';
      case LineItemType.consumable:
        return 'Consumable';
      case LineItemType.extra:
        return 'Extra Service';
      case LineItemType.adjustment:
        return 'Adjustment';
      case LineItemType.credit:
        return 'Credit';
    }
  }

  static LineItemType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'package':
        return LineItemType.package;
      case 'consumable':
        return LineItemType.consumable;
      case 'extra':
        return LineItemType.extra;
      case 'adjustment':
        return LineItemType.adjustment;
      case 'credit':
        return LineItemType.credit;
      default:
        return LineItemType.consumable;
    }
  }
}

/// Invoice line item model
class InvoiceLineItem {
  final String id;
  final String invoiceId;
  final LineItemType lineType;
  final String description;
  final String? horseId;
  final String? horseName;
  final double quantity;
  final double unitPrice;
  final double totalPrice;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  InvoiceLineItem({
    required this.id,
    required this.invoiceId,
    required this.lineType,
    required this.description,
    this.horseId,
    this.horseName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.metadata = const {},
    required this.createdAt,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    final horse = json['horse'] as Map<String, dynamic>?;
    return InvoiceLineItem(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      lineType: LineItemType.fromString(json['line_type'] as String),
      description: json['description'] as String,
      horseId: json['horse_id'] as String?,
      horseName: horse?['name'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'invoice_id': invoiceId,
    'line_type': lineType.name,
    'description': description,
    'horse_id': horseId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total_price': totalPrice,
    'metadata': metadata,
  };

  InvoiceLineItem copyWith({
    String? id,
    String? invoiceId,
    LineItemType? lineType,
    String? description,
    String? horseId,
    String? horseName,
    double? quantity,
    double? unitPrice,
    double? totalPrice,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return InvoiceLineItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      lineType: lineType ?? this.lineType,
      description: description ?? this.description,
      horseId: horseId ?? this.horseId,
      horseName: horseName ?? this.horseName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Invoice model
class Invoice {
  final String id;
  final String yardId;
  final String? yardName;
  final String userId;
  final String? userName;
  final String? invoiceNumber;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime issueDate;
  final DateTime? dueDate;
  final InvoiceStatus status;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final double amountPaid;
  final String currency;
  final String? pdfUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<InvoiceLineItem> lineItems;

  Invoice({
    required this.id,
    required this.yardId,
    this.yardName,
    required this.userId,
    this.userName,
    this.invoiceNumber,
    this.periodStart,
    this.periodEnd,
    required this.issueDate,
    this.dueDate,
    required this.status,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.currency,
    this.pdfUrl,
    required this.createdAt,
    required this.updatedAt,
    this.lineItems = const [],
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final yard = json['yard'] as Map<String, dynamic>?;
    final lineItemsJson = json['invoice_line_items'] as List?;

    return Invoice(
      id: json['id'] as String,
      yardId: json['yard_id'] as String,
      yardName: yard?['name'] as String?,
      userId: json['user_id'] as String,
      userName: user?['full_name'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : null,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      status: InvoiceStatus.fromString(json['status'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'GBP',
      pdfUrl: json['pdf_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lineItems:
          lineItemsJson
              ?.map(
                (item) =>
                    InvoiceLineItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Balance remaining on invoice
  double get balanceDue => totalAmount - amountPaid;

  /// Check if invoice is fully paid
  bool get isPaid => status == InvoiceStatus.paid || balanceDue <= 0;

  /// Check if invoice is overdue
  bool get isOverdue {
    if (status == InvoiceStatus.overdue) return true;
    if (isPaid) return false;
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  Invoice copyWith({
    String? id,
    String? yardId,
    String? yardName,
    String? userId,
    String? userName,
    String? invoiceNumber,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? issueDate,
    DateTime? dueDate,
    InvoiceStatus? status,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    double? amountPaid,
    String? currency,
    String? pdfUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<InvoiceLineItem>? lineItems,
  }) {
    return Invoice(
      id: id ?? this.id,
      yardId: yardId ?? this.yardId,
      yardName: yardName ?? this.yardName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      currency: currency ?? this.currency,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lineItems: lineItems ?? this.lineItems,
    );
  }
}

/// Repository for managing invoices
class InvoiceRepository {
  final _supabase = Supabase.instance.client;

  /// Generate a unique invoice number
  String _generateInvoiceNumber(String yardId) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(5);
    return 'INV-${now.year}${now.month.toString().padLeft(2, '0')}-$timestamp';
  }

  /// Get all invoices for a user in a specific yard
  Future<List<Invoice>> getUserInvoices(String yardId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('invoices')
        .select('''
          *,
          invoice_line_items(*, horse:horse_id(name))
        ''')
        .eq('yard_id', yardId)
        .eq('user_id', userId)
        .order('issue_date', ascending: false);

    return (response as List).map((json) => Invoice.fromJson(json)).toList();
  }

  /// Get all invoices for a user across ALL yards (for multi-yard billing view)
  /// Groups invoices by yard and includes yard names
  Future<List<Invoice>> getAllUserInvoices() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('invoices')
        .select('''
          *,
          yard:yard_id(name),
          invoice_line_items(*, horse:horse_id(name))
        ''')
        .eq('user_id', userId)
        .order('issue_date', ascending: false);

    return (response as List).map((json) => Invoice.fromJson(json)).toList();
  }

  /// Get all invoices for a yard (owner view)
  Future<List<Invoice>> getYardInvoices(
    String yardId, {
    InvoiceStatus? status,
  }) async {
    var query = _supabase
        .from('invoices')
        .select('''
          *,
          invoice_line_items(*, horse:horse_id(name))
        ''')
        .eq('yard_id', yardId);

    if (status != null) {
      query = query.eq('status', status.name);
    }

    final response = await query.order('issue_date', ascending: false);
    final invoices = (response as List)
        .map((json) => Invoice.fromJson(json))
        .toList();

    // Fetch user names separately (no FK relationship between invoices and profiles)
    if (invoices.isNotEmpty) {
      final userIds = invoices.map((i) => i.userId).toSet().toList();
      final profilesResponse = await _supabase
          .from('profiles')
          .select('user_id, full_name')
          .inFilter('user_id', userIds);

      final userNames = <String, String>{};
      for (final profile in profilesResponse as List) {
        userNames[profile['user_id'] as String] =
            profile['full_name'] as String? ?? 'Unknown';
      }

      // Add user names to invoices
      return invoices
          .map((inv) => inv.copyWith(userName: userNames[inv.userId]))
          .toList();
    }

    return invoices;
  }

  /// Get a single invoice by ID
  Future<Invoice?> getInvoice(String invoiceId) async {
    final response = await _supabase
        .from('invoices')
        .select('''
          *,
          invoice_line_items(*, horse:horse_id(name))
        ''')
        .eq('id', invoiceId)
        .maybeSingle();

    if (response == null) return null;
    var invoice = Invoice.fromJson(response);

    // Fetch user name separately
    final profileResponse = await _supabase
        .from('profiles')
        .select('full_name')
        .eq('user_id', invoice.userId)
        .maybeSingle();

    if (profileResponse != null) {
      invoice = invoice.copyWith(
        userName: profileResponse['full_name'] as String?,
      );
    }

    return invoice;
  }

  /// Create a new invoice with line items
  Future<Invoice> createInvoice({
    required String yardId,
    required String userId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<Map<String, dynamic>> lineItems,
    DateTime? dueDate,
    double taxRate = 0,
    double discountAmount = 0,
  }) async {
    // Calculate totals
    double subtotal = 0;
    for (final item in lineItems) {
      subtotal += (item['total_price'] as num).toDouble();
    }
    final taxAmount = subtotal * taxRate;
    final totalAmount = subtotal + taxAmount - discountAmount;

    // Calculate due date if not provided (default: 14 days from issue)
    final issueDate = DateTime.now();
    final effectiveDueDate = dueDate ?? issueDate.add(const Duration(days: 14));

    // Create invoice
    final invoiceResponse = await _supabase
        .from('invoices')
        .insert({
          'yard_id': yardId,
          'user_id': userId,
          'invoice_number': _generateInvoiceNumber(yardId),
          'period_start': periodStart.toIso8601String().split('T')[0],
          'period_end': periodEnd.toIso8601String().split('T')[0],
          'issue_date': issueDate.toIso8601String(),
          'due_date': effectiveDueDate.toIso8601String(),
          'status': 'issued',
          'subtotal': subtotal,
          'tax_amount': taxAmount,
          'discount_amount': discountAmount,
          'total_amount': totalAmount,
          'amount_paid': 0,
          'currency': 'GBP',
        })
        .select()
        .single();

    final invoiceId = invoiceResponse['id'] as String;

    // Create line items
    if (lineItems.isNotEmpty) {
      final lineItemsWithInvoiceId = lineItems.map((item) {
        return {...item, 'invoice_id': invoiceId};
      }).toList();

      await _supabase.from('invoice_line_items').insert(lineItemsWithInvoiceId);
    }

    // Fetch and return complete invoice
    final invoice = await getInvoice(invoiceId);
    return invoice!;
  }

  /// Update invoice status
  Future<void> updateInvoiceStatus(
    String invoiceId,
    InvoiceStatus status,
  ) async {
    await _supabase
        .from('invoices')
        .update({
          'status': status.name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', invoiceId);
  }

  /// Mark invoice as paid
  Future<void> markInvoicePaid(String invoiceId, {double? amountPaid}) async {
    final invoice = await getInvoice(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    final paidAmount = amountPaid ?? invoice.totalAmount;

    await _supabase
        .from('invoices')
        .update({
          'status': 'paid',
          'amount_paid': paidAmount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', invoiceId);
  }

  /// Update invoice totals (after editing line items)
  Future<void> recalculateInvoiceTotals(String invoiceId) async {
    // Get all line items for invoice
    final lineItemsResponse = await _supabase
        .from('invoice_line_items')
        .select('total_price')
        .eq('invoice_id', invoiceId);

    double subtotal = 0;
    for (final item in lineItemsResponse as List) {
      subtotal += (item['total_price'] as num).toDouble();
    }

    // Get current invoice to preserve tax rate
    final invoice = await getInvoice(invoiceId);
    if (invoice == null) return;

    final taxRate = invoice.subtotal > 0
        ? invoice.taxAmount / invoice.subtotal
        : 0.0;
    final taxAmount = subtotal * taxRate;
    final totalAmount = subtotal + taxAmount - invoice.discountAmount;

    await _supabase
        .from('invoices')
        .update({
          'subtotal': subtotal,
          'tax_amount': taxAmount,
          'total_amount': totalAmount,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', invoiceId);
  }

  /// Add a line item to an invoice
  Future<InvoiceLineItem> addLineItem({
    required String invoiceId,
    required LineItemType lineType,
    required String description,
    String? horseId,
    required double quantity,
    required double unitPrice,
    Map<String, dynamic>? metadata,
  }) async {
    final totalPrice = quantity * unitPrice;

    final response = await _supabase
        .from('invoice_line_items')
        .insert({
          'invoice_id': invoiceId,
          'line_type': lineType.name,
          'description': description,
          'horse_id': horseId,
          'quantity': quantity,
          'unit_price': unitPrice,
          'total_price': totalPrice,
          'metadata': metadata ?? {},
        })
        .select('*, horse:horse_id(name)')
        .single();

    // Recalculate invoice totals
    await recalculateInvoiceTotals(invoiceId);

    return InvoiceLineItem.fromJson(response);
  }

  /// Update a line item
  Future<void> updateLineItem({
    required String lineItemId,
    String? description,
    double? quantity,
    double? unitPrice,
  }) async {
    // Get current line item
    final currentResponse = await _supabase
        .from('invoice_line_items')
        .select()
        .eq('id', lineItemId)
        .single();

    final currentQuantity = (currentResponse['quantity'] as num).toDouble();
    final currentUnitPrice = (currentResponse['unit_price'] as num).toDouble();
    final invoiceId = currentResponse['invoice_id'] as String;

    final newQuantity = quantity ?? currentQuantity;
    final newUnitPrice = unitPrice ?? currentUnitPrice;
    final newTotalPrice = newQuantity * newUnitPrice;

    await _supabase
        .from('invoice_line_items')
        .update({
          if (description != null) 'description': description,
          if (quantity != null) 'quantity': quantity,
          if (unitPrice != null) 'unit_price': unitPrice,
          'total_price': newTotalPrice,
        })
        .eq('id', lineItemId);

    // Recalculate invoice totals
    await recalculateInvoiceTotals(invoiceId);
  }

  /// Delete a line item
  Future<void> deleteLineItem(String lineItemId) async {
    // Get invoice ID before deleting
    final response = await _supabase
        .from('invoice_line_items')
        .select('invoice_id')
        .eq('id', lineItemId)
        .single();

    final invoiceId = response['invoice_id'] as String;

    await _supabase.from('invoice_line_items').delete().eq('id', lineItemId);

    // Recalculate invoice totals
    await recalculateInvoiceTotals(invoiceId);
  }

  /// Check and update overdue invoices for a yard
  Future<int> updateOverdueInvoices(String yardId) async {
    final now = DateTime.now();

    final response = await _supabase
        .from('invoices')
        .update({'status': 'overdue', 'updated_at': now.toIso8601String()})
        .eq('yard_id', yardId)
        .eq('status', 'issued')
        .lt('due_date', now.toIso8601String())
        .select();

    return (response as List).length;
  }

  /// Get invoice statistics for a yard
  Future<Map<String, dynamic>> getInvoiceStats(String yardId) async {
    final invoices = await getYardInvoices(yardId);

    int totalCount = invoices.length;
    int paidCount = 0;
    int outstandingCount = 0;
    int overdueCount = 0;
    double totalRevenue = 0;
    double totalOutstanding = 0;

    for (final invoice in invoices) {
      if (invoice.status == InvoiceStatus.paid) {
        paidCount++;
        totalRevenue += invoice.amountPaid;
      } else if (invoice.status == InvoiceStatus.overdue) {
        overdueCount++;
        totalOutstanding += invoice.balanceDue;
      } else if (invoice.status == InvoiceStatus.issued) {
        outstandingCount++;
        totalOutstanding += invoice.balanceDue;
      }
    }

    return {
      'totalCount': totalCount,
      'paidCount': paidCount,
      'outstandingCount': outstandingCount,
      'overdueCount': overdueCount,
      'totalRevenue': totalRevenue,
      'totalOutstanding': totalOutstanding,
    };
  }

  /// Delete an invoice (only if draft or cancelled)
  Future<void> deleteInvoice(String invoiceId) async {
    final invoice = await getInvoice(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    if (invoice.status != InvoiceStatus.draft &&
        invoice.status != InvoiceStatus.cancelled) {
      throw Exception('Can only delete draft or cancelled invoices');
    }

    // Line items will be cascade deleted
    await _supabase.from('invoices').delete().eq('id', invoiceId);
  }

  /// Cancel an invoice
  Future<void> cancelInvoice(String invoiceId) async {
    await updateInvoiceStatus(invoiceId, InvoiceStatus.cancelled);
  }

  /// Generate a pro-rated final invoice for a departing user
  /// Period: billing cycle start → leaving date
  /// Package costs are pro-rated based on days used
  /// Only yard owners and managers can generate invoices
  Future<Invoice> generateFinalInvoice({
    required String yardId,
    required String userId,
    required DateTime leavingDate,
    DateTime? cycleStart,
  }) async {
    // Authorization: Verify caller is owner or manager of this yard
    final callerId = _supabase.auth.currentUser?.id;
    if (callerId == null) throw Exception('Not authenticated');

    final callerProfile = await _supabase
        .from('profiles')
        .select('role, yard_id')
        .eq('user_id', callerId)
        .maybeSingle();

    if (callerProfile == null) {
      throw Exception('Caller profile not found');
    }

    final callerYardId = callerProfile['yard_id'] as String?;
    final callerRole = callerProfile['role'] as String?;

    if (callerYardId != yardId) {
      throw Exception('Not authorized: You are not a member of this yard');
    }

    if (callerRole != 'owner' && callerRole != 'manager') {
      throw Exception(
        'Not authorized: Only owners and managers can generate invoices',
      );
    }

    // Determine billing cycle start (default: 1st of the leaving month)
    final effectiveCycleStart =
        cycleStart ?? DateTime(leavingDate.year, leavingDate.month, 1);

    // Calculate pro-rating factor
    final daysInMonth = DateTime(
      leavingDate.year,
      leavingDate.month + 1,
      0,
    ).day;
    final daysUsed =
        leavingDate.day; // Days from 1st to leaving date (inclusive)
    final proRateFactor = daysUsed / daysInMonth;

    // Get user's horses in this yard
    final horsesResponse = await _supabase
        .from('horses')
        .select('id, name')
        .eq('current_yard_id', yardId)
        .eq('created_by', userId);

    final horses = horsesResponse as List;
    if (horses.isEmpty) {
      throw Exception('User has no horses in this yard');
    }

    final horseIds = horses.map((h) => h['id'] as String).toList();
    final horseNames = <String, String>{};
    for (final h in horses) {
      horseNames[h['id'] as String] = h['name'] as String;
    }

    // Get active packages for user's horses
    final now = DateTime.now();
    final packagesResponse = await _supabase
        .from('user_packages')
        .select('horse_id, livery_package:package_id(name, base_price)')
        .eq('yard_id', yardId)
        .inFilter('horse_id', horseIds)
        .lte('effective_from', now.toIso8601String())
        .or('effective_to.is.null,effective_to.gte.${now.toIso8601String()}');

    // Get consumable logs for the period
    final logsResponse = await _supabase
        .from('consumable_logs')
        .select('''
          id, horse_id, quantity_usage,
          consumable_type:consumable_type_id(name, price_per_usage_unit)
        ''')
        .eq('yard_id', yardId)
        .inFilter('horse_id', horseIds)
        .gte('log_at', effectiveCycleStart.toIso8601String())
        .lte('log_at', leavingDate.toIso8601String())
        .eq('is_billable', true)
        .eq('is_deleted', false);

    // Build line items
    final lineItems = <Map<String, dynamic>>[];

    // Add pro-rated package costs per horse
    for (final pkg in packagesResponse as List) {
      final horseId = pkg['horse_id'] as String;
      final liveryPkg = pkg['livery_package'] as Map<String, dynamic>?;
      if (liveryPkg != null) {
        final basePrice = (liveryPkg['base_price'] as num?)?.toDouble() ?? 0;
        final packageName = liveryPkg['name'] as String? ?? 'Livery Package';
        final horseName = horseNames[horseId] ?? 'Horse';
        final proRatedPrice = basePrice * proRateFactor;

        lineItems.add({
          'line_type': 'package',
          'description':
              '$packageName - $horseName (pro-rated $daysUsed/$daysInMonth days)',
          'horse_id': horseId,
          'quantity': 1,
          'unit_price': proRatedPrice,
          'total_price': proRatedPrice,
          'metadata': {
            'original_price': basePrice,
            'pro_rate_factor': proRateFactor,
            'days_used': daysUsed,
            'days_in_month': daysInMonth,
          },
        });
      }
    }

    // Add consumable charges
    for (final log in logsResponse as List) {
      final horseId = log['horse_id'] as String;
      final horseName = horseNames[horseId] ?? 'Horse';
      final consumable = log['consumable_type'] as Map<String, dynamic>?;
      final quantity = (log['quantity_usage'] as num?)?.toDouble() ?? 0;
      final pricePerUnit =
          (consumable?['price_per_usage_unit'] as num?)?.toDouble() ?? 0;
      final consumableName = consumable?['name'] as String? ?? 'Consumable';

      lineItems.add({
        'line_type': 'consumable',
        'description': '$consumableName - $horseName',
        'horse_id': horseId,
        'quantity': quantity,
        'unit_price': pricePerUnit,
        'total_price': quantity * pricePerUnit,
      });
    }

    if (lineItems.isEmpty) {
      throw Exception('No billable items found for this period');
    }

    // Create the invoice
    final invoice = await createInvoice(
      yardId: yardId,
      userId: userId,
      periodStart: effectiveCycleStart,
      periodEnd: leavingDate,
      lineItems: lineItems,
      dueDate: leavingDate.add(
        const Duration(days: 14),
      ), // Due 14 days after leaving
    );

    return invoice;
  }
}
