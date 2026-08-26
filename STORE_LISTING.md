# Google Play Store & Apple App Store Listing Package

> **App Name:** ShiftPay  
> **Package ID:** `com.bondaanh.shiftpay`  
> **Category:** Finance / Productivity  
> **Target Audience:** Shift workers, nurses, factory employees, hospitality staff, emergency responders, contractors

---

## 1. Store Text & Metadata

### 🏷️ App Title *(30 characters maximum)*
```text
ShiftPay: Shift & Overtime Pay
```

### 📝 Short Description *(80 characters maximum)*
```text
Calculate shift wages, overtime hours, night differentials & track your pay.
```

### 📄 Full Description *(Google Play Store / App Store)*
```text
Track your shift hours, calculate gross earnings, overtime, and night differentials accurately with ShiftPay — the clean, minimalist shift wage calculator built for nurses, hospitality staff, emergency responders, factory workers, and hourly professionals.

Whether you work rotating day shifts, 12-hour hospital rotations, overnight grave shifts, or split schedules, ShiftPay eliminates calculation errors and gives you complete visibility over your earned wages in seconds.

⚡ KEY FEATURES

⏱️ FAST & ACCURATE SHIFT CALCULATIONS
• Simple, one-tap clock-in and clock-out time pickers.
• Handles overnight shifts crossing midnight seamlessly.
• Configurable unpaid breaks (0m, 15m, 30m, 45m, 60m) deducted automatically.
• One-tap quick presets: 9–5 Day, 3–11 Evening, 11–7 Night, 12h Day, and 12h Night.

⚡ AUTOMATIC OVERTIME ENGINE
• Set standard daily thresholds (e.g. 8.0 hrs/day).
• Customizable overtime multipliers (1.5x Time & Half, 2.0x Double Time, or custom rates like 1.75x or 2.5x).
• Instant split breakdown of Regular vs Overtime hours & pay.

🌙 NIGHT DIFFERENTIAL BONUS PREMIUM
• Configure exact night premium windows (e.g. 10:00 PM – 6:00 AM).
• Add custom hourly bonuses (+$2.50/hr, +$5.00/hr) applied only during eligible night hours.

💰 TIPS, ALLOWANCES & DEDUCTIONS
• Add flat allowances or tips directly to any shift.
• Account for meal deductions, uniform fees, or parking costs.
• Live Effective Hourly Rate indicator ($/hr).

📊 SHIFT HISTORY & ANALYTICAL WEEKLY REPORTS
• Save all logged shifts directly to your local device.
• Instant clipboard summary export ready to text, email, or archive.
• Comprehensive Weekly analytical breakdown: gross earnings, total hours, average rate, and overtime metrics.

🎨 CLEAN, MODERN & BEAUTIFUL DESIGN
• High-contrast, minimalist interface inspired by modern design standards.
• Instant Light & Dark mode toggle.
• Multi-currency support: USD ($), GBP (£), EUR (€), JPY (¥), KHR (៛), CAD ($), AUD ($), and more.

🔒 PRIVATE & OFFLINE-FIRST
• All your shift data remains safely on your device.
• Works 100% offline without needing internet access.

Take control of your shift wages and make sure you get paid every dollar you earned with ShiftPay!
```

---

## 2. Store Graphic Assets

All store graphic assets are prepared and optimized in the repository:

| Asset | Specifications | Path |
| :--- | :--- | :--- |
| **App Icon** | `512 × 512 PNG (32-bit, max 1024KB)` | [`assets/store/icon_512x512.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/icon_512x512.png) |
| **Feature Graphic** | `1024 × 500 PNG (Rich Obsidian Grid & UI Preview)` | [`assets/store/feature_graphic_1024x500.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/feature_graphic_1024x500.png) |
| **Screenshot 1: Dashboard** | `1080 × 2400 PNG (Gross pay hero & time pickers)` | [`assets/store/screenshots/01_shift_calculator_dashboard.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/screenshots/01_shift_calculator_dashboard.png) |
| **Screenshot 2: Rules Modal** | `1080 × 2400 PNG (Overtime & gross pay rules)` | [`assets/store/screenshots/02_shift_rules_modal.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/screenshots/02_shift_rules_modal.png) |
| **Screenshot 3: Night Differential** | `1080 × 2400 PNG (Night premium & wage multipliers)` | [`assets/store/screenshots/03_night_differential_and_wages.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/screenshots/03_night_differential_and_wages.png) |
| **Screenshot 4: Shift History** | `1080 × 2400 PNG (Saved shifts & weekly reports)` | [`assets/store/screenshots/04_shift_history_and_presets.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/screenshots/04_shift_history_and_presets.png) |

---

## 3. Google Play Console Data Safety Questionnaire Answers

Use these answers when filling the **Data safety** section in Google Play Console:

### Overview
- **Does your app collect or share any of the required user data types?**  
  👉 **Yes** (Through Google Mobile Ads & Firebase Analytics SDKs).
- **Is all of the user data collected by your app encrypted in transit?**  
  👉 **Yes** (Uses HTTPS/TLS).
- **Do you provide a way for users to request that their data is deleted?**  
  👉 **Yes** (Users can reset/clear local data inside the app).

### Data Types Collected:
1. **Device or other IDs** (Advertising ID / Instance ID):
   - **Collected?** Yes
   - **Shared?** Yes (With Google AdMob / Firebase)
   - **Processed ephemerally?** No
   - **Required or optional?** Required
   - **Purposes:**
     - Analytics
     - Advertising or marketing
2. **App Info and Performance** (Crash logs, diagnostics):
   - **Collected?** Yes
   - **Shared?** No
   - **Purposes:** Analytics, App functionality

---

## 4. Google Play Content Rating & Target Audience

- **Category:** Finance / Tools / Productivity
- **Content Rating:** Everyone (PEGI 3, USK 0, ESRB Everyone)
- **Ads Declaration:** "Yes, my app contains ads" (Banner & Rewarded)
- **Target Age:** 18 and over (or 13+)
- **News App:** No
- **COVID-19 Contact Tracing:** No
- **Financial Features:** Personal finance / wage calculator (No real-money transactions, banking, or credit lending)

---

## 5. Privacy Policy Link
Use the hosted URL of `PRIVACY_POLICY.md` (or raw GitHub markdown link):  
`https://raw.githubusercontent.com/sothysek93/shiftpay/main/PRIVACY_POLICY.md`
