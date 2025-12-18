# Stallio Implementation Progress

**Created**: Dec 5, 2025  
**Last Updated**: Dec 18, 2025

---

## Priority Legend
- 🔴 **CRITICAL** - Core functionality broken/missing
- 🟠 **HIGH** - Important features incomplete
- 🟡 **MEDIUM** - Nice-to-have, affects UX
- 🟢 **LOW** - Minor polish items
- ⏳ **DEFERRED** - Intentionally postponed

---

## 🔴 CRITICAL ISSUES

### 1. Billable Calculation Not Working
**Status**: ✅ DONE  
**Description**: All consumable logs have `is_billable = true` regardless of whether the item is included in the user's package.  
**Spec Reference**: S3-06  
**Solution**: Created `check_consumable_billable()` database function + trigger.  
**Files**:
- `lib/features/staff/data/consumable_logs_repository.dart` - Removed hardcoded is_billable
- Supabase: `set_consumable_billable` trigger on `consumable_logs` table

### 2. Invoice System
**Status**: ✅ DONE (Phase 1)  
**Description**: Invoice generation, viewing, and management for owners and customers.  
**Spec Reference**: S4-01  
**Solution**: 
- Created `invoice_line_items` table via Supabase migration
- Created `InvoiceRepository` with full CRUD operations
- Owner billing page: Invoices tab with status filtering (Outstanding, Paid, All)
- Owner actions: View invoice details, edit line items, mark as paid
- Customer billing page: Dynamic "Pay Now" card when invoice ready
- Customer view: Status badges (In Progress → Invoice Ready → Overdue)
- Invoice period dates shown correctly (supports early-generated invoices)
**Files**:
- `lib/features/billing/data/invoice_repository.dart` - Invoice & LineItem models, repository
- `lib/features/billing/presentation/dialogs/invoice_detail_dialog.dart` - View invoice
- `lib/features/billing/presentation/dialogs/edit_invoice_dialog.dart` - Edit line items
- `lib/features/dashboard/presentation/owner_billing_page.dart` - Owner invoice management
- `lib/features/user/presentation/pages/billing_page.dart` - Customer Pay Now UI
**Pending**:
- Automated invoice generation at end of billing cycle (Edge Function)
- "Leaving date" field for departing users (enables early invoice generation)

---

## 🟠 HIGH PRIORITY

### 3. Feed/Announcements Not Connected
**Status**: ✅ DONE  
**Description**: `feed_posts` table exists but UI shows hardcoded placeholders.  
**Spec Reference**: S5-04, S7.4  
**Solution**: 
- Created `FeedRepository` with getAnnouncements/getFeedPosts/createPost
- Connected `AnnouncementsSection` and `SocialFeedSection` to real data
- Added `is_pinned` field to `feed_posts` table for announcements
- Added FAB on FeedPage for owners/managers to create posts
**Files**:
- `lib/core/ui/feed_widgets.dart` - Now fetches real data
- `lib/features/shared/presentation/pages/feed_page.dart` - Added post creation
- NEW: `lib/features/feed/data/feed_repository.dart`
- Supabase: Added `is_pinned` column to `feed_posts`

### 4. User Package Display on People Page
**Status**: ✅ DONE  
**Description**: Active users don't show their package name (only invites do).  
**Solution**: Query `user_packages` table and join with `livery_packages` for active users.  
**Files**:
- `lib/features/people/data/people_repository.dart` - Now fetches package info from user_packages

### 5. Booking System Incomplete
**Status**: ✅ DONE  
**Description**: Calendar UI exists but no booking functionality.  
**Spec Reference**: S5-01  
**Solution**:
- Created `BookingRepository` with CRUD operations and conflict checking
- Added booking creation dialog with facility selector and time slot grid
- Connected calendar to show real bookings from `facility_bookings` table
**Files**:
- `lib/features/shared/presentation/pages/calendar_page.dart` - Now shows real bookings
- NEW: `lib/features/bookings/data/bookings_repository.dart`

