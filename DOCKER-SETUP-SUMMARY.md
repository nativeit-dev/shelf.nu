# Docker Compose Setup - Summary

This document provides a summary of the Docker Compose setup added to Shelf.nu.

## Files Created

### Configuration Files
- **`docker-compose.yml`** - Development environment with hot-reload
- **`docker-compose.prod.yml`** - Production environment with optimizations
- **`Dockerfile.dev`** - Development Docker image
- **`.env.example`** - Environment variables template

### Documentation
- **`DOCKER-COMPOSE-README.md`** - Quick start guide
- **`docs/docker-compose.md`** - Comprehensive documentation
- **`docs/docker-compose-testing.md`** - Testing and troubleshooting guide

### Utility Tools
- **`Makefile`** - Convenient make commands
- **`scripts/docker-dev.sh`** - Development environment manager
- **`scripts/docker-prod.sh`** - Production environment manager

### Updated Files
- **`.dockerignore`** - Enhanced to exclude unnecessary files
- **`README.md`** - Added Docker Compose references

## Features

### Development Environment
✅ Hot-reload support for live code changes
✅ Volume mounts for source code editing
✅ Persistent node_modules for faster rebuilds
✅ Health checks for automatic monitoring
✅ Port 3000 (configurable)

### Production Environment
✅ Multi-stage build for optimized image size
✅ Resource limits (CPU/Memory)
✅ Health checks with longer startup period
✅ Restart policy (unless-stopped)
✅ Port 8080 (configurable)

## Quick Start

### Development
```bash
# 1. Setup environment
cp .env.example .env
# Edit .env with your Supabase credentials

# 2. Start development server
docker-compose up

# Application available at http://localhost:3000
```

### Production
```bash
# 1. Setup environment
cp .env.example .env.production
# Edit .env.production with production credentials

# 2. Build and deploy
docker-compose -f docker-compose.prod.yml up -d

# Application available at http://localhost:8080
```

## Usage Options

### Using Docker Compose Commands
```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

### Using Utility Scripts
```bash
./scripts/docker-dev.sh start
./scripts/docker-dev.sh logs
./scripts/docker-dev.sh stop
```

### Using Makefile
```bash
make dev-start
make dev-logs
make dev-stop
```

## Prerequisites

Before using Docker Compose:

1. ✅ Install Docker and Docker Compose
2. ✅ Complete Supabase setup (see `docs/supabase-setup.md`)
3. ✅ Configure `.env` file with required variables:
   - DATABASE_URL
   - DIRECT_URL
   - SUPABASE_URL
   - SUPABASE_ANON_PUBLIC
   - SUPABASE_SERVICE_ROLE
   - SESSION_SECRET
   - INVITE_TOKEN_SECRET

## Environment Variables

All environment variables from the existing `.env` file are supported:

**Required:**
- Database configuration (Supabase)
- Supabase authentication
- Session secrets

**Optional:**
- SMTP configuration
- Stripe integration
- Map tiles (MapTiler)
- Analytics (Microsoft Clarity)
- Monitoring (Sentry)

See `.env.example` for complete list with descriptions.

## Testing

Comprehensive testing guide available in `docs/docker-compose-testing.md`:

- Configuration validation
- Build testing
- Container health checks
- Database connectivity
- Hot-reload functionality
- Performance benchmarks

## Common Commands

### Development
```bash
# Start
docker-compose up -d
make dev-start
./scripts/docker-dev.sh start

# Logs
docker-compose logs -f
make dev-logs
./scripts/docker-dev.sh logs

# Stop
docker-compose down
make dev-stop
./scripts/docker-dev.sh stop

# Rebuild
docker-compose up --build
make dev-build
./scripts/docker-dev.sh build

# Migrations
docker-compose exec app npm run db:deploy
make dev-migrate
./scripts/docker-dev.sh migrate

# Shell access
docker-compose exec app bash
make dev-shell
./scripts/docker-dev.sh shell
```

### Production
```bash
# Build
docker-compose -f docker-compose.prod.yml build
make prod-build
./scripts/docker-prod.sh build

