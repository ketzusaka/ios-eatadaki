# Eatadaki iOS Documentation

This directory contains architecture and design documentation for the Eatadaki iOS application.

## Documentation Index

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Complete architecture overview, state machine design, and module structure
- [FEATURES.md](./FEATURES.md) - Overview of app features and their status

## Feature Documentation

Detailed feature documentation is available in the [features/](./features/) subdirectory.

## Quick Reference

### App States
- **Initializing**: App startup, database initialization
- **Unauthenticated**: Login/registration flow
- **Authenticated**: Main app experience with user data access

### Module Responsibilities
- **Eatadaki**: App entry point, state machine
- **EatadakiUI**: SwiftUI views and UI components
- **EatadakiData**: Database operations and repositories (GRDB)
- **EatadakiKit**: Shared utilities and business logic

