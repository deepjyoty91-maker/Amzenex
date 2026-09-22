# Medmylife - Patient Appointment Management Application

A production-quality Flutter mobile application developed for **Medmylife** demonstrating Clean Architecture, BLoC/Cubit state management, debounced search, offline local database persistence, appointment booking, offline sync queue, unit testing, and robust error handling.

---

## Architecture Overview & Diagram

This project follows **Clean Architecture** with feature-oriented package organization to guarantee separation of concerns, high testability, and seamless API swappability.

```
                  ┌──────────────────────────────────────────────┐
                  │              Presentation Layer              │
                  │  (UI Screens, Widgets, Controls, Debouncers) │
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼
                  ┌──────────────────────────────────────────────┐
                  │            State Management Layer            │
                  │    (AuthCubit, DoctorCubit, AppointmentCubit)│
                  └──────────────────────┬───────────────────────┘
                                         │
                                         ▼
                  ┌──────────────────────────────────────────────┐
                  │             Domain & Repository Layer        │
                  │  (Data Models, Entities, Repository Contracts)│
                  └──────────────────────┬───────────────────────┘
                                         │
                  ┌──────────────────────┴──────────────────────┐
                  ▼                                             ▼
    ┌───────────────────────────┐                 ┌───────────────────────────┐
    │     Remote Data Source    │                 │     Local Data Source     │
    │  (Mock REST API Service)  │                 │    (Hive Database Cache)  │
    └───────────────────────────┘                 └───────────────────────────┘
```


## Features Implemented

1. **Authentication (Login)**
   - Email/Mobile number and password fields with input validation.
   - Loading indicator state and error handling.
   - Session persistence via `SharedPreferences`.
   - "Autofill Demo Credentials" button for instant testing.

2. **Doctor Directory & Debounced Search**
   - Doctor cards with name, speciality, experience, consultation fee, and availability status.
   - Search input by doctor name or speciality with **Debouncer (350ms)** to prevent excessive keystroke requests.
   - Pull-to-refresh (`RefreshIndicator`).
   - Loading, Error with Retry button, and Empty search result states.

3. **Offline Support & Local Caching**
   - Doctor directory automatically cached in local **Hive database**.
   - If network fails or user goes offline, repository seamlessly falls back to local database.
   - Simulated Offline Mode toggle on Doctor Directory screen header for testing offline capabilities.

4. **Appointment Booking & Offline Sync Queue (Bonus Feature)**
   - Slot selection chips (`10:00 AM`, `10:30 AM`, `11:00 AM`, `11:30 AM`, `02:00 PM`, etc.).
   - Prevents duplicate slot bookings for the same doctor.
   - **Offline Queue Sync**: When offline, bookings are saved locally with `PENDING` status. When connection is restored, manual or automatic sync transitions items: `PENDING` → `SYNCING` → `SYNCED`.

5. **Unit Testing**
   - 10 unit test cases covering JSON parsing, repository caching & offline fallback, Cubit state transitions, debounced search filtering, and offline queue state transitions.

---

## Framework & Environment

- **Flutter SDK**: `3.47.5` (Channel stable)
- **Dart SDK**: `3.13.4`
- **State Management**: `flutter_bloc` (Cubit)
- **Local Database**: `hive` & `hive_flutter`
- **Session Store**: `shared_preferences`
- **Testing**: `flutter_test`, `mocktail`, `bloc_test`

---



## Assumptions & Known Limitations

1. **Mock Authentication**: Login uses simulated authentication logic with persistent session storage. Any password $\ge$ 6 characters will succeed (except `error@medmylife.com` / `wrong123` which trigger simulated errors).
2. **Network Simulator**: A toggle button in the App Bar allows evaluators to simulate offline/online modes instantly without disabling system WiFi.

---



