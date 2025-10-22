#!/bin/bash
# Development environment management script

set -e

COMMAND=${1:-help}

case $COMMAND in
  start)
    echo "🚀 Starting development environment..."
    docker-compose up -d
    echo "✅ Development server started at http://localhost:3000"
    echo "📝 View logs with: ./scripts/docker-dev.sh logs"
    ;;
    
  stop)
    echo "🛑 Stopping development environment..."
    docker-compose down
    echo "✅ Development environment stopped"
    ;;
    
  restart)
    echo "🔄 Restarting development environment..."
    docker-compose restart
    echo "✅ Development environment restarted"
    ;;
    
  logs)
    echo "📋 Showing logs (Ctrl+C to exit)..."
    docker-compose logs -f
    ;;
    
  build)
    echo "🔨 Rebuilding development environment..."
    docker-compose down
    docker-compose up --build -d
    echo "✅ Development environment rebuilt and started"
    ;;
    
  migrate)
    echo "🗄️  Running database migrations..."
    docker-compose exec app npm run db:deploy
    echo "✅ Migrations completed"
    ;;
    
  shell)
    echo "🐚 Opening shell in container..."
    docker-compose exec app bash
    ;;
    
  clean)
    echo "🧹 Cleaning up Docker resources..."
    docker-compose down -v
    echo "✅ Cleanup completed (volumes removed)"
    ;;
    
  status)
    echo "📊 Container status:"
    docker-compose ps
    ;;
    
  help|*)
    echo "Shelf.nu Development Environment Manager"
    echo ""
    echo "Usage: ./scripts/docker-dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start    - Start development server (detached)"
    echo "  stop     - Stop development server"
    echo "  restart  - Restart development server"
    echo "  logs     - Show container logs"
    echo "  build    - Rebuild and restart"
    echo "  migrate  - Run database migrations"
    echo "  shell    - Open bash shell in container"
    echo "  clean    - Stop and remove all volumes"
    echo "  status   - Show container status"
    echo "  help     - Show this help message"
    echo ""
    ;;
esac
