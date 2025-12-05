import '../../features/people/data/people_repository.dart';

/// Centralized service for role-based permission checking.
/// Use this to determine what UI elements to show and what actions are allowed.
class RoleService {
  /// Can the user invite new members to the yard?
  /// Only Managers (level 3) and Owners (level 4) can invite.
  static bool canInvite(YardRole role) => role.level >= 3;

  /// Can the user manage yard settings (packages, consumables, etc.)?
  /// Only Owners can manage yard settings.
  static bool canManageYard(YardRole role) => role == YardRole.owner;

  /// Can the user log consumables?
  /// Staff (level 2) and above can log consumables.
  static bool canLogConsumables(YardRole role) => role.level >= 2;

  /// Can the user assign horses to staff members?
  /// Only Managers and Owners can assign horses.
  static bool canAssignHorses(YardRole role) => role.level >= 3;

  /// Can the user create tasks?
  /// Staff and above can create tasks.
  static bool canCreateTasks(YardRole role) => role.level >= 2;

  /// Can the user view the People page?
  /// All yard members can view people, but actions are restricted.
  static bool canViewPeople(YardRole role) => true;

  /// Can the user edit other people's roles?
  /// Only Managers and Owners can edit roles.
  static bool canEditRoles(YardRole role) => role.level >= 3;

  /// Can the user view billing information?
  /// All users can view their own billing.
  static bool canViewBilling(YardRole role) => true;

  /// Can the user view yard-wide billing/invoices?
  /// Only Owners can view all billing.
  static bool canViewAllBilling(YardRole role) => role == YardRole.owner;

  /// Can the user report issues?
  /// All yard members can report issues.
  static bool canReportIssues(YardRole role) => true;

  /// Can the user resolve issues?
  /// Staff and above can resolve issues.
  static bool canResolveIssues(YardRole role) => role.level >= 2;

  /// Is this user a staff member or above (operational role)?
  static bool isOperationalRole(YardRole role) => role.level >= 2;

  /// Is this user a manager or above (management role)?
  static bool isManagementRole(YardRole role) => role.level >= 3;
}
