---
name: Resguardo Emergency Response
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#44474d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#75777e'
  outline-variant: '#c5c6cd'
  surface-tint: '#515f78'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#0d1c32'
  on-primary-container: '#76849f'
  inverse-primary: '#b9c7e4'
  secondary: '#bb0112'
  on-secondary: '#ffffff'
  secondary-container: '#e02928'
  on-secondary-container: '#fffbff'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#002109'
  on-tertiary-container: '#009842'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d6e3ff'
  primary-fixed-dim: '#b9c7e4'
  on-primary-fixed: '#0d1c32'
  on-primary-fixed-variant: '#39475f'
  secondary-fixed: '#ffdad6'
  secondary-fixed-dim: '#ffb4ab'
  on-secondary-fixed: '#410002'
  on-secondary-fixed-variant: '#93000b'
  tertiary-fixed: '#7ffc97'
  tertiary-fixed-dim: '#62df7d'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005320'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
  display-mobile:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 26px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
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
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 18px
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system delivers an unwavering sense of clarity, rapid operational utility, and calm authority during high-stress crises. Designed for emergency preparedness, active crisis management, and instantaneous welfare confirmation, the visual language prioritizes immediate legibility over ornament. 

The aesthetic fuses **High-Contrast Utilitarianism** with **Modern Cleanliness**:
- **Pure Canvas:** Clean, unadulterated white surfaces (`#FFFFFF`) eliminate visual noise and reduce cognitive strain under sunlight or emergency conditions.
- **Authoritative Contrast:** Monolithic deep navy typography and structure ground the UI in dependability, avoiding harsh pure blacks in favor of an institutional, calculated tone.
- **Triage Signifiers:** Distinctive functional alert pigments (vibrant emergency crimson, decisive welfare emerald, and caution amber) cut cleanly through neutral surfaces to direct eye flow within milliseconds.
- **Tactile Assurance:** Components use deliberate boundaries, crisp geometry, and unequivocal affordances so users can execute life-critical actions with total confidence.

## Colors

The palette is engineered around high accessibility ratios, sharp differentiation, and standardized emergency color psychology:

- **Surface Base (`#FFFFFF`):** Pure white canvas, providing maximum luminous reflectance and zero tinting for peak daylight readability.
- **Primary & Structural Ink (`#0A192F`):** Deep Navy. Used for display titles, structural borders, icons, primary system actions, and body copy. Delivers an AAA-grade contrast ratio against pure white while lending a composed, authoritative character.
- **Secondary / Emergency SOS (`#DC2626` base, `#EF4444` hover/active):** High-urgency crimson reserved strictly for panic triggers, active distress signals, critical alerts, and destructive actions.
- **Tertiary / Welfare ("Estoy a Salvo") (`#16A34A` base, `#10B981` active/tint):** Reassuring emerald green dedicated to safe status pings, verified check-ins, successful network synchronizations, and all-clear states.
- **Warning / Amber (`#D97706` base, `#F59E0B` active/tint):** Cautionary status indicator for low battery warnings, degraded GPS signal, advisory notices, or approaching perimeter hazards.
- **Secondary Surfaces & Fills (`#F8FAFC` to `#F1F5F9`):** Subdued off-white and cool slate fills that differentiate nested card containers without sacrificing contrast.
- **Structural Outlines (`#E2E8F0` resting, `#0A192F` focused/emphasized):** Crisp low-luminance dividers and containment rings.

## Typography

The type system prioritizes micro-legibility and situational awareness:

- **Headlines (Space Grotesk):** Provides structured, geometric, technical punchiness to critical headers, emergency states, and countdown trackers. The deliberate letterforms create an authoritative posture without appearing aggressive.
- **Body & Dialogue (Inter):** Maximizes neutral readability across high-density instructions, contact profiles, triage checklists, and medical notes. Tall x-height prevents character collision on low-resolution or cracked mobile screens.
- **Labels & Data Readouts (JetBrains Mono):** Monospaced precision assigned to telemetry, GPS coordinates, timestamps, battery percentages, and device connectivity states to guarantee rapid optical parsing.
- All typography renders in Deep Navy (`#0A192F`), maintaining consistent optical weight without low-contrast gray washouts.

## Layout & Spacing

A strictly regimented 8-point base grid ensures rapid predictability during high-adrenaline user interactions:

