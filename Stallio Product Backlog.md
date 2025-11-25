# **Product Backlog & Detailed Sprint Stories**

Project: Stallio  
Version: 5.0 (Definitive \- Aligned with Stallio Spec)  
Phase: MVP (Phase 1\)

## ** Project-Wide Requirements**

**\[S0-01\]** As a **PM**, I want **all UI to adhere to the brand guide**. So that **the app feels like a single, premium "Stallio" product**. I know this is done when:

1. All screens MUST adapt to system-theme by default (light/dark mode) 
2. All interactive elements MUST use the "Stallio Green" accent.  
3. Layouts MUST be card-based, clean, and use the 'underglow' effect.

## ** Sprint 1: Foundation & Yard Setup**

**Goal:** Establish the offline-first infrastructure AND onboard our first user. By the end, an Owner can create an account, define their yard, and land on a home screen.  
**\[S1-01\]** As a **\[Flutter\] System**, I want to **initialize the Flutter App with a Local Database (drift)**. So that **the app can function without internet access**. I know this is done when:

1. The app launches on iOS, Android, and Web.  
2. The drift database is initialized.

**\[S1-02\]** As a **\[Supabase\] System**, I want to **initialize the Remote Database Schema**. So that **I have a central source of truth to sync with**. I know this is done when:

1. The Supabase project is live.  
2. The yards table is created.  
3. The profiles table is created (extending auth.users).

**\[S1-03\]** As a **\[Supabase\] System**, I want to **implement initial RLS Policies**. So that **the database is secure from day one**. I know this is done when:

1. A user can only see/edit their *own* profile.  
2. A user associated with a yard\_id can *only* see data matching that yard\_id.

**\[S1-04\]** As a **\[Flutter\] New Owner**, I want to **create a secure account (Signup)**. So that **I can become the first user**. I know this is done when:

1. The Email/Password signup screen (adhering to S0-01) is functional.  
2. It connects to Supabase Auth.  
3. On success, it creates a user in auth.users and triggers the creation of a profiles row.

**\[S1-05\]** As a **\[Flutter\] Owner**, I want to **go through a "Yard Creation" wizard**. So that **I can set up my business in the app**. I know this is done when:

1. After signup, the user is prompted: "Create Your Yard".  
2. The form (yard\_name, yard\_address) saves data to the *local* yards table.

**\[S1-06\]** As a **\[Flutter\] System**, I want to **implement the local sync\_queue**. So that **I can track actions that happened while offline**. I know this is done when:

1. The table exists with columns: id, table, operation, payload, created\_at.  
2. The "Yard Creation" (S1-05) writes to this queue.

**\[S1-07\]** As a **\[Flutter\] System**, I want to **build the Background Sync Service (Push & Pull)**. So that **local data gets to the server and back**. I know this is done when:

1. The service detects a network connection.  
2. It pushes the sync\_queue to Supabase.  
3. It pulls new data from Supabase.  
4. The "Yard Creation" data from S1-05 syncs successfully.

**\[S1-08\]** As a **\[Flutter\] Owner**, I want to **land on a basic "Home" screen**. So that **I have a central navigation point**. I know this is done when:

1. After login/setup, I see a simple dashboard (adhering to S0-01).  
2. The screen is a skeleton with a "Setup Checklist" (e.g., "Next: Configure Services").

## **🗓️ Sprint 2: Yard Configuration & Setup Wizard**

**Goal:** The Owner can set up their *entire* business. All services, prices, packages, and invoice settings are configured before any other users are invited.  
**\[S2-01\]** As a **\[Supabase\] System**, I want to **create consumable\_types & livery\_packages tables**. So that **the Owner can store their business logic**. I know this is done when:

1. The consumable\_types table is created (with columns for name, stock\_unit, usage\_unit, ratio, price\_per\_usage).  
2. The livery\_packages table is created (with columns for name, base\_price, included\_items (JSONB)).

**\[S2-02\]** As a **\[Flutter\] Owner**, I want to **define my "a-la-carte" Consumables (Extras)**. So that **I can set prices and units for items**. I know this is done when:

1. A "Yard Settings" \-\> "Consumables" screen exists.  
2. I can create "Hay" with: Stock Unit \= "Bale", Usage Unit \= "Slice", Ratio \= 8, Price \= £0.50.  
3. This action works fully offline (saves to local DB & syncs).

**\[S2-03\]** As a **\[Flutter\] Owner**, I want to **create "Livery Packages"**. So that **I can bundle services for my customers**. I know this is done when:

1. A "Create Package" screen exists.  
2. I can create a "Full Livery" package with a Base Price (£450).  
3. I can use checkboxes to link consumables (e.g., "Includes Hay", "Includes Arena").  
4. This action works fully offline and syncs.

**\[S2-04\]** As a **\[Supabase\] System**, I want to **create an invoice\_settings table**. So that **the Owner can store their invoice details**. I know this is done when:

1. The table is created to store logo\_url, bank\_details, payment\_terms, billing\_day, cutoff\_buffer.

**\[S2-05\]** As a **\[Flutter\] Owner**, I want to **configure my Invoice Details**. So that **my invoices look professional**. I know this is done when:

1. An "Invoice Settings" screen exists.  
2. I can upload a Yard Logo (to Supabase Storage).  
3. I can add Bank Details / Payment Info.  
4. I can set my Billing Day and Cut-off Buffer.  
5. This action works fully offline and syncs.

## **🗓️ Sprint 3: Team Onboarding & Operations**

