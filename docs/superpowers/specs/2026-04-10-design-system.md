# Design System Spec

A minimal, token-based design system for WorkflowApp — the macOS menu-bar/HUD application for the Workflows engine.

## Goals

- Sharp, precise, clean visual language tailored for a compact HUD context
- Native macOS feel — aligned with Apple Human Interface Guidelines and liquid glass
- Light and dark theme support out of the box (via system colors)
- Theme isolation — system theme now, swappable to custom themes later
- Zero external dependencies (SwiftUI only)
- Professional yet fluid — built for engineers and IT specialists
- High visual standards with minimal surface area

## Architecture

**Pattern:** Token structs with SwiftUI Environment injection (Approach A).

A `Theme` struct bundles all design tokens (colors, fonts, spacing). Injected via `@Environment(\.theme)`. Views consume tokens through ergonomic view modifiers that read the environment internally — individual views never need to declare `@Environment(\.theme)` themselves.

Theme is applied once at the root of the view hierarchy via `.theme(.system)`. Child views inherit it. Swapping themes means passing a different `Theme` value — same type, different data.

```
Theme
├── colors: Colors
├── fonts: Fonts
└── spacing: Spacing
```

## Colors

Two structs: `Colors` (full palette) and `ColorSet` (three-level hierarchy).

```swift
struct ColorSet {
    let primary: Color
    let secondary: Color
    let tertiary: Color
}

struct Colors {
    let content: ColorSet       // text, icons — things you read
    let background: ColorSet    // surfaces, fills
    let accent: Color           // interactive elements, links
    let positive: Color         // success states (running)
    let negative: Color         // error/failure states
    let warning: Color          // attention needed (waiting)
}
```

### System Theme Color Mapping

| Token | NSColor |
|---|---|
| `content.primary` | `.labelColor` |
| `content.secondary` | `.secondaryLabelColor` |
| `content.tertiary` | `.tertiaryLabelColor` |
| `background.primary` | `.textBackgroundColor` |
| `background.secondary` | `.controlBackgroundColor` |
| `background.tertiary` | `.windowBackgroundColor` |
| `accent` | `.controlAccentColor` |
| `positive` | `.systemGreen` |
| `negative` | `.systemRed` |
| `warning` | `.systemOrange` |

All system colors — light/dark adaptation is automatic.

## Fonts

Five levels. Compact choices suited for a dense HUD, plus monospace for technical content.

```swift
struct Fonts {
    let title: Font         // workflow name, section headers
    let subtitle: Font      // state labels, secondary headings
    let body: Font          // descriptions, content text
    let caption: Font       // timestamps, metadata, auxiliary info
    let mono: Font          // workflow IDs, state identifiers, technical values
}
```

### System Theme Font Mapping

| Token | SwiftUI Font |
|---|---|
| `title` | `.headline` |
| `subtitle` | `.subheadline` |
| `body` | `.body` |
| `caption` | `.caption` |
| `mono` | `.body.monospaced()` |

Headline/subheadline rather than title/title2 — the HUD is small, density over grandeur.

## Spacing

Fixed named constants. No relative math. Intentionally compact scale for the HUD context.

```swift
struct Spacing {
    let xxs: CGFloat = 2    // tight gaps, inline separators
    let xs: CGFloat = 4     // icon-to-label, compact padding
    let s: CGFloat = 6      // intra-component gaps
    let m: CGFloat = 8      // default padding, stack spacing
    let l: CGFloat = 12     // between components
    let xl: CGFloat = 16    // section separation
    let cornerRadius: CGFloat = 8  // default rounding for cards/containers
}
```

## View Modifiers

Thin wrappers that read `@Environment(\.theme)` internally. Views never need to declare the environment themselves.

### Color Modifiers

```swift
// Foreground color via keypath
.themeColor(\.content.primary)

// Background color via keypath
.themeBackground(\.background.secondary)
```

Both accept `KeyPath<Colors, Color>`.

### Font Modifier

```swift
.themeFont(\.title)
```

Accepts `KeyPath<Fonts, Font>`.

### Spacing Modifiers

```swift
// All edges
.themePadding(\.m)

// Specific edges
.themePadding(\.xs, .horizontal)
```

Accepts `KeyPath<Spacing, CGFloat>` and optional `Edge.Set` (defaults to `.all`).

### Example: Workflow Card

Note: dynamic color mapping (e.g., state → color) is the view's responsibility. Views that need conditional token selection will read `@Environment(\.theme)` directly — this is expected for data-driven styling.

```swift
HStack(spacing: 8) {
    Circle()
        .fill(stateColor)  // mapped from workflow state to theme color
        .frame(width: 6, height: 6)

    Text(workflow.name)
        .themeFont(\.title)
        .themeColor(\.content.primary)

    Spacer()

    Text(workflow.state)
        .themeFont(\.mono)
        .themeColor(\.content.secondary)
}
.themePadding(\.m)
.themeBackground(\.background.secondary)
.clipShape(RoundedRectangle(cornerRadius: 8))
```

## File Structure

All files inside `Apps/WorkflowApp/Sources/WorkflowApp/DesignSystem/`:

```
DesignSystem/
├── Theme.swift                       // Theme struct, .system factory, EnvironmentKey, .theme() modifier
├── Colors.swift                      // Colors, ColorSet structs
├── Fonts.swift                       // Fonts struct
├── Spacing.swift                     // Spacing struct
├── Modifiers/
│   ├── ThemeColorModifier.swift      // .themeColor(), .themeBackground()
│   ├── ThemeFontModifier.swift       // .themeFont()
│   └── ThemePaddingModifier.swift    // .themePadding()
```

7 files total. No `Assets.xcassets`. No dependencies beyond SwiftUI.

## Out of Scope

- Custom (non-system) color themes — future work, structure supports it
- Spacing view modifiers for stacks (ThemeHStack/ThemeVStack) — add when pain is felt
- Component library (buttons, cards, fields) — separate spec when needed
- Animation tokens
- Icon system
