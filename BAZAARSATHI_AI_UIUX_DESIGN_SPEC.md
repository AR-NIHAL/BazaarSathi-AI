# 🛒 BazaarSathi AI (বাজার সাথী এআই) — UI/UX Design & Product Specification
**Target Design Platform:** Google Stitch / Figma AI / Modern Mobile UI Systems  
**Product Version:** 1.0.0 (Production Blueprint)  
**Author:** Lead Principal UI/UX & Product Designer  

---

## 📌 1. Product Concept & Executive Summary

### 1.1 The Concept
**BazaarSathi AI** is a hyper-localized, AI-powered smart grocery and bazaar companion specifically engineered for Bangladeshi and South Asian marketplace cultures. 

In traditional South Asian households, grocery shopping ("কাঁচাবাজার") is an episodic, sensory, and often chaotic experience. Lists are routinely scribbled on scrap paper, exchanged via rapid voice notes, or calculated mentally. Estimating costs against fluctuating market prices, converting complex weekend feast recipes (e.g., Kacchi Biryani, Shorshe Ilish, Khichuri) into precise raw ingredient amounts, and navigating busy bazaar alleys while ticking off items on a phone is cumbersome.

**BazaarSathi AI solves this through a Multimodal AI & Offline-First Core:**
1. **Bengali & Banglish Spoken Dictation:** Shoppers speak freely in conversational Bangla or Banglish ("দুই কেজি আলু, আধা কেজি মুরগি আর এক ডজন ডিম"), and the AI extracts structured items, units, and categories.
2. **Multimodal OCR (Paper to Digital):** Shoppers snap a photo of any handwritten paper list, grocery chit, or supermarket receipt, and Gemini Vision converts it into a digital checklist.
3. **AI Recipe-to-Bazaar Generator:** Select a dish and head count (e.g., Beef Kacchi for 6 persons); the AI generates an itemized ingredient shopping list with estimated prices.
4. **Real-time Budget & Progress Tracking:** Automatically estimates market prices in Bangladeshi Taka (৳) and computes live spending as items are ticked off.
5. **Dual-Engine Resilience:** Fully usable offline inside basement bazaar stalls using local NoSQL storage (Hive) and a rule-based NLP fallback engine.

---

## 🌟 2. Complete Feature Inventory

| Feature Module | Technical Functionality | User Experience & UI Impact |
| :--- | :--- | :--- |
| **Continuous Voice Recognition** | Speech-to-Text engine tuned to `bn_BD` and `bn_IN`, continuous dictation, 5-second silence detection, and dynamic buffer. | Hands-free shopping. Micro-animated floating mic button with pulsating recording indicator. |
| **Generative AI Parsing** | Gemini 2.5 Flash model prompt-engineered for Bangladeshi bazaar nomenclature. | Converts ambiguous phrases into structured objects: item name, normalized Bengali unit, category, and BDT estimate. |
| **Rule-Based Offline Fallback** | Local regex parsing Banglish numerals, units ('kg', 'gm', 'hali', 'poya', 'adha'), and Banglish dictionary. | Zero downtime. If internet drops in the bazaar, parsing switches invisibly to offline mode. |
| **Multimodal Vision OCR** | Gemini 2.5 Flash Multimodal OCR reading Bengali/English handwritten chits & receipts. | Camera capture & gallery upload sheet with live processing progress and auto-insertion into list. |
| **Recipe-to-Bazaar Assistant** | Contextual culinary prompt estimating ingredient portions for 2–15 people. | Interactive bottom sheet with dish chips (বিরিয়ানি, খিচুড়ি, রেজালা) and visual person counter. |
| **Shopping Progress & Budget** | Live mathematical aggregator calculating progress percentage, completed vs remaining items, and BDT budget. | Gradient-infused hero card with progress bar, stat badges, and budget vs actual expense indicator. |
| **Category Grouping** | Automatic clustering: সবজি (Vegetables), মাছ-মাংস (Meat/Fish), মুদি মাল (Grocery), ফল (Fruits), অন্যান্য (Others). | Sectional list view with custom thematic icons, category headers, and clear visual hierarchy. |
| **In-Bazaar Checklist Action** | Instant check/uncheck with reactive strike-through and badge updates. | Large tap-friendly checkbox hit-boxes (minimum 44x44 pt) designed for one-handed operation. |
| **Manual Item Creation & Edit** | Full modal bottom sheet with name, quantity chips, category selector, and optional manual price. | Fast-fill chips (`১ কেজি`, `২ কেজি`, `৫০০ গ্রাম`, `১ লিটার`, `১ ডজন`) for rapid single-tap inputs. |
| **Filter & View Customization** | Horizontal pill filters + toggle for "Pending Items Only" (বাকি আইটেম). | Reduces visual clutter while actively walking inside the market. |
| **Safety Deletion & Undo** | Swipe/tap delete with temporary SnackBar featuring native "আনডু" action. | Prevents accidental data loss when jostled in crowded markets. |
| **Batch Clear** | Confirmatory dialog before resetting the list. | Prevents accidental resets between shopping sessions. |

