# Eatadaki iOS Architecture

## Overview

Eatadaki is a SwiftUI-based iOS application that uses a simple state machine pattern to manage application flow and user authentication state.

## Architecture Pattern

The app follows a **state machine pattern** with three primary states:

1. **Initializing** - App startup and core service initialization
2. **Unauthenticated** - User is not logged in
3. **Authenticated** - User is logged in and has access to full app features

## State Flow

```
┌─────────────┐
│ Initializing │
└──────┬──────┘
       │
       ├─────────────────┐
       │                 │
       ▼                 ▼
┌──────────────┐  ┌──────────────┐
│Unauthenticated│  │ Authenticated│
└──────────────┘  └──────────────┘
```

### State Transitions

- **App Launch** → `Initializing`
- **Initialization Complete (No User)** → `Unauthenticated`
- **Initialization Complete (User Found)** → `Authenticated`
- **Logout** → `Unauthenticated`
- **Login Success** → `Authenticated`

## State Descriptions

### Initializing

**Purpose**: Set up core services and infrastructure when the app launches.

**Responsibilities**:
- Create and initialize databases (GRDB)
- Set up core services
- Check for existing user session
- Determine initial authentication state

**Error Handling**:
- Initialization should almost never fail
- Potential failure cases:
  - Disk space issues
  - Database corruption (rare)
  - Critical service unavailability

**Duration**: Should be brief (< 1 second typically)

**Next States**:
- `Unauthenticated` - If no user session found
- `Authenticated` - If valid user session exists

### Unauthenticated

**Purpose**: Handle user login and registration flows.

**Responsibilities**:
- Display login/registration UI
- Handle authentication requests
- Validate user credentials
- Create new user accounts

**Features Available**:
- Login
- Registration
- Password reset (if applicable)

**Restrictions**:
- No access to user-specific data
- Cannot create spots
- Cannot manage items

**Next States**:
- `Authenticated` - After successful login/registration

### Authenticated

**Purpose**: Main application experience for logged-in users.

**Responsibilities**:
- Display main app content
- Manage user data
- Handle user actions

**Features Available**:
- Spot creation and management
- Item management
- User profile management
- All authenticated features

**Dependencies**:
- User session
- Database access
- Authenticated API services (if applicable)

**Next States**:
- `Unauthenticated` - After logout

## Module Structure

### Eatadaki (App)
- **Purpose**: Main app entry point and state machine orchestration
- **Responsibilities**:
  - App lifecycle management
  - State machine implementation
  - Root view coordination
- **Dependencies**: EatadakiUI, EatadakiData, EatadakiKit

### EatadakiUI
- **Purpose**: SwiftUI views and UI components
- **Responsibilities**:
  - View implementations
  - UI state management
  - User interaction handling
- **Dependencies**: EatadakiKit

### EatadakiData
- **Purpose**: Data persistence layer
- **Responsibilities**:
  - Database operations (GRDB)
  - Repository pattern implementation
  - Database migrations
  - Data models (e.g., `Spot`)
- **Dependencies**: GRDB, EatadakiKit
- **Key Components**:
  - `EatadakiRepository`: Protocol defining data access interface with async/throws methods
  - `RealEatadakiRepository`: Actor-based concrete implementation using `DatabasePool` for thread-safe data access
  - `UserDatabaseMigrator`: Handles user table migrations
  - `DeviceConfigDatabaseMigrator`: Handles device configuration table migrations
  - `ExperiencesDatabaseMigrator`: Handles experiences, experience ratings, and spots table migrations
  - `Spot`: Core data model with UUID-based identification
- **Database Conventions**:
  - Use camelCase for database column names to match Swift property names
  - Avoid CodingKeys - rely on GRDB's automatic Codable support for direct property-to-column mapping

### EatadakiKit
- **Purpose**: Shared utilities and business logic
- **Responsibilities**:
  - Common types and protocols
  - Business logic
  - Shared utilities
- **Dependencies**: None (foundation layer)

## Data Flow

### Initialization Flow
1. App launches → `Initializing` state
2. Initialize database (GRDB `DatabasePool`)
3. Run database migrations (`UserDatabaseMigrator`, `DeviceConfigDatabaseMigrator`, `ExperiencesDatabaseMigrator`)
4. Check for existing user session
5. Transition to `Unauthenticated` or `Authenticated`

### Authentication Flow
1. User enters credentials in `Unauthenticated` state
2. Validate credentials
3. Create/restore user session
4. Transition to `Authenticated` state

### Main App Flow (Authenticated)
1. User interacts with UI
2. UI calls data layer through `EatadakiRepository` protocol
3. `RealEatadakiRepository` performs async database operations using `DatabasePool`
4. Updates propagate back to UI

## Testing Guidelines

### Database Testing

When writing tests that interact with the database, **never perform assertions inside database read/write blocks**. Instead, fetch data from the database and perform assertions outside the block.

**❌ Incorrect:**
```swift
try db.read { database in
    let entry = try Row.fetchOne(database, sql: "SELECT ...")
    #expect(entry != nil)  // This will crash the test runner!
    #expect(entry?["value"] as? String == "expected")
}
```

**✅ Correct:**
```swift
let fetchedEntry = try await db.read { database in
    try Row.fetchOne(database, sql: "SELECT ...")
}
let entry = try #require(fetchedEntry)
#expect(entry["value"] as? String == "expected")
```

**Why:** Running test macros (like `#expect` or `#require`) inside database read/write blocks causes the test runner to crash instead of properly reporting test failures. Always return data from the database block and perform assertions outside.

## Key Design Principles

1. **State-Driven UI**: UI reflects current app state
2. **Separation of Concerns**: Clear boundaries between UI, Data, and Business Logic
3. **User-Centric**: All user data requires authentication
4. **Resilient Initialization**: Graceful handling of initialization failures
5. **Simple State Machine**: Easy to understand and maintain state transitions

## Data Modeling
Models will have a few types so we want a consistent naming scheme to help us find the correct one.  

- A model has a concept name, like a `Spot` or `User`, and then we build the real type names off their purpose.
- A model representing a persisted entity should be suffixed `Record`; e.g. `SpotRecord` and `UserRecord`.
- A model representing persisted data, but not a specific entity, should be suffixed `Info` + level of detail in the data. Our typical options are `InfoSummary`, `InfoPartial`, and `InfoDetailed`.
- A model representing a network request should be suffixed `Request`. 
- A model representing a network response should be suffixed `Response`. If the response has varying levels of detail it should have the same detail suffix as persisted data.

## Future Considerations

- Add error states for initialization failures
- Consider adding a "Loading" substate for async operations
- Implement state persistence for app backgrounding
- Add analytics/telemetry for state transitions

