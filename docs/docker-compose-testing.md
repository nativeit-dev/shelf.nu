# Docker Compose Testing Guide

This guide helps you verify that your Docker Compose setup is working correctly.

## Prerequisites Check

Before testing, ensure you have:

1. ✅ Docker and Docker Compose installed
2. ✅ `.env` file created and configured
3. ✅ Supabase project set up and accessible
4. ✅ All required environment variables configured

### Verify Prerequisites

```bash
# Check Docker installation
docker --version
docker compose version

# Check .env file exists
test -f .env && echo "✅ .env file exists" || echo "❌ .env file missing"

# Verify required environment variables (without showing values)
grep -q "DATABASE_URL=" .env && echo "✅ DATABASE_URL configured" || echo "❌ DATABASE_URL missing"
grep -q "SUPABASE_URL=" .env && echo "✅ SUPABASE_URL configured" || echo "❌ SUPABASE_URL missing"
```

## Development Environment Tests

### Test 1: Configuration Validation

Validate Docker Compose configuration syntax:

```bash
docker compose config --quiet
echo "✅ Development configuration is valid"
```

### Test 2: Image Build

Build the development image:

```bash
docker compose build
```

Expected output: Build completes without errors

### Test 3: Container Start

Start the development environment:

```bash
docker compose up -d
```

Expected output:
```
[+] Running 2/2
 ✔ Network shelf.nu_default  Created
 ✔ Container shelf-dev       Started
```

### Test 4: Container Health

Check container status:

```bash
docker compose ps
```

Expected output: Container shows as "running" (Up)

Wait for application to start (30-60 seconds), then check health:

```bash
# Check if container is healthy
docker inspect shelf-dev --format='{{.State.Health.Status}}'
```

Expected output: `healthy` (after startup period)

### Test 5: Application Access

Test if the application responds:

```bash
curl -f http://localhost:3000/health-check
```

Expected output: HTTP 200 OK response

Access in browser:
```bash
# Open in default browser (Linux)
xdg-open http://localhost:3000

# Or manually visit: http://localhost:3000
```

Expected: Login page loads successfully

### Test 6: Logs Check

View application logs:

```bash
docker compose logs -f --tail=50
```

Expected: No error messages, application starts successfully

Press Ctrl+C to exit logs

### Test 7: Database Connection

Test database connectivity:

```bash
docker compose exec app npm run db:deploy
```

Expected output: Migrations run successfully or "No pending migrations"

### Test 8: Hot Reload

Test hot-reload functionality:

```bash
# Make a small change to a file
echo "/* Test change $(date) */" >> app/root.tsx

# Watch logs for rebuild
docker compose logs -f
```

Expected: Vite detects change and rebuilds automatically

Revert the change:
```bash
git checkout app/root.tsx
```

### Test 9: Volume Persistence

Test that node_modules persist:

```bash
# Stop container
docker compose down

# Start again (should be faster)
time docker compose up -d

# Should start in under 10 seconds
```

### Test 10: Clean Restart

Test full cleanup and restart:

```bash
# Clean everything
docker compose down -v

# Rebuild from scratch
docker compose up --build -d

# Wait for startup
sleep 30

# Verify health
curl -f http://localhost:3000/health-check
```

## Production Environment Tests

### Test 1: Production Configuration Validation

```bash
docker compose -f docker-compose.prod.yml config --quiet
echo "✅ Production configuration is valid"
```

### Test 2: Production Image Build

```bash
docker compose -f docker-compose.prod.yml build
```

Expected: Multi-stage build completes successfully

### Test 3: Production Container Start

```bash
docker compose -f docker-compose.prod.yml up -d
```

Expected output:
```
[+] Running 1/1
 ✔ Container shelf-prod  Started
```

### Test 4: Production Health Check

```bash
# Wait for startup (60 seconds)
sleep 60

# Check health
curl -f http://localhost:8080/health-check
```

Expected: HTTP 200 OK response

### Test 5: Production Performance

Test production build performance:

```bash
# Check image size
docker images shelf-prod:latest

# Check resource usage
docker stats shelf-prod --no-stream
```

Expected:
- Image size: < 1GB
- Memory usage: < 500MB at idle

### Test 6: Production Logs

```bash
docker compose -f docker-compose.prod.yml logs --tail=50
```

Expected: Clean startup logs, no errors

## Utility Scripts Tests

### Test Development Script

