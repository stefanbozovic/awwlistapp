# Xcode Security Settings

Security build-setting decisions for Wishmory.

## Enabled settings

- `ENABLE_ENHANCED_SECURITY` on the `Wishlistia` application target: Enables compiler and runtime hardening for the shipped app.
- `com.apple.security.hardened-process` to `true`: Enables the hardened-process entitlement family.
- `com.apple.security.hardened-process.enhanced-security-version-string` to `2`: Selects the current enhanced-security protections.
- `com.apple.security.hardened-process.hardened-heap` to `true`: Enables allocator type-isolation protections.
- `com.apple.security.hardened-process.dyld-ro` to `true`: Protects dynamic-loader state.
- `com.apple.security.hardened-process.platform-restrictions-string` to `2`: Enables runtime platform restrictions.

## Disabled settings

No C, C++, Objective-C, or Objective-C++ sources are compiled by this project, so C-family compiler and static-analyzer warnings are not applicable.

## Deferred

- Hardware memory tagging: Requires a staged rollout and compatible hardware; it remains deliberately disabled.
- Project-level `ENABLE_ENHANCED_SECURITY`: The setting is currently applied to the shipping app target. Set it at project level before adding new executable targets so they inherit the protection.
- Automated unit and UI testing: No test target exists yet. Add coverage before release for onboarding, Sign in with Apple, persistence/migration, notifications, and the share extension.
