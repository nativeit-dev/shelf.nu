#!/bin/bash
# Environment variables validation script for Docker Compose setup

set -e

ENV_FILE="${1:-.env}"
ERRORS=0
WARNINGS=0

echo "🔍 Validating environment file: $ENV_FILE"
echo ""

# Check if file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: $ENV_FILE not found!"
    echo "   Run: cp .env.example .env"
    exit 1
fi

echo "✅ File exists"
echo ""

# Function to check required variable
check_required() {
    local var_name=$1
    local var_desc=$2
    
    if grep -q "^${var_name}=" "$ENV_FILE" && ! grep -q "^${var_name}=$" "$ENV_FILE" && ! grep -q "^${var_name}=\"\"" "$ENV_FILE"; then
        echo "✅ $var_name - $var_desc"
    else
        echo "❌ $var_name - $var_desc (MISSING or EMPTY)"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check optional variable
check_optional() {
    local var_name=$1
    local var_desc=$2
    
    if grep -q "^${var_name}=" "$ENV_FILE" && ! grep -q "^${var_name}=$" "$ENV_FILE" && ! grep -q "^${var_name}=\"\"" "$ENV_FILE"; then
        echo "✅ $var_name - $var_desc"
    else
        echo "⚠️  $var_name - $var_desc (optional)"
        WARNINGS=$((WARNINGS + 1))
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Required Variables:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_required "DATABASE_URL" "Database connection (pooling)"
check_required "DIRECT_URL" "Database connection (direct)"
check_required "SUPABASE_URL" "Supabase project URL"
check_required "SUPABASE_ANON_PUBLIC" "Supabase anonymous key"
check_required "SUPABASE_SERVICE_ROLE" "Supabase service role key"
check_required "SESSION_SECRET" "Session encryption secret"
check_required "INVITE_TOKEN_SECRET" "Invite token secret"
check_required "SERVER_URL" "Server URL"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Optional Variables:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
check_optional "SMTP_HOST" "Email server host"
check_optional "SMTP_PORT" "Email server port"
check_optional "SMTP_USER" "Email username"
check_optional "SMTP_PWD" "Email password"
check_optional "SMTP_FROM" "Email from address"
check_optional "STRIPE_SECRET_KEY" "Stripe secret key"
check_optional "STRIPE_PUBLIC_KEY" "Stripe public key"
check_optional "MAPTILER_TOKEN" "Map tiles token"
check_optional "MICROSOFT_CLARITY_ID" "Analytics ID"
check_optional "SENTRY_DSN" "Error monitoring DSN"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All required variables are configured!"
    echo ""
    if [ $WARNINGS -gt 0 ]; then
        echo "⚠️  $WARNINGS optional variables are not set"
        echo "   This is OK for testing, but recommended for production"
    fi
    echo ""
    echo "✅ Environment file is valid!"
    echo ""
    echo "Next steps:"
    echo "  Development: docker-compose up"
    echo "  Production:  docker-compose -f docker-compose.prod.yml up -d"
    exit 0
else
    echo "❌ Found $ERRORS required variables missing or empty"
    echo ""
    echo "Please edit $ENV_FILE and set all required variables."
    echo "Use .env.example as a reference."
    echo ""
    echo "For Supabase setup, see: docs/supabase-setup.md"
    exit 1
fi
