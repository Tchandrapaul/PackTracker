# PawLog

An iOS app for tracking your pet's daily activity — bathroom breaks, meals, walks, water, and treats. Built for households and caregivers who share pet duties, with CloudKit-powered pack sharing coming in Phase 3.

## Features

- **Quick logging** — tap a single event or batch-select multiple at once
- **Backdate entries** — pick any time/date when logging or editing
- **Edit events** — correct a timestamp after the fact with a swipe
- **Daily summary** — see counts for each event type at a glance
- **Events timeline** — scroll through a day strip or expand to a full calendar
- **Multi-pet support** — add multiple pets, switch between them instantly
- **Per-pet history** — all events, stats, and recent activity are scoped to the active pet

## Tech Stack

- **SwiftUI** — declarative UI throughout, no UIKit
- **Combine / ObservableObject** — reactive state via `EventStore` and `PetStore`
- **JSON persistence** — local storage in the app's Documents directory
- **CloudKit** *(Phase 3)* — iCloud sync and pack sharing via zone sharing API
- **Sign in with Apple** *(Phase 3)* — user identity for pack membership

## Project Structure

```
PawLog/
├── PawLogApp.swift        # Entry point, store injection, first-launch migration
├── RootTabView.swift      # Tab navigation (Home, Log, Events, Settings)
│
├── Models
│   ├── Pet.swift          # Pet struct with age/subtitle helpers
│   ├── PetEvent.swift     # PetEvent + EventType (SF Symbols, colors)
│   ├── PetStore.swift     # ObservableObject — manages [Pet], activePetId
│   └── EventStore.swift   # ObservableObject — pet-scoped CRUD + migration
│
└── Views
    ├── HomeView.swift      # Pet card, today summary, recent activity
    ├── LogEventsView.swift # Single/batch logging with time picker
    ├── EventsView.swift    # Day strip, calendar, summary card, event list
    └── SettingsView.swift  # Pet management, pack stubs, app preferences
```

## Roadmap

### ✅ Phase 1 — UI Polish
- SF Symbols with per-type colors replacing placeholder emojis
- Day strip with auto-scroll to today and 90-day browsable range
- Expandable full calendar with working collapse
- Home, Settings, and Events views fully built out
- Event editing (timestamp correction)

### ✅ Phase 2 — Multi-Pet Support
- `Pet` model with name, breed, and birthdate
- `PetStore` with active pet tracking persisted across launches
- All events scoped to a pet via `petId`
- Backward-compatible migration for pre-Phase 2 events
- Pet management in Settings (add, edit, delete with cascade)
- Pet switcher on Home for households with multiple pets

### 🔲 Phase 3 — CloudKit + Pack Sharing
- Sign in with Apple for stable user identity
- CloudKit private zones for each user's pets and events
- Zone sharing — invite family/caregivers to a "pack" via share link
- Real-time sync via `CKSubscription` push notifications
- Local JSON cache with CloudKit as source of truth

## Requirements

- iOS 17+
- Xcode 15+

## License

MIT
