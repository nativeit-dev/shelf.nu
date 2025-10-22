# Docker Compose Setup

This guide explains how to deploy Shelf.nu using Docker Compose for both development and production environments.

## Overview

Shelf.nu provides two Docker Compose configurations:

- **`docker-compose.yml`** - Development environment with hot-reload
- **`docker-compose.prod.yml`** - Production environment optimized for performance

## Prerequisites

> [!IMPORTANT]
> Before using Docker Compose, you **must** complete these prerequisites:

1. **Docker & Docker Compose** - Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine with Docker Compose
2. **Supabase Setup** - Follow the [Supabase Setup Guide](./supabase-setup.md) to configure your database and authentication
3. **Environment Variables** - Copy `.env.example` to `.env` and configure with your actual values

### Required Environment Variables

At minimum, you must configure these variables in your `.env` file:

```bash
# Database (from Supabase)
DATABASE_URL="postgres://USER:PASSWORD@HOST:6543/DB_NAME?pgbouncer=true"
DIRECT_URL="postgres://USER:PASSWORD@HOST:5432/DB_NAME"

# Supabase Authentication
SUPABASE_URL="https://your-instance-name.supabase.co"
SUPABASE_ANON_PUBLIC="your-anon-public-key"
SUPABASE_SERVICE_ROLE="your-service-role-key"

# Application Secrets
SESSION_SECRET="generate-a-random-secret-here"
INVITE_TOKEN_SECRET="another-random-secret-here"

# Server Configuration
SERVER_URL="http://localhost:3000"
```

Generate random secrets using:
```bash
openssl rand -base64 32
```

## Development Environment

### Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file** with your Supabase credentials and secrets

3. **Start development server:**
   ```bash
   docker-compose up
   ```

The application will be available at `http://localhost:3000`

### Development Features

- **Hot-reload** - Changes to code are automatically reflected
- **Volume mounts** - Source code is mounted for live editing
- **Persistent node_modules** - Faster rebuilds with cached dependencies
- **Health checks** - Automatic container health monitoring

### Development Commands

```bash
# Start in foreground (see logs)
docker-compose up

# Start in background (detached)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down

# Rebuild containers after dependency changes
docker-compose up --build

# Run database migrations
docker-compose exec app npm run db:deploy

# Run tests
docker-compose exec app npm run test

# Access container shell
docker-compose exec app bash

# Stop and remove containers with volumes
docker-compose down -v
```

### Rebuilding After Changes

After modifying `package.json` or Dockerfile:
```bash
docker-compose down
docker-compose up --build
```

## Production Environment

### Quick Start

1. **Copy environment template:**
   ```bash
   cp .env.example .env.production
   ```

2. **Edit `.env.production` file** with production credentials

3. **Build and start production server:**
   ```bash
   docker-compose -f docker-compose.prod.yml up -d
   ```

The application will be available at `http://localhost:8080` (or your configured PORT)

### Production Features

- **Optimized build** - Multi-stage build with minimal image size
- **Resource limits** - CPU and memory limits for stability
- **Health checks** - Automatic container health monitoring
- **Auto-restart** - Containers restart automatically on failure

### Production Commands

```bash
# Build production image
docker-compose -f docker-compose.prod.yml build

# Start production server
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop production server
docker-compose -f docker-compose.prod.yml down

# Restart production server
docker-compose -f docker-compose.prod.yml restart

# View container stats
docker stats shelf-prod
```

### Using Custom Environment File

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.production up -d
```

## Configuration

### Port Configuration

Change the exposed port by setting `PORT` in your `.env` file:

```bash
# Development (default: 3000)
PORT=3000

# Production (default: 8080)
PORT=8080
```

### Resource Limits (Production)

Adjust resource limits in `docker-compose.prod.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'        # Maximum CPU cores
      memory: 2G       # Maximum memory
    reservations:
      cpus: '1'        # Minimum CPU cores
      memory: 1G       # Minimum memory
```

## Database Migrations

### Running Migrations

After pulling new code with database changes:

```bash
# Development
docker-compose exec app npm run db:deploy

