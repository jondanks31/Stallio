import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/branded_dialog.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../settings/data/settings_repository.dart';
import '../../data/people_repository.dart';

/// Shows a dialog to invite a new person to the yard.
/// Returns the created [Invite] if successful, null if cancelled.
Future<Invite?> showInviteDialog({
  required BuildContext context,
  required String yardId,
}) async {
  final emailController = TextEditingController();
  YardRole selectedRole = YardRole.user;
  String? selectedPackageId;
  List<LiveryPackage> packages = [];
  bool isLoading = false;
  bool isLoadingPackages = true;
  Invite? createdInvite;

  final isDark = Theme.of(context).brightness == Brightness.dark;
  final repository = PeopleRepository();
  final settingsRepository = SettingsRepository();

  // Load packages
  try {
    packages = await settingsRepository.getPackages(yardId);
    isLoadingPackages = false;
  } catch (e) {
    debugPrint('Error loading packages: $e');
    isLoadingPackages = false;
  }

  final result = await showDialog<Invite?>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        final requiresPackage = selectedRole == YardRole.user;

        return Dialog(
          backgroundColor: isDark
              ? BrandColors.dialogBgDark
              : BrandColors.dialogBgLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440, maxHeight: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: BrandColors.yellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person_add_outlined,
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
                              'Invite to Yard',
                              style: Theme.of(ctx).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                            ),
                            Text(
                              'Send an invite code via email',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Email field
                  TextField(
                    controller: emailController,
                    decoration: brandedInputDecoration(
                      context: ctx,
                      label: 'Email Address',
                      hint: 'person@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Role selection
                  Text(
                    'Role',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [YardRole.user, YardRole.staff, YardRole.manager]
                        .map((role) {
                          final isSelected = selectedRole == role;
                          return GestureDetector(
                            onTap: () =>
                                setDialogState(() => selectedRole = role),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? BrandColors.charcoal
                                    : (isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? BrandColors.charcoal
                                      : Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                role.displayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          );
                        })
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Package selection (only for User role)
                  if (requiresPackage) ...[
                    Text(
                      'Livery Package',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoadingPackages)
                      const Center(child: CircularProgressIndicator())
                    else if (packages.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_outlined,
                              color: Colors.orange[700],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No packages configured. Create packages in Yard Settings first.',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        initialValue: selectedPackageId,
                        decoration: brandedDropdownDecoration(
                          context: ctx,
                          label: 'Select Package',
                        ),
                        hint: const Text('Choose a package'),
                        items: packages.map((pkg) {
                          return DropdownMenuItem(
                            value: pkg.id,
                            child: Text(
                              '${pkg.name} (£${pkg.basePrice.toStringAsFixed(0)}/mo)',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setDialogState(() => selectedPackageId = value),
                      ),
                    const SizedBox(height: 8),
                  ],

                  const SizedBox(height: 24),

                  // Success state - show invite code
                  if (createdInvite != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Invite Created!',
                            style: Theme.of(ctx).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code with ${emailController.text}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          // Invite code display
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text: createdInvite!.inviteCode ?? '',
                                ),
                              );
                              SnackbarService.showSuccess(ctx, 'Code copied!');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.black26 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    createdInvite!.inviteCode ?? '',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Expires in 24 hours',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, createdInvite),
                      style: FilledButton.styleFrom(
                        backgroundColor: BrandColors.yellow,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Done'),
                    ),
                  ] else ...[
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed:
                              isLoading ||
                                  emailController.text.isEmpty ||
                                  (requiresPackage && selectedPackageId == null)
                              ? null
                              : () async {
                                  setDialogState(() => isLoading = true);
                                  try {
                                    final invite = await repository
                                        .createInvite(
                                          yardId: yardId,
                                          email: emailController.text.trim(),
                                          role: selectedRole,
                                          packageId: selectedPackageId,
                                        );

                                    // Send invite email via Edge Function
                                    try {
                                      await Supabase.instance.client.functions
                                          .invoke(
                                            'send-invite-email',
                                            body: {'inviteId': invite.id},
                                          );
                                    } catch (emailError) {
                                      // Email sending failed but invite was created
                                      debugPrint(
                                        'Failed to send invite email: $emailError',
                                      );
                                    }

                                    setDialogState(() {
                                      createdInvite = invite;
                                      isLoading = false;
                                    });
                                  } on PostgrestException catch (e) {
                                    setDialogState(() => isLoading = false);
                                    if (ctx.mounted) {
                                      SnackbarService.showError(
                                        ctx,
                                        'Failed: ${e.message}',
                                      );
                                    }
                                  } catch (e) {
                                    setDialogState(() => isLoading = false);
                                    if (ctx.mounted) {
                                      SnackbarService.showError(
                                        ctx,
                                        'Failed to create invite',
                                      );
                                    }
                                  }
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: BrandColors.yellow,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Send Invite'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  );

  return result;
}