# Deploy
docker-compose -f docker-compose.prod.yml up -d
make prod-deploy
./scripts/docker-prod.sh deploy

# Logs
docker-compose -f docker-compose.prod.yml logs -f
make prod-logs
./scripts/docker-prod.sh logs

# Stop
docker-compose -f docker-compose.prod.yml down
make prod-stop
./scripts/docker-prod.sh stop
```

## Architecture

### Development Setup
```
┌─────────────────────────────────────┐
│   Docker Compose (Development)      │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │   shelf-dev container        │  │
│  │                              │  │
│  │   Node.js 22                 │  │
│  │   Vite Dev Server            │  │
│  │   Port 3000                  │  │
│  │                              │  │
│  │   Volumes:                   │  │
│  │   - Source code (mounted)    │  │
│  │   - node_modules (volume)    │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│             ↓                       │
└─────────────┼───────────────────────┘
              ↓
      ┌───────────────┐
      │   Supabase    │
      │  (External)   │
      └───────────────┘
```

### Production Setup
```
┌─────────────────────────────────────┐
│   Docker Compose (Production)       │
├─────────────────────────────────────┤
│                                     │
│  ┌──────────────────────────────┐  │
│  │   shelf-prod container       │  │
│  │                              │  │
│  │   Node.js 22                 │  │
│  │   Built application          │  │
│  │   Port 8080                  │  │
│  │                              │  │
│  │   Resource Limits:           │  │
│  │   - CPU: 2 cores max         │  │
│  │   - Memory: 2GB max          │  │
│  │                              │  │
│  └──────────────────────────────┘  │
│             ↓                       │
└─────────────┼───────────────────────┘
              ↓
      ┌───────────────┐
      │   Supabase    │
      │  (External)   │
      └───────────────┘
```

## Differences from Standard Docker

**Docker Compose Advantages:**
- Easier environment variable management
- Built-in networking
- Volume management
- Service orchestration
- Development-friendly

**Standard Docker Advantages:**
- Simpler for CI/CD
- More portable commands
- Better for Kubernetes migration
- Pre-built images from registry

Both approaches are fully supported. Choose based on your needs.

## Security Considerations

1. **Never commit `.env` files** - Already in .gitignore
2. **Use `.env.example` as template** - Safe to commit
3. **Rotate secrets regularly** - Especially SESSION_SECRET and INVITE_TOKEN_SECRET
4. **Use secrets management in production** - Docker secrets or external vault
5. **Restrict network access** - Configure firewall rules
6. **Keep images updated** - Rebuild regularly for security patches

## Performance Expectations

### Development
- Initial build: 3-5 minutes
- Subsequent starts: 5-15 seconds
- Hot-reload: 1-3 seconds
- Memory usage: 300-500MB

### Production
- Build time: 5-10 minutes
- Image size: 500MB-1GB
- Startup time: 10-30 seconds
- Memory usage: 200-400MB at idle

## Troubleshooting

Common issues and solutions in `docs/docker-compose.md#troubleshooting`:

- Container won't start
- Database connection issues
- Port conflicts
- Hot-reload not working
- Build failures

## Next Steps

After setup:

1. ✅ Test the setup using `docs/docker-compose-testing.md`
2. ✅ Configure reverse proxy for production (nginx/Traefik)
3. ✅ Set up SSL/TLS certificates
4. ✅ Configure backup strategy
5. ✅ Set up monitoring and logging
6. ✅ Review security settings

## Documentation Links

- **Quick Start:** [DOCKER-COMPOSE-README.md](./DOCKER-COMPOSE-README.md)
- **Full Guide:** [docs/docker-compose.md](./docs/docker-compose.md)
- **Testing Guide:** [docs/docker-compose-testing.md](./docs/docker-compose-testing.md)
- **Supabase Setup:** [docs/supabase-setup.md](./docs/supabase-setup.md)
- **Standard Docker:** [docs/docker.md](./docs/docker.md)

## Support

Docker Compose support is community-powered. For help:

1. Check documentation first
2. Search GitHub Issues
3. Ask in GitHub Discussions
4. Contribute improvements

## License

Same as Shelf.nu project - AGPL-3.0 License