---

## 🎨 3. Design System & Visual Identity

### 3.1 Design Philosophy: "Neo-Bengal Fresh Market"
The aesthetic blends **Scandinavian clarity** (clean spacing, high readability, high contrast) with **vibrant Bengal marketplace freshness** (coriander emerald green, turmeric gold, terracotta clay, crisp white).

### 3.2 Color Tokens
```css
/* Core Brand Colors */
--color-primary-900: #064E3B;  /* Deep Forest Emerald */
--color-primary-700: #15803D;  /* Rich Fresh Coriander Green (Main Brand) */
--color-primary-600: #16A34A;  /* Active Green Accent */
--color-primary-100: #DCFCE7;  /* Soft Mint Tint */
--color-primary-50:  #F0FDF4;  /* Ultra Light Fresh Background */

/* Accent & Utility Colors */
--color-accent-gold:  #EAB308; /* Turmeric/Mustard Gold (Budget & Highlights) */
--color-accent-amber: #F59E0B; /* Recipe Engine Warmth */
--color-danger:       #EF4444; /* Chilli Red (Delete, Stop Recording) */
--color-danger-bg:    #FEE2E2; /* Soft Red Alert */

/* Neutral Surfaces */
--color-surface-bg:   #F8FAFC; /* Clean Canvas Off-white */
--color-surface-card: #FFFFFF; /* Pure Card Surface */
--color-text-main:    #0F172A; /* Slate 900 (High-contrast Black) */
--color-text-muted:   #64748B; /* Slate 500 (Subtitles & Placeholders) */
--color-border:       #E2E8F0; /* Slate 200 (Subtle Dividers) */
```

### 3.3 Typography Stack
- **Primary Bengali Font:** `Hind Siliguri` / `Noto Sans Bengali` / `Anek Bangla` (Weights: 400 Regular, 500 Medium, 600 SemiBold, 700 Bold).
- **Secondary / Numerals Font:** `Plus Jakarta Sans` or `Inter` (for crisp financial figures, percentages, and icons).
- **Hierarchy:**
  - `Display / App Title`: 20px / SemiBold
  - `Section / Category Header`: 16px / Bold / Primary Color
  - `Card Title (Item Name)`: 16px / SemiBold / Text Main
  - `Meta / Quantity / Price`: 13px–14px / Regular & Bold
  - `Caption / Badge`: 11px–12px / Medium

### 3.4 Elevation & Radii
- **Border Radius:**
  - Cards: `16px`
  - Chips & Buttons: `12px`
  - Floating Input Bar: `24px` (Full Pill)
  - Bottom Sheets: `24px 24px 0px 0px`
- **Shadows:**
  - Soft Card Shadow: `0px 4px 12px rgba(0, 0, 0, 0.04)`
  - Elevated Hero Card: `0px 10px 20px rgba(21, 128, 61, 0.20)`
  - Floating Action Bar: `0px -4px 16px rgba(0, 0, 0, 0.06)`

---

## 📱 4. Screen-by-Screen UI/UX Architecture & Layout Specifications