**Goal:** The Owner can now invite their team and customers, assign them to packages, and Staff can begin logging daily work.  
**\[S3-01\]** As a **\[Supabase\] System**, I want to **create the Invite System logic**. So that **invites are secure and link to the right yard/role**. I know this is done when:

1. An invites table is created.  
2. An Edge Function exists to generate a token and send an email.

**\[S3-02\]** As a **\[Flutter\] Owner**, I want to **invite a new Staff, Manager, or User**. So that **I can onboard my team and customers**. I know this is done when:

1. I can input an email & role.  
2. If the role is "User", I MUST select their "Livery Package" (from S2-03) from a dropdown.  
3. The invite (S3-01) is successfully triggered.

**\[S3-03\]** As a **\[Flutter\] New User**, I want to **sign up with an invite**. So that **I am added to the Yard and my account is set up**. I know this is done when:

1. I can register using the token from the invite.  
2. The system correctly links my profile to the yard\_id and package\_id.

**\[S3-04\]** As a **\[Flutter\] User/Staff**, I want to **create a Horse Profile**. So that **I can store my horse's details**. I know this is done when:

1. A user can add their own horse.  
2. The action works fully offline.  
3. RLS policies (from S1-03) are proven to work: Staff see all horses, Users only see their own.

**\[S3-05\]** As a **\[Flutter\] Staff**, I want to **log a Consumable usage for a horse**. So that **the user gets billed *if required***. I know this is done when:

1. I can select a Horse \-\> Select an Item ("Hay") \-\> Enter Qty (2 slices).  
2. This action MUST work fully offline.

**\[S3-06\]** As a **\[Supabase\] System**, I want to **automatically check if a log is "Billable"**. So that **I only charge for extras not in a user's package**. I know this is done when:

1. A database function or trigger runs when a log (S3-05) syncs.  
2. It checks the user.package.included\_items.  
3. If "Hay" is included, the log is saved with is\_billable \= false.  
4. If "Hay" is NOT included, the log is saved with is\_billable \= true.

## **🗓️ Sprint 4: Finance & Analytics**

**Goal:** The billing cycle runs successfully and the Owner can see their financial health.  
**\[S4-01\]** As a **\[Supabase\] System**, I want to **generate Monthly Invoices (Edge Function)**. So that **I don't have to calculate bills manually**. I know this is done when:

1. A pg\_cron job runs on the Owner-set Billing Day.  
2. The function gets the user.package.base\_price.  
3. It sums all logs where is\_billable \= true & created\_at is before the cut-off date.  
4. It generates an invoice (PDF or data) with details from invoice\_settings.

**\[S4-02\]** As a **\[Flutter\] User**, I want to **view and pay my Invoice**. So that **I know what I owe**. I know this is done when:

1. A "My Bills" screen shows a list of invoices.  
2. I can see a full breakdown of charges.  
3. The Owner can mark the invoice as "Paid".

**\[S4-03\]** As a **\[Flutter\] Owner**, I want to **view the Financial Dashboard**. So that **I can see the business health**. I know this is done when:

1. The Home screen populates with a Revenue Chart (1m/3m/1y).  
2. A list of "Unpaid Invoices" (Debtors) is clearly visible.

**\[S4-04\]** As a **\[Supabase\] System**, I want to **create an inventory table & "Burn Rate" logic**. So that **the Owner can track stock levels**. I know this is done when:

1. An inventory table tracks current\_stock\_level (in stock\_units).  
2. A DB function updates this stock level (e.g., \-0.25 bales) on new log syncs.  
3. A DB view is created to calculate "average daily use" for the "Burn Rate".

**\[S4-05\]** As a **\[Flutter\] Owner**, I want to **view my Inventory "Burn Rate"**. So that **I know when to re-order supplies**. I know this is done when:

1. The dashboard shows "Hay: 4.5 Bales remaining".  
2. It shows "Avg 2.2 bales/day" (from S4-04).  
3. It displays a "Re-order in 2 days" alert.

## **🗓️ Sprint 5: Community & External**

**Goal:** Add value-add features like bookings and communication.  
**\[S5-01\]** As a **\[Flutter\] User**, I want to **book an Arena Slot (Internal)**. So that **I can ride without clashing**. I know this is done when:

1. I can see a Calendar View of available slots.  
2. The logic correctly checks my user.package.included\_items for "Arena".  
3. If "Arena" is not included, a-la-carte charge is added to my next bill.

**\[S5-02\]** As a **\[Supabase\] System**, I want to **create a Public Booking Endpoint**. So that **guests can book without an account**. I know this is done when:

1. An Edge Function exists to check availability and take a payment (e.g., Stripe).  
2. It inserts a booking with user\_id \= null.

**\[S5-03\]** As a **\[Flutter\] Guest**, I want to **book an Arena Slot (Public Web Link)**. So that **I can hire the arena**. I know this is done when:

1. A public-facing Flutter Web page (no login) exists.  
2. It successfully calls the (S5-02) endpoint.

**\[S5-04\]** As a **\[Flutter\] Staff**, I want to **post to the Social Feed**. So that **I can announce yard news**. I know this is done when:

1. I can create a post with text and an optional photo.  
2. All users in my Yard can see the post.

**\[S5-05\]** As a **\[Flutter\] User**, I want to **report an Issue**. So that **maintenance problems get fixed**. I know this is done when:

1. I can submit a report with a photo, description, and location.  
2. Staff see a list of "Open Issues" which they can mark as "Resolved".