# Frontend Dockerfile - Node.js 20 Alpine
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Copy package descriptors
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy application source code
COPY . .

# Expose application port
EXPOSE 3000

# Set environment defaults
ENV NODE_ENV=production \
    PORT=3000 \
    BACKEND_URL=http://backend:5000

# Start Express server
CMD ["node", "server.js"]

