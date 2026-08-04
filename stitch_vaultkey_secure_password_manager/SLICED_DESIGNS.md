# VaultKey — Sliced Design Document

> Extracted from HTML prototypes for Flutter implementation
> Source: `stitch_vaultkey_secure_password_manager/`

---

## 1. Design Tokens

### 1.1 Color Palette (Material 3 Dark)

| Token | Hex | Usage |
| --- | --- | --- |
| `background` | `#0e131f` | App scaffold background |
| `surface` | `#0e131f` | Cards, sheets base |
| `surface-dim` | `#0e131f` | Dimmed surfaces |
| `surface-bright` | `#343946` | Elevated hover states |
| `surface-container-lowest` | `#090e1a` | Bottom sheets, modals |
| `surface-container-low` | `#161b28` | Input fields |
| `surface-container` | `#1a1f2c` | Cards, list items, containers |
| `surface-container-high` | `#252a37` | Hovered cards, secondary buttons |
| `surface-container-highest` | `#303542` | Borders, dividers |
| `surface-variant` | `#303542` | Outlines, borders |
| `on-surface` | `#dee2f3` | Primary text |
| `on-surface-variant` | `#c2c6d6` | Secondary text, placeholders |
| `outline` | `#8c909f` | Default borders |
| `outline-variant` | `#424754` | Subtle dividers |
| `primary` | `#adc6ff` | Primary accent, links, icons |
| `on-primary` | `#002e6a` | Text on primary buttons |
| `primary-container` | `#4d8eff` | Active states, filled buttons |
| `on-primary-container` | `#00285d` | Text on primary-container |
| `inverse-primary` | `#005ac2` | Hover primary (legacy `#3B82F6`) |
| `secondary` | `#4edea3` | Success, strong passwords, TOTP |
| `on-secondary` | `#003824` | Text on secondary |
| `secondary-container` | `#00a572` | Success backgrounds |
| `tertiary` | `#ffb95f` | Warnings, OTP urgency |
| `tertiary-container` | `#ca8100` | Warning backgrounds |
| `error` | `#ffb4ab` | Errors |
| `error-container` | `#93000a` | Error backgrounds |
| `on-error` | `#690005` | Text on error |

### 1.2 Typography

| Token | Font | Size | Weight | Line-Height | Letter-Spacing |
| --- | --- | --- | --- | --- | --- |
| `headline-lg` | Inter | 32px | 700 | 40px | -0.02em |
| `headline-lg-mobile` | Inter | 24px | 700 | 32px | -0.01em |
| `headline-md` | Inter | 20px | 600 | 28px | — |
| `body-lg` | Inter | 16px | 400 | 24px | — |
| `body-md` | Inter | 14px | 400 | 20px | — |
| `label-sm` | Inter | 12px | 600 | 16px | 0.05em |
| `code-md` | JetBrains Mono | 14px | 500 | 20px | — |

### 1.3 Spacing (8px Grid)

| Token | Value |
| --- | --- |
| `xs` | 4px |
| `sm` / `base` | 8px |
| `md` | 16px |
| `lg` | 24px |
| `xl` | 32px |
| `gutter` | 16px |
| `margin-mobile` | 16px |
| `margin-tablet` | 32px |

### 1.4 Shape / Radius

| Token | Value | Usage |
| --- | --- | --- |
| `sm` | 4px | Small tags |
| `DEFAULT` / `md` | 8px | Buttons, inputs, small cards |
| `lg` | 12px | Cards |
| `xl` | 16px | Modals, bottom sheets (top corners) |
| `full` | 9999px | Pills, avatars, FABs |

---

## 2. Screen Inventory

