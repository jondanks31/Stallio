# **Project Specification: Stallio**

Version: 2.0 (Definitive)  
Architect: Gemini  
Product Manager: You  
Developer: Windsurf

## **1\. Project Mission & Name**

* **Project Name:** **Stallio** (provisional)  
* **Mission:** To create a modern, reliable, and user-friendly management system for UK equestrian yards. The system's primary differentiator will be its "offline-first" reliability, coupled with a premium, professional UI. It will solve core problems around billing, consumables tracking, and team communication.

## **2\. Brand & UI/UX Vision**

This is a critical component and should inform all frontend development.

* **Name:** Stallio  
* **Feel:** Premium, fast, and professional. Simple, minimum navigational clicks.  
* **Theme:** The primary interface should be the typical light (whites, light greys) and dark (deep greys/blacks) mode, defaulting to the user’s system settings but also selectable via a theme toggl  
* **Layout:** Clean, card-based layouts with generous padding and fully rounded corners.  
* **Accent Color:** A vibrant, energetic green (e.g., \#34D399 / Tailwind's emerald-400). This is our "Stallio Green." It must *not* be a pale lime green.  
* **Effects:** Use the accent color for an "underglow" effect (e.g., box-shadow) on hovered or active elements (buttons, chart highlights, etc.). Primary pages should have a soft, subtle underglow in the background, with any elements on top separate from the background effects.  
* **Iconography:** Use a clean, thin-line, modern icon set (e.g., Phosphor Icons or similar).  
* **Reference:** The UI/UX for https://nixtio.com/cases/crextio/ is the primary visual target. We are adapting this clean, high-contrast, data-dense style for our own platform.

## **3\. Core Technical Stack**

* **Frontend (Apps):** Flutter (iOS, Android, Web).  
* **Backend (BaaS):** Supabase.  
* **Local Database (Offline):** drift for Flutter.

## **4\. Core Architecture: Offline-First & Multi-Tenancy**

### **4.1. Multi-Tenancy (Supabase)**

* **Tenant Separation:** Achieved using a yard\_id column on all tenant-specific tables (e.g., horses, bookings, invoices).  
* **Security:** Enforced using **PostgreSQL Row-Level Security (RLS)**. This is a non-negotiable database-level rule.  
  * *Example Policy:* "A user can only SELECT from the horses table WHERE the horses.yard\_id matches their own profiles.yard\_id."

### **4.2. Offline-First Sync Engine (Flutter)**

This is the most complex technical part of the build.

* **Local DB:** The Flutter app will use a local drift database as its **single source of truth**. The UI *only* reads from/writes to this local DB.  
* **Sync Queue:** All new or changed data is written to a local sync\_queue table on the device.  
* **Sync Process:**  
  1. A background service detects a network connection.  
  2. **Pull:** The app first pulls down any changes from Supabase to update its local DB.  
  3. **Push:** The app then processes its local sync\_queue in **strict FIFO order**, sending each change to Supabase.  
* **Conflict & Deletion Strategy:**  
  * **Logs (Append-Only):** All consumables and care logs are INSERT-only.  
  * **Deletions (Soft Delete):** When a user "deletes" a log, the app sets is\_deleted \= true. The UI hides it, and billing functions ignore it, retaining a full audit trail.  
  * **Edits (Last Write Wins):** For all other edits (e.s., updating a horse profile), the last synced change (Last Write Wins) will be the final state.

## **5\. User Roles & Permissions (Inherited)**

Enforced by Supabase RLS policies.

* **Yard Owner:** Full read/write/financial/admin access for their yard\_id.  
* **Yard Manager:** All permissions *except* high-level financial/subscription management. (Inherits Staff & User).  
* **Staff:** Can view user/horse details, add logs, manage issues. (Inherits User).  
* **User (Customer):** Can manage their own details, their horses, book arenas, and view invoices.  
* **Critical Permission Rule:** **Only** a User can UPDATE their own horse's sensitive care information (e.g., diet\_notes). All other roles have read-only access to these specific fields.

## **6\. Core Business Logic & Data Models**

### **6.1. Livery Packages (Critical Logic)**

This is the core of the billing system.

* An **Owner** must first create "Livery Packages" (e.g., "Full Livery", "DIY Livery").  
* A livery\_package will have a package\_name, a base\_price (e.g., £500), and a list of *included services* (e.g., "Includes Hay", "Includes Straw", "Includes Arena").  
* When an **Owner** invites a new **User**, they *must* assign them to one of these packages.

### **6.2. Inventory & Unit Conversion**

* Owners must configure their consumables in the Setup Wizard.  
* The consumable\_types table must store:  
  * name: "Hay"  
  * stock\_unit: "Bale"  
  * usage\_unit: "Slice"  
  * ratio: 8 (i.e., 8 Slices per Bale)  
  * price\_per\_usage\_unit: £0.50 (This is the a-la-carte price)  
* This allows Staff to log "2 slices" while the Owner's dashboard tracks "0.25 bales" used.

## **7\. Key Feature Implementation**

### **7.1. Automated Invoicing (Backend: Supabase)**

This logic is *entirely* dependent on **Section 6.1**.

* **Trigger:** A scheduled pg\_cron task (e.g., on the 1st of the month) will run a Supabase Edge Function.  
* **Billing Cut-off:** The function will adhere to the Owner-set "Billing Cut-off Window" (e.g., 5 days) to allow for sync delays.  
* **Invoice Logic:** For each User, the function will:  
  1. Get the user.package.base\_price (e.g., £500).  
  2. Query all logs for that user before the cut-off date.  
  3. For each log, a **database function** will check: "Is this item (hay) included in this user's package?"  
  4. If **YES**, the log is ignored (cost is 0).  
  5. If **NO**, the price\_per\_usage\_unit is added to the total.  
  6. The final invoice (Base Price \+ all billable extras) is generated and saved.

### **7.2. Owner/Manager Dashboard (Frontend: Flutter)**

This is the primary landing page for Owner/Manager roles, matching the UI/UX vision.

* **Financial Analytics:** Revenue charts (1m, 3m, 6m, 1y), list of "Unpaid Invoices" (Debtors), and flags for "Consistently Late" payers.  
* **Inventory Analytics:** "Burn Rate" tracking.  
  * Shows: "Hay: 4.5 Bales remaining".  
  * Calculates: "Avg. 2.2 bales/day".  
  * Alerts: "Re-order in 2 days".

### **7.3. User Invites (Backend: Supabase)**

* An Edge Function will generate a secure, single-use invite token, storing it in an invites table with the yard\_id, role, and package\_id (if role=User).  
* New users signing up with this token will be automatically assigned to the correct yard and package.

### **7.4. Social Feed & Issue Reporting**

* **Social Feed:** A simple, internal feed (powered by Supabase Realtime) for yard announcements.  
* **Issue Reporting:** Users can log issues (e.g., "Broken fence") with a photo and location, which Staff can then track and resolve.

### **7.5. Arena Bookings**

* If Arena bookings are enabled, users can book slots (duration set by Yard Owner) using an internal booking system linked to the yard. All users can see taken or available slots.  
* A simple approval system should be included should a user wish to book the arena for more than X amount of slots, such as for lessons or clinics. When submitting an approval request, users can add a comment saying why they need it.  
* Arena can be free under certain packages, or as an add on price (E.e., Part Livery package includes arena hire for free, but DIY package requires the Arena to be added on for an additional £10/month)S

