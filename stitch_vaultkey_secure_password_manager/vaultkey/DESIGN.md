---
name: VaultKey
colors:
  surface: '#0e131f'
  surface-dim: '#0e131f'
  surface-bright: '#343946'
  surface-container-lowest: '#090e1a'
  surface-container-low: '#161b28'
  surface-container: '#1a1f2c'
  surface-container-high: '#252a37'
  surface-container-highest: '#303542'
  on-surface: '#dee2f3'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#dee2f3'
  inverse-on-surface: '#2b303d'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#4edea3'
  on-secondary: '#003824'
  secondary-container: '#00a572'
  on-secondary-container: '#00311f'
  tertiary: '#ffb95f'
  on-tertiary: '#472a00'
  tertiary-container: '#ca8100'
  on-tertiary-container: '#3e2400'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#6ffbbe'
  secondary-fixed-dim: '#4edea3'
  on-secondary-fixed: '#002113'
  on-secondary-fixed-variant: '#005236'
  tertiary-fixed: '#ffddb8'
  tertiary-fixed-dim: '#ffb95f'
  on-tertiary-fixed: '#2a1700'
  on-tertiary-fixed-variant: '#653e00'
  background: '#0e131f'
  on-background: '#dee2f3'
  surface-variant: '#303542'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  code-md:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 32px
---

## Brand & Style

This design system is engineered for high-security, enterprise-grade environments. The brand personality is authoritative, immutable, and precise. It targets professionals and security-conscious individuals who require a tool that feels like a digital fortress.

The design style is **Corporate / Modern** with a focus on **Tonal Layering**. It prioritizes clarity and utility over decorative elements. By utilizing a deep, monochromatic base with high-intensity accent colors, the UI evokes an emotional response of safety, reliability, and technical sophistication. Every interaction must feel intentional; motion should be swift and functional, reinforcing the system's efficiency and responsiveness.

## Colors

The palette is anchored in a "Dark Mode First" philosophy to reduce eye strain and provide a discreet interface for sensitive data. 

- **Background & Surface:** The deep navy `#0F1420` provides the base layer, while `#1A1F2B` is used for containers, cards, and modals to create a sense of physical structure.
- **Accents:** Electric Blue `#3B82F6` serves as the primary action color. Emerald Green `#10B981` is reserved strictly for positive security states (e.g., strong passwords, verified biometrics).
- **Feedback:** Amber `#F59E0B` and Red `#EF4444` are used sparingly for critical warnings, ensuring they capture immediate attention without overwhelming the user during standard navigation.

## Typography

This design system utilizes **Inter** for all primary UI elements to ensure maximum legibility and a systematic, utilitarian feel. For security-sensitive data—such as passwords, recovery keys, and one-time codes—**JetBrains Mono** is introduced to provide clear character differentiation (e.g., distinguishing '1', 'l', and 'I').

Text hierarchy is strictly enforced. Headlines use a tighter letter-spacing for a grounded look, while labels utilize uppercase and slight tracking for categorization. All body text should maintain a high contrast ratio against the navy background to ensure accessibility in various lighting conditions.

## Layout & Spacing

The layout is built on a rigorous **8px grid system**. This rhythm ensures alignment across all components and reinforces the "enterprise-grade" feel.

- **Mobile:** A single-column fluid layout with 16px side margins. Cards and inputs span the full width of the safe area.
- **Tablet:** A 12-column grid. Sidebars are fixed at 280px for navigation, while content sits in a centered container with a maximum width of 768px to prevent line lengths from becoming unreadable.
- **Density:** The system uses "Comfortable" spacing for primary views (Vault lists) and "Compact" spacing for data-heavy views (Security Audits).

## Elevation & Depth

In a dark, high-security environment, depth is conveyed through **Tonal Layers** rather than heavy shadows.

- **Level 0 (Base):** Deep Navy `#0F1420`. Used for the main application background.
- **Level 1 (Surface):** Slightly lighter navy `#1A1F2B`. Used for cards, list items, and input fields.
- **Level 2 (Overlay):** `#252B38`. Used for hovered states or secondary buttons.
- **Level 3 (Modal):** The lightest surface tier with a 1px subtle border in a low-opacity white (10%) to define edges.

Shadows are used sparingly and should be highly diffused with a 40% opacity of the base background color, creating a "lifted" effect rather than a cast shadow.

## Shapes

The shape language uses **Rounded** corners to provide a modern, refined feel without appearing "playful." 

- **Standard Elements:** Buttons, input fields, and small cards use a 0.5rem (8px) radius.
- **Large Containers:** Modals and bottom sheets use a 1rem (16px) radius on top corners to soften the entry into the viewport.
- **Indicators:** Status pills (e.g., "Secure", "Compromised") are fully rounded (pill-shaped) to distinguish them from actionable buttons.

## Components

### Buttons
- **Primary:** Solid `#3B82F6` with white text. High-security actions (e.g., "Delete Vault") use `#EF4444`.
- **Secondary:** Outlined with a 1px border of `#252B38` and `#3B82F6` text.

### Inputs
- Background: `#1A1F2B`.
- Border: 1px solid `#252B38`, changing to `#3B82F6` on focus.
- Password fields must include a visibility toggle and a "Copy" quick-action icon.

### Cards
- Used to group related credentials. Cards should have no shadow but use a subtle `#252B38` border to separate them from the background.

### Strength Indicators
- A 4-segment progress bar. Segments turn from Red (1) to Amber (2-3) to Emerald Green (4) as password entropy increases.

### Security-Focused Elements
- **Biometric Prompt:** A large, centered shield or fingerprint icon using the Primary color.
- **Data Masks:** Sensitive fields (SSN, Passwords) are masked with bullets by default, requiring a deliberate "eye" icon tap to reveal.