- **Grid Framework:** Fluid 4-column layout on mobile (<640px) expanding to 8 columns on tablet (641px–1024px) and 12 columns on desktop/command displays (>1024px).
- **Safe Touch Targets:** On handheld devices, interactive triggers enforce a minimum bounding box of 48px by 48px, with SOS triggers occupying full-width bottom pinned sheets or high-visibility card tiers.
- **Vertical Hierarchy:** Content sections are grouped with `space-md` internally and separated by `space-lg` to `space-xl` cross-boundary margins to prevent accidental taps during tremors or rapid motion.
- **Reflow Architecture:** Emergency actions remain persistent and dock to the lower viewport boundaries on mobile views, while maps, contacts, and telemetry shift into modular high-visibility panels on widescreen layouts.

## Elevation & Depth

To maximize performance, avoid murky visual artifacts, and preserve sunlight visibility, depth relies on **crisp structural borders and planar separation** rather than soft diffuse shadows:

- **Level 0 (Canvas Base):** Pure `#FFFFFF`.
- **Level 1 (Cards & Nested Containers):** Solid `#FFFFFF` or `#F8FAFC` resting on top of the canvas, defined by a distinct `1px solid #E2E8F0` border. No ambient blur shadow.
- **Level 2 (Active Modules & Map Overlays):** `#FFFFFF` paired with a sharp, dual boundary: `1px solid #0A192F` overlaid with a tight key-offset shadow (`0 2px 4px rgba(10, 25, 47, 0.08)`).
- **Level 3 (Emergency Modals & Critical Floating Panels):** `#FFFFFF` enclosed in an unmistakable `2px solid #0A192F` stroke accompanied by an assertive, high-density drop shadow (`0 8px 24px rgba(10, 25, 47, 0.16)`).
- **Alert Pulse Planes:** Urgent states (e.g., active SOS dispatch) employ an animated crisp outer ring (`0 0 0 4px rgba(220, 38, 38, 0.25)`) to signal transmission without obscuring screen content.

## Shapes

The design uses a compact, disciplined **Soft (`1`)** shape metric (`0.25rem` base, `0.5rem` for cards/inputs, and `0.75rem` for primary actionable cards). 

- Standard inputs, buttons, status chips, and cards maintain modest, disciplined radii to evoke technical instrument displays rather than playful consumer software.
- The solitary exceptions are the circular SOS Emergency trigger button and status pill tags, which use full capsule/circle curves to immediately establish their specialized functions.

## Components

### Buttons
- **SOS Button (Primary Destructive / Urgent):** Massive central element or fixed bar. Solid Crimson (`#DC2626`) background, text in pure white (`#FFFFFF`), `0.75rem` radius or circle, font `Space Grotesk 700`. Active state deepens to `#B91C1C`.
- **"Estoy a Salvo" Button (Primary Safe):** Solid Emerald (`#16A34A`), text in pure white (`#FFFFFF`), bold tactile feedback with an active state of `#15803D`.
- **Standard Primary Action:** Deep Navy (`#0A192F`) fill with crisp white text. Focused outlines are offset by 2px in `#0A192F`.
- **Secondary Outline Action:** `#FFFFFF` background, `1.5px solid #0A192F` border, `#0A192F` text.

### Status Chips & Badges
- Constructed with `JetBrains Mono` at `label-md` or `label-sm` with a `0.25rem` corner radius.
- **Safe:** `#F0FDF4` background with `1px solid #BBF7D0` border and `#16A34A` text.
- **Warning / Low Battery:** `#FEF3C7` background with `1px solid #FDE68A` border and `#B45309` text.
- **Emergency / Unresolved:** `#FEF2F2` background with `1px solid #FECACA` border and `#DC2626` text.

### Cards & Telemetry Containers
- Pure `#FFFFFF` surface with `1px solid #E2E8F0` border and `0.5rem` radius. 
- Headers feature uppercase `JetBrains Mono` meta-labels above `Space Grotesk` titles.
- When an emergency state is tied to a specific card, the border width shifts immediately to `2px` colored according to the triage level (Crimson, Emerald, or Amber).

### Input Fields & Controls
- Form fields utilize a `#FFFFFF` fill enclosed in `1px solid #CBD5E1` with a `0.25rem` radius.
- In-focus state transitions cleanly to `1.5px solid #0A192F` without colored halos.
- Text content is `#0A192F`, while placeholder text uses `#64748B`.

### Lists & Activity Feeds
- Grouped contact logs, location pings, and incident timelines are divided by `1px solid #F1F5F9` lines.
- Left edge features colored indicator notches (4px width) designating safe confirmations, warnings, or emergency pings.

### Checkboxes & Radios
- Sharp `0.25rem` squircle or circle geometry, framed with `1.5px solid #0A192F`.
- Checked state fills with `#0A192F` housing a pure `#FFFFFF` vector checkmark or radio dot.