### 6. Unified Work List (Tasks + Issues)
**Status**: ✅ DONE  
**Description**: Tasks and Issues were separate pages - staff could miss things. Now unified into single "Work List" view.  
**Solution**:
- Added `priority`, `assigned_to`, `resolved_by` fields to `issues` table
- Created unified `WorkItem` model abstracting both Tasks and Issues
- Created `WorkListRepository` with combined queries and filtering
- Created `WorkListPage` with:
  - Type filter (All, Tasks, Issues)
  - Assignment filter (Mine, Unassigned, All - "All" for managers/owners only)
  - Priority sorting (Urgent first)
  - Self-assignment for unassigned items
  - Manager/Owner assignment to staff members
  - Assignment dropdown when creating tasks/issues
  - Visual indicator (green icon) when item is assigned
  - Audit trail showing who resolved issues
- Updated staff and owner dashboards to use unified work list
- Security: Server-side role validation for assignment permissions
- Security: Yard membership validation when assigning to users
- Cleaned up dead code (removed old tasks_repository, issues_repository, tasks_page, issues_page)
**Files**:
- `lib/features/staff/data/work_list_repository.dart`
- `lib/features/staff/presentation/pages/work_list_page.dart`
- `lib/features/staff/presentation/staff_dashboard_page.dart`
- `lib/features/dashboard/presentation/owner_dashboard_page.dart`
- Supabase: Added `priority`, `assigned_to`, `resolved_by` columns to `issues`

### 7. Issue Photo Upload
**Status**: ⬜ Not Started  
**Description**: Issues repository supports photos but UI doesn't allow upload.  
**Files**:
- Staff dashboard issue creation

### 8. My Horses Page - Enhanced Tabs
**Status**: ✅ DONE  
**Description**: Refactored My Horses page into modular widgets and enhanced all note tabs with contextual layouts.  
**Solution**:
- **Feed Tab**: Recipe card layout with feed times (Morning/Afternoon/Evening), feed items as chips, and special instructions
- **Care Tab**: Sectioned free text with suggested headers (Daily Routine, Medications, Turnout, Rugging, etc.)
- **Contacts Tab**: Structured contact entries with types (Vet, Farrier, Physio, Dentist, Saddle Fitter, Instructor, Emergency, Insurance)
- **Notes Tab**: Simple free text (unchanged)
- All data stored as JSON in existing text fields (no DB migrations needed)
- Inline validation errors (no more snackbars hidden behind dialogs)
- Scrollable dialogs to prevent overflow on smaller screens
**Files**:
- `lib/features/user/presentation/pages/my_horses_page.dart` - Slimmed to ~260 lines
- `lib/features/user/presentation/widgets/horses/horse_selector.dart` - Dropdown pill + empty state
- `lib/features/user/presentation/widgets/horses/horse_avatar_card.dart` - Avatar + photo upload
- `lib/features/user/presentation/widgets/horses/horse_care_feed.dart` - Activity timeline
- `lib/features/user/presentation/widgets/horses/horse_feed_tab.dart` - Recipe card layout
- `lib/features/user/presentation/widgets/horses/horse_care_tab.dart` - Sectioned instructions
- `lib/features/user/presentation/widgets/horses/horse_contacts_tab.dart` - Structured contacts
- `lib/features/user/presentation/widgets/horses/horse_notes_tab.dart` - Free text notes

### 9. Work List Page Refactor
**Status**: ✅ DONE  
**Description**: Refactored work_list_page.dart into smaller modular widgets for maintainability.  
**Files**:
- `lib/features/staff/presentation/pages/work_list_page.dart` - Slimmed to ~260 lines
- `lib/features/staff/presentation/widgets/work_list/work_list_filters.dart`
- `lib/features/staff/presentation/widgets/work_list/work_item_card.dart`
- `lib/features/staff/presentation/widgets/work_list/work_item_dialogs.dart`
- `lib/features/staff/presentation/widgets/work_list/add_work_item_sheet.dart`

---

## 🟡 MEDIUM PRIORITY

### 10. Financial Dashboard Charts
**Status**: ⬜ Not Started  
**Description**: Owner dashboard missing revenue/analytics charts.  
**Spec Reference**: S4-03