```
                     ┌───────────────────────────────────┐
                     │          APP BAR / HEADER         │
                     │  🛒 স্মার্ট বাজার ফর্দ  [🍲] [📷] [➕] [🗑️] │
                     └─────────────────┬─────────────────┘
                                       │
                     ┌─────────────────▼─────────────────┐
                     │    HERO: SHOPPING SUMMARY CARD    │
                     │   [ বাজারের অগ্রগতি ]   [ ৭৫% ]    │
                     │   ███████████████████▒▒▒▒▒        │
                     │  আইটেম: ১২ টি | কেনা: ৯ | বাকি: ৩ │
                     │  💰 আনুমানিক বাজেট: ৳১,৪৫০ | খরচ: ৳৯২০ │
                     └─────────────────┬─────────────────┘
                                       │
                     ┌─────────────────▼─────────────────┐
                     │     FILTER & VIEW TOGGLE ROW      │
                     │ [সব] [সবজি] [মাছ-মাংস] [মুদি] | [👁️ বাকি] │
                     └─────────────────┬─────────────────┘
                                       │
                     ┌─────────────────▼─────────────────┐
                     │      GROUPED SHOPPING CHECKLIST   │
                     │                                   │
                     │  🥬 সবজি                           │
                     │  ┌──────────────────────────────┐ │
                     │  │ [✓] গোল আলু  ২ কেজি (~৳৮০)   │ │
                     │  │ [ ] দেশি পেঁয়াজ ১ কেজি (~৳১১০) │ │
                     │  └──────────────────────────────┘ │
                     │  🥩 মাছ ও মাংস                    │
                     │  ┌──────────────────────────────┐ │
                     │  │ [✓] ব্রয়লার মুরগি ১ কেজি (~৳২১০)│ │
                     │  └──────────────────────────────┘ │
                     └─────────────────┬─────────────────┘
                                       │
                     ┌─────────────────▼─────────────────┐
                     │      BOTTOM ACTION & VOICE BAR    │
                     │   [📷 Scan]  [ মুখে বলুন... ]  [🎤 Mic]  │
                     └───────────────────────────────────┘
```

---

### SCREEN 1: Main Dashboard (স্মার্ট বাজার ফর্দ & লাইভ ট্র্যাকিং)
**Viewport:** 390 × 844 px (Standard Mobile)  
**Goal:** Deliver instantaneous visibility into what has been bought, what remains, and current spend.

#### 1. Top Navigation Bar (`AppBar`)
- **Left:** App Brand Emblem (Cart + Leaf icon) + Title: `স্মার্ট বাজার ফর্দ 🛒` (Bold, 18px, White).
- **Right Action Buttons:**
  1. `🍲 Recipe Assistant`: Opens Recipe-to-Bazaar Generator.
  2. `📷 Scan Sheet`: Opens Camera/Gallery sheet for handwritten chits.
  3. `➕ Manual Add`: Opens full item editor modal.
  4. `🗑️ Clear All`: Confirmatory dialog to flush completed lists.
- **Background:** Rich Coriander Green Gradient (`#15803D` to `#166534`).

#### 2. Hero Progress & Budget Analytics Card (`ShoppingSummaryCard`)
- **Card Background:** Deep Emerald Gradient (`#15803D` -> `#16A34A`), 16px radius, subtle drop shadow.
- **Header:**
  - Left: Icon `analytics_outlined` + Title `বাজারের অগ্রগতি` (White, 16px).
  - Right: Floating Pill Badge `৭৫%` (Semi-transparent white container).
- **Progress Bar:** High-contrast white bar over a 25% opacity track (8px height, rounded ends).
- **Key Metrics Row (3-column stat chips):**
  - `মোট আইটেম`: ১২ টি (Bullet list icon)
  - `কেনা সম্পন্ন`: ৯ টি (Green tick circle icon)
  - `বাকি আছে`: ৩ টি (Clock pending icon)
- **Financial Strip:**
  - Translucent slate ribbon with wallet icon: `আনুমানিক বাজেট: ৳১,৪৫০` (Saffron Gold text).
  - Right side: `খরচ: ৳৯২০` (White 70% text).

#### 3. Category Filter & Focus Bar
- Horizontal scrolling chips: `সব` (All), `সবজি` (Vegetables), `মাছ-মাংস` (Fish/Meat), `মুদি মাল` (Grocery), `ফল` (Fruits), `অন্যান্য` (Others).
- Right-aligned Filter Icon: Toggle button for `শুধু বাকি আইটেম দেখুন` (Show Pending Only) which instantly collapses bought items for friction-free in-market shopping.

