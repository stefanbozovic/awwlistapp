# AwwList launch handoff

## Verified in this project

- App target: `Wishlistia`, product name: **AwwList**
- Bundle ID: `com.stefanbozovic.awwlist`
- Version/build: `1.0 (1)`
- Minimum OS: iOS 26.6; iPhone and iPad supported
- Distribution signing is automatic for team `YZXY7AL2JS`.
- The project builds successfully in Xcode with no source diagnostics in the app’s primary files.
- Features that must be covered in App Review notes: Sign in with Apple, local notifications, photo picking, and the Safari Share extension.

## Privacy answer to use only while the app remains local-first

The current build has no configured `AwwListAPIBaseURL`. Wishes, people, optional photos, the optional Apple display name/identifier, and MetricKit diagnostic files remain on the device. No app data is sent to the developer’s server.

Use these App Privacy answers for this exact build:

- Does the app or third-party partners collect data from this app? **No**
- Does the app use tracking? **No**
- Privacy manifest: `PrivacyInfo.xcprivacy` already declares the required UserDefaults reason `CA92.1`.

Re-audit the privacy answers before any release that sets `AwwListAPIBaseURL`, uploads diagnostics, adds analytics, or adds a remote sync service.

## Store listing draft

**Subtitle**

Remember the little things that matter

**Promotional text**

Save a hint today. Give a gift they will not expect tomorrow.

**Description**

AwwList is your private place for the little things people mention: a gift idea, a link, a photo, or a future reminder. Save it with the person it belongs to, organize it your way, and come back when the moment is right.

- Keep wishes and gift ideas together
- Save links and shared pages from Safari
- Add photos, notes, categories, and wish status
- Set reminders for birthdays and important moments
- Keep everything on your device

**Keywords**

gift ideas, wishlist, reminders, birthdays, wish list, gifts, notes

**Support URL and privacy-policy URL**

Publish real, public HTTPS pages before submission. The privacy policy should state that the app stores user content locally on the device, does not sell or track personal data, and should include a contact email.

## App Review notes

Paste and adapt the following:

> AwwList is a local-first wishlist and gift-idea organizer. No login is required; use “Continue without an account” on the first screen. Sign in with Apple is optional and stores only a local identity/display name in this version. The Share extension accepts text and web links from Safari after the main app has been opened once. Notifications are optional and used only for reminders the user creates. All user content is stored locally on the device.

## Before archive and submission

- [ ] Confirm the app icon includes a 1024 × 1024 App Store icon and all required device variants.
- [ ] Capture 3–10 current screenshots for each supported device family; include the Safari Share flow if it is a selling point.
- [ ] Set the correct app category, age rating, copyright, support URL, and privacy-policy URL in App Store Connect.
- [ ] Confirm the exact availability countries, price (Free), and whether the app is for children.
- [ ] Confirm the App Group `group.com.stefanbozovic.awwlist` and Sign in with Apple capability are enabled for both identifiers in Certificates, Identifiers & Profiles.
- [ ] Archive using the Release configuration, then validate the archive before upload.
- [ ] Test the release archive on a physical iPhone: onboarding, optional Apple sign-in, local data deletion, notifications, photo import, and Safari Share extension.
- [ ] Increment `CURRENT_PROJECT_VERSION` for every subsequent upload.

## Release blockers that need an owner decision

1. The current iOS minimum is 26.6. Confirm that this intentionally limits the audience to devices on iOS 26.6 or later.
2. A privacy-policy URL, support URL, screenshots, category, age rating, availability, and App Review contact are App Store Connect values and cannot be safely invented in the project.
3. Remote sync is intentionally inactive. Do not claim cross-device sync or account backup in the listing until the backend is configured and privacy disclosures are updated.
