# ---- Build Stage ----
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Build passes VITE_API_URL pointing to the backend service
ARG VITE_API_URL=http://backend:5001
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build

# ---- Runtime Stage ----
FROM nginx:stable-alpine

# Copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# Custom nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