#### 4. Grouped Grocery Checklist (`SliverList`)
- **Category Header:** Colored typography (e.g., `সবজি`, `মাছ-মাংস`) with count badge.
- **Item Card (`ListTile` Card):**
  - **Leading Avatar:** 40px rounded avatar with category-specific icon (Eco leaf for greens, Restaurant for meats, Apple for fruits).
  - **Title:** Bengali item name (e.g., `গোল আলু`, `ইলিশ মাছ`). When checked: strike-through line + muted gray text (`#94A3B8`).
  - **Subtitle Wrap:**
    - Quantity pill: `পরিমাণ: ২ কেজি`.
    - Price tag pill: `~ ৳১০০` (Green border, light green fill).
  - **Trailing Actions:**
    - `✏️ Edit`: Opens prefilled item editor.
    - `☑️ Checkbox`: High-impact emerald checkmark (44px tap zone).
    - `❌ Delete`: Triggers undo SnackBar.

#### 5. Persistent Bottom Smart Input Bar
- Floats above screen bottom (safe area padded).
- **Left:** Camera Scan Quick Button (Emerald icon).
- **Center:** Pill Search & Voice Display Field (`মুখে বলুন বা এখানে লিখুন...`). As user speaks or types, live text appears. When text is present, a green `Send` arrow appears.
- **Right:** Circular Floating Action Button (FAB).
  - Idle: Green with Microphone icon (`mic`).
  - Recording: Pulsating Red with Stop icon (`stop`).

---

### SCREEN 2: Active Voice Recording & Dictation Overlay
**State:** Triggered when user taps the microphone FAB.

- **Visual State:** Bottom input field transforms with animated audio waveform dots.
- **Placeholder Text:** `শুনছি... ফর্দ বলুন, শেষ হলে স্টপ চাপুন` (Bold red accent).
- **Real-time Streaming:** Recognized words stream live into the input box (`"দুই কেজি আলু এক কেজি পেঁয়াজ..."`).
- **Smart Silence Timeout:** If user pauses for 5 seconds after speaking, the app automatically finalizes the input and sends it to the AI parser.
- **Manual Stop:** User can tap the red Stop FAB anytime to process immediately.

---

### SCREEN 3: AI Paper Memo & Receipt Scanner (Vision OCR Sheet)
**State:** Triggered by camera button in App Bar or Bottom Bar.

- **Bottom Sheet Component:** 24px rounded top sheet.
- **Title:** `কাগজের বাজার ফর্দ স্ক্যান করুন 📸`
- **Options List:**
  1. `ক্যামেরা দিয়ে ছবি তুলুন` (Camera Icon, Light Green Avatar, subtitle: "কাগজে লেখা বাজার ফর্দের সরাসরি ছবি তুলুন").
  2. `গ্যালারি থেকে ছবি আপলোড করুন` (Gallery Icon, Light Green Avatar, subtitle: "ফোনে সেভ করা ফর্দের ছবি সিলেক্ট করুন").
- **Processing Dialog:**
  - Animated scanner graphic / skeleton pulsing bar.
  - Subtext: `কাগজের ফর্দ স্ক্যান করা হচ্ছে...`.
  - Notification toast upon success: `ছবি থেকে ৬ টি আইটেম যুক্ত করা হয়েছে!` with green pill.

---

### SCREEN 4: AI Recipe-to-Bazaar Assistant (`RecipeBazaarDialog`)
**State:** Triggered by chef icon `🍲`.

- **Bottom Sheet Header:**
  - Icon: Soup Kitchen (`Icons.restaurant_menu`).
  - Title: `রেসিপি বাজার সহকারী 🍲` (18px Bold).
  - Close cross icon at top right.
  - Description: `আপনি যে খাবার রান্না করতে চান তা লিখুন, এআই স্বয়ংক্রিয়ভাবে প্রয়োজনীয় সব মশলা ও উপকরণের বাজার ফর্দ তৈরি করে দেবে।`
- **Input Field:**
  - Label: `খাবার / রান্নার নাম`
  - Hint: `যেমন: কাচ্চি বিরিয়ানি, ইলিশ ভুনা`
- **Popular Preset Chips:**
  - Quick-tap meal chips: `গরুর কাচ্চি বিরিয়ানি`, `খিচুড়ি ও ইলিশ মাছ`, `চিকেন রোস্ট ও পোলাও`, `খাসির রেজালা`, `সবজি নুডুলস`. Tapping any chip autofills the input.
- **Head Count Selector (Portion Scaling):**
  - Question: `কত জনের জন্য রান্না হবে?`
  - Horizontal chip selectors: `২ জন`, `৪ জন`, `৬ জন`, `৮ জন`, `১০ জন`, `১৫ জন`.
- **Primary CTA Button:**
  - Full-width 48px height elevated button: `✨ উপকরণের ফর্দ তৈরি করুন` (Green `#15803D`, white text, sparkle icon).
