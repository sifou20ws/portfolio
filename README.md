# Portfolio

A cross-platform developer portfolio built with **Flutter + GetX**. It runs on Android, iOS, web, macOS, Windows and Linux.

- Responsive layout: a bottom `NavigationBar` below 840 px and a frosted top header above it. Grids use 1, 2 or 3 columns.
- Dark and light themes with shared design tokens. The theme follows the system and can also be toggled by hand; the choice is saved.
- English, French and Arabic, with full RTL support. The language choice is saved.
- Sections fade in on scroll, the header highlights the section in view, cards lift on hover, and the project banner is shared with the detail page through a Hero animation.
- Deep-linkable project pages (`/#/projects/<id>`) with a zoomable screenshot carousel.

## Run

```bash
flutter pub get
flutter run -d chrome        # or: -d macos, an emulator, a device…
flutter test
flutter build web --release  # output in build/web
```

## Architecture (feature-first + GetX)

```
lib/
├── main.dart                     # Boot: GetStorage + SettingsService, then runApp
├── app/
│   ├── app.dart                  # GetMaterialApp (theme, i18n, routes), reactive via Obx
│   ├── bindings/initial_binding.dart   # App-wide DI (ProjectRepository)
│   └── routes/                   # Route names + GetPage table with bindings
├── core/                         # Shared, feature-agnostic code
│   ├── config/app_config.dart    # ← YOUR name, links, CV url, stats
│   ├── i18n/                     # LocaleKeys + en/fr/ar tables + language metadata
│   ├── responsive/responsive.dart# Breakpoints, context.isMobile…, ResponsiveLayout, MaxWidthContainer
│   ├── services/settings_service.dart  # Theme mode + locale (persisted)
│   ├── theme/                    # Design tokens (spacing, radii, durations, palette) + ThemeData
│   ├── utils/                    # Link launcher/snackbar, validators, context extensions
│   └── widgets/                  # Reveal, HoverLift, ResponsiveGrid, TechChip, ProjectImage…
├── data/
│   ├── models/                   # Project, LocalizedText, TechStack, ProjectLinks
│   ├── repositories/             # ProjectRepository interface + JSON asset implementation
│   └── static/skills_data.dart   # ← YOUR skill categories
└── features/
    ├── home/                     # Shell: header / bottom nav, hero, footer, scroll-spy controller
    ├── skills/                   # Skills grid
    ├── projects/                 # Cards, list controller, detail page, gallery, store links
    └── contact/                  # Social links + validated form
assets/
└── data/projects.json            # ← YOUR projects
```

Each feature owns its `bindings/`, `controllers/`, `views/` and `widgets/` folders. Controllers never import widgets from another feature. The home page composes the sections from the other features.

## Dependencies

| Package | Why |
|---|---|
| `get` | State management, routing, DI and UI translations |
| `get_storage` | Saves the theme and language choice |
| `flutter_localizations` | Material/Cupertino strings and automatic RTL `Directionality` |
| `flutter_animate` | Entrance, looping and hover animations |
| `google_fonts` | Plus Jakarta Sans (Latin) and Cairo (Arabic) |
| `font_awesome_flutter` | Brand icons for GitHub, LinkedIn, Google Play and Apple |
| `url_launcher` | Store, GitHub and CV links, plus `mailto:` for the contact form |
| `intl` | Required by `flutter_localizations` |

## Make it yours

1. **Profile**: edit `lib/core/config/app_config.dart` (name, initials, email, GitHub, LinkedIn, CV URL, optional avatar, stats). Set any link to `null` to hide its button.
2. **Bio and title**: edit `hero_*` in `lib/core/i18n/{en,fr,ar}.dart`.
3. **Skills**: edit `lib/data/static/skills_data.dart`.
4. **Projects**: edit `assets/data/projects.json`. The full schema is documented on `Project` in `lib/data/models/project.dart`. In short:
   - Any text field can be a plain string (`"title": "ShopSphere"`) or a map per language (`{"en": "…", "fr": "…", "ar": "…"}`). A missing language falls back to English.
   - Images: `thumbnail` (home card, 16:10), `banner` (wide header on the detail page; falls back to `thumbnail`) and `screenshots` (portrait phone shots). Each accepts an asset path or an `https://` URL. Empty values get branded placeholder art in the project's `accentColor`. Asset folders are not recursive, so add each per-project folder (e.g. `assets/images/projects/shopsphere/`) to `pubspec.yaml`.
   - `links.playStore / appStore / webDemo / github`: `null` hides that button. If every link is `null`, the page shows "Private project".
   - `featured: false` keeps a project out of the home grid, but its URL still works.
5. **Brand colours**: edit `AppColors` in `lib/core/theme/app_tokens.dart`. Material 3 derives the rest of the colour scheme from `seed`.

### Adding a language

Add a `xx.dart` table next to `en.dart`, register it in `AppTranslations.keys` and `AppLocales.all`, and add its text to the JSON maps. `test/translations_test.dart` fails if any key is missing.

## Production notes

- **Contact form**: there is no backend. On submit, the form checks the fields and then opens the visitor's mail app with the message filled in. To send the message directly, replace the body of `ContactController.submit` with a call to your own endpoint, Formspree, EmailJS or a Firebase Function.
- **Fonts**: `google_fonts` downloads the fonts at runtime. For offline use, or to avoid a font swap on first load, bundle the `.ttf` files and set `GoogleFonts.config.allowRuntimeFetching = false`.
- **Web URLs**: the app uses hash URLs (`/#/projects/id`), which work on any static host. For clean URLs, call `usePathUrlStrategy()` from `flutter_web_plugins` and configure your host to rewrite every path to `index.html`.