| # | Screen | File | Type | Notes |
| --- | --- | --- | --- | --- |
| 1 | **Splash** | `splash_screen/code.html` | Full-screen | Logo + loading bar + "Initializing Secure Enclave" |
| 2 | **Onboarding** | `onboarding_flow/code.html` | Carousel | 3 slides: Store passwords, Generate strong passwords, 2FA shield |
| 3 | **Sign Up** | `sign_up_screen/code.html` | Auth form | Email, master password, confirm, strength meter, terms |
| 4 | **Log In** | `login_screen/code.html` | Auth form | Email, master password, biometric, forgot password |
| 5 | **Unlock** | `unlock_screen/code.html` | Auth gate | Master password + biometric fallback, decorative orbits |
| 6 | **Vault Home** | `vault_home/code.html` | Main list | Search, profile, category chips, credential cards, FAB |
| 7 | **Add/Edit Password** | `add_edit_password/code.html` | Form | Item name, vault picker, URL, username, password, notes, tags |
| 8 | **Authenticator** | `authenticator_tab/code.html` | List | TOTP codes, global 30s timer, copy action |
| 9 | **Password Generator** | `password_generator/code.html` | Bottom sheet | Generated password, strength, length slider, toggles |
| 10 | **QR Scanner** | `qr_scanner/code.html` | Full-screen camera | Viewfinder overlay, scan frame, manual entry |
| 11 | **TOTP Timer (Three.js)** | `three.js/code.html` | Animation | Circular progress ring animation for TOTP countdown |
| 12 | **Brand Logo** | `vaultkey_brand_logo/screen.png` | Asset | PNG export of brand logo |

---

## 3. Shared Components

### 3.1 AppBar (Fixed Header)

- **Height**: 64px (`h-16`)
- **Background**: `surface/80` + `backdrop-blur-xl`
- **Shadow**: `0 1px 8px rgba(0,0,0,0.2)`
- **Left**: Brand logo (h-8) + screen title (`headline-md`)
- **Right**: Profile avatar (32px rounded-full)
- **Safe area**: `pt-safe` (notch/status bar padding)

### 3.2 Text Input (Standard)

- **Background**: `surface-container` (`#1a1f2c`)
- **Border**: none default, `ring-1 ring-primary` on focus
- **Radius**: `lg` (8px) or `xl` (12px) depending on density
- **Height**: 48px (compact) or 56px (comfortable)
- **Left icon**: Material Symbol, `on-surface-variant` → `primary` on focus
- **Right action**: Copy, visibility toggle, or open-in-new
- **Text style**: `body-md` or `code-md` for passwords
- **Placeholder**: `on-surface-variant/50`

### 3.3 Primary Button (Filled)

- **Background**: `inverse-primary` (`#005ac2`) or `primary-container` (`#4d8eff`)
- **Text**: White / `on-primary`
- **Height**: 48–56px
- **Radius**: `md` (8px) or `xl` (12px)
- **Shadow**: `0 4px 20px rgba(173,198,255,0.15)` (subtle glow)
- **Active state**: `scale-[0.98]`
- **Icon + Label** layout common

### 3.4 Secondary Button (Outlined)

- **Border**: 1px `surface-container-highest` or `outline-variant`
- **Text**: `primary` or `on-surface`
- **Background**: transparent → `surface-container-high` on hover

### 3.5 Credential Card

- **Background**: `surface-container`
- **Radius**: `2xl` (16px) or `xl` (12px)
- **Shadow**: `shadow-sm shadow-black/20`
- **Padding**: 16px
- **Layout**: Row — [Icon (48px)] + [Title + Subtitle] + [Actions]
- **Icon container**: 48px rounded-xl, `surface` bg, colored icon
- **Shimmer**: `bg-gradient-to-r from-transparent via-white/5 to-transparent` on hover
- **Actions**: Copy (content_copy), More (more_vert)

### 3.6 Category Chip

- **Active**: `bg-primary text-on-primary` + `shadow-lg shadow-primary/20`
- **Inactive**: `bg-surface-container text-on-surface-variant` + `shadow-sm shadow-black/10`
- **Radius**: `xl` (12px)
- **Padding**: px-5 py-2.5
- **Text**: `label-sm`