- **Result:** AI calculates exact meats, rice, onions, ginger-garlic, whole spices, and oil quantities with prices and injects them into the checklist.

---

### SCREEN 5: Add / Edit Item Bottom Sheet (`AddEditItemDialog`)
**State:** Triggered by `➕` in App Bar or `✏️` on an existing item card.

- **Header:** `নতুন আইটেম যোগ করুন ➕` or `আইটেম পরিবর্তন করুন ✏️`.
- **Item Name Input:** `আইটেমের নাম` with bag icon (e.g., `রুই মাছ`, `সয়াবিন তেল`).
- **Two-Column Row:**
  - **Left (60%):** `পরিমাণ` (Quantity) e.g., `১ কেজি`, `৫০০ গ্রাম`.
  - **Right (40%):** `মূল্য (৳)` (Estimated or actual price) e.g., `৩৫০`.
- **Quick Quantity Chips:**
  - Single-tap preset buttons: `১ কেজি`, `২ কেজি`, `৫০০ গ্রাম`, `১ লিটার`, `১ ডজন`, `৪ টি`.
- **Category Picker:**
  - Horizontal choice chips: `সবজি`, `মাছ-মাংস`, `মুদি মাল`, `ফল`, `অন্যান্য`. Selected category is filled with dark green `#15803D`.
- **Submit Button:** `তালিকায় যোগ করুন` (Add to list) or `পরিবর্তন সংরক্ষণ করুন` (Save Changes).

---

### SCREEN 6: Empty State Canvas
**State:** When `_bazaarBox.isEmpty == true`.

- **Center Graphic:** Large minimalist shopping cart outline icon (`#CBD5E1`, 80px).
- **Header:** `আপনার বাজারের ফর্দ খালি!`
- **Subtitle:** `নিচে মাইক চেপে, ছবি তুলে বা রেসিপি থেকে আইটেম যোগ করুন।`
- **Quick Action Shortcut Buttons:**
  - Button 1: `📷 কাগজের ফর্দ স্ক্যান` (Light green button, green border).
  - Button 2: `🍲 রেসিপি সহকারী` (Light orange button, orange border).

---

## 🤖 5. Copy-Paste Ready Prompts for Google Stitch / Figma AI

To generate high-fidelity UI/UX mockups in **Google Stitch**, copy and paste the standardized prompts below:

### Prompt 1: Main Dashboard & Active Shopping UI
```text
Design a hyper-modern mobile grocery checklist screen for a Bangladeshi app named "BazaarSathi AI". 
Viewport: 390x844px. 
Color Palette: Fresh coriander emerald green (#15803D), off-white background (#F8FAFC), warm turmeric gold (#EAB308), crisp card white (#FFFFFF). 
Typography: Clean Bengali typography (Hind Siliguri) combined with Inter numerals.

Top App Bar:
- Emerald green gradient background with title "স্মার্ট বাজার ফর্দ 🛒" in bold white.
- Action icons on right: Recipe Chef Pot icon, Camera Scan icon, Plus icon, Trash bin icon.

Hero Section (Top Card):
- A gradient card (#15803D to #16A34A) with 16px border-radius and soft shadow.
- Title: "বাজারের অগ্রগতি" with a white translucent badge showing "৭৫%".
- High contrast progress bar showing 75% progress.
- 3 stat counters: "মোট আইটেম: ১২ টি", "কেনা সম্পন্ন: ৯ টি", "বাকি আছে: ৩ টি".
- Bottom strip: Wallet icon with "আনুমানিক বাজেট: ৳১,৪৫০" in golden yellow, and "খরচ: ৳৯২০".

Filter Row:
- Horizontal scrolling pill chips: "সব", "সবজি", "মাছ-মাংস", "মুদি মাল", "ফল". Active chip in dark green.
- Right side toggle icon for "বাকি আইটেম" (pending items filter).

Grouped List View:
- Section header "🥬 সবজি" (Vegetables):
  * Card 1: Checkbox checked, strikethrough text "গোল আলু", quantity "২ কেজি", price badge "~ ৳৮০", edit icon.
  * Card 2: Checkbox unchecked, title "দেশি পেঁয়াজ", quantity "১ কেজি", price badge "~ ৳১১০", edit icon, trash icon.
- Section header "🥩 মাছ ও মাংস" (Fish & Meat):
  * Card 3: Checkbox checked, strikethrough text "ব্রয়লার মুরগি", quantity "১ কেজি", price badge "~ ৳২২০".

Bottom Sticky Action Bar:
- White floating bar with rounded search pill: camera scan icon on left, placeholder "মুখে বলুন বা এখানে লিখুন...", and an emerald circular floating mic button on the right.
```

