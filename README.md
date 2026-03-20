# 📦 ShopSmart – DevOps Enabled Full Stack Application

## 🚀 Project Overview
ShopSmart is a full-stack web application built using a **React frontend** and a **Node.js backend**. The project demonstrates modern **DevOps practices** such as Continuous Integration (CI), automated testing, linting, dependency management, and idempotent scripting.

---

## 🏗️ Architecture

Client (React + Vite)  
        ↓ API Calls  
Server (Node.js + Express)  
        ↓  
Business Logic  

### Tech Stack
- **Frontend:** React + Vite
- **Backend:** Node.js + Express
- **Testing:** Jest (backend), Vitest (frontend)
- **CI/CD:** GitHub Actions
- **Linting:** ESLint
- **Dependency Management:** Dependabot

---

## 🔄 DevOps Workflow

### 1. Version Control (Git)
- Project managed using Git
- Multiple meaningful commits
- Each commit represents a logical change
- Avoided last-day bulk commits

---

### 2. Continuous Integration (CI)

GitHub Actions pipeline runs automatically on:
- push
- pull_request

### CI Pipeline Includes:
- Install dependencies
- Run lint checks
- Run tests
- Build frontend

Location:
.github/workflows/backend-ci.yml

---

## 🧪 Testing Strategy

### Backend Testing (Jest)
- Tests API endpoints
- Example: `/api/health`

### Frontend Testing (Vitest)
- Tests React components
- Example: UI rendering validation

---

## 🧹 Code Quality (Linting)

ESLint is configured for both frontend and backend.

### Benefits:
- Detects errors early
- Enforces consistent coding standards
- Integrated into CI pipeline

---

## 📦 Dependency Management

Dependabot is configured to:
- Monitor outdated dependencies
- Suggest updates automatically
- Improve security and maintainability

Location:
.github/dependabot.yml

---

## ⚙️ Idempotent Setup Script

A reusable script (`setup.sh`) is created to:
- Install backend dependencies
- Install frontend dependencies
- Build frontend

### Why idempotent?
The script can be safely executed multiple times without breaking the system.

### Usage:
```bash
chmod +x setup.sh
./setup.sh
