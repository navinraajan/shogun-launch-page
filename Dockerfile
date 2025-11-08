# === Stage 1: Build ===
# Use a Node.js LTS (Long Term Support) version on a lean 'alpine' base
FROM node:20-alpine AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock, pnpm-lock.yaml)
COPY package.json package-lock.json* ./

# Install all dependencies (including devDependencies for building)
# Using 'npm ci' (clean install) is recommended for reproducible builds
RUN npm ci

# Copy the rest of your application source code
COPY . .

# Run the Next.js build command
RUN npm run build

# Prune devDependencies to reduce the size of node_modules
RUN npm prune --production

# === Stage 2: Production ===
# Start from a fresh, lightweight Node.js Alpine image
FROM node:20-alpine AS production

WORKDIR /app

# Create a non-root user 'nextjs' and a group 'nextjs' for security
RUN addgroup -S nextjs && adduser -S nextjs -G nextjs

# Copy only the necessary files from the 'builder' stage
# 1. The production-only node_modules
COPY --from=builder /app/node_modules ./node_modules
# 2. The built .next folder
COPY --from=builder /app/.next ./.next
# 3. The package.json (needed by 'next start')
COPY --from=builder /app/package.json ./package.json
# 4. The public folder (images, fonts, etc.)
COPY --from=builder /app/public ./public
# 5. The next.config.js (if it exists)
COPY --from=builder /app/next.config.js* ./

# Change ownership of the app directory to the 'nextjs' user
# This is not strictly necessary for 'next start' but is good practice
RUN chown -R nextjs:nextjs /app

# Switch to the non-root user
USER nextjs

# Expose the port Next.js runs on (default 3000)
EXPOSE 3000

# Set the PORT environment variable (Next.js respects this)
ENV PORT 3000

# The command to start the Next.js production server
# This will execute 'next start' as defined in your package.json 'start' script
CMD ["npm", "start"]