---

### Prompt 2: Recipe-to-Bazaar AI Generator Bottom Sheet
```text
Design a modern bottom sheet modal for an AI Grocery Assistant app named "BazaarSathi AI". 
Theme: Clean, warm culinary aesthetic with soft green and amber accents. 
Viewport: 390x600px bottom sheet with 24px rounded top corners and drag handle.

Header:
- Icon: Cooking pot / chef hat in emerald green.
- Title: "রেসিপি বাজার সহকারী 🍲" (18px, bold).
- Subtitle: "আপনি যে খাবার রান্না করতে চান তা লিখুন, এআই স্বয়ংক্রিয়ভাবে প্রয়োজনীয় সব মশলা ও উপকরণের বাজার ফর্দ তৈরি করে দেবে।" (13px, muted slate).
- Close 'X' icon at top right.

Input Field:
- Soft gray fill input field with soup bowl icon.
- Label: "খাবার / রান্নার নাম".
- Pre-filled text: "গরুর কাচ্চি বিরিয়ানি".

Quick Suggestion Chips:
- Horizontal wrap of popular Bangladeshi dishes: "খিচুড়ি ও ইলিশ মাছ", "চিকেন রোস্ট ও পোলাও", "খাসির রেজালা", "সবজি নুডুলস". Light green border and subtle green background.

Head Count Section:
- Subtitle: "কত জনের জন্য রান্না হবে?" (14px, bold).
- Horizontal choice chips: "২ জন", "৪ জন", "৬ জন" (Selected in emerald green), "৮ জন", "১০ জন", "১৫ জন".

Call to Action:
- Full-width button with 12px border radius in rich green (#15803D).
- Label: "✨ উপকরণের ফর্দ তৈরি করুন" (16px bold white text with sparkle icon).
```

---

### Prompt 3: Paper Memo Scanner & Vision OCR Processing View
```text
Design an AI document scanning bottom sheet for a mobile app named "BazaarSathi AI". 
Purpose: Converts handwritten paper bazaar notes and supermarket slips into digital checklist items.

Layout:
- 24px rounded white bottom sheet.
- Header: "কাগজের বাজার ফর্দ স্ক্যান করুন 📸" in bold dark slate.
- Option Tile 1: Camera capture with a circular green icon badge, Title "ক্যামেরা দিয়ে ছবি তুলুন", subtitle "কাগজে লেখা বাজার ফর্দের সরাসরি ছবি তুলুন".
- Option Tile 2: Gallery picker with a circular green photo library badge, Title "গ্যালারি থেকে ছবি আপলোড করুন", subtitle "ফোনে সেভ করা ফর্দের ছবি সিলেক্ট করুন".
- Visual separator.
- Animated preview card showing an illustrated paper memo being scanned by an emerald laser grid, with a progress bar and label "কাগজের ফর্দ স্ক্যান করা হচ্ছে...".
```

---

## 💡 6. UX Micro-Interactions & Usability Guidelines for Bazaar Environments

1. **One-Handed Thumb Zone Optimization:**
   - Bazaar shoppers hold shopping bags in one hand and the smartphone in the other.
   - All critical actions (Checkbox ticking, Mic activation, Camera scan) are positioned in the bottom 40% of the screen.
2. **Haptic Feedback:**
   - Provide a short haptic vibration (`HapticFeedback.lightImpact()`) upon checking off an item to give tactile confirmation in noisy wet markets.
3. **Contrast Ratio (Outdoor Sunlight Readability):**
   - High contrast text (`#0F172A` on `#FFFFFF` and `#FFFFFF` on `#15803D`) ensures full legibility in bright, outdoor vegetable markets.
4. **Resilient Error States:**
   - If AI quota runs out or network signal is shielded by concrete bazaar basements, gracefully show an offline banner without blocking the user: `অফলাইন নিয়মে আইটেম যোগ করা হয়েছে!`
5. **Undo Safety Net:**
   - Deletion does not trigger blocking modals; it triggers an instant action accompanied by a 4-second SnackBar with an `আনডু (Undo)` action.
