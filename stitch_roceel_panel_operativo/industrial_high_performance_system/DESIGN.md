---
name: Industrial High-Performance System
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#45464d'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#006e25'
  on-secondary: '#ffffff'
  secondary-container: '#78fa87'
  on-secondary-container: '#007327'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#0b1c30'
  on-tertiary-container: '#75859d'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#7bfd89'
  secondary-fixed-dim: '#5de070'
  on-secondary-fixed: '#002106'
  on-secondary-fixed-variant: '#00531a'
  tertiary-fixed: '#d3e4fe'
  tertiary-fixed-dim: '#b7c8e1'
  on-tertiary-fixed: '#0b1c30'
  on-tertiary-fixed-variant: '#38485d'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Nunito Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Nunito Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Nunito Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Nunito Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Nunito Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.04em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style
The design system is engineered for high-stakes industrial and professional environments where reliability, clarity, and rapid action are paramount. The brand personality is authoritative and precise, yet approachable enough to reduce cognitive load during complex tasks. 

We utilize a **Corporate / Modern** design style with subtle industrial influences. This is characterized by a "utilitarian elegance"—using generous whitespace to organize dense information and a high-contrast palette to guide user intent. The aesthetic evokes a sense of robust software that is both powerful and easy to navigate, moving away from cluttered legacy interfaces toward a streamlined, focus-driven experience.

## Colors
The color strategy employs a "Signal and Foundation" approach. 

- **Primary (Navy Blue):** Used for structural elements, navigation backgrounds, and primary headings. It provides the industrial weight and stability the system requires.
- **Secondary/Action (Signal Green):** This is the high-visibility accent (#51D466). It is reserved strictly for primary actions (Check-in, Confirm, Save), active progress indicators, and critical success states. It must stand out against the navy to provide a clear "go" signal.
- **Neutral:** A range of cool grays (Slate) provides the canvas, ensuring the interface feels airy and modern rather than heavy.
- **Surface:** We use a pure white or very light gray (#F8FAFC) for card surfaces to maintain high legibility.

## Typography
This design system utilizes **Nunito Sans** across all levels. The typeface’s slightly rounded terminals soften the industrial aesthetic, making the interface feel modern and human-centric without sacrificing professionalism.

- **Headlines:** Use Bold (700) or ExtraBold (800) weights in Navy Blue to establish clear hierarchy.
- **Body:** Standardized at 16px for optimal readability. Use a slightly lighter Slate color (#334155) for secondary body text to create visual breathing room.
- **Labels:** SemiBold or Bold weights are used for form labels and button text to ensure they are glanceable. Small labels (12px) should always use uppercase with slight letter spacing for clarity in data-heavy views.

## Layout & Spacing
The layout follows a **Fluid Grid** model based on an 8px stepping scale, ensuring consistency across all components.

- **Desktop:** A 12-column grid with 24px gutters and 40px outer margins. Content is generally contained within a max-width of 1440px to prevent excessive line lengths.
- **Mobile:** A 4-column fluid grid with 16px margins. 
- **Spacing Logic:** We prioritize "logical grouping." Elements within a component (e.g., a label and an input) use 8px spacing. Distinct sections or cards use 24px or 32px spacing to define clear boundaries.

## Elevation & Depth
To maintain the industrial-modern feel, we use **Tonal Layers** combined with **Ambient Shadows**.

- **Level 0 (Background):** Solid neutral gray (#F8FAFC).
- **Level 1 (Cards/Surface):** White background with a subtle, low-opacity shadow (Color: Navy, Opacity: 4%, Blur: 8px) and a 1px border (#E2E8F0).
- **Level 2 (Dropdowns/Modals):** Increased shadow depth (Opacity: 8%, Blur: 16px) to clearly lift the element above the page.
- **Interaction:** Buttons do not use heavy shadows; instead, they use color shifts. Primary green buttons should darken slightly on hover to provide tactile feedback without looking "mushy."

## Shapes
The shape language is **Soft (Level 1)**. This strikes a balance between the precision of sharp corners and the friendliness of fully rounded shapes.

- **Standard Elements:** Buttons, input fields, and checkboxes use a 0.25rem (4px) corner radius.
- **Containers:** Large cards and modals use a 0.5rem (8px) radius.
- **Progress Bars:** These are the only exception, using a fully rounded (pill) shape to denote fluid movement and completion status.

## Components
- **Buttons:** 
  - **Primary:** Background in Signal Green (#51D466), text in White. Used for the main path (Confirm, Save).
  - **Secondary:** Transparent background with a Navy Blue border and Navy text.
  - **Destructive:** Used sparingly, with a red tint (#EF4444).
- **Input Fields:** 1px Slate border, 16px horizontal padding. On focus, the border transitions to Signal Green with a subtle 2px outer glow.
- **Chips/Status Tags:** 
  - Success/Active states use a light green tint background with Signal Green text.
  - Pending states use a light navy tint with Navy text.
- **Progress Indicators:** Linear bars use a Slate track with a Signal Green fill. The green fill communicates healthy, forward momentum.
- **Cards:** White background, 4px border radius, subtle border. Content should be padded by 24px (lg spacing) to ensure information is not cramped.
- **Checkboxes & Radios:** When selected, these must use the Signal Green fill to signify the active choice clearly.