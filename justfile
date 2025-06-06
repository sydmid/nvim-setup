# Sample justfile for terminal management system
# This file demonstrates how to set up common development services
# that can be launched via the Neovim terminal management system

# Default recipe to show available commands
default:
    @just --list

# Web development server (e.g., Next.js, Vite, etc.)
web:
    echo "🌐 Starting web development server..."
    echo "This would typically run: npm run dev or yarn dev"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): Web server running on http://localhost:3000"
        sleep 5
    done

# API server (e.g., Express, FastAPI, etc.)
api:
    echo "🚀 Starting API server..."
    echo "This would typically run: npm run api or python -m uvicorn main:app"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): API server running on http://localhost:8000"
        sleep 3
    done

# Database server (e.g., PostgreSQL, MongoDB, etc.)
db:
    echo "💾 Starting database server..."
    echo "This would typically run: docker-compose up postgres or mongod"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): Database server running on port 5432"
        sleep 4
    done

# Background worker (e.g., Celery, Bull, etc.)
worker:
    echo "⚙️  Starting background worker..."
    echo "This would typically run: celery worker or npm run worker"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): Processing background jobs..."
        sleep 2
    done

# Test runner (e.g., Jest, Pytest, etc.)
test:
    echo "🧪 Running tests..."
    echo "This would typically run: npm test, pytest, or cargo test"
    echo "Running test suite..."
    for i in {1..10}; do
        echo "Test $i/10: ✅ Passed"
        sleep 1
    done
    echo "All tests completed!"

# Build process (e.g., Webpack, Vite build, etc.)
build:
    echo "🏗️  Starting build process..."
    echo "This would typically run: npm run build or cargo build"
    for i in {1..5}; do
        echo "Building... $((i*20))% complete"
        sleep 2
    done
    echo "✅ Build completed successfully!"

# Development server with hot reload
dev:
    echo "🔥 Starting development server with hot reload..."
    echo "This would typically run: npm run dev or cargo watch"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): Dev server with hot reload running"
        sleep 3
    done

# Log viewer (e.g., tail logs, Docker logs, etc.)
logs:
    echo "📋 Viewing application logs..."
    echo "This would typically run: tail -f app.log or docker logs -f container"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): [INFO] Application running normally"
        sleep 1
        echo "$(date): [DEBUG] Processing request"
        sleep 1
        echo "$(date): [INFO] Request completed successfully"
        sleep 2
    done

# System monitoring (e.g., htop, docker stats, etc.)
monitor:
    echo "📊 Starting system monitor..."
    echo "This would typically run: htop, docker stats, or custom monitoring"
    echo "Press Ctrl+C to stop"
    while true; do
        echo "$(date): CPU: $((RANDOM % 100))%, Memory: $((RANDOM % 100))%, Disk: $((RANDOM % 100))%"
        sleep 2
    done

# Stop all services (useful for cleanup)
stop-all:
    echo "🛑 Stopping all services..."
    pkill -f "just web" || true
    pkill -f "just api" || true
    pkill -f "just db" || true
    pkill -f "just worker" || true
    pkill -f "just dev" || true
    pkill -f "just logs" || true
    pkill -f "just monitor" || true
    echo "All services stopped."

# Install dependencies
install:
    echo "📦 Installing dependencies..."
    echo "This would typically run: npm install, pip install -r requirements.txt, etc."
    echo "Dependencies installed successfully!"

# Setup development environment
setup:
    echo "🛠️  Setting up development environment..."
    just install
    echo "Creating configuration files..."
    echo "Environment setup complete!"

# Run linting and formatting
lint:
    echo "🧹 Running linters and formatters..."
    echo "This would typically run: eslint, prettier, black, rustfmt, etc."
    echo "Code formatting completed!"

# Database migrations
migrate:
    echo "🔄 Running database migrations..."
    echo "This would typically run: npm run migrate or alembic upgrade head"
    echo "Database migrations completed!"

# Seed database with test data
seed:
    echo "🌱 Seeding database with test data..."
    echo "This would typically run: npm run seed or python seed.py"
    echo "Database seeded successfully!"
