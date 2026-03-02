# Stage 1: Build the frontend
FROM node:18-alpine AS frontend-builder

# Create frontend directory
RUN mkdir -p /app/frontend
WORKDIR /app/frontend

# Copy all frontend files at once
COPY frontend/package.json frontend/package-lock.json ./
RUN npm install

COPY frontend/vite.config.ts ./
COPY frontend/index.html ./
COPY frontend/tsconfig.json ./
COPY frontend/tsconfig.node.json ./
COPY frontend/src ./src

# Build the frontend
RUN npm run build

# Stage 2: Setup backend
FROM node:18-alpine AS backend-setup

# Create backend directory
RUN mkdir -p /app/backend
WORKDIR /app/backend

# Copy backend files
COPY backend/package.json backend/package-lock.json ./
RUN npm install --production

COPY backend/server.js ./

# Stage 3: Final production image
FROM node:18-alpine

# Create app directory
RUN mkdir -p /app
WORKDIR /app

# Install nginx
RUN apk add --no-cache nginx

# Copy backend from stage 2
COPY --from=backend-setup /app/backend ./backend

# Copy built frontend from stage 1
COPY --from=frontend-builder /app/frontend/dist ./dist

# Copy nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Expose port
EXPOSE 8080

# Start nginx and backend
CMD sh -c "cd backend && node server.js & nginx -g 'daemon off;'"
