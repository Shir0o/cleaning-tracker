---
name: Cleaning Tracker
description: Private, offline-first domestic maintenance tracker with tactile neobrutalist accents and room visual identities
colors:
  primary: "#3A7D5C"
  warning: "#B98637"
  critical: "#C2583F"
  surface-light: "#FFFFFF"
  surface-dark: "#1E211A"
  bg-light: "#E9EFE5"
  bg-dark: "#12140F"
  text-light: "#26301F"
  text-dark: "#EEF2E9"
  text-muted-light: "#6B7563"
  text-muted-dark: "#9AA48F"
  border-light: "#EEF1EA"
  border-dark: "#26301F"
  nav-border-light: "#DDE3D8"
  gauge-track-light: "#D7DED0"
  gauge-track-dark: "#333A2D"
  room-kitchen-accent: "#3A7D5C"
  room-kitchen-tint: "#EAF3EC"
  room-kitchen-accent-dark: "#7FD3A4"
  room-bathroom-accent: "#3F7F9C"
  room-bathroom-tint: "#E7F0F4"
  room-bathroom-accent-dark: "#7CBCD8"
  room-bedroom-accent: "#7A5DB0"
  room-bedroom-tint: "#F1ECF5"
  room-bedroom-accent-dark: "#BDA0E2"
  room-living-accent: "#B0803F"
  room-living-tint: "#F4EFE6"
  room-living-accent-dark: "#D9AC72"
  room-laundry-accent: "#5C7A52"
  room-laundry-tint: "#EEF1EA"
  room-laundry-accent-dark: "#9FBF90"
typography:
  display:
    fontFamily: "Nunito, -apple-system, sans-serif"
    fontSize: "28px"
    fontWeight: 900
    lineHeight: 1.2
    letterSpacing: "normal"
  headline:
    fontFamily: "Nunito, -apple-system, sans-serif"
    fontSize: "20px"
    fontWeight: 800
    lineHeight: 1.25
    letterSpacing: "normal"
  title:
    fontFamily: "Nunito, -apple-system, sans-serif"
    fontSize: "16px"
    fontWeight: 800
    lineHeight: 1.3
    letterSpacing: "normal"
  body:
    fontFamily: "Nunito, -apple-system, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.45
    letterSpacing: "normal"
  label:
    fontFamily: "Nunito, -apple-system, sans-serif"
    fontSize: "12px"
    fontWeight: 800
    lineHeight: 1.2
    letterSpacing: "0.05em"
  mono:
    fontFamily: "Chivo Mono, monospace"
    fontSize: "13px"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "0.02em"
rounded:
  none: "0px"
  sm: "10px"
  md: "14px"
  lg: "18px"
  xl: "24px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  2xl: "24px"
  3xl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.text-light}"
    textColor: "{colors.surface-light}"
    rounded: "{rounded.none}"
    padding: "16px 24px"
    typography: "label"
  button-action:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface-light}"
    rounded: "{rounded.none}"
    padding: "16px 24px"
    typography: "label"
  button-snooze:
    backgroundColor: "transparent"
    textColor: "{colors.primary}"
    rounded: "{rounded.md}"
    padding: "8px 16px"
    typography: "label"
  card-task:
    backgroundColor: "{colors.surface-light}"
    textColor: "{colors.text-light}"
    rounded: "{rounded.lg}"
    padding: "16px"
  card-room:
    backgroundColor: "{colors.surface-light}"
    textColor: "{colors.text-light}"
    rounded: "{rounded.xl}"
    padding: "16px"
  chip-pill:
    backgroundColor: "{colors.bg-light}"
    textColor: "{colors.primary}"
    rounded: "{rounded.sm}"
    padding: "4px 10px"
    typography: "label"
  input-field:
    backgroundColor: "{colors.surface-light}"
    textColor: "{colors.text-light}"
    rounded: "{rounded.none}"
    padding: "16px"
    height: "56px"
    typography: "body"
---

# Design System: Cleaning Tracker

## Overview

**Creative North Star: "The Domestic Workshop"**

Cleaning Tracker is a pragmatic, tactile instrument for home stewardship. Rather than feeling like a chore checklist or gamified mobile app, Cleaning Tracker behaves like a precision physical tool found in a well-kept domestic workshop—rugged, high-contrast, deeply tactile, and calm under pressure. Combining rounded ergonomic cards and comforting sage tones with unapologetic neobrutalist utility controls (2px solid black strokes, zero-radius action buttons, 4px hard offsets), the interface provides instantaneous clarity when inspecting appliances in low light or operating with wet hands.

