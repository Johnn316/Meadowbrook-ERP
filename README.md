# Meadowbrook ERP

A Flutter app that bundles a small CRM and a farm-management module into one
offline-first mobile ERP, built around Kenyan agribusiness — KES currency, all
47 counties, and local crop/livestock lists baked into the constants.

> **This is a learning project.** It's a portfolio/practice build, not a
> production system. There's no authentication, no backend, and no multi-user
> support — everything lives in a local SQLite file on the device.

---

## Project status

**Phase 1 scope delivered per client requirements.** Development is currently
paused pending the client's direction on the next phase.

Delivered and working:

- **Contacts** — create, edit, delete, search by name, filter by contact type;
  call and SMS hand-off from the detail screen
- **Leads** — create, edit, delete, search, filter by pipeline stage, change
  stage, running pipeline value
- **Invoices** — create, edit, delete, filter by status, record part or full
  payment, automatic non-repeating invoice numbers, A4 PDF export via the
  system share sheet
- **Farms** — create, edit, delete, search by name or county, with per-farm
  crops, livestock, equipment, and income/expense tracking
- **Weather** — live conditions and a 7-day forecast per farm, resolved from
  the farm's county
- **Dashboard** — contact, lead, invoice, and farm totals with invoiced,
  collected, and outstanding figures; pull to refresh
- **Data portability** — XML export and import for contacts, leads, and
  invoices, individually or together
- **Local storage** — SQLite with versioned schema migrations, working fully
  offline apart from the weather panel
- **Theming** — light and dark modes, persisted between launches

