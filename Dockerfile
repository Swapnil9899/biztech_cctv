# Use a simple approach - build everything in one stage
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install nginx for serving the app
RUN apk add --no-cache nginx

# ============================================
# STEP 1: Copy and build frontend
# ============================================
# Create frontend directory
RUN mkdir -p /app/frontend

# Copy frontend package files
COPY frontend/package.json /app/frontend/
COPY frontend/package-lock.json /app/frontend/

# Install frontend dependencies and build
WORKDIR /app/frontend
RUN npm install && npm run build

# ============================================
# STEP 2: Setup backend
# ============================================
# Create backend directory  
RUN mkdir -p /app/backend

# Copy backend package files
COPY backend/package.json /app/backend/
COPY backend/package-lock.json /app/backend/

# Install backend dependencies
WORKDIR /app/backend
RUN npm install --production

# Copy backend source
COPY backend/server.js /app/backend/

# ============================================
# STEP 3: Final setup
# ============================================
WORKDIR /app

# Create dist directory and copy frontend build
RUN mkdir -p /app/dist
COPY /app/frontend/dist/* /app/dist/

# Copy nginx config
COPY nginx.conf /etc/nginx/http.d/default.conf

# Expose port
EXPOSE 8080

# Start both services
CMD sh -c "cd /app/backend && node server.js & nginx -g 'daemon off;'"