The visual language rejects frivolous gradients, low-contrast pastel gray-on-gray palettes, and patronizing gamification. In their place, it uses clear tri-state health telemetry, structured room category identities, and bold geometric typography. Every domestic zone is immediately distinct, and every interaction offers tangible tactile weight.

**Key Characteristics:**
- **High-Contrast Tactile Neobrutalism:** Crisp 2px solid borders, 4px un-blurred hard drop shadows on interactive controls, and zero-radius utility buttons balance ergonomic rounded cards (18px–24px).
- **Tri-State Urgency Telemetry:** Clear maintenance health tracking anchored by Forest Pine (`#3A7D5C`), Warm Amber (`#B98637`), and Terracotta Brick (`#C2583F`).
- **Atmospheric Room Identities:** Five dedicated domestic categories (Kitchen, Bathroom, Bedroom, Living Room, Laundry & Utility) paired with distinct pastel tints and rich accent colors.
- **Frictionless Mobile Ergonomics:** Engineered for physical, high-friction environments with oversized touch targets (48px–64px), persistent bottom navigation, and high legibility.

## Colors

The palette balances organic sage-tinted neutrals with authoritative semantic urgency signals and specialized domestic zone accents.

### Primary
- **Forest Pine** (`#3A7D5C`): The primary brand anchor, positive health signal (>=80% Home Health), primary action buttons, active navigation indicators, and floating action button.

### Secondary
- **Warm Amber** (`#B98637`): Warning status indicator for degrading systems (50%–79% Home Health), "Due Soon" task pills, and moderate attention notices.

### Tertiary
- **Terracotta Brick** (`#C2583F`): High-urgency alert color for critical deterioration (<50% Home Health), overdue task pills, and destructive actions.

### Room Accents
- **Kitchen Green** (`#3A7D5C` Light / `#7FD3A4` Dark): Dedicated to countertop, appliance, and culinary maintenance. Paired with soft tint (`#EAF3EC` Light / `rgba(74, 155, 115, 0.18)` Dark).
- **Bathroom Slate Blue** (`#3F7F9C` Light / `#7CBCD8` Dark): Dedicated to plumbing, shower, and sanitary systems. Paired with soft tint (`#E7F0F4` Light / `rgba(63, 127, 156, 0.20)` Dark).
- **Bedroom Lavender** (`#7A5DB0` Light / `#BDA0E2` Dark): Dedicated to bedding, air quality, and sleeping quarters. Paired with soft tint (`#F1ECF5` Light / `rgba(122, 93, 176, 0.24)` Dark).
- **Living Room Ochre** (`#B0803F` Light / `#D9AC72` Dark): Dedicated to common spaces, furniture, and lighting. Paired with soft tint (`#F4EFE6` Light / `rgba(176, 128, 63, 0.22)` Dark).
- **Laundry Sage** (`#5C7A52` Light / `#9FBF90` Dark): Dedicated to washers, dryers, and utility maintenance. Paired with soft tint (`#EEF1EA` Light / `rgba(92, 122, 82, 0.24)` Dark).

### Neutral
- **Light Background** (`#E9EFE5`): Warm sage-tinted paper canvas for light mode scaffolds.
- **Dark Background** (`#12140F`): Deep obsidian charcoal canvas for dark mode scaffolds.
- **Light Surface** (`#FFFFFF`): Crisp white elevated cards, input fields, and dialog containers.
- **Dark Surface** (`#1E211A`): Deep olive-charcoal surface for cards and container panels in dark mode.
- **Light Text / On-Surface** (`#26301F`): High-contrast forest black for light mode headings, borders, and body text.
- **Dark Text / On-Surface** (`#EEF2E9`): Bright off-white for dark mode text and high-contrast structural borders.
- **Light Muted Text** (`#6B7563`): Subdued olive gray for secondary metadata, timestamps, and inactive iconography.
- **Dark Muted Text** (`#9AA48F`): Desaturated sage gray for secondary metadata in dark mode.
- **Hairline Border** (`#EEF1EA` Light / `#26301F` Dark): Subtle interior container dividing lines and card outlines.

