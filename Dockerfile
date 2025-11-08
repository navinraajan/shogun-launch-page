# === Stage 1: Build ===
# Use the same Alpine base
FROM node:20-alpine AS builder

WORKDIR /app

# 1. Install dependencies (with cache)
# This won't copy your local node_modules thanks to .dockerignore
COPY package.json package-lock.json* ./
RUN npm ci

# 2. Copy source code
COPY . .

# 3. Run the build
# This will create .next/standalone thanks to your next.config.js
RUN npm run build


# === Stage 2: Production ===
# Start from a fresh, lightweight Alpine image
FROM node:20-alpine AS production

WORKDIR /app

# Create a non-root user for security
RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

# Copy the minimal standalone build from the builder stage
# This includes the server.js, .next/static, and a minimal node_modules
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

# Copy the public folder
COPY --from=builder /app/public ./public

# Change ownership to the non-root user
RUN chown -R nextjs:nextjs /app

# Switch to the non-root user
USER nextjs

EXPOSE 3000
ENV PORT 3000
ENV NODE_ENV production

# Start the optimized standalone server
CMD ["node", "server.js"]