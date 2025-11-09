# === Stage 1: Build ===
# This stage is perfect, no changes needed
FROM node:20-alpine AS builder

WORKDIR /app

# 1. Install dependencies
COPY package.json package-lock.json* ./
RUN npm ci

# 2. Copy source code
COPY . .

# 3. Run the build
RUN npm run build

# === Stage 2: Production ===
# Use the smallest possible base image
FROM alpine:latest AS production

WORKDIR /app

# Install 'nodejs' runtime (much smaller than the full 'node' image)
# Also add 'tzdata' for correct timezone support
RUN apk add --no-cache nodejs tzdata

# Create a non-root user for security
RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

# Copy the minimal standalone build from the builder stage
# Use --chown to set permissions at the same time
COPY --from=builder --chown=nextjs:nextjs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nextjs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nextjs /app/public ./public

# Switch to the non-root user
USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV NODE_ENV=production
ENV TZ="Etc/UTC" 
# Start the optimized standalone server
CMD ["node", "server.js"]