Verified on Android: `flutter analyze` reports no issues and a debug APK
builds. Items still open are listed under [Known gaps](#known-gaps) below.

---

## What it actually does

### CRM

- **Contacts** — create, edit, delete. Search by name, filter by type
  (Farmer / Supplier / Buyer / Partner / Other). The detail screen has `tel:`
  and `sms:` quick actions that hand off to the phone's dialer and messaging
  app.
- **Leads** — full CRUD with a search box and a status filter across the
  pipeline (New → Contacted → Qualified → Proposal → Won / Lost), plus a
  dedicated status-change action. Shows the summed value of whatever is
  currently filtered.
- **Invoices** — CRUD, status filter (Paid / Partial / Unpaid / Overdue), and
  payment recording that tracks `amountPaid` against `amount`. Invoice numbers
  (`INV-001`, `INV-002`, …) come from a counter persisted in
  `SharedPreferences`, so the sequence never reuses a number after a delete.
  Each invoice renders to an A4 PDF and goes out through the system share
  sheet. Header totals for invoiced / collected / outstanding.
- **Dashboard** — summary cards plus recent leads and recent invoices, with
  pull-to-refresh across all four providers.

### Farm management

- **Farms** — name, county, acreage, description. Searchable by name or county.
- **Weather** — the farm detail screen pulls live current conditions and a
  7-day forecast from the [Open-Meteo](https://open-meteo.com) API, geocoded
  from a built-in table of centre coordinates for all 47 counties. No API key
  needed; WMO weather codes are mapped to icons and descriptions locally, and
  network failures fall back to an inline error state.
- **Per-farm sub-modules**, reachable from the farm detail screen:
  - **Crops** — variety, planting date, expected harvest, status
    (Growing / Ready / Harvested)
  - **Livestock** — type, name, head count, notes
  - **Equipment** — type, condition, notes
  - **Finances** — income/expense entries with running totals and net profit

### Settings

- Dark/light theme toggle, persisted across launches.
- **XML export** — contacts, leads, invoices individually or all three in one
  file, written to a temp file and pushed to the share sheet.
- **XML import** — pick an XML file, parse it, and upsert the records back into
  the database. This is the app's "sync": you move data between devices by
  passing a file around.

---

## Tech stack

| | |
|---|---|
| Framework | Flutter (Dart SDK `>=3.0.0 <4.0.0`), Material 3 |
| Database | `sqflite` — local SQLite, schema v3 with migrations |
| State | `provider` (`ChangeNotifier`) |
| Typography | `google_fonts` — Merriweather for headings, Lato for body |
| PDF | `pdf` + `printing` |
| XML | `xml` + `file_picker` + `share_plus` |
| Network | `http` (weather only) |
| Misc | `uuid`, `intl`, `shared_preferences`, `url_launcher`, `path_provider` |

`fl_chart` and `connectivity_plus` are declared in `pubspec.yaml` but aren't
imported anywhere yet.

### Database

One static `AppDatabase` class wraps `sqflite` directly — no ORM, no code
generation. Eight tables: `contacts`, `leads`, `invoices`, `farms`, `crops`,
`livestock`, `equipment`, `farm_finances`. Schema version 3, with `onCreate`
building the full set and `onUpgrade` adding the farm tables for anyone
upgrading from v1/v2. On first run it seeds five sample contacts, leads, and
invoices so the UI isn't empty.

The folder is named `core/database/drift/` for historical reasons — Drift was
tried and abandoned (`drift_dev` is still commented out in `pubspec.yaml`).
Nothing in there uses Drift.

Child tables reference `farmId` as a plain `TEXT` column; there are no foreign
key constraints or indexes, so deleting a farm leaves its crops, livestock,
equipment, and finance rows orphaned in the database.

### State management

`main()` initialises the database, then registers five `ChangeNotifier`
providers: `ThemeProvider`, `ContactsProvider`, `LeadsProvider`,
`InvoicesProvider`, `FarmsProvider`. Each holds an in-memory list, calls into
`AppDatabase`, and mutates locally after a write to avoid a full reload.

The farm sub-modules (crops, livestock, equipment, finances) skip Provider
entirely and use `setState` with direct `AppDatabase` calls — a real
inconsistency in the codebase, not a design decision.

---

## Project structure

```
lib/
├── main.dart                  # DB init + provider registration
├── app.dart                   # MaterialApp, theming, home = MainShell
├── core/
│   ├── constants/             # counties, crops, lead statuses, currency codes
│   ├── database/drift/        # AppDatabase — sqflite schema + all CRUD
│   ├── services/              # pdf_service, xml_service
│   ├── theme/                 # colors, typography, light/dark themes, provider
│   └── utils/                 # currency_utils — shared KES formatting
├── features/
│   ├── auth/                  # login screen (not wired into navigation)
│   ├── crm/
│   │   ├── contacts/          # domain/ + data/ + presentation/
│   │   ├── leads/
│   │   └── invoices/
│   ├── farm/
│   │   ├── farms/             # list + detail hub + weather
│   │   └── crops/  livestock/  equipment/  finances/
│   ├── dashboard/
│   └── settings/
└── shared/widgets/app_drawer.dart   # MainShell: app bar + drawer + bottom nav
```

Currency formatting lives in one place — `CurrencyUtils.format` for on-screen
values (`Ksh 150,000`) and `CurrencyUtils.formatPrecise` for PDF invoices
(`KES 150,000.00`), both reading their symbols from `AppConstants`.

Each feature follows `domain/` (model) → `data/` (provider) →
`presentation/` (screens), though only the CRM features and `farms` have the
`data/` layer filled in.

Navigation is a single `MainShell` with five destinations — Dashboard,
Contacts, Leads, Invoices, Farm — reachable from both a bottom nav bar and a
side drawer. There's no router package; sub-screens use `Navigator.push`.

### Known gaps

Being upfront about what isn't finished:

- There is **no server-side sync**. Moving data between devices means
  exporting XML and importing it on the other side.
- `login_screen.dart` is fully built (with a fake 2-second delay and no
  credential check) but the app boots straight to `MainShell` — it's never
  shown. There is no authentication.
- "New Lead" and "Invoice" buttons on the contact detail screen are empty
  callbacks.
- Forms validate with ad-hoc `trim().isEmpty` guards rather than `Form` /
  `TextFormField` validators, and amount fields fall back to `0.0` on
  unparseable input instead of rejecting it.
- Modal bottom sheets create `TextEditingController`s that are never disposed.
- Database calls are largely unguarded — there's no error handling around
  `sqflite` failures.
- `test/` contains one placeholder assertion. There are no real tests.

---

## Running it

```bash
flutter pub get
flutter run
```

**Android is the target platform.** The desktop SQLite dependencies
(`sqflite_common_ffi`, `sqlite3_flutter_libs`) are deliberately commented out
in `pubspec.yaml` because their build hooks need network access and Visual C++
tooling — so `flutter run -d windows` will fail at database init until those
are re-enabled. The iOS, web, macOS, and Linux folders are stock Flutter
scaffolding that hasn't been exercised.

The weather panel needs an internet connection; everything else works fully
offline.

Build a release APK:

```bash
flutter build apk --release
```

Regenerate the launcher icon from `assets/images/logo.jpeg`:

```bash
dart run flutter_launcher_icons
```
