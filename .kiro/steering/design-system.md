---
inclusion: fileMatch
fileMatchPattern: 'lib/**/{screens,view,custom_components,app_colors,app_text_styles,theme_colours,text_styles,screen_size}*.dart'
---

# QuickMed — Design System

Applies when working on UI: screens, views, custom components, and the
color/typography/sizing tokens.

## Sources of truth

- **Colors:** `lib/services/app_colors.dart` → `AppColors`. This is the single
  source of truth: brand tokens (mint/teal/navy), semantic tokens
  (`scaffoldBackground`, `cardBackground`, `textPrimary`, `error`, …), and an
  explicit Material 3 `AppColors.lightScheme` (deliberately **not**
  `ColorScheme.fromSeed`).
- **Typography:** `lib/services/app_text_styles.dart` → `AppTextStyles`.
  Context-based factories using `google_fonts` (Montserrat body/heading,
  Palanquin Dark for brand titles) + `AppColors` + `context.fs(...)`. Examples:
  `AppTextStyles.splashTitle(context)`, `homeTitle`, `bannerTitle`, `chipTitle`,
  `body`, `title`, `headline`.
- **Sizing:** `lib/utils/screen_size.dart` → `ScreenExt` on `BuildContext`:
  `context.sw`, `context.sh`, `context.fs(size)` (size × screenWidth / 375).

## Hard rules

1. **No raw hex / `Colors.*` at call sites** — use an `AppColors` token; add a
   token if one is missing.
2. **No hardcoded font sizes** — size text with `context.fs(...)`, preferably
   via a named `AppTextStyles` factory.
3. **Match Figma margins** exactly.
4. **Prefer Cubit over StatefulWidget** for non-trivial state.

## Legacy (do not extend)

- `theme_colours.dart` (`ThemeColours`) — legacy green/orange/grey palette
  scheduled for deletion. Its header carries a full migration map to `AppColors`.
- `text_styles.dart` (`TextStyles`) — plainer legacy styles.
- Some `custom_components` and legacy screens still reference `ThemeColours` and
  inline `GoogleFonts.montserrat(...)`; when you touch such a widget, migrate it
  toward `AppColors`/`AppTextStyles` rather than adding more legacy usage.

The `custom_components/` naming split (`themed_*` / `gradient_*` / `bordered_*`)
reflects this migration: `themed_*` lean canonical, the others still use the
legacy palette.

## Palette migration note

`AppColors` doc comments describe a phased consolidation: legacy CTA green folds
into the teal family (`gradientStart`/`gradientEnd`). If the green brand should
be kept, redefine those `AppColors` tokens rather than reviving `ThemeColours`.
