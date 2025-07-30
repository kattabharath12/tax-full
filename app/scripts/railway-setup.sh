
#!/bin/bash

# Railway Setup Script for TaxGrok.AI
# This script helps automate the Railway deployment setup

set -e

echo "🚂 TaxGrok.AI Railway Setup Script"
echo "=================================="

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
    echo "✅ Railway CLI installed"
fi

# Check if user is logged in
if ! railway whoami &> /dev/null; then
    echo "🔐 Please log in to Railway:"
    railway login
fi

echo "📋 Current Railway projects:"
railway list

read -p "Do you want to create a new Railway project? (y/n): " create_new

if [[ $create_new == "y" || $create_new == "Y" ]]; then
    echo "🆕 Creating new Railway project..."
    railway init
    
    echo "🗄️ Adding PostgreSQL database..."
    railway add postgresql
    
    echo "⏳ Waiting for database to be ready..."
    sleep 10
else
    echo "🔗 Linking to existing project..."
    railway link
fi

echo "🔧 Setting up environment variables..."

# Function to set environment variable
set_env_var() {
    local var_name=$1
    local var_description=$2
    local is_required=${3:-false}
    
    read -p "Enter $var_description: " var_value
    
    if [[ -n "$var_value" ]]; then
        railway variables set "$var_name=$var_value"
        echo "✅ Set $var_name"
    elif [[ "$is_required" == "true" ]]; then
        echo "❌ $var_name is required!"
        exit 1
    else
        echo "⏭️ Skipped $var_name"
    fi
}

# Set required environment variables
echo "Setting required environment variables..."
set_env_var "NEXTAUTH_SECRET" "NextAuth secret (minimum 32 characters)" true
set_env_var "ABACUSAI_API_KEY" "AbacusAI API key" true

# Get Railway app URL
echo "🌐 Getting Railway app URL..."
app_url=$(railway domain)
if [[ -n "$app_url" ]]; then
    railway variables set "NEXTAUTH_URL=https://$app_url"
    echo "✅ Set NEXTAUTH_URL to https://$app_url"
else
    echo "⚠️ Could not determine app URL. You may need to set NEXTAUTH_URL manually after deployment."
fi

# Set optional Google Cloud variables
echo "Setting optional Google Document AI variables..."
read -p "Do you want to configure Google Document AI? (y/n): " setup_google

if [[ $setup_google == "y" || $setup_google == "Y" ]]; then
    set_env_var "GOOGLE_CLOUD_PROJECT_ID" "Google Cloud Project ID"
    set_env_var "GOOGLE_CLOUD_LOCATION" "Google Cloud Location (default: us)"
    set_env_var "GOOGLE_CLOUD_W2_PROCESSOR_ID" "W2 Processor ID"
    set_env_var "GOOGLE_CLOUD_1099_PROCESSOR_ID" "1099 Processor ID"
    
    read -p "Enter path to Google Cloud service account JSON file: " json_file_path
    if [[ -f "$json_file_path" ]]; then
        json_base64=$(base64 -i "$json_file_path")
        railway variables set "GOOGLE_APPLICATION_CREDENTIALS_JSON=$json_base64"
        echo "✅ Set Google Cloud credentials"
    else
        echo "⚠️ Service account file not found. You can set this later."
    fi
fi

# Set production environment variables
railway variables set "NODE_ENV=production"
railway variables set "NEXT_TELEMETRY_DISABLED=1"

echo "🗄️ Running database migrations..."
railway run npx prisma migrate deploy

read -p "Do you want to seed the database with test data? (y/n): " seed_db
if [[ $seed_db == "y" || $seed_db == "Y" ]]; then
    echo "🌱 Seeding database..."
    railway run npm run db:seed
    echo "✅ Database seeded with test data"
fi

echo "🚀 Deploying to Railway..."
railway up

echo "✅ Deployment initiated!"
echo "📊 Monitor deployment progress:"
echo "   railway logs"
echo ""
echo "🌐 Your app will be available at:"
if [[ -n "$app_url" ]]; then
    echo "   https://$app_url"
else
    echo "   Check 'railway domain' for your app URL"
fi
echo ""
echo "🎉 Setup complete! Check the deployment logs for any issues."