# Production
docker-compose -f docker-compose.prod.yml exec app npm run db:deploy
```

### Initial Setup

When starting fresh:

```bash
# Development
docker-compose exec app npm run setup

# Production
docker-compose -f docker-compose.prod.yml exec app npm run setup
```

## Troubleshooting

### Container Won't Start

1. **Check logs:**
   ```bash
   docker-compose logs -f app
   ```

2. **Verify environment variables:**
   ```bash
   docker-compose exec app env | grep -E "DATABASE_URL|SUPABASE"
   ```

3. **Test database connectivity:**
   ```bash
   docker-compose exec app npx prisma db push --skip-generate
   ```

### Database Connection Issues

- Ensure `DATABASE_URL` and `DIRECT_URL` are correctly configured
- Verify Supabase database is accessible from your Docker host
- Check Supabase connection pooling settings

### Build Failures

1. **Clear Docker cache:**
   ```bash
   docker-compose down -v
   docker system prune -a
   docker-compose up --build
   ```

2. **Check Node version:**
   The Dockerfiles use Node 22. Ensure compatibility with your dependencies.

### Port Already in Use

If port 3000 or 8080 is already in use:

1. **Change port in `.env`:**
   ```bash
   PORT=3001
   ```

2. **Restart containers:**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Hot-Reload Not Working

1. **Check volume mounts** in `docker-compose.yml`
2. **Verify file changes** are saved
3. **Restart development container:**
   ```bash
   docker-compose restart app
   ```

### Health Check Failing

The health check endpoint is `/health-check`. If it's failing:

1. **Check if app is running:**
   ```bash
   docker-compose exec app ps aux | grep node
   ```

2. **Test health endpoint manually:**
   ```bash
   docker-compose exec app curl -f http://localhost:3000/health-check
   ```

3. **Increase start_period** in health check config if app takes longer to start

## Advanced Usage

### Using with Reverse Proxy

For production deployments behind nginx or Traefik:

1. **Update `SERVER_URL` in `.env`:**
   ```bash
   SERVER_URL="https://your-domain.com"
   ```

2. **Configure reverse proxy** to forward to container port

Example nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Multi-Stage Development

Run multiple environments simultaneously:

```bash
# Development on port 3000
docker-compose up -d

# Staging on port 3001
PORT=3001 docker-compose -f docker-compose.yml up -d

# Production on port 8080
docker-compose -f docker-compose.prod.yml up -d
```

### Custom Build Arguments

Build with custom Node version:

```bash
docker build --build-arg NODE_VERSION=20 -f Dockerfile.dev -t shelf-dev:node20 .
```

## Best Practices

### Development

1. **Use volume mounts** for live code updates
2. **Keep `.env` file secure** - Never commit it
3. **Run migrations** after pulling database changes
4. **Monitor logs** regularly with `docker-compose logs -f`

### Production

1. **Use `.env.production`** with production credentials
2. **Set resource limits** based on your server capacity
3. **Enable health checks** for automatic recovery
4. **Regular backups** of your Supabase database
5. **Monitor container stats** with `docker stats`
6. **Use secrets management** for sensitive data in production
7. **Set up logging** to external service for long-term retention

## Comparison with Standard Docker

If you prefer using standard Docker commands instead of Docker Compose, see the [Docker Guide](./docker.md) for instructions.

### When to Use Docker Compose

- ✅ Local development with hot-reload
- ✅ Simplified environment variable management
- ✅ Easy multi-container orchestration
- ✅ Development team collaboration

### When to Use Standard Docker

- ✅ Production deployments with orchestrators (Kubernetes, etc.)
- ✅ CI/CD pipelines
- ✅ Simple single-container deployments
- ✅ Using pre-built images from ghcr.io

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Supabase Setup Guide](./supabase-setup.md)
- [Local Development Guide](./local-development.md)
- [Standard Docker Guide](./docker.md)

## Support

For Docker-related issues:

1. Check this documentation first
2. Search [GitHub Issues](https://github.com/Shelf-nu/shelf.nu/issues)
3. Ask in [GitHub Discussions](https://github.com/Shelf-nu/shelf.nu/discussions)

> [!NOTE]
> Docker support is community-powered. While we accept fixes and improvements, official support is limited.
