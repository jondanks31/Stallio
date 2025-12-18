import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../data/people_repository.dart';

/// A single row in the people table, expandable to show more details.
class PersonRow extends StatelessWidget {
  const PersonRow({
    super.key,
    required this.person,
    required this.isExpanded,
    required this.isDesktop,
    required this.onTap,
    this.onEdit,
    this.onResendInvite,
    this.onRemove,
    this.onSetLeavingDate,
    this.onClearLeavingDate,
    this.onGenerateFinalInvoice,
  });

  final YardPerson person;
  final bool isExpanded;
  final bool isDesktop;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onResendInvite;
  final VoidCallback? onRemove;
  final VoidCallback? onSetLeavingDate;
  final VoidCallback? onClearLeavingDate;
  final VoidCallback? onGenerateFinalInvoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      color: isExpanded
          ? (isDark
                ? BrandColors.yellow.withValues(alpha: 0.08)
                : BrandColors.yellow.withValues(alpha: 0.1))
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            // Main row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: isDesktop
                  ? _buildDesktopRow(theme, isDark)
                  : _buildMobileRow(theme, isDark),
            ),
            // Expanded details
            if (isExpanded) _buildExpandedDetails(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopRow(ThemeData theme, bool isDark) {
    return Row(
      children: [
        // Checkbox
        SizedBox(
          width: 40,
          child: Checkbox(
            value: false,
            onChanged: (_) {},
            side: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
          ),
        ),
        // Avatar + Name
        Expanded(
          flex: 2,
          child: Row(
            children: [
              _buildAvatar(isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.fullName ?? person.email ?? 'Unknown',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (person.email != null && person.fullName != null)
                      Text(
                        person.email!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Role
        Expanded(
          flex: 1,
          child: Text(
            person.role.displayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        // Package
        Expanded(
          flex: 1,
          child: Text(
            person.packageName ?? '-',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        // Horses
        Expanded(
          flex: 1,
          child: person.horses.isEmpty
              ? Text(
                  '-',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black38,
                  ),
                )
              : Text(
                  person.horses.length == 1
                      ? person.horses.first.name
                      : '${person.horses.length} horses',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
        ),
        // Stable No.
        Expanded(
          flex: 1,
          child: Text(
            person.stableNumber ?? '-',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        // Contact
        Expanded(
          flex: 1,
          child: Text(
            person.phone ?? '-',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        // Vet
        Expanded(
          flex: 1,
          child: Text(
            person.vetName ?? '-',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        // Status
        Expanded(flex: 1, child: _buildStatusBadge(isDark)),
        // Actions
        SizedBox(
          width: onResendInvite != null ? 96 : 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onResendInvite != null)
                IconButton(
                  onPressed: onResendInvite,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  tooltip: 'Resend invite',
                  visualDensity: VisualDensity.compact,
                  style: IconButton.styleFrom(
                    foregroundColor: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 18,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'remove':
                      onRemove?.call();
                      break;
                    case 'set_leaving':
                      onSetLeavingDate?.call();
                      break;
                    case 'clear_leaving':
                      onClearLeavingDate?.call();
                      break;
                    case 'generate_invoice':
                      onGenerateFinalInvoice?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (person.status == PersonStatus.active && !person.isLeaving)
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
                  // Set leaving date (only for active users without leaving date)
                  if (person.status == PersonStatus.active && !person.isLeaving)
                    const PopupMenuItem(
                      value: 'set_leaving',
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            size: 18,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Set Leaving Date',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  // Clear leaving date (only for users with leaving date set)
                  if (person.isLeaving)
                    const PopupMenuItem(
                      value: 'clear_leaving',
                      child: Row(
                        children: [
                          Icon(Icons.undo, size: 18, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Cancel Departure',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  // Generate final invoice (only for leaving users without final invoice)
                  if (person.isLeaving && person.finalInvoiceId == null)
                    const PopupMenuItem(
                      value: 'generate_invoice',
                      child: Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 18,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Generate Final Invoice',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          person.status == PersonStatus.invited
                              ? Icons.cancel_outlined
                              : Icons.person_remove_outlined,
                          size: 18,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          person.status == PersonStatus.invited
                              ? 'Revoke'
                              : 'Remove',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileRow(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main row with avatar, name, status
        Row(
          children: [
            _buildAvatar(isDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.fullName ?? person.email ?? 'Unknown',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    person.role.displayName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(isDark),
            const SizedBox(width: 4),
            // Action menu for mobile
            _buildMobileActionMenu(isDark),
          ],
        ),
        // Quick info chips row
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            // Leaving date (show prominently if set)
            if (person.isLeaving && person.leavingDate != null)
              _buildLeavingChip(isDark),
            // Package
            if (person.packageName != null)
              _buildInfoChip(
                Icons.inventory_2_outlined,
                person.packageName!,
                isDark,
              ),
            // Horses
            _buildInfoChip(
              Icons.pets,
              person.horses.isEmpty
                  ? 'No horses'
                  : person.horses.length == 1
                  ? person.horses.first.name
                  : '${person.horses.length} horses',
              isDark,
            ),
            // Stable
            if (person.stableNumber != null)
              _buildInfoChip(
                Icons.home_outlined,
                'Stable ${person.stableNumber}',
                isDark,
              ),
            // Phone
            if (person.phone != null)
              _buildInfoChip(Icons.phone_outlined, person.phone!, isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatar(bool isDark) {
    final initials = _getInitials();

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: person.status == PersonStatus.invited
            ? BrandColors.yellow.withValues(alpha: 0.3)
            : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(12),
        image: person.avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(person.avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: person.avatarUrl == null
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: person.status == PersonStatus.invited
                      ? BrandColors.charcoal
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            )
          : null,
    );
  }

  String _getInitials() {
    if (person.fullName != null && person.fullName!.isNotEmpty) {
      final parts = person.fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return person.fullName![0].toUpperCase();
    }
    if (person.email != null && person.email!.isNotEmpty) {
      return person.email![0].toUpperCase();
    }
    return '?';
  }

  Widget _buildStatusBadge(bool isDark) {
    Color bgColor;
    Color textColor;

    switch (person.status) {
      case PersonStatus.active:
        bgColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green[700]!;
        break;
      case PersonStatus.invited:
        bgColor = BrandColors.yellow.withValues(alpha: 0.3);
        textColor = BrandColors.charcoal;
        break;
      case PersonStatus.leaving:
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange[700]!;
        break;
      case PersonStatus.departed:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        person.status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(isDesktop ? 72 : 16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horses section (only show in expanded for desktop, mobile shows in chips)
          if (person.horses.isNotEmpty && isDesktop) ...[
            Text(
              'Horses',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: person.horses.map((horse) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 14,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        horse.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          // Contact details - use Wrap for mobile
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              if (person.phone != null && isDesktop)
                _buildDetailItem(
                  Icons.phone_outlined,
                  'Phone',
                  person.phone!,
                  theme,
                  isDark,
                ),
              if (person.emergencyContactName != null)
                _buildDetailItem(
                  Icons.emergency_outlined,
                  'Emergency',
                  '${person.emergencyContactName}${person.emergencyContactPhone != null ? "\n${person.emergencyContactPhone}" : ""}',
                  theme,
                  isDark,
                ),
              if (person.vetName != null)
                _buildDetailItem(
                  Icons.medical_services_outlined,
                  'Vet',
                  '${person.vetName}${person.vetPhone != null ? "\n${person.vetPhone}" : ""}',
                  theme,
                  isDark,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white38 : Colors.black38),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeavingChip(bool isDark) {
    final daysLeft = person.daysUntilLeaving ?? 0;
    final dateStr = person.leavingDate != null
        ? DateFormat('d MMM').format(person.leavingDate!)
        : '';

    String text;
    if (daysLeft < 0) {
      text = 'Left $dateStr';
    } else if (daysLeft == 0) {
      text = 'Leaving today';
    } else if (daysLeft == 1) {
      text = 'Leaving tomorrow';
    } else {
      text = 'Leaving $dateStr';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.exit_to_app, size: 12, color: Colors.orange[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileActionMenu(bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: isDark ? Colors.white54 : Colors.black45,
      ),
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'resend':
            onResendInvite?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
          case 'set_leaving':
            onSetLeavingDate?.call();
            break;
          case 'clear_leaving':
            onClearLeavingDate?.call();
            break;
          case 'generate_invoice':
            onGenerateFinalInvoice?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (person.status == PersonStatus.active && !person.isLeaving)
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
        if (person.status == PersonStatus.invited)
          const PopupMenuItem(
            value: 'resend',
            child: Row(
              children: [
                Icon(Icons.send_outlined, size: 18),
                SizedBox(width: 8),
                Text('Resend Invite'),
              ],
            ),
          ),
        // Set leaving date (only for active users without leaving date)
        if (person.status == PersonStatus.active && !person.isLeaving)
          const PopupMenuItem(
            value: 'set_leaving',
            child: Row(
              children: [
                Icon(Icons.exit_to_app, size: 18, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Set Leaving Date',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
          ),
        // Clear leaving date (only for users with leaving date set)
        if (person.isLeaving)
          const PopupMenuItem(
            value: 'clear_leaving',
            child: Row(
              children: [
                Icon(Icons.undo, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Text('Cancel Departure', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        // Generate final invoice (only for leaving users without final invoice)
        if (person.isLeaving && person.finalInvoiceId == null)
          const PopupMenuItem(
            value: 'generate_invoice',
            child: Row(
              children: [
                Icon(Icons.receipt_long, size: 18, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Generate Final Invoice',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(
                person.status == PersonStatus.invited
                    ? Icons.cancel_outlined
                    : Icons.person_remove_outlined,
                size: 18,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                person.status == PersonStatus.invited ? 'Revoke' : 'Remove',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
