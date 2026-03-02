FROM node:20-slim

WORKDIR /app

# Copy backend files
COPY backend/package*.json /app/backend/
WORKDIR /app/backend
RUN npm install

# Copy frontend files
COPY frontend/package*.json /app/frontend/
WORKDIR /app/frontend
RUN npm install

# Copy application code
WORKDIR /app
COPY backend/ /app/backend/
COPY frontend/ /app/frontend/
COPY SPEC.md /app/
COPY README.md /app/

# Expose ports
EXPOSE 8000 3000

# Start backend and frontend
CMD ["sh", "-c", "cd /app/backend && node server.js & cd /app/frontend && npm run dev"]
