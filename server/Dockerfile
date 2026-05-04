# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev

COPY . .

# ---- Runtime Stage ----
FROM node:20-alpine

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=5001

RUN addgroup -S nodeapp && adduser -S nodeapp -G nodeapp

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY package.json ./

USER nodeapp
EXPOSE 5001
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:5001/api/health || exit 1

CMD ["node", "src/index.js"]