### Named Rules
**The Health Spectrum Rule.** Home Health and urgency status are communicated strictly across three canonical thresholds: Forest Pine (>=80% Operational), Warm Amber (50%–79% Degrading), and Terracotta Brick (<50% Critical/Overdue). No arbitrary intermediary gradients or celebratory pastel confetti.

**The Room Identity Rule.** Domestic zones must strictly use their assigned room theme tint and accent pairing. A Kitchen task must never be badged with Bathroom slate or Laundry sage.

## Typography

**Display Font:** Nunito (with Space Grotesk on utility headers; -apple-system fallback)
**Body Font:** Nunito (with Inter fallback for dense forms; sans-serif)
**Label/Mono Font:** Chivo Mono (monospace fallback)

**Character:** Friendly rounded geometry grounded by bold weights (w700–w900) and strict technical monospace counters, creating an approachable yet authoritative workshop persona.

### Hierarchy
- **Display** (FontWeight.w900, 28px, line-height 1.2): Primary screen titles ("DUE TODAY", "ROOMS") and aggregate health percentages.
- **Headline** (FontWeight.w800, 20px, line-height 1.25): Modal titles, section introductions, and completion dialog banners.
- **Title** (FontWeight.w800, 15px–16px, line-height 1.3): Task card titles, room category names, and button labels.
- **Body** (FontWeight.w600/w700, 14px, line-height 1.45): Task descriptions, settings descriptions, and dialog explanation text. Max line length 65ch.
- **Label** (FontWeight.w800/w900, 11px–12px, letter-spacing 0.05em, uppercase): Section pills ("OVERDUE (2)", "DUE SOON"), button actions, and room count tags.
- **Mono** (FontWeight.w700, 13px, letter-spacing 0.02em): Technical intervals ("EVERY 90 DAYS"), calendar timestamps, and log completion records.

### Named Rules
**The Heavyweight Hierarchy Rule.** Nunito's rounded letterforms require heavy weights (w700 to w900) for structural headings, card titles, and badges to preserve tactical authority and avoid playful softness.

## Layout

Layout follows an 8pt base grid rhythm (4px, 8px, 12px, 16px, 20px, 24px, 32px).
- **Screen Margins:** Horizontal padding is fixed at 20px on mobile screens, providing ample breathing room against edge bezel touches.
- **Card Padding:** Standard card interior padding is 16px, expanding to 24px for major dashboard summary containers.
- **Vertical Spacing Rhythm:** 10px between recurring list cards; 16px–20px between distinct category sections; 80px bottom scroll clearance above the persistent navigation bar.
- **Touch Target Density:** Primary actionable items are sized at 52px–64px height to guarantee easy activation with wet hands or thumbs.

## Elevation & Depth

Cleaning Tracker uses flat, tactile neobrutalism. Depth is achieved through high-contrast structural borders and solid offset drop shadows rather than diffuse ambient blurs.

### Shadow Vocabulary
- **Neobrutalist Hard Offset** (`box-shadow: 4px 4px 0px #26301F` Light / `4px 4px 0px #EEF2E9` Dark): Used on primary action buttons, dialog confirm triggers, and settings action blocks.
- **Card Ambient Grounding** (`box-shadow: 0 4px 10px rgba(0, 0, 0, 0.04)` Light / `0 4px 10px rgba(0, 0, 0, 0.20)` Dark): Used on task list cards and room groupings to lift them cleanly above the scaffold canvas.
- **Floating Action Glow** (`box-shadow: 0 4px 10px rgba(58, 125, 92, 0.25)`): Dedicated to the circular add task FAB to ensure quick visual acquisition.

### Named Rules
**The Tactical Anchor Rule.** Utility buttons and bottom action sheets use zero-radius rectangular geometry with solid 2px borders and 4px un-blurred drop shadows. Floating blur is reserved strictly for the circular add FAB and ambient card elevation.

## Shapes

The form language is an intentional pairing of ergonomic rounded containers and crisp rectangular utility blocks:
- **Task Cards & Group Containers:** Rounded corners at 18px–20px radius (`rounded.lg`), softening large content blocks.
- **Summary Cards & Modal Sheets:** Rounded corners at 24px radius (`rounded.xl`).
- **Room Badges & Icon Containers:** 14px radius (`rounded.md`) on 42px x 42px square icon tiles.
- **Section Badges & Pills:** 10px–12px radius (`rounded.sm`), creating compact capsule indicators.
- **Neobrutalist Buttons & Form Inputs:** Crisp 0px radius (`rounded.none`), projecting functional durability.
- **Borders:** 2px solid `#26301F` on action buttons and input fields; 4px solid on system modal dialogs; 1px hairline (`#EEF1EA`) on ambient task cards.

