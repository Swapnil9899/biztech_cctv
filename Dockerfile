# Stage 1: Build the frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# Copy frontend package files first for caching
COPY frontend/package*.json ./frontend/
WORKDIR /app/frontend
RUN npm install

# Copy frontend source and build
WORKDIR /app
COPY frontend/vite.config.ts ./frontend/
COPY frontend/index.html ./frontend/
COPY frontend/tsconfig.json ./frontend/
COPY frontend/tsconfig.node.json ./frontend/
COPY frontend/src ./frontend/src/

WORKDIR /app/frontend
RUN npm run build

# Stage 2: Setup backend
FROM node:18-alpine AS backend-setup

WORKDIR /app

# Copy backend package files
COPY backend/package*.json ./backend/
WORKDIR /app/backend
RUN npm install --production

# Copy backend source
WORKDIR /app
COPY backend/server.js ./backend/

# Stage 3: Final production image
FROM node:18-alpine

WORKDIR /app

# Install nginx for serving frontend
RUN apk add --no-cache nginx

# Copy backend from stage 2
COPY --from=backend-setup /app/backend ./backend

# Copy built frontend from stage 1
COPY --from=frontend-builder /app/frontend/dist ./dist

# Copy nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Change to backend directory to run server
WORKDIR /app/backend

# Expose port
EXPOSE 8080

# Start nginx in background and run backend
CMD sh -c "node server.js & nginx -g 'daemon off;'"