### 3.7 Strength Indicator (4-segment bar)

- **Container**: `h-1.5` rounded-full, `bg-surface-container-high`
- **Segments**: 4 flex children
- **Colors by strength**:
  - Weak (1): `error`
  - Fair (2): `tertiary`
  - Good (3): `tertiary` + `secondary`
  - Strong (4): all `secondary`
- **Label**: `label-sm` right-aligned, color matches level

### 3.8 Bottom Sheet

- **Background**: `surface-container-highest`
- **Top radius**: `rounded-t-3xl` (24px)
- **Shadow**: `shadow-2xl`
- **Drag handle**: 48px × 6px `bg-outline-variant rounded-full`
- **Padding**: `px-margin-mobile` + `pb-safe`

### 3.9 Floating Action Button (FAB)

- **Background**: `primary-container` (`#4d8eff`)
- **Icon**: White, Material Symbols
- **Size**: 56px
- **Radius**: `full`
- **Shadow**: `shadow-lg shadow-primary/30`
- **Position**: Bottom-right, above safe area

---

## 4. Per-Screen Breakdown

### 4.1 Splash Screen

**Layout**: Centered column, full-screen `background`

#### Splash Elements

| Element | Spec |
| --- | --- |
| Background glow | `w-[800px] h-[800px] rounded-full bg-primary/20 blur-[120px] animate-pulse opacity-10` |
| Logo | 128px (`w-32 h-32`), object-contain, drop-shadow-2xl, `animate-[bounce_3s_ease-in-out_infinite]` |
| App name | `headline-lg` white, tracking-tight |
| Tagline | `body-md` `on-surface-variant/70`, uppercase, tracking-widest |
| Progress bar | `w-full h-1 bg-surface-container-highest rounded-full` |
| Progress fill | `bg-primary`, animated with custom `loading` keyframe |
| Status text | `label-sm` `on-surface-variant/50`, uppercase, tracking-widest + spinning `sync` icon |

**Animation**: `loading` — translateX + width morph, 2s ease-in-out infinite

#### Assets

- Brand logo image (see §6 Assets)

---

### 4.2 Onboarding Flow

**Layout**: Full-screen swipeable carousel (3 slides), horizontal scroll snap

#### Global chrome

- Top-right "Skip" button: `text-on-surface-variant`, hover `bg-surface-bright`, rounded-full
- Bottom dot indicators + "Get Started" CTA (slide 3)

#### Per slide structure

| Element | Spec |
| --- | --- |
| Icon container | 128px (`w-32 h-32`), `bg-surface-container rounded-2xl`, shadow-xl, border `surface-variant` |
| Glow behind icon | `absolute inset-0 bg-{color}/20 rounded-full blur-3xl animate-pulse` |
| Icon | Material Symbols `text-6xl` (`48px`), filled, color = slide accent |
| Headline | `headline-lg-mobile` `on-background`, centered, tracking-tight |
| Body | `body-lg` `on-surface-variant`, centered, max-w-xs, leading-relaxed |

#### Slide content

| Slide | Icon | Color | Headline | Body |
| --- | --- | --- | --- | --- |
| 1 | `lock` | `primary` | Store passwords securely | "Your digital fortress. Enterprise-grade encryption..." |
| 2 | `vpn_key` | `secondary` | Generate strong passwords | "Stop using 'password123'. Instantly create complex..." |
| 3 | `shield_lock` | `tertiary` | Two-Factor Authentication | "Add an extra layer of security with time-based codes..." |

---

### 4.3 Sign Up Screen

**Layout**: Centered column, scrollable form

#### Sign Up Elements

