# bicycle_rental_center

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## Recent Development Progress

### 1. OAuth2 Password Grant Authentication Implementation

**Fixed Password Grant Authentication**

- Refactored `AuthService` (`lib/services/auth_service.dart`) to implement proper OAuth2 password grant flow
- Updated endpoint from `/user/info` to `/oauth/token` with correct form-encoded request format
- Removed unnecessary Authorization header from login requests
- Added secure token storage using `shared_preferences` with automatic expiry tracking
- Created type-safe `TokenResponse` model (`lib/models/token_response.dart`) for better error handling
- Implemented proper error response parsing for API failures

**Key Features:**

- Secure local token storage
- Type-safe authentication responses
- Comprehensive error handling with specific error messages

### 2. Data Services and Models Creation

**User Data Service**

- Created comprehensive user data models (`lib/models/user_data.dart`):
  - `UserData`, `UserResult`, `CenterUserAccess`, `Center` classes
- Implemented `UserDataService` (`lib/services/user_data_service.dart`) for fetching user information
- Integrated with `AuthService` for automatic token management
- Added helper methods for authentication checks and data refresh

**Filter Metadata Services**

- Created bicycle filter metadata models (`lib/models/filter_meta.dart`):
  - `FilterMeta`, `Make`, `BicycleType`, `BicycleModel`, `ConditionStatus`, `RunningStatus`
- Created activity metadata models (`lib/models/activity_meta.dart`):
  - `ActivityMeta`, `ActivityType`, `ActivityStatus`, `ActivityTrackType`
- Implemented unified `FilterMetaService` (`lib/services/filter_meta_service.dart`) with methods:
  - `getFilterMeta()` - Bicycle filter data from `/bicycle-meta/filter-meta`
  - `getActivityMeta()` - Activity filter data from `/activity/meta/filter-meta`

**All services feature:**

- Consistent authentication using `AuthService.getAccessToken()`
- Robust error handling for network and API failures
- Type-safe model parsing with proper null safety
- Helper methods for specific data retrieval

### 3. Login Screen Integration

**AuthService Integration**

- Refactored `login_screen.dart` to use custom `AuthService` instead of Supabase
- Updated login flow to handle `TokenResponse` objects with proper success/error states
- Improved error messaging to show specific API error descriptions
- Maintained all existing UI/UX functionality and form validation

**Main App Cleanup**

- Removed all Supabase dependencies from `main.dart`
- Eliminated `AuthWrapper` class and Supabase initialization code
- Updated app to launch directly to login screen
- Verified no orphaned references to removed components
- Preserved all theming, routing, and app configuration

### 4. Technical Architecture

**Authentication Flow:**

```
App Start → LoginScreen → AuthService.login() → TokenResponse → Dashboard
```

**Service Dependencies:**

- All API services depend on `AuthService` for token management
- Automatic token refresh and validation
- Consistent error handling across all services
- Type-safe model parsing throughout the application

**API Endpoints Integrated:**

- `POST /token` - OAuth2 authentication
- `GET /external-api/v1/user/info` - User data retrieval
- `GET /external-api/v1/bicycle-meta/filter-meta` - Bicycle filters
- `GET /external-api/v1/activity/meta/filter-meta` - Activity filters

The application now uses a complete REST API authentication system with comprehensive data services, replacing the previous Supabase integration while maintaining all functionality.
