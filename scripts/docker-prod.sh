#!/bin/bash
# Production environment management script

set -e

COMMAND=${1:-help}
COMPOSE_FILE="docker-compose.prod.yml"

case $COMMAND in
  start)
    echo "🚀 Starting production environment..."
    docker-compose -f $COMPOSE_FILE up -d
    echo "✅ Production server started at http://localhost:8080"
    echo "📝 View logs with: ./scripts/docker-prod.sh logs"
    ;;
    
  stop)
    echo "🛑 Stopping production environment..."
    docker-compose -f $COMPOSE_FILE down
    echo "✅ Production environment stopped"
    ;;
    
  restart)
    echo "🔄 Restarting production environment..."
    docker-compose -f $COMPOSE_FILE restart
    echo "✅ Production environment restarted"
    ;;
    
  logs)
    echo "📋 Showing logs (Ctrl+C to exit)..."
    docker-compose -f $COMPOSE_FILE logs -f
    ;;
    
  build)
    echo "🔨 Building production image..."
    docker-compose -f $COMPOSE_FILE build
    echo "✅ Production image built"
    ;;
    
  deploy)
    echo "🚀 Deploying production environment..."
    docker-compose -f $COMPOSE_FILE build
    docker-compose -f $COMPOSE_FILE down
    docker-compose -f $COMPOSE_FILE up -d
    echo "✅ Production environment deployed"
    ;;
    
  migrate)
    echo "🗄️  Running database migrations..."
    docker-compose -f $COMPOSE_FILE exec app npm run db:deploy
    echo "✅ Migrations completed"
    ;;
    
  shell)
    echo "🐚 Opening shell in container..."
    docker-compose -f $COMPOSE_FILE exec app bash
    ;;
    
  stats)
    echo "📊 Container statistics:"
    docker stats shelf-prod --no-stream
    ;;
    
  status)
    echo "📊 Container status:"
    docker-compose -f $COMPOSE_FILE ps
    ;;
    
  help|*)
    echo "Shelf.nu Production Environment Manager"
    echo ""
    echo "Usage: ./scripts/docker-prod.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start    - Start production server (detached)"
    echo "  stop     - Stop production server"
    echo "  restart  - Restart production server"
    echo "  logs     - Show container logs"
    echo "  build    - Build production image"
    echo "  deploy   - Build and deploy (build + restart)"
    echo "  migrate  - Run database migrations"
    echo "  shell    - Open bash shell in container"
    echo "  stats    - Show resource usage"
    echo "  status   - Show container status"
    echo "  help     - Show this help message"
    echo ""
    ;;
esac