| Element | Spec |
| --- | --- |
| Header icon | 64px rounded-2xl, `bg-surface-container`, `shield_lock` `primary` 32px filled + glow |
| Title | `headline-lg-mobile` `on-background` |
| Subtitle | `body-md` `on-surface-variant` max-w-[280px] |
| Email input | Standard input, `mail` icon, placeholder `"name@company.com"` |
| Master password | Standard input, `key` icon, `code-md` tracking-wider, visibility toggle, strength bar below |
| Confirm password | Standard input, `lock_reset` icon, match validation error text |
| Terms checkbox | "I agree to Terms" + link |
| CTA | Full-width primary button "Create Account" |
| Footer | "Already have an account? Sign In" link |

#### Sign Up Interactions

- Password strength: real-time 4-segment bar update
- Confirm validation: error text `text-error` opacity toggle when mismatch
- Visibility toggles on both password fields

---

### 4.4 Log In Screen

**Layout**: Centered column, compact card

#### Login Elements

| Element | Spec |
| --- | --- |
| Brand logo | 96px (`w-24 h-24`) centered, mb-lg |
| Card container | `bg-surface p-xl rounded-xl shadow-lg border border-surface-variant`, max-w-sm |
| Title | `headline-lg-mobile` `on-surface` |
| Subtitle | `body-md` `on-surface-variant` |
| Email input | `mail` icon, standard |
| Password input | `lock` icon, standard, visibility toggle, "Forgot Password?" link right-aligned |
| Primary CTA | `bg-[#3B82F6]` (legacy) → use `inverse-primary`, white text, `login` icon, "Log In" |
| Divider | "Or continue with" `label-sm` `outline` uppercase, tracking-wider |
| Biometric button | Full-width outlined, `fingerprint` icon, "Biometric Login" |
| Footer | "Don't have an account? Sign Up" |

---

### 4.5 Unlock Screen

**Layout**: Centered column, decorative background

#### Background effects

- Radial dot grid: `radial-gradient(circle, primary 1px, transparent 1px)`, 32px size, 20% opacity
- Orbit rings: 384px and 448px circles, `border-surface-variant`, slow rotation (60s / 90s)

#### Unlock Elements

| Element | Spec |
| --- | --- |
| Hero icon | 96px (`w-24 h-24`) circle, `bg-surface-container-high`, `lock` 48px `primary` filled |
| Glow | `absolute -inset-4 bg-primary/20 rounded-full blur-2xl`, hover opacity transition |
| Scan line | `h-1 bg-primary/40 blur-[2px] animate-ping` inside shield |
| Title | `headline-lg-mobile` `on-background` "Vault Locked" |
| Subtitle | `body-md` `on-surface-variant` "Enter your Master Password to proceed." |
| Password input | Centered text, `code-md` tracking-[0.3em], `password` left icon, visibility toggle right |
| Unlock button | Full-width `bg-primary` `on-primary`, `headline-md`, `arrow_forward` icon, shimmer effect |
| Biometric fallback | `fingerprint` icon button below, `on-surface-variant` |
| Footer | "Forgot Master Password?" link |

**Animation**: `shimmer` — gradient sweep across button, 2.5s infinite

---

### 4.6 Vault Home

**Layout**: Main scrollable list with sticky header

#### Sticky Search Header

- Position: `sticky top-16 z-40`
- Background: `bg-background/95 backdrop-blur-xl`
- Shadow: `0 4px 16px rgba(0,0,0,0.2)`
- Search input: flex-1, `bg-surface-container rounded-xl`, `search` icon, placeholder "Search vault..."
- Profile avatar: 48px rounded-xl, right side

#### Category Chips

- Horizontal scroll, `px-margin-mobile py-2`, gap-sm
- Items: All Items (active), Logins, Cards, Secure Notes, Identity
- Overflow: `scrollbar-width: none`

#### Credential List

