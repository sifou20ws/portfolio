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
flutter analyze && flutter test
```

To preview the web build exactly as GitHub Pages serves it (clean URLs, per-project pages, 404 fallback):

```bash
flutter build web --release --base-href /portfolio/ --pwa-strategy=none
python3 tool/generate_route_pages.py build/web http://localhost:8766/portfolio/
python3 tool/serve_like_pages.py 8766   # then open http://localhost:8766/portfolio/
```

Pushing to `main` runs `.github/workflows/deploy.yml`: analyze → test → build → post-build steps → deploy to GitHub Pages.

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

## TODO

Search the code for `TODO(seif)`:

- [ ] **Formspree form ID** → `AppConfig.formspreeId` (`lib/core/config/app_config.dart`). Until then the contact form opens the visitor's email app.
- [ ] **Hero stats** → real numbers in `AppConfig.stats`, then uncomment them (the row is hidden while empty).
- [ ] **Profile photo** → `AppConfig.avatar` (square, at least 600×600).
- [ ] **Experience & Education section** → between Skills and Projects in `lib/features/home/views/home_view.dart`.

## Production notes

- **Contact form**: with `AppConfig.formspreeId` set, messages go straight to your inbox through [Formspree](https://formspree.io) (`lib/data/repositories/formspree_client.dart`). Without it, the visitor's email app opens with the message filled in and the form keeps its text.
- **Fonts**: Plus Jakarta Sans and Cairo (weights 400–800) are bundled in `google_fonts/`, so nothing is downloaded at runtime. Add a file there if you start using another weight.
- **Web URLs**: clean paths (`/portfolio/projects/<id>`). GitHub Pages is a static host, so `tool/generate_route_pages.py` writes a real page per project (with its own link-preview tags) plus a `404.html` fallback; old `#/…` links are rewritten in `web/index.html`.
- **No service worker**: the site is built with `--pwa-strategy=none` so visitors always get the latest deploy; `tool/kill_switch_service_worker.js` retires the caching worker older versions installed.
- **Link previews**: `web/og-image.jpg` (1200×630) and the Open Graph tags in `web/index.html`. Check them after a deploy with a tool such as the LinkedIn Post Inspector.
