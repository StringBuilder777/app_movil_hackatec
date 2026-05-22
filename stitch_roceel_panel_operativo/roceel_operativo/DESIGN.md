---
name: ROCEEL Operativo
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
  on-surface-variant: '#44474c'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#74777d'
  outline-variant: '#c4c6cd'
  surface-tint: '#515f72'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#0e1c2d'
  on-primary-container: '#778599'
  inverse-primary: '#b9c8dd'
  secondary: '#386090'
  on-secondary: '#ffffff'
  secondary-container: '#a2c9ff'
  on-secondary-container: '#2a5483'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#370e00'
  on-tertiary-container: '#e45405'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d5e4fa'
  primary-fixed-dim: '#b9c8dd'
  on-primary-fixed: '#0e1c2d'
  on-primary-fixed-variant: '#3a485a'
  secondary-fixed: '#d3e4ff'
  secondary-fixed-dim: '#a2c9ff'
  on-secondary-fixed: '#001c38'
  on-secondary-fixed-variant: '#1c4877'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb599'
  on-tertiary-fixed: '#370e00'
  on-tertiary-fixed-variant: '#7f2b00'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
  surface-card: '#FFFFFF'
  text-primary: '#0F172A'
  text-secondary: '#64748B'
  border-subtle: '#E2E8F0'
  success: '#16A34A'
  warning: '#EAB308'
  danger: '#DC2626'
  info: '#0284C7'
  extra-hour: '#F97316'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.01em
  headline-sm:
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
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.04em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  touch-target: 56px
  gutter: 16px
  margin-edge: 16px
---

## Brand & Style
The design system for the mobile application is built on the pillars of **Industrial Precision** and **Technical Reliability**. It is designed specifically for field technicians who operate in high-stakes, physically demanding environments. The interface must communicate authority and efficiency, ensuring that complex operational data is legible at a glance, even under challenging lighting conditions.

The chosen design style is **Corporate / Modern** with a focus on functional robustness. It avoids decorative elements like gradients or glassmorphism in favor of a flat, high-contrast aesthetic that prioritizes utility. The visual language is "Technical-Flat"—using structural grid alignment, crisp borders, and generous touch targets to accommodate users who may be wearing safety gear or operating in industrial settings.

## Colors
The palette is rooted in deep industrial blues to establish a professional and stable foundation. The **Primary** dark blue is used for high-level navigation and headers, while the **Secondary** blue supports interactive elements and secondary actions.

**Industrial Orange** (#EA580C) serves as the primary accent, reserved strictly for critical operational actions and calls to action that require immediate attention. Semantic colors follow international safety standards for industrial environments: Green for success/safe, Yellow for warning, and Red for danger/hazard. To ensure maximum accessibility in outdoor or plant lighting, the background remains a cool, clean grey-white, providing a stark contrast for the primary slate-colored text.

## Typography
Inter is utilized throughout the system for its exceptional legibility and neutral, technical character. The type scale is intentionally generous to ensure readability on mobile devices in vibrating or poorly lit environments. 

Headlines use **Bold** and **Semibold** weights to create a clear hierarchy and denote section starts. Body text is locked to a 16px base for optimal scanning. Captions and labels use 14px or 12px but maintain a medium-to-bold weight to ensure stroke thickness is sufficient against the background. All Spanish (Mexico) localized text should respect these height constraints to avoid clipping on longer technical terms common in the industry.

## Layout & Spacing
The layout operates on a **4px base unit**, scaling up to a **12-column fluid grid** for tablets and a **single-column vertical flow** for mobile. 

A critical requirement for this system is "glove-friendly" design. This means a minimum touch target of **56dp** for all primary interactive elements. Margin and padding within cards should never drop below 16px (md) to prevent visual clutter and accidental taps. Between distinct functional blocks (e.g., between two separate work orders), use 24px (lg) spacing to clearly delineate tasks.

## Elevation & Depth
In alignment with the "Industrial-Flat" style, depth is conveyed through **Tonal Layering** and very subtle shadows rather than complex skeuomorphism. 

- **Surface Level 0:** The app background (#F8FAFC) is the lowest level.
- **Surface Level 1 (Cards):** Primary containers are pure white with a single, soft shadow (0px 2px 4px rgba(15, 23, 42, 0.05)) and a 1px border (#E2E8F0) to ensure they stand out even in high-glare environments.
- **Surface Level 2 (Floating/Active):** Elements that are being interacted with or top-level modals use a secondary shadow layer (0px 10px 15px rgba(15, 23, 42, 0.1)) to suggest they are "above" the operational plane.

No background blurs or translucency are permitted, as they can degrade performance on lower-end industrial ruggedized devices.

## Shapes
The shape language balances modern software aesthetics with industrial sturdiness. 

- **Cards:** Use a **12px radius** to feel modern and approachable.
- **Buttons:** Use a **8px radius** to provide a tighter, more precise appearance that signifies "action."
- **Badges/Chips:** Use **Pill-shaped (999px)** rounding to clearly distinguish status indicators and tags from interactive buttons.
- **Inputs:** Follow the button rounding (8px) for consistency in the data-entry areas.

## Components

### Buttons
Primary buttons must be 56px tall with the primary dark blue or industrial orange background. Labels are centered, uppercase, and bold. Secondary buttons use a 1.5px outline in the secondary blue color.

### Cards
Cards are the primary container for work orders and technical data. They must feature a consistent 16px internal padding. Critical information (like "Time Remaining" or "Hazard Level") should be placed in the top right corner of the card using a status badge.

### Input Fields
Inputs require a visible 1px border at all times to define the hit area. When focused, the border thickness increases to 2px in the primary blue. Labels must remain visible above the field (no floating labels that disappear) to maintain context during data entry.

### Badges
Badges for "Extra Hours" or "Status" use high-saturation backgrounds (e.g., #F97316) with white text. They are pill-shaped and should have a minimum height of 28px to remain legible.

### Icons
Use **Material Symbols Rounded**. The rounded corners of the icons mirror the shape language of the cards and buttons. Standard icon size for action bars is 24px, centered within a 48px or 56px touch target.

### Lists
List items should have a minimum height of 72px when containing two lines of text (Title + Subtitle) to ensure they are easy to select while moving or wearing gloves. Each list item should be separated by a 1px border or a 12px vertical gap.