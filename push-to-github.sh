#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# EduHub — GitHub Push Script
# Run this AFTER extracting eduhub-github-ready.tar.gz
# ═══════════════════════════════════════════════════════════════

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     EduHub → GitHub Push Script          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ── STEP 1: Get GitHub username ─────────────────────────────────
echo -e "${YELLOW}[1/6] Enter your GitHub username:${NC}"
read -r GITHUB_USER

# ── STEP 2: Get repo name ───────────────────────────────────────
echo -e "${YELLOW}[2/6] Enter repository name (default: eduhub):${NC}"
read -r REPO_NAME
REPO_NAME=${REPO_NAME:-eduhub}

# ── STEP 3: Choose auth method ──────────────────────────────────
echo ""
echo -e "${YELLOW}[3/6] Choose authentication method:${NC}"
echo "  1) Personal Access Token (PAT) — Recommended"
echo "  2) SSH Key"
read -r AUTH_CHOICE

if [ "$AUTH_CHOICE" = "1" ]; then
  echo -e "${YELLOW}Enter your GitHub Personal Access Token:${NC}"
  read -rs GITHUB_TOKEN
  REMOTE_URL="https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${REPO_NAME}.git"
else
  REMOTE_URL="git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
fi

# ── STEP 4: Create repo on GitHub ──────────────────────────────
echo ""
echo -e "${YELLOW}[4/6] Creating GitHub repository...${NC}"

if [ "$AUTH_CHOICE" = "1" ]; then
  HTTP_CODE=$(curl -s -o /tmp/gh_response.json -w "%{http_code}" \
    -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/user/repos \
    -d "{
      \"name\": \"${REPO_NAME}\",
      \"description\": \"EduHub — Enterprise e-learning platform for Egyptian students. Next.js 15 + Express + PostgreSQL + Claude AI\",
      \"private\": false,
      \"has_issues\": true,
      \"has_projects\": false,
      \"has_wiki\": false,
      \"auto_init\": false
    }")

  if [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✅ Repository created: https://github.com/${GITHUB_USER}/${REPO_NAME}${NC}"
  elif [ "$HTTP_CODE" = "422" ]; then
    echo -e "${YELLOW}⚠️  Repository already exists — will push to existing repo${NC}"
  else
    echo -e "${RED}❌ Failed to create repo (HTTP ${HTTP_CODE}). Create it manually at https://github.com/new${NC}"
    cat /tmp/gh_response.json
    exit 1
  fi
fi

# ── STEP 5: Set remote & push ──────────────────────────────────
echo ""
echo -e "${YELLOW}[5/6] Setting remote and pushing...${NC}"

cd "$(dirname "$0")"

# Remove existing remote if any
git remote remove origin 2>/dev/null || true

# Add new remote
git remote add origin "$REMOTE_URL"

# Push all branches
git push -u origin main --force

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Repository published successfully!               ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Repository URL:${NC}  https://github.com/${GITHUB_USER}/${REPO_NAME}"
echo -e "${CYAN}Clone URL:${NC}       git clone https://github.com/${GITHUB_USER}/${REPO_NAME}.git"
echo -e "${CYAN}Branch:${NC}          main (17 commits)"
echo ""

# ── STEP 6: Setup topics ──────────────────────────────────────
if [ "$AUTH_CHOICE" = "1" ]; then
  echo -e "${YELLOW}[6/6] Adding repository topics...${NC}"
  curl -s -X PUT \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/${GITHUB_USER}/${REPO_NAME}/topics" \
    -d '{"names":["nextjs","express","postgresql","prisma","typescript","tailwindcss","docker","edtech","arabic","egypt","claude-ai","turborepo","monorepo"]}' > /dev/null

  echo -e "${GREEN}✅ Topics added${NC}"
fi

echo ""
echo -e "${CYAN}Next steps:${NC}"
echo "  1. Copy infrastructure/docker/.env.example → infrastructure/docker/.env"
echo "  2. Fill in all secrets (DB, JWT, AWS, Anthropic, Fawry)"
echo "  3. docker compose up -d --build"
echo "  4. docker compose run --rm backend sh -c 'npx prisma migrate deploy && npm run seed'"
echo "  5. Login: admin@eduhub.eg / Admin@EduHub2024!"
echo ""
