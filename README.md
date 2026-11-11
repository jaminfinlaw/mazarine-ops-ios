# MAZARINE OPS Mobile

Native iPhone foundation for the approved two-screen MAZARINE sales workspace.

## Current milestone: sample-data interface

This is an explicitly labeled, offline **demo**, not a production-connected CRM.
It contains only synthetic customer data with `example.com` addresses and no callable
phone numbers. No production endpoint, credential, device token, or APNs key is bundled.
Edits are in memory and reset on relaunch. There is no network client or push registration yet.

### Included

- Leads & Activity: four interactive summary filters, inline search, activity feed,
  unread indicators, inline lead quick actions, pull-to-refresh, foreground refresh.
- Lead Details: contact copy actions, boat information, latest/earlier configurations,
  activity history, notes, follow-ups, status action.
- Native SwiftUI sheets for account, notification preferences/history, notes, status,
  follow-up scheduling, and call/email/text previews.
- Local sample note/status/follow-up changes update both primary screens.
- No bottom navigation or third primary screen.
- Original supplied MZ PNG, unchanged, aspect-fit; Manrope headings and Avenir Next body.
- Dynamic Type-aware controls and accessibility labels.

Call, Mail, Messages, configurator sharing, login, and push delivery are intentionally
not enabled against sample contacts. Buttons clearly explain their integration status.
No interaction claims that an actual call, email, text, or OPS save occurred.
Boat images are not fabricated. Opened-only configurations do not display invented selections.
Lead lifecycle choices are preview-only; live allowed transitions must come from OPS.

## Open and run

1. Open `MazarineOPSMobile.xcodeproj` in Xcode.
2. Select the `MazarineOPSMobile` scheme and an installed iPhone simulator.
3. Run. Simulator builds do not need an Apple Developer team.

The minimum deployment target is iOS 17. Development used Xcode 27.2 / Swift 6.
The checked-in project is generated with XcodeGen; normal opening/building does not
require XcodeGen.

To regenerate after changing `project.yml`:

```sh
brew install xcodegen
xcodegen generate
```

Command-line checks (replace the simulator name with one installed locally):

```sh
xcodebuild -project MazarineOPSMobile.xcodeproj -scheme MazarineOPSMobile \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build

xcodebuild -project MazarineOPSMobile.xcodeproj -scheme MazarineOPSMobile \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO test
```

Unit tests cover counts, filtering/search, unread behavior, local edits, follow-up
validation/completion, refresh preservation, and opened-only state. UI tests exercise
two-screen navigation, note entry, and account/notification sheets.

## Structure

```text
MazarineOPSMobile/
  App/          App entry, navigation, observable sample workspace
  Core/         Brand colors, typography, shared cards and controls
  Features/     The two primary views and modal sheets
  Models/       Typed sales models and isolated synthetic fixtures
  Resources/    Original logo, font, font license, asset catalog
MazarineOPSMobileTests/
MazarineOPSMobileUITests/
```

## Brand resources

The original `MZ_Badge_PinkTellowBlue.png` is 1224 x 587, imported without modification.
SHA-256:

```text
b2b66c70e3d5c0ad29478c3a69028d72b490df80224d8aa2516a384b8da3fe21
```

Manrope is distributed under the SIL Open Font License; the upstream license is
included in `MazarineOPSMobile/Resources/Fonts/OFL.txt`. Source:
https://github.com/google/fonts/tree/main/ofl/manrope

An approved square App Store icon is still required. No substitute logo or icon artwork
has been generated. The prototype intentionally omits an AppIcon catalog.

## Integration and distribution gates

The next milestone is OPS bearer authentication and scoped read-only APIs, reusing
existing Supabase identities, RLS, `can_view_lead` / `can_manage_lead`, and sales capabilities.
The app must not query production database tables directly.
Keychain/session refresh, live workflows, versioned/idempotent writes, and APNs are
future work, not implemented production features.

Before backend work: confirm staging/test accounts, actual login/MFA policy, canonical
follow-up behavior, and mobile permission scope. Before push: approve category defaults,
recipient selection, cooldowns, lock-screen privacy, and latency target.

Before TestFlight: configure an approved bundle ID, Apple Developer team, signing,
APNs entitlements/keys, App Store Connect, approved icon, privacy disclosures, and
real-device tests. Do not commit credentials. Production migrations/deployments
require separate approval.
