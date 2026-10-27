# TheSpotMarket

> **Real-time IPO Intelligence, NSE/BSE Market Data & SpotAI Analytics**

---

## 🏗 Repository Structure (Monorepo)

```text
TheSpotMarket/
├── flutter_mobile/        # Flutter Android & iOS mobile client application
├── backend/               # Node.js Express REST API backend (SmartAPI + IndianAPI + SpotAI)
├── frontend/              # React 18 + Vite + Tailwind + GSAP public marketing site
├── docs/                  # Comprehensive documentation, security audits & phase reports
└── archive/               # Reference tools (Indian-Stock-Market-API) & test captures
```

---

## 📱 1. Mobile App (`flutter_mobile/`)

Built with Flutter 3.x for Android & iOS.

### Setup & Run:
```bash
cd flutter_mobile

# Install dependencies
flutter pub get

# Run code analysis
flutter analyze

# Run unit & security tests (51 passing tests)
flutter test

# Run app locally
flutter run

# Build release APK
flutter build apk --release
```

---

## 🚀 2. Backend API (`backend/`)

Built with Node.js, Express, Angel One SmartAPI, and IndianAPI.

### Setup & Run:
```bash
cd backend

# Install dependencies
npm install

# Run locally in development mode
npm run dev

# Start in production mode
npm start
```

### Environment Configuration:
Copy `backend/.env.example` to `backend/.env` and configure:
- `INDIANAPI_KEY` — IndianAPI IPO subscription key
- `ANGEL_API_KEY`, `ANGEL_CLIENT_ID`, `ANGEL_PASSWORD`, `ANGEL_TOTP_SECRET` — Angel One SmartAPI credentials
- `AI_API_KEY` — OpenAI or Google Gemini API key
- `PORT` — Server port (default: 3000)

---

## 📚 3. Documentation (`docs/`)

All architecture designs, security audit logs, and implementation reports are indexed in:
- **[docs/README.md](docs/README.md)**
  - `docs/audits/` — Master security verifications, API inventory, and baseline audits.
  - `docs/phases/` — Phase 1 through 7 changelogs and execution records.
  - `docs/architecture/` — Market data migration plans and technical specifications.
