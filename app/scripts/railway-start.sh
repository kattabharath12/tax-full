#!/bin/bash

# Railway Start Script
# This script handles the startup process for Railway deployment

set -e

echo "🚂 Starting TaxGrok.AI on Railway..."

# Generate Prisma client if not already generated
if [ ! -d "node_modules/.prisma/client" ]; then
    echo "📦 Generating Prisma client..."
    npx prisma generate
fi

# Run database migrations
echo "🗄️ Running database migrations..."
npx prisma migrate deploy

# Start the Next.js application
echo "🚀 Starting Next.js application..."
exec npm start
