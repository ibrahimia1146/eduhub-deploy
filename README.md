# 🧠 EduHub — منصة التعليم الذكي

<div align="center">

![EduHub](https://img.shields.io/badge/EduHub-v2.0-7C3AED?style=for-the-badge&logo=graduation-cap)
![Next.js](https://img.shields.io/badge/Next.js-15-black?style=for-the-badge&logo=next.js)
![Express](https://img.shields.io/badge/Express.js-4.x-green?style=for-the-badge&logo=express)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?style=for-the-badge&logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=for-the-badge&logo=docker)
![Claude AI](https://img.shields.io/badge/Claude-AI-orange?style=for-the-badge)

**Enterprise-grade e-learning platform for Egyptian preparatory and secondary school students.**

[Student Portal](#) · [Admin Portal](#) · [API Docs](#api-endpoints) · [Deploy Guide](docs/DEPLOYMENT.md)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Environment Variables](#environment-variables)
- [API Endpoints](#api-endpoints)
- [Deployment](#deployment)
- [Tech Stack](#tech-stack)

---

## Overview

EduHub is a full-stack monorepo enterprise educational platform built for Egyptian prep and secondary school students. It features:

- **Recorded lessons** with HLS streaming + CloudFront protection
- **Sequential progression** — next lesson locks until video watched + homework submitted + exam passed (≥70%)
- **7 homework answer types** — MCQ, True/False, Essay, Image Upload, PDF Upload, File Upload, Text Answer
- **6 exam question types** — MCQ, True/False, Essay, Short Answer, Math (numeric), Image-Based
- **AI Tutor** powered by Claude (Anthropic) available 24/7
- **Single-device login enforcement** with device fingerprinting
- **Admin portal** with full content management, student approval, analytics, and security monitoring

---

## Features

### Student Portal
| Feature | Description |
|---------|-------------|
| 🔐 Registration | Full name, phone, mother/father phone, national ID upload, admin approval |
| 🎬 Video Lessons | HLS streaming, resume playback, dynamic watermark, anti-download |
| 📝 Homework | 7 answer types, AI grading for text answers |
| 🏆 Exams | Personalized per-student, MATH questions, IMAGE-BASED questions |
| 🔓 Progression | Sequential unlock — video + homework + exam ≥70% |
| 🤖 AI Tutor | Chat, summaries, practice questions, weakness detection, study plans |
| 🏅 Certificates | Auto-issued PDF on course completion, public verify URL |
| 💳 Payments | Fawry integration + activation codes |
| 📊 Dashboard | Progress, attendance, subscription status, QR student ID |

### Admin Portal
| Feature | Description |
|---------|-------------|
| 👥 Student Management | Registration approval/rejection, ban/suspend/reactivate |
| 📚 Content Management | Course → Section → Lesson CRUD (admin-only) |
| 📹 Video Upload | Presigned S3 upload + HLS transcoding pipeline |
| 📋 Question Bank | MCQ, True/False, Essay, Short Answer, MATH, IMAGE_BASED |
| 📊 Analytics | Student growth, revenue charts, exam stats, governorate breakdown |
| 🔔 Notifications | Broadcast to audience segments via In-App / SMS / Email |
| 🛡️ Security | Suspicious activity detection, audit logs, device tracking |
| 🎫 Support | Full ticket system with replies and status management |
| 🔑 Activation Codes | Bulk generation with plan assignment |

---

## Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────────┐
│                    Nginx (SSL + Proxy)               │
│  eduhub.eg → Student Portal (:3000)                │
│  admin.eduhub.eg → Admin Portal (:3001)            │
│  api.eduhub.eg → Backend API (:4000)               │
└──────┬──────────────────────┬───────────────────────┘
       │                      │
  ┌────▼────┐           ┌────▼────┐
  │ Student │           │  Admin  │
  │ Portal  │           │ Portal  │
  │Next.js  │           │Next.js  │
  └────┬────┘           └────┬────┘
       │                      │
       └──────────┬───────────┘
                  │ REST API (JWT)
            ┌─────▼──────┐
            │  Backend   │
            │ Express.js │
            │  +Prisma   │
            └─────┬──────┘
          ┌───────┼────────┐
     ┌────▼──┐ ┌──▼──┐ ┌──▼──────┐
     │  PG   │ │Redis│ │   AWS   │
     │  DB   │ │Cache│ │S3+CDN   │
     └───────┘ └─────┘ └─────────┘
```

---

## Project Structure

```
eduhub/
├── apps/
│   ├── student-portal/          # Next.js 15 — Student facing app (port 3000)
│   │   ├── src/app/
│   │   │   ├── login/           # Authentication
│   │   │   ├── register/        # Registration with national ID upload
│   │   │   ├── dashboard/       # Student home
│   │   │   ├── courses/         # Course browser + detail
│   │   │   ├── lesson/[id]/     # Lesson viewer (video + PDFs + gates)
│   │   │   ├── homework/        # 7 answer type submission
│   │   │   ├── exams/           # Exam taking + results
│   │   │   ├── ai-tutor/        # Claude AI chat
│   │   │   ├── certificates/    # Issued certificates
│   │   │   ├── payments/        # Fawry + activation codes
│   │   │   ├── profile/         # Profile + QR student ID
│   │   │   ├── notifications/   # In-app notifications
│   │   │   ├── notes/           # Personal study notes
│   │   │   ├── watch-history/   # Video watch progress
│   │   │   └── settings/        # Password change, security
│   │   ├── src/components/
│   │   │   └── layout/DashboardLayout.tsx
│   │   ├── src/lib/api.ts       # API client with auto token refresh
│   │   └── src/store/           # Zustand auth store
│   │
│   └── admin-portal/            # Next.js 15 — Admin facing app (port 3001)
│       ├── src/app/admin/
│       │   ├── dashboard/       # Analytics overview
│       │   ├── students/        # Registration approval workflow
│       │   ├── parents/         # Parent contact management
│       │   ├── courses/         # Course CRUD
│       │   │   └── [id]/        # Section + Lesson management
│       │   ├── lessons/[id]/    # Video upload, PDFs, homework, exam
│       │   ├── questions/       # Question bank (all 6 types)
│       │   ├── subscriptions/   # Subscription overview
│       │   ├── activation-codes/# Code generation
│       │   ├── notifications/   # Broadcast messaging
│       │   ├── support/         # Ticket management
│       │   ├── security/        # Security monitoring
│       │   ├── analytics/       # Deep analytics
│       │   ├── revenue/         # Financial reports
│       │   ├── attendance/      # Course completion tracking
│       │   └── settings/        # Platform configuration
│       └── src/components/
│           └── layout/AdminLayout.tsx
│
├── backend/                     # Express.js + Prisma API (port 4000)
│   ├── prisma/
│   │   ├── schema.prisma        # Full database schema (25+ models)
│   │   └── seed/index.ts        # Initial data + admin accounts
│   └── src/
│       ├── config/              # env, prisma, redis, logger
│       ├── middlewares/         # auth (JWT+RBAC), validate, audit, ratelimit
│       ├── jobs/scheduler.ts    # 7 background jobs
│       ├── utils/               # AppError, tokens, storage (S3), pdf, slugify
│       └── modules/
│           ├── auth/            # JWT, OTP, single-device login
│           ├── students/        # Approval workflow, parent linking
│           ├── courses/         # Course → Section → Lesson CRUD
│           ├── videos/          # HLS, CloudFront signed URLs, watermark
│           ├── homework/        # 7 answer types + AI grading
│           ├── exams/           # Question bank, MATH grading, AI recommendations
│           ├── progress/        # Sequential unlock logic
│           ├── ai/              # Claude integration (tutor, generators, analysis)
│           ├── payments/        # Fawry + activation codes + subscriptions
│           ├── notifications/   # Multi-channel (in-app + SMS + email) + broadcast
│           ├── certificates/    # Auto-issue PDF certificates
│           ├── analytics/       # Dashboard stats, revenue, security events
│           ├── tickets/         # Support system
│           ├── notes/           # Student personal notes
│           └── videos/          # Video streaming & watch tracking
│
├── infrastructure/
│   ├── docker/
│   │   ├── docker-compose.yml   # Full production stack
│   │   └── .env.example         # Environment template
│   └── nginx/
│       └── nginx.conf           # SSL termination + routing
│
├── docs/
│   └── DEPLOYMENT.md            # Full deployment guide
│
├── package.json                 # Monorepo root (Turborepo)
├── turbo.json                   # Build pipeline
├── .gitignore
├── LICENSE
└── README.md
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Node.js | ≥ 20.0.0 |
| npm | ≥ 10.0.0 |
| Docker | ≥ 24.0.0 |
| Docker Compose | v2 |

---

## Quick Start

### Option A — Docker (Recommended)

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/eduhub.git
cd eduhub

# 2. Set up environment
cp infrastructure/docker/.env.example infrastructure/docker/.env
# Edit .env — change ALL passwords and secrets!
nano infrastructure/docker/.env

# 3. Start everything
cd infrastructure/docker
docker compose up -d --build

# 4. Run database migrations + seed initial data
docker compose run --rm backend sh -c "npx prisma migrate deploy && npm run seed"

# 5. Verify
curl http://localhost:4000/health
```

**Access:**
- Student Portal: http://localhost:3000
- Admin Portal: http://localhost:3001
- API: http://localhost:4000

### Option B — Local Development

```bash
# Install all dependencies (from root)
npm install

# Set up backend env
cp infrastructure/docker/.env.example backend/.env
# Edit backend/.env with your local DB/Redis credentials

# Generate Prisma client
npm run db:generate

# Run migrations
npm run db:migrate

# Seed the database
npm run db:seed

# Start all services concurrently
npm run dev
```

---

## Default Credentials

> ⚠️ **Change these immediately after first login!**

| Role | Email | Password |
|------|-------|----------|
| Super Admin | `admin@eduhub.eg` | `Admin@EduHub2024!` |
| Content Manager | `content@eduhub.eg` | `Content@2024!` |

**Demo activation codes:** `DEMO-2024-EDUHUB-TEST` through `DEMO-2033-EDUHUB-TEST`

---

## Environment Variables

Copy `infrastructure/docker/.env.example` and fill in all values. Key variables:

```env
# Database
DATABASE_URL=postgresql://USER:PASSWORD@postgres:5432/eduhub

# JWT (generate with: node -e "console.log(require('crypto').randomBytes(64).toString('hex'))")
ACCESS_TOKEN_SECRET=your_64_char_hex_secret
REFRESH_TOKEN_SECRET=your_64_char_hex_secret

# AWS (for video storage + CloudFront)
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
S3_BUCKET=eduhub-media-prod
CLOUDFRONT_DOMAIN=https://xxxxx.cloudfront.net

# Anthropic AI
ANTHROPIC_API_KEY=sk-ant-api03-...

# Fawry Payments
FAWRY_MERCHANT_CODE=...
FAWRY_SECURITY_KEY=...

# SMS/Email
SMS_API_KEY=...
SMTP_HOST=smtp.mailgun.org
```

---

## API Endpoints

Base URL: `https://api.eduhub.eg/api/v1`

### Auth
```
POST   /auth/register          # Student registration (multipart, includes nationalId)
POST   /auth/login             # Phone + password + deviceFingerprint
POST   /auth/admin/login       # Email + password
POST   /auth/refresh           # Refresh access token
POST   /auth/logout            # Invalidate session
GET    /auth/me                # Current user info
POST   /auth/forgot-password   # Send OTP
POST   /auth/reset-password    # Reset with OTP
```

### Courses
```
GET    /courses                # List (students see published only)
GET    /courses/:id            # Course detail with full tree
GET    /courses/:id/student-view   # With lock/progress status
POST   /courses/:id/enroll     # Enroll student
POST   /courses                # Create (admin)
POST   /courses/:id/sections   # Add section (admin)
POST   /courses/sections/:id/lessons  # Add lesson (admin)
POST   /courses/lessons/:id/pdfs     # Add PDF (admin)
```

### Videos
```
POST   /videos/upload-url      # Get presigned S3 upload URL (admin)
GET    /videos/lessons/:id/playback   # Get signed stream URL + cookies
POST   /videos/lessons/:id/progress  # Update watch position
```

### Homework
```
POST   /homework/lessons/:id   # Create homework (admin)
POST   /homework/:id/submit    # Submit answer (student, multipart)
GET    /homework/me            # My homework list
POST   /homework/submissions/:id/grade  # Grade (admin)
```

### Exams
```
POST   /exams/questions        # Add to question bank (admin)
GET    /exams/questions        # Browse question bank
POST   /exams/lessons/:id      # Create exam for lesson (admin)
POST   /exams/:id/start        # Start exam attempt (student)
POST   /exams/attempts/:id/submit   # Submit answers
GET    /exams/attempts/:id/result   # View results + AI recommendations
```

### AI
```
POST   /ai/tutor/chat          # Chat with AI tutor
POST   /ai/lessons/:id/summary # Generate lesson summary
POST   /ai/lessons/:id/practice-questions  # Generate practice questions
POST   /ai/generate/exam       # AI exam generator (admin)
POST   /ai/generate/homework   # AI homework generator (admin)
GET    /ai/me/analysis         # Weakness detection + failure prediction
POST   /ai/me/study-plan       # Generate personalized study plan
```

### Payments
```
POST   /payments/fawry/initiate       # Start Fawry payment
POST   /payments/fawry/callback       # Fawry webhook (public)
POST   /payments/activation-codes/redeem  # Redeem a code
GET    /payments/subscription/me       # My subscription status
POST   /payments/activation-codes/generate  # Generate codes (admin)
```

### Notifications
```
GET    /notifications          # My notifications
PATCH  /notifications/:id/read # Mark as read
PATCH  /notifications/read-all # Mark all read
POST   /notifications/broadcast  # Broadcast (admin)
```

---

## Background Jobs

7 scheduled jobs run automatically after server start:

| Job | Interval | Description |
|-----|----------|-------------|
| `expire-subscriptions` | 1 hour | Marks expired subscriptions |
| `subscription-expiry-warnings` | 6 hours | Notifies students 3 days before expiry |
| `detect-at-risk-students` | 24 hours | Flags students with avg exam < 60% |
| `homework-deadline-reminders` | 1 hour | Warns students 24h before deadline |
| `clean-video-sessions` | 24 hours | Removes expired video session tokens |
| `clean-refresh-tokens` | 24 hours | Removes expired/revoked tokens |
| `recalculate-course-durations` | 24 hours | Keeps course duration metadata accurate |

---

## Deployment

See [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md) for the full production deployment guide including:
- Ubuntu 22.04 server setup
- SSL certificates with Let's Encrypt
- AWS S3 + CloudFront configuration
- IAM policy for video streaming
- DNS records
- Automated daily backups to S3
- Nginx configuration
- Security checklist

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Student Portal | Next.js 15, React 18, TypeScript, Tailwind CSS, Framer Motion, Zustand, SWR |
| Admin Portal | Next.js 15, React 18, TypeScript, Tailwind CSS, Recharts, Zustand |
| Backend API | Node.js, Express.js, TypeScript, Prisma ORM |
| Database | PostgreSQL 16 |
| Cache / Sessions | Redis 7 |
| AI | Anthropic Claude (claude-opus-4-6) |
| Video | AWS S3, CloudFront, HLS.js |
| Payments | Fawry (Egypt), Activation Codes |
| Notifications | In-App, SMS (configurable), Email (SMTP) |
| Auth | JWT (access + refresh), OTP, Device Fingerprinting |
| Infrastructure | Docker, Docker Compose, Nginx |
| Build System | Turborepo |

---

## Security

- **Single-device login** — new device login signs out all previous sessions
- **JWT blacklist** — invalidated tokens stored in Redis until natural expiry
- **Rate limiting** — global (200/min), auth (10/15min), AI (20/min), upload (30/hr)
- **Audit logging** — all admin actions logged with before/after state
- **Device fingerprinting** — tracks OS, browser, IP per session
- **Suspicious activity detection** — 3+ distinct IPs streaming same video = flag
- **Account ban system** — permanent or temporary ban with notification
- **CloudFront signed URLs** — videos require time-limited cryptographic signatures

---

## License

MIT — see [LICENSE](LICENSE)

---

<div align="center">
Built with ❤️ by <strong>Abdelrahman Ehab</strong> | Powered by <strong>Apex Hub</strong>
</div>