- Sections: "Pinned" + "All Accounts" (or similar)
- Section header: `label-sm` `on-surface-variant` uppercase tracking-wider
- Cards: see §3.5 Credential Card
- Sample entries include: GitHub/Enterprise (code icon, red), Gmail (mail icon, #EA4335), etc.

#### FAB

- Position: bottom-right, above safe area
- Icon: `add` or `plus`
- Style: see §3.9

---

### 4.7 Add/Edit Password

**Layout**: Scrollable form, sections grouped

#### Sections

1. **Vault Selection & Item Name**
   - Item Name input: `badge` icon, placeholder "e.g. Work Email, Netflix"
   - Vault/Folder picker: button row, `folder` icon (filled, `secondary`), selected value, `expand_more`

2. **Core Credentials Box**
   - Container: `bg-surface-container rounded-xl`, internal gradient `from-primary/5 to-transparent`
   - Website URL: `language` icon, URL input, `open_in_new` button
   - Username: `person` icon, input, `content_copy` button
   - Password: `lock` icon, `code-md` input, visibility toggle, `content_copy`, strength indicator
   - TOTP field: `timer` icon, `code-md` input, 30s circular timer SVG, `content_copy`

3. **Additional Details**
   - Notes: `notes` icon, multiline textarea
   - Tags: `sell` icon, chip input area

4. **Actions**
   - "Delete Item" text button: `error` color, left-aligned
   - "Save Changes" primary button: full-width

---

### 4.8 Authenticator Tab

**Layout**: List with sticky AppBar

#### AppBar

- Logo (h-8) + "Authenticator" title (`headline-md`)
- Profile avatar (32px rounded-full)

#### Global Timer

- 48px circle, `bg-surface-container`
- SVG circular progress: 36×36 viewBox, stroke-width 3
- Background track: `surface-variant`
- Progress: `primary`, animated with CSS `transition-all duration-1000 ease-linear`
- Center text: 10px `code-md` countdown

#### TOTP Entries

- **High Priority** section: `bg-surface-container rounded-xl`, gradient accent `from-primary/10 to-transparent`
- **All Accounts** section: standard list
- Entry layout:
  - Left: 40px rounded-lg icon container, `surface-container-highest`, colored Material Symbol (filled)
  - Middle: Title (`headline-md` 16px) + subtitle (`body-md` 13px `on-surface-variant`)
  - Right: `content_copy` icon, hover opacity transition
  - Bottom: `code-md` `headline-lg` `primary` tracking-[0.2em]

#### Authenticator Interactions

- Tap entry → copy code to clipboard
- Global timer syncs all entries (30s TOTP window)

---

### 4.9 Password Generator

**Layout**: Bottom sheet modal

#### Sheet chrome

- Drag handle: 48×6px `bg-outline-variant rounded-full`
- Close button: top-right, `close` icon

#### Content

| Element | Spec |
| --- | --- |
| Title | `headline-lg-mobile` "Generator" |
| Password display | `bg-surface-container-lowest rounded-xl p-md pr-14`, `code-md` `headline-md` `primary` tracking-widest, break-all |
| Hover glow | `bg-primary/5` opacity transition |
| Copy button | 32px circle, right side of display |
| Regenerate | `label-sm` `primary`, `refresh` icon, right-aligned below display |
| Strength bar | 4-segment, see §3.7 |
| Length slider | Label "Length" + value, custom slider styling |
| Toggles | Include Uppercase, Lowercase, Numbers, Symbols — switch style |
| History | "Recent Passwords" section with chip list |
| Primary CTA | "Use Password" full-width button |

---

### 4.10 QR Scanner

**Layout**: Full-screen camera overlay

#### Viewfinder

- Center: 288×288px (`w-72 h-72`) clear area
- Corners: 32×32px (`w-8 h-8`) `bg-surface-container-highest` with inset shadow in `secondary` (#4edea3)
- Scan line: `h-1 bg-primary/80 blur-[1px] shadow-[0_0_15px_#adc6ff]`, animates vertically 2s ease-in-out infinite alternate

#### Shade overlay

- Top, left, right, bottom: `bg-background/80 backdrop-blur-sm`

#### Bottom text

- `qr_code_scanner` icon 48px `on-surface-variant`
- Title: `headline-md` "Scan Authenticator Code"
- Subtitle: `body-md` `on-surface-variant` centered max-w-[280px]

#### Bottom action

- "Manual Entry" pill button: `bg-surface-container`, `keyboard` icon, `primary` text, ring-1 `outline-variant/30`

#### Background

- Simulated camera feed: blurred dark tech image, 40% opacity

---

### 4.11 TOTP Timer Animation (Three.js)

**Purpose**: Reusable circular countdown animation for TOTP 30-second window

#### Implementation

- SVG-based (preferred for Flutter) or CustomPainter
- Circle radius: 15.9155 (for 100 circumference)
- Circumference: ~100 units
- Stroke dasharray: `100, 100`
- Stroke dashoffset: animated from 100 → 0 over 30s
- Colors: track = `surface-variant`, progress = `primary`

#### Flutter equivalent

- `CustomPaint` with `CircularProgressIndicator` or custom `CustomPainter`
- `AnimationController` 30s linear
- Update every 100ms for smoothness

---

## 5. Navigation Flow

```text
[Splash] ──→ [Onboarding] ──→ [Sign Up] ──┐
     │           │              │          │
     │           └────────→ [Log In] ←───┘
     │                         │
     └─────────────────────────┘ (if returning user)
                               ↓
                         [Unlock] ←── (app resume / timeout)
                               ↓
                         [Vault Home] ←──→ [Add/Edit Password]
                               │
              ┌────────────────┼────────────────┐
              ↓                ↓                ↓
        [Authenticator]  [QR Scanner]      [Password Generator]
              │                │                ↑
              └────────────────┴────────────────┘
```

**Tab structure** (implied):

- Vault (home)
- Authenticator (TOTP)
- Generator (tool)
- Profile/Settings (implied by avatar taps)

---

## 6. Asset Inventory

### 6.1 External Images (require download / replacement)

| Screen | Asset | URL | Usage |
| --- | --- | --- | --- |
| Splash | Brand logo | `lh3.googleusercontent.com/aida-public/AB6AXuBlTnSh-...` | Center logo |
| Login | Brand logo | Same as above | Center logo |
| Login | User profile | `lh3.googleusercontent.com/aida-public/AB6AXuDBzyaf-...` | Profile avatar |
| Vault Home | User profile | Same as above | Search header avatar |
| Authenticator | User profile | Same as above | AppBar avatar |
| QR Scanner | Camera bg | `lh3.googleusercontent.com/aida-public/AB6AXuD-bkfii-...` | Blurred background |
| Brand Logo | screen.png | `vaultkey_brand_logo/screen.png` | Logo export |
| Profile | screen.png | `professional_studio_headshot_.../screen.png` | Profile photo |

**Recommendation**: Download these and place in `assets/images/` or `assets/brand/`. The Google-hosted URLs are temporary/AI-generated placeholders.

### 6.2 Material Symbols Icons Used

| Icon Name | Screens | Usage |
| --- | --- | --- |
| `lock` | Splash, Onboarding, Unlock | Security icon |
| `vpn_key` | Onboarding | Key icon |
| `shield_lock` | Onboarding, Sign Up | Shield icon |
| `mail` | Login, Sign Up | Email input |
| `login` | Login | CTA icon |
| `fingerprint` | Login, Unlock | Biometric |
| `visibility` / `visibility_off` | Login, Sign Up, Unlock, Add/Edit | Password toggle |
| `password` | Unlock | Master password |
| `arrow_forward` | Unlock | CTA icon |
| `search` | Vault Home | Search input |
| `code` | Vault Home | GitHub credential |
| `mail` | Vault Home | Gmail credential |
| `content_copy` | Vault Home, Add/Edit, Authenticator, Generator | Copy action |
| `more_vert` | Vault Home | Overflow menu |
| `add` / `plus` | Vault Home | FAB |
| `badge` | Add/Edit | Item name |
| `folder` | Add/Edit | Vault picker |
| `language` | Add/Edit | URL field |
| `person` | Add/Edit | Username |
| `timer` | Add/Edit | TOTP field |
| `notes` | Add/Edit | Notes field |
| `sell` | Add/Edit | Tags field |
| `work` | Authenticator | Acme Corp entry |
| `refresh` | Generator | Regenerate |
| `close` | Generator | Close sheet |
| `keyboard` | QR Scanner | Manual entry |
| `qr_code_scanner` | QR Scanner | Scanner icon |
| `sync` | Splash | Loading spinner |

**Flutter mapping**: Use `material_symbols_icons` package or standard `Icons.` equivalents where possible.

---

## 7. Flutter Theme Mapping

### 7.1 ColorScheme (dark)

```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFFadc6ff),
  brightness: Brightness.dark,
  // Override specific tokens to match design exactly
  primary: const Color(0xFFadc6ff),
  onPrimary: const Color(0xFF002e6a),
  primaryContainer: const Color(0xFF4d8eff),
  onPrimaryContainer: const Color(0xFF00285d),
  secondary: const Color(0xFF4edea3),
  onSecondary: const Color(0xFF003824),
  secondaryContainer: const Color(0xFF00a572),
  tertiary: const Color(0xFFffb95f),
  error: const Color(0xFFffb4ab),
  surface: const Color(0xFF0e131f),
  onSurface: const Color(0xFFdee2f3),
  onSurfaceVariant: const Color(0xFFc2c6d6),
  outline: const Color(0xFF8c909f),
  outlineVariant: const Color(0xFF424754),
  surfaceContainerHighest: const Color(0xFF303542),
  surfaceContainerHigh: const Color(0xFF252a37),
  surfaceContainer: const Color(0xFF1a1f2c),
  surfaceContainerLow: const Color(0xFF161b28),
  surfaceContainerLowest: const Color(0xFF090e1a),
  surfaceBright: const Color(0xFF343946),
  surfaceDim: const Color(0xFF0e131f),
)
```

### 7.2 TextTheme

```dart
TextTheme(
  headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.02 * 32, height: 40/32),
  headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, height: 28/20),
  bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, height: 24/16),
  bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, height: 20/14),
  labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05 * 12, height: 16/12),
)
```

Add `fontFamily: 'JetBrainsMono'` for `code-md` styles (passwords, TOTP codes).

### 7.3 ShapeTheme

```dart
ShapeTheme(
  // Map to component defaults
  // Buttons: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
  // Cards: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 or 16))
  // FAB: CircleBorder()
  // Chips: StadiumBorder() or RoundedRectangleBorder(radius: 12)
)
```

---

## 8. Implementation Checklist

- [ ] Set up `google_fonts` package (Inter, JetBrains Mono)
- [ ] Configure dark `ColorScheme` with exact hex values
- [ ] Build `AppBar` widget with blur + safe area
- [ ] Build `VaultInput` widget (icon + field + action)
- [ ] Build `CredentialCard` widget with shimmer
- [ ] Build `CategoryChip` widget with active/inactive states
- [ ] Build `StrengthBar` widget (4-segment animated)
- [ ] Build `TOTPTimer` widget (SVG/CustomPainter 30s)
- [ ] Build `BottomSheet` scaffold with drag handle
- [ ] Implement all 10 screens as separate routes
- [ ] Add `flutter_animate` or custom animations for shimmer, loading, scan line
- [ ] Replace placeholder image URLs with local assets
- [ ] Add `material_symbols_icons` dependency for outlined icons

---

*Document generated from prototype slices. For detailed design philosophy, see `vaultkey/DESIGN.md`.*