### 11. Inventory Burn Rate
**Status**: ⬜ Not Started  
**Description**: `inventory` table exists but no tracking or UI.  
**Spec Reference**: S4-04, S4-05

### 12. Profile Photo Upload
**Status**: ⬜ Not Started  
**Description**: Users can upload horse photos but not their own avatar.

### 13. Weather Widget Integration
**Status**: ⬜ Not Started  
**Description**: Shows placeholder "-- °C".

---

## 🟢 LOW PRIORITY

### 14. Directory/Insights Buttons
**Status**: ⬜ Not Started  
**Description**: Non-functional buttons on People page header.

### 15. Export Functionality
**Status**: ⬜ Not Started  
**Description**: Export button on People page does nothing.

### 16. Password Change In-App
**Status**: ⬜ Not Started  
**Description**: Users can only reset via email, not change in-app.

---

## ⏳ DEFERRED

### D1. Offline-First Architecture
**Status**: ⏳ Deferred to Post-MVP  
**Description**: Full offline-first with sync queue not implemented. App requires internet.  
**Reason**: Major architectural refactor. Would require rewriting all repositories.  
**Decision**: Ship MVP with online-only, add offline support in v1.1.

### D2. Email Notifications
**Status**: ⏳ Deferred  
**Description**: Invites show codes but don't send emails.  
**Reason**: Requires email service setup (Resend/SendGrid/etc).

### D3. Push Notifications
**Status**: ⏳ Deferred  
**Description**: No mobile push notifications.

### D4. Public Booking Page
**Status**: ⏳ Deferred  
**Description**: Guest booking without account (Stripe integration).

---

## Implementation Log

| Date | Item | Status | Notes |
|------|------|--------|-------|
| Dec 5 | Initial audit | ✅ | Created this document |
| Dec 5 | Billable calculation | ✅ | DB trigger `check_consumable_billable()` |
| Dec 5 | Feed/Announcements | ✅ | FeedRepository + is_pinned field |
| Dec 5 | User packages on People | ✅ | Query user_packages table |
| Dec 5 | Booking system | ✅ | BookingsRepository + calendar integration |
| Dec 5 | Feed post creation | ✅ | FAB + dialog for owners/managers |
| Dec 8 | Unified Work List | ✅ | Tasks + Issues combined, priority sorting |
| Dec 8 | Work List Assignment | ✅ | Manager/Owner can assign to staff, dropdown on create |
| Dec 8 | Work List Security | ✅ | Server-side role checks, yard membership validation |
| Dec 8 | Code Cleanup | ✅ | Removed dead tasks/issues repos and pages |
| Dec 17 | Work List Refactor | ✅ | Extracted into modular widgets (filters, card, dialogs, sheet) |
| Dec 17 | My Horses Refactor | ✅ | Extracted into modular widgets (selector, avatar, feed, tabs) |
| Dec 17 | Feed Tab Enhancement | ✅ | Recipe card layout with times, items, instructions |
| Dec 17 | Care Tab Enhancement | ✅ | Sectioned free text with suggested headers |
| Dec 17 | Contacts Tab Enhancement | ✅ | Structured contacts (Vet, Farrier, Physio, etc.) |
| Dec 17 | Dialog UX Fixes | ✅ | Inline validation errors, scrollable dialogs |
| Dec 17-18 | Invoice System | ✅ | invoice_line_items table, InvoiceRepository, models |
| Dec 17-18 | Owner Invoice Management | ✅ | Invoices tab, status filtering, edit line items, mark paid |
| Dec 17-18 | Customer Pay Now UI | ✅ | Dynamic status badges, Pay Now card, invoice period dates |
| | | | |

---

## Architecture Notes

### Database Tables (Supabase)
- `feed_posts` - Connected to UI
- `facility_bookings` - Connected to calendar
- `user_packages` - Per-horse package assignments
- `inventory` - Stock tracking (unused)
- `invoices` - Invoice storage, connected to billing UI
- `invoice_line_items` - Invoice line items (package, consumable, extra, adjustment, credit)

### Accent Color
- Primary: `#FFD66B` (warm yellow)
- Used throughout app consistently

### Supabase Project
- ID: `lktcpeupxzdciheyuhhh`
