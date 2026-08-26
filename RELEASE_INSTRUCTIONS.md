# 🚀 ShiftPay Release & Publishing Guide

This document contains instructions for publishing the initial version and deploying future updates to the **Google Play Store**.

---

## 🔐 1. Keystore & Security Details

Your official production upload keystore has been created and verified:

- **Keystore File Location**: `/Users/shorthy/shiftpay-release.jks`
- **Alias**: `shiftpay`
- **Password**: `shiftpay2026`
- **Config File**: `android/key.properties` *(Kept strictly in `.gitignore`)*

> [!IMPORTANT]
> **Backup your keystore file**: Keep a safe backup copy of `/Users/shorthy/shiftpay-release.jks`. If lost, Google Play will not allow you to update the app without contacting Google support to reset the upload key.

---

## 📦 2. Ready-to-Upload Release Binaries

| Asset | Path | Purpose |
| :--- | :--- | :--- |
| **Signed Production AAB** | [`build/app/outputs/bundle/release/app-release.aab`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/build/app/outputs/bundle/release/app-release.aab) | **Upload to Google Play Console** |
| **Signed Release APK** | [`build/app/outputs/flutter-apk/app-release.apk`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/build/app/outputs/flutter-apk/app-release.apk) | Direct testing on physical Android devices |

---

## 📤 3. How to Submit Version 1.0.0 (First Release)

### Step 1: Open Google Play Console
1. Go to **[Google Play Console](https://play.google.com/console)**.
2. Select your app: **ShiftPay** (`com.bondaanh.shiftpay`).

### Step 2: Complete Store Presence
Navigate to **Store presence ➔ Main store listing**:
- **App Name**: `ShiftPay: Shift & Overtime Pay`
- **Short Description**: `Calculate shift wages, overtime hours, night differentials & track your pay.`
- **Full Description**: *(Copy from [`STORE_LISTING.md`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/STORE_LISTING.md))*.
- **App Icon (512x512)**: Upload [`assets/store/icon_512x512.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/icon_512x512.png).
- **Feature Graphic (1024x500)**: Upload [`assets/store/feature_graphic_1024x500.png`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/feature_graphic_1024x500.png).
- **Phone Screenshots (1080x2400)**: Upload all 4 images from [`assets/store/screenshots/`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/assets/store/screenshots/).

### Step 3: Complete App Content Declarations
- **Privacy Policy**: `https://raw.githubusercontent.com/sothysek93/shiftpay/main/PRIVACY_POLICY.md`
- **Ads**: Declare **"Yes, my app contains ads"**.
- **Data Safety**: Refer to Section 3 in [`STORE_LISTING.md`](file:///Users/shorthy/Freelance/06_mobile_and_web_apps/flutter_mobile/shiftpay/STORE_LISTING.md).
- **Target Audience**: 18 and over (or 13+).
- **Category**: Finance / Productivity.

### Step 4: Create the Production Release
1. In the left sidebar, navigate to **Release ➔ Production** (or **Closed Testing**).
2. Click **Create new release**.
3. Under **App bundles**, upload:
   `build/app/outputs/bundle/release/app-release.aab`
4. Enter **Release name**: `1.0.0 (1)`
5. Enter **Release notes**:
```text
en-US
• Initial release of ShiftPay: Shift Wage & Overtime Calculator.
• Fast clock-in / clock-out calculations with automatic unpaid break deduction.
• Customizable overtime engine with 1.5x, 2.0x, and custom multipliers.
• Night Differential Premium tracking with configurable night windows.
• Add flat tips, allowances, and meal deductions with live effective hourly rate calculation.
• Local shift history tracking and one-tap weekly analytical timesheet export.
```
6. Click **Save ➔ Review release ➔ Start rollout to Production**.

---

## 🔄 4. How to Publish Future Updates (e.g. v1.0.1, v1.1.0)

Whenever you want to release an update:

### Step 1: Bump Version in `pubspec.yaml`
Edit `pubspec.yaml` and increment the version number and build code:
```yaml
# Format: version_name+version_code
version: 1.0.1+2
```

### Step 2: Build Signed Production Bundle
Run this command in the terminal:
```bash
flutter build appbundle --release
```

### Step 3: Upload to Play Console
1. Go to **Release ➔ Production ➔ Create new release**.
2. Upload the newly generated `build/app/outputs/bundle/release/app-release.aab`.
3. Add your release notes summarizing new features or bug fixes.
4. Click **Start rollout to Production**.
