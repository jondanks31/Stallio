import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../user/data/billing_repository.dart';

/// Owner Billing page - shows all users' bills for invoicing
class OwnerBillingPage extends StatefulWidget {
  const OwnerBillingPage({super.key, required this.yardId});

  final String yardId;

  @override
  State<OwnerBillingPage> createState() => _OwnerBillingPageState();
}

class _OwnerBillingPageState extends State<OwnerBillingPage> {
  final _billingRepository = BillingRepository();
  List<UserBillingSummary> _userBills = [];
  bool _isLoading = true;
  final Set<String> _expandedUsers = {};

  @override
  void initState() {
    super.initState();
    _loadBilling();
  }

  Future<void> _loadBilling() async {
    debugPrint('OwnerBillingPage: loading billing for yard ${widget.yardId}');
    setState(() => _isLoading = true);
    try {
      final bills = await _billingRepository.getAllUsersBilling(widget.yardId);
      debugPrint('OwnerBillingPage: got ${bills.length} user bills');
      if (mounted) {
        setState(() {
          _userBills = bills;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (cycleStart, cycleEnd) = _billingRepository.getCurrentBillingCycle();

    return RefreshIndicator(
      onRefresh: _loadBilling,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Billing cycle header
            _buildCycleHeader(isDark, cycleStart, cycleEnd),
            const SizedBox(height: 24),

            // Summary stats
            _buildSummaryStats(isDark),
            const SizedBox(height: 24),

            // User bills list
            _buildUserBillsList(isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleHeader(bool isDark, DateTime start, DateTime end) {
    final dateFormat = DateFormat('d MMM');

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
    bool isDark,
  ) {
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
          Icon(icon, size: 20, color: const Color(0xFFFFD66B)),
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
