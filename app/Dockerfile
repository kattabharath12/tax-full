FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Use npm install instead of npm ci to avoid lock file issues
RUN npm install

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Set environment variables to skip build-time analysis
ENV SKIP_ENV_VALIDATION=true
ENV NEXT_TELEMETRY_DISABLED=1

# Build with skip flags
RUN npm run build -- --experimental-build-mode=compile || npm run build

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
