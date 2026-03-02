# Stage 1: Build the frontend
FROM node:18-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package.json ./
COPY frontend/package-lock.json ./
RUN npm install

# Copy frontend source files
COPY frontend/vite.config.ts ./
COPY frontend/index.html ./
COPY frontend/tsconfig.json ./
COPY frontend/tsconfig.node.json ./
COPY frontend/src ./src

# Build the frontend
RUN npm run build

# Stage 2: Setup backend
FROM node:18-alpine AS backend-setup

WORKDIR /app/backend

# Copy backend package files
COPY backend/package.json ./
COPY backend/package-lock.json ./
RUN npm install --production

# Copy backend source
COPY backend/server.js ./

# Stage 3: Final production image
FROM node:18-alpine

WORKDIR /app

# Install nginx
RUN apk add --no-cache nginx

# Copy backend from stage 2
COPY --from=backend-setup /app/backend ./

# Copy built frontend from stage 1
COPY --from=frontend-builder /app/frontend/dist ./dist

# Copy nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Expose port
EXPOSE 8080

# Start nginx and backend
CMD sh -c "node server.js & nginx -g 'daemon off;'"
