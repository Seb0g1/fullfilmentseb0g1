#!/bin/bash

# Скрипт для запуска сайта на сервере
# Использование: ./start.sh

set -e

echo "=========================================="
echo "🚀 Запуск сайта fulfillment"
echo "=========================================="
echo ""

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Проверка сборки
if [ ! -d "dist" ]; then
    echo -e "${YELLOW}⚠️  Frontend не собран. Запускаю сборку...${NC}"
    npm install
    npm run build
fi

# Проверка зависимостей backend
if [ ! -d "server/node_modules" ]; then
    echo -e "${YELLOW}⚠️  Зависимости backend не установлены. Устанавливаю...${NC}"
    cd server
    npm install
    cd ..
fi

# Проверка .env
if [ ! -f "server/.env" ]; then
    echo -e "${RED}❌ Файл server/.env не найден!${NC}"
    echo "Создайте файл server/.env с настройками Telegram бота"
    exit 1
fi

# Запуск backend сервера
echo ""
echo -e "${GREEN}🚀 Запуск backend сервера...${NC}"
cd server
node server.js &
BACKEND_PID=$!
cd ..

echo -e "${GREEN}✅ Backend сервер запущен (PID: $BACKEND_PID)${NC}"
echo ""
echo "📝 Frontend файлы находятся в папке 'dist'"
echo "🌐 Настройте nginx для раздачи статики и проксирования API"
echo ""
echo "Для остановки нажмите Ctrl+C"

# Ожидание сигнала
trap "kill $BACKEND_PID 2>/dev/null; exit" INT TERM
wait $BACKEND_PID

