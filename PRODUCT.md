# 💊 QuickMed — Product Specification

QuickMed is an on-demand, hyper-local medicine delivery mobile application designed to bridge the gap between local pharmacies and customers. The product focuses on speed, reliability, and ease of use, with a core value proposition of delivering essential medicines "in a whoosh."

Initially optimized and targeted for **Kota City, Rajasthan** (a major education hub in India with a high density of student residents, hostels, and coaching centers), the product addresses the urgent healthcare accessibility needs of young students, busy parents, and elderly citizens.

---

## 🎯 Target Audience & User Personas

1. **The Kota Student:** 
   * *Background:* Lives in a hostel or PG away from family.
   * *Pain Point:* Falls ill suddenly, has no family nearby to buy medicines, and lacks transport.
   * *Need:* Extremely fast delivery (under 30 minutes) of common OTC and prescription drugs without leaving their room.
2. **The Elderly Resident:**
   * *Background:* Lives alone or with an aging spouse in residential colonies like Nayapura or Talwandi.
   * *Pain Point:* Difficulty walking or driving to the market, especially during extreme summers or winters.
   * *Need:* Simple, clear interface with text scaling, and reliable order tracking.
3. **The Busy Parent / Working Professional:**
   * *Background:* Balances a tight job schedule and household responsibilities.
   * *Pain Point:* Forgets to replenish regular chronic disease medicines (e.g., blood pressure or diabetes pills).
   * *Need:* Quick search by salt or brand, recurring order histories, and seamless cart checkouts.

---

## 📱 Core Features & User Journeys

### 1. Welcome & Onboarding
* **Splash Screen:** A premium, short (3-second) animated or transition-based entrance. A gradient branding theme displays the QuickMed logo, immediately setting a professional tone before routing the user.
* **Feature Carousel:** A multi-page interactive slider explaining key values:
  * "Quickest Delivery" (hyper-local partner network).
  * "Salt-based Search" (helping users find cheaper generic alternatives).
  * "Live GPS Tracking" (real-time delivery status).
* **CTA Navigation:** Straightforward navigation directing users to registration/login.

### 2. Dual-Channel Authentication
* **Mobile OTP Authentication:** Quick sign-in using phone numbers, triggering a secure One-Time Password (OTP) verification screen.
* **Email & Password Flow:** Backwards-compatible sign-up/sign-in form with real-time email format validation (`email@domain.com`) and error alerts.
* **Social Login Stubs:** Single-tap login options for Google and Apple accounts to expedite the onboarding process.

### 3. Home & Store Dashboard
* **Promotional Banner:** Visual slides presenting active healthcare discount codes, seasonal alerts, or platform announcements.
* **Category Grid:** Quick filter tiles (e.g., "Daily Essentials", "OTC Drugs", "Fever & Cold", "First Aid") for rapid catalog browsing.
* **Medicine Showcase:** Grid representation of available drugs featuring:
  * Product images.
  * Precise brand names.
  * Real-time price tags (₹ INR).
  * A direct "Add to Cart" CTA.

### 4. Smart Salt & Brand Search
* **Search Execution:** Live search bar supporting queries by brand name (e.g., *Paracetamol*) or chemical composition/salt (e.g., *Acetaminophen*).
* **Filtering & Sorting:** Auto-suggestions, quick clearing, and results matching designed to run instantly even under low bandwidth.

### 5. Persistent Cart & Order Summary
* **Quantity Selectors:** Interactive controls in the cart to increment, decrement, or delete items.
* **Transparent Pricing:** An itemized receipt outlining:
  * Item Subtotal.
  * Fixed delivery-partner fee (e.g., ₹20).
  * Platform administrative fee (e.g., ₹5).
  * Final "Amount to Pay" (₹).
* **Delivery Address:** Single-pane display of the active delivery location.

### 6. Real-Time Order Tracking
* **Google Maps Integration:** Visual map displaying:
  * Live location of the delivery partner.
  * Customer's drop-off point.
  * Dynamic green polyline routing.
* **Partner Contact Pane:** Details of the assigned rider (e.g., Ramesh Kumar) with instant call/message shortcuts and estimated arrival time (ETA).

### 7. Profile & Order History
* **User Information:** Displays basic profile stats, delivery addresses, and settings.
* **Draggable Order History Sheet:** A bottom sheet that pulls up to reveal a list of historical orders, each complete with unique Order IDs (`#QM1024`), order date, status tags ("Delivered", "Cancelled", "In Progress"), and total bill sums.

---

## ⚠️ Current Feature Gap Analysis (Mock vs. Production)

| Feature | Current UI State | Missing Production Backend Logic |
|---|---|---|
| **Catalog Data** | Fully designed grid; renders random prices and names. | Needs connection to a database table storing medicine inventories, categories, and stock counts. |
| **Search Engine** | Basic client-side string filter. | Needs full-text search capability (e.g., Supabase pg_trgm or Meilisearch) to match typos and salt descriptions. |
| **Cart Integration** | Uses local `setState` isolated on the Cart page; "Add" buttons on landing screen do not sync. | Needs a centralized State Management solution (e.g., a shared `CartCubit`) connecting the landing screen and persistent database sync. |
| **Authentication** | Dual-initialized. Firebase email sign-up works; Supabase OTP is stubbed. | Need to consolidate auth state under one provider and write session persistence logic. |
| **Live Tracking** | Emulates movement by looping over pre-configured coordinates in Kota. | Needs integration with real-time GPS stream APIs (e.g., WebSockets, Supabase Realtime, or Firebase RTDB) connected to a rider companion app. |
| **Payment Gateway** | Hard-coded bill values and instant checkout routing. | Needs integration with payment processors like UPI, Razorpay, or Stripe. |

---

## 🚀 Product Roadmap & Future Scope

### Phase 1: Core Consolidation (Short-Term)
1. **Centralized Cart State:** Connect the product grid directly to a shared cart manager.
2. **Prescription Upload System:** Add a file selector/camera capture feature permitting users to attach medical prescriptions (Rx) for restricted medications.
3. **Database Integration:** Move all medicine items and categories to Supabase/Firestore tables.

### Phase 2: Hyper-Local Enhancements (Mid-Term)
1. **Rider Routing Optimization:** Real GPS updates for riders and geo-fenced boundaries for Kota neighborhoods (Talwandi, Nayapura, Vigyan Nagar, Landmark Area).
2. **Pharmacist Live Chat:** An in-app support chat allowing students or elderly users to message a pharmacist with questions about drug dosage and alternatives.
3. **Smart Address Book:** Support for tagging multiple addresses (e.g., "Hostel", "Library", "Home", "Parents' House").

### Phase 3: Engagement & Growth (Long-Term)
1. **Chronic Pill Subscriptions:** Automatic monthly refills and delivery scheduling for recurring prescriptions.
2. **Health Tracking Dashboard:** Basic vitals logger (Blood Sugar, Blood Pressure) with automated reminders to order diagnostics.