```bash
# Test help command
./scripts/docker-dev.sh help

# Test start
./scripts/docker-dev.sh start

# Test status
./scripts/docker-dev.sh status

# Test logs (press Ctrl+C after a few seconds)
./scripts/docker-dev.sh logs

# Test stop
./scripts/docker-dev.sh stop
```

### Test Production Script

```bash
# Test help command
./scripts/docker-prod.sh help

# Test build
./scripts/docker-prod.sh build

# Test start
./scripts/docker-prod.sh start

# Test status
./scripts/docker-prod.sh status

# Test stop
./scripts/docker-prod.sh stop
```

## Makefile Tests

### Test Development Targets

```bash
make dev-start
make dev-logs    # Press Ctrl+C after a few seconds
make dev-stop
```

### Test Production Targets

```bash
make prod-build
make prod-start
make prod-logs   # Press Ctrl+C after a few seconds
make prod-stop
```

## Common Issues and Solutions

### Issue: Container won't start

**Symptoms:** Container exits immediately

**Solution:**
```bash
# Check logs for errors
docker compose logs

# Verify environment variables
docker compose config | grep -A 20 "environment:"

# Check database connectivity
docker compose run --rm app npx prisma db push --skip-generate
```

### Issue: Port already in use

**Symptoms:** Error binding to port 3000 or 8080

**Solution:**
```bash
# Find process using the port
lsof -i :3000
# or
netstat -tuln | grep 3000

# Change port in .env
echo "PORT=3001" >> .env

# Restart
docker compose down && docker compose up -d
```

### Issue: Hot-reload not working

**Symptoms:** Changes not reflected in browser

**Solution:**
```bash
# Check volume mounts
docker compose config | grep -A 10 "volumes:"

# Restart container
docker compose restart

# If still not working, rebuild
docker compose up --build
```

### Issue: Database connection failed

**Symptoms:** Prisma connection errors

**Solution:**
```bash
# Test database URL format
docker compose exec app node -e "console.log(process.env.DATABASE_URL?.substring(0, 20))"

# Verify Supabase is accessible
docker compose exec app curl -f $SUPABASE_URL

# Check migrations
docker compose exec app npx prisma migrate status
```

### Issue: Build failures

**Symptoms:** Docker build errors

**Solution:**
```bash
# Clear Docker cache
docker system prune -a

# Rebuild without cache
docker compose build --no-cache

# Check disk space
df -h
```

## Performance Benchmarks

Expected performance metrics:

### Development Environment
- **Initial build**: 3-5 minutes
- **Subsequent starts**: 5-15 seconds
- **Hot-reload**: 1-3 seconds
- **Memory usage**: 300-500MB

### Production Environment
- **Build time**: 5-10 minutes
- **Image size**: 500MB-1GB
- **Startup time**: 10-30 seconds
- **Memory usage**: 200-400MB at idle
- **Request latency**: < 100ms

## Automated Test Script

Save this as `test-docker-compose.sh`:

```bash
#!/bin/bash
set -e

echo "🧪 Testing Docker Compose Setup"
echo ""

# Configuration test
echo "1️⃣  Validating configuration..."
docker compose config --quiet && echo "✅ Config valid" || exit 1

# Build test
echo "2️⃣  Building development image..."
docker compose build || exit 1
echo "✅ Build successful"

# Start test
echo "3️⃣  Starting containers..."
docker compose up -d || exit 1
echo "✅ Containers started"

# Wait for startup
echo "4️⃣  Waiting for application startup (30s)..."
sleep 30

# Health check
echo "5️⃣  Checking application health..."
if curl -f http://localhost:3000/health-check 2>/dev/null; then
    echo "✅ Health check passed"
else
    echo "⚠️  Health check failed (app may still be starting)"
fi

# Logs check
echo "6️⃣  Checking logs for errors..."
if docker compose logs | grep -i "error" | grep -v "0 errors"; then
    echo "⚠️  Found errors in logs"
else
    echo "✅ No errors in logs"
fi

# Cleanup
echo "7️⃣  Cleaning up..."
docker compose down

echo ""
echo "✅ All tests completed!"
```

Make it executable and run:
```bash
chmod +x test-docker-compose.sh
./test-docker-compose.sh
```

## Next Steps

After successful testing:

1. ✅ Configure production environment variables
2. ✅ Set up reverse proxy (nginx/Traefik) if needed
3. ✅ Configure backup strategy for database
4. ✅ Set up monitoring and logging
5. ✅ Review security settings
6. ✅ Configure SSL/TLS certificates

## Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Troubleshooting Guide](./docker-compose.md#troubleshooting)
- [Production Best Practices](./docker-compose.md#best-practices)