## Components

### Buttons
- **Shape:** Zero-radius rectangle (0px) on neobrutalist primary action buttons; 12px–14px radius on secondary snooze and settings buttons; circular (52px diameter) on FAB.
- **Primary Action:** Solid background (`#26301F` or `#3A7D5C`), white uppercase text, 2px solid border, 4px un-blurred drop shadow (`box-shadow: 4px 4px 0px #26301F`).
- **Hover / Active:** `:hover` elevates slightly (`translate(-1px, -1px)` with 5px shadow); `:active` presses into the surface (`translate(3px, 3px)` with 1px shadow).
- **Secondary Snooze Button:** Outlined button with 1.5px border (`#3A7D5C`), transparent background, 12px border radius, 8px 16px padding.

### Chips & Badges
- **Section Pill:** Capsule badge (12px radius) with 15% opacity semantic background tint (`#C2583F` for Overdue, `#B98637` for Due Soon, `#3A7D5C` for Healthy). Includes a 7px solid circular indicator dot and uppercase label.
- **Choice Filter Chip:** 8px–12px radius chip with solid `#3A7D5C` fill when active and high-contrast text (`#FFFFFF`), or surface card fill with muted label when inactive.

### Cards & Containers
- **Task Item Card:** 18px border radius, 16px internal padding, surface fill (`#FFFFFF` Light / `#1E211A` Dark), 1px subtle hairline border, and 0 4px 10px ambient shadow. Contains a 42px room icon tile, bold title, status dot with label, and circular check action button.
- **Room Section Card:** 20px border radius with a solid room tint header (`#EAF3EC` for Kitchen), room icon, category title, task count pill, and divided task list items.

### Inputs & Fields
- **Style:** 56px height, 2px solid border (`#26301F` Light / `#EEF2E9` Dark), zero border radius, filled surface background (`#FFFFFF` Light / `#1E211A` Dark), 16px horizontal padding.
- **Focus:** 2px border transitions to primary Forest Pine (`#3A7D5C`).
- **Placeholder:** Subdued gray (`#8A8A8A`), uppercase, font size 15px.

### Navigation
- **Bottom Navigation Bar:** Fixed 72px height, top border divider (`#DDE3D8` Light / `#26301F` Dark), surface fill, with 4 evenly spaced navigation destinations (`Due`, `Rooms`, `Stats`, `More`) and a centered 52px circular add FAB (`#3A7D5C`).

### Signature Component: Home Health Ring Gauge
- **Description:** Circular dual-arc gauge (140px x 140px, 12px–14px stroke width) displaying the aggregate home maintenance percentage.
- **Behavior:** Background track uses neutral gray-green (`#D7DED0` Light / `#333A2D` Dark). Progress arc smoothly fills clockwise from 12 o'clock in tri-state semantic color: Forest Pine (`#3A7D5C`) for >=80%, Warm Amber (`#B98637`) for 50%–79%, and Terracotta Brick (`#C2583F`) for <50%. The center displays bold percentage text and health condition label.

## Do's and Don'ts

### Do:
- **Do** anchor primary interface actions and healthy states to Forest Pine (`#3A7D5C`).
- **Do** use 2px solid borders and zero-radius geometry on neobrutalist action triggers and primary input fields.
- **Do** maintain a strict 3-tier health state (Pine for >=80%, Amber for 50%–79%, Terracotta for <50%).
- **Do** format maintenance intervals and completion logs in monospace (`Chivo Mono`) with uppercase styling.
- **Do** pair every room category with its official tint and accent colors.
- **Do** keep interactive button heights at or above 48px (56px–64px preferred for main action sheets) for wet-hands mobile operation.

### Don't:
- **Don't** use multi-color gradients, saturated rainbow borders, or celebratory floating confetti animations.
- **Don't** apply blurry, multi-layer ambient drop shadows to utility buttons; maintain flat borders or hard 4px un-blurred drop shadows.
- **Don't** use light font weights (<w600) with `GoogleFonts.nunito` on interface elements.
- **Don't** mix room theme accent colors across categories (e.g. using Kitchen green for a Bathroom task).
- **Don't** shrink touch targets below 44px on any interactive control.
