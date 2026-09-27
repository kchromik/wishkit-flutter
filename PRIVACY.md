# Privacy Manifest for WishKit Flutter SDK

This document mirrors Apple's `PrivacyInfo.xcprivacy` format for the Flutter SDK.

## Data Collected

### Device UUID
- **Type**: Persistent identifier
- **Purpose**: Associates feedback, votes, and comments with a consistent anonymous user across sessions
- **Storage**: `SharedPreferences` (local only)
- **Transmitted**: Yes — as `x-wishkit-uuid` header on every API request
- **Retention**: Until app uninstall or `WishKit.deleteUUID()` called

### User-Provided Information
| Field | Transmitted | Purpose |
|-------|-------------|---------|
| Custom ID | Yes (`x-wishkit-sdk-app-name` + body) | Host-defined user correlation |
| Email | Yes (in wish body, only if field shown) | Contact for follow-up |
| Name | Yes (in wish body) | Display in dashboard |
| Payment tier | Yes (in user update) | Plan-level features |

### Feedback Content
- **Wish title/description**: Yes — core product data
- **Votes**: Yes — `POST /wish/vote` with wish ID
- **Comments**: Yes — `POST /comment/create` with text

### Chat
- **Messages**: Yes — `POST /chat/send` with text, polled via `GET /chat/list`
- **Unread status**: Yes — `GET /chat/status`

## Data NOT Collected

- **No location data** (GPS, IP geolocation)
- **No contacts/calendar/photos**
- **No health/biometric data**
- **No usage analytics** beyond what the API returns
- **No crash logs** (handled by host app's crash reporter)
- **No advertising identifiers** (IDFA/AAID)

## Network Requests

All requests go to the configured `baseUrl` (default `https://www.wishkit.io/api`):

| Endpoint | Method | Headers | Body |
|----------|--------|---------|------|
| `/wish/list` | GET | `x-wishkit-api-key`, `x-wishkit-uuid`, `x-wishkit-sdk-*` | — |
| `/wish/create` | POST | (same) | `{title, description, email?, state}` |
| `/wish/vote` | POST | (same) | `{wishId}` |
| `/wish/unvote` | POST | (same) | `{wishId}` |
| `/comment/create` | POST | (same) | `{wishId, description}` |
| `/comment/list` | GET | (same) | `?wishId=` |
| `/chat/status` | GET | (same) | — |
| `/chat/list` | GET | (same) | `?cursor=` |
| `/chat/send` | POST | (same) | `{body}` |
| `/user/update` | PATCH | (same) | `{customID?, email?, name?, payment?}` |

### Conditional Header
- `x-wishkit-sdk-bundle-id`: **Only in release builds** (debug builds omit it). Value = `appId` from `configure()`.

## Third-Party SDKs

| Package | Purpose | Data Access |
|---------|---------|-------------|
| `http` | Networking | Request/response bodies |
| `shared_preferences` | Local UUID storage | Device-local key-value |
| `uuid` | UUID generation | None (local only) |
| `provider` | State management | None |
| `intl` / `flutter_localizations` | Date/string formatting | Locale only |

## Host Responsibilities

The **host app** controls:
- Whether `emailField` is shown (`none`/`optional`/`required`)
- Whether translation is enabled (via `translator` callback — no default engine)
- Whether chat is shown (`showChatButtonInFeedbackView`)
- Whether debug logs are enabled (`showDebugLogs`)
- The `baseUrl` (can point to a self-hosted backend)

## User Rights

Since all data is scoped to the host's WishKit project:
- **Access/Deletion**: Host manages via WishKit dashboard or API
- **Opt-out**: Host can stop calling `WishKit.configure()` or delete the UUID

## Compliance

- **GDPR**: No personal data collected without host explicitly enabling fields
- **CCPA**: No sale of data; all data belongs to host project
- **App Store / Play Store**: No prohibited data collection

## Contact

Privacy questions: privacy@wishkit.io