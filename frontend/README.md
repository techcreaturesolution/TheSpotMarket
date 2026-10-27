# TheSpotMarket - Public Marketing Website

> Public marketing and intelligence portal companion to TheSpotMarket Flutter mobile app.

---

## 🛠 Tech Stack
- **Framework**: React 18 + Vite (JavaScript, JSX)
- **Styling**: Tailwind CSS v3 with custom mobile app design tokens (Dark Theme only)
- **Routing**: `react-router-dom` v6 with `ScrollToTop` and `HelmetProvider` SEO
- **Animations**: GSAP 3 + ScrollTrigger + `@gsap/react` (`useGSAP` hook) with `prefers-reduced-motion` compliance
- **Icons & SEO**: `lucide-react`, `react-helmet-async`
- **Typography**: `@fontsource/inter` and `@fontsource/roboto` (self-hosted)

---

## 🎨 Theme Tokens & Design System

| Token | Hex / Value | Description |
|---|---|---|
| `background` | `#040A07` | Deep dark emerald canvas |
| `surface` | `#0C1610` | Standard card surface |
| `surface-2` | `#0B1711` | Secondary card surface |
| `primary` | `#10B981` | Brand emerald green |
| `primary-dark` | `#059669` | Hover emerald shade |
| `accent` | `#34D399` | Luminous mint highlight |
| `bull` | `#16A34A` | Bullish market green |
| `bear` | `#DC2626` | Bearish market red |
| `text` | `#FFFFFF` | Primary white text |
| `muted` | `rgba(255, 255, 255, 0.70)` | Secondary descriptive text |
| `subtle` | `rgba(255, 255, 255, 0.50)` | Captions, disclaimers, borders |
| `border` | `rgba(255, 255, 255, 0.10)` | 10% translucent white borders |
| `card radius` | `16px` | Smooth modern corner radius |
| `card-gradient`| `#0C2016` (40%) → `#030D08` (70%) | Dual dark gradient |

---

## 🚀 Commands

### 1. Install Dependencies
```bash
cd frontend
npm install
```

### 2. Run Locally in Development Mode
```bash
npm run dev
```
Runs at `http://localhost:5180/` (or default port).

### 3. Build for Production
```bash
npm run build
```

### 4. Preview Production Build
```bash
npm run preview
```

---

## 🏛 Phase 2 Layout Shell Features

- **Sticky Glass Navbar** ([`src/components/layout/Navbar.jsx`](file:///d:/Ravi/Radhe/TheSpotMarket/frontend/src/components/layout/Navbar.jsx)): Official app icon, GSAP ScrollTrigger background fade-in on scroll, hash link scrolling, and timeline-driven slide-in mobile drawer.
- **Floating SpotAI Button** ([`src/components/layout/FloatingSpotAiButton.jsx`](file:///d:/Ravi/Radhe/TheSpotMarket/frontend/src/components/layout/FloatingSpotAiButton.jsx)): Liquid-glass floating button at bottom-right with continuous GSAP float and glow pulse; scrolls smoothly to `#spotai`.
- **4-Column Footer** ([`src/components/layout/Footer.jsx`](file:///d:/Ravi/Radhe/TheSpotMarket/frontend/src/components/layout/Footer.jsx)): Brand & social media icons, Product links, Company links, and Legal & Compliance links with regulatory disclaimer.
- **Page Transitions** ([`src/components/layout/MainLayout.jsx`](file:///d:/Ravi/Radhe/TheSpotMarket/frontend/src/components/layout/MainLayout.jsx)): Smooth GSAP fade-in transition on route change with automatic cleanup.
- **SEO & Accessibility** ([`src/components/layout/SEO.jsx`](file:///d:/Ravi/Radhe/TheSpotMarket/frontend/src/components/layout/SEO.jsx), [`src/components/layout/SkipToContent.jsx`](file:///d:/Ravi/Radhe/TheSpotMarket/frontend/src/components/layout/SkipToContent.jsx)): `react-helmet-async` metadata, OpenGraph, Twitter card, skip link, visible focus rings, and Escape key drawer close.

---

## 🧪 Routes & Verification

- `/` — Homepage with `#features`, `#how-it-works`, `#spotai`, `#faq` sections
- `/about` — About Us & platform mission
- `/contact` — Contact & Support channels
- `/privacy` — Privacy Policy
- `/terms` — Terms of Service
- `/disclaimer` — SEBI Regulatory Compliance Disclaimer
- `/data-deletion` — User Data Deletion Instructions
- `/*` — 404 Not Found fallback
