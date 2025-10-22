# Docker Compose Quick Start Guide

This is a quick reference guide for using Docker Compose with Shelf.nu. For comprehensive documentation, see [docs/docker-compose.md](./docs/docker-compose.md).

## Prerequisites

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) or Docker Engine with Docker Compose
2. Complete [Supabase Setup](./docs/supabase-setup.md)
3. Configure environment variables

## Setup

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env with your Supabase credentials
# Required: DATABASE_URL, DIRECT_URL, SUPABASE_URL, SUPABASE_ANON_PUBLIC, 
#           SUPABASE_SERVICE_ROLE, SESSION_SECRET, INVITE_TOKEN_SECRET

# 3. Start development server
docker-compose up

# Application available at http://localhost:3000
```

## Common Commands

### Development

```bash
# Start (foreground)
docker-compose up

# Start (background)
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose up --build

# Run migrations
docker-compose exec app npm run db:deploy

# Access shell
docker-compose exec app bash
```

### Production

```bash
# Build and start
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop
docker-compose -f docker-compose.prod.yml down

# Application available at http://localhost:8080
```

## Troubleshooting

### Container won't start
```bash
docker-compose logs -f app
```

### Database connection issues
- Verify DATABASE_URL and DIRECT_URL in .env
- Ensure Supabase is accessible

### Port already in use
```bash
# Change PORT in .env
PORT=3001

# Restart
docker-compose down && docker-compose up -d
```

### Hot-reload not working
```bash
docker-compose restart app
```

## Documentation

- **Full Guide:** [docs/docker-compose.md](./docs/docker-compose.md)
- **Supabase Setup:** [docs/supabase-setup.md](./docs/supabase-setup.md)
- **Standard Docker:** [docs/docker.md](./docs/docker.md)

## Need Help?

- [GitHub Issues](https://github.com/Shelf-nu/shelf.nu/issues)
- [GitHub Discussions](https://github.com/Shelf-nu/shelf.nu/discussions)
