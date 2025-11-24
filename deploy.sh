#!/bin/bash

# Скрипт для деплоя сайта на сервер
# Использование: ./deploy.sh

set -e

echo "=========================================="
echo "🚀 Деплой сайта fulfillment на sakoo.ru"
echo "=========================================="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Проверка Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js не установлен!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js установлен: $(node --version)${NC}"

# Проверка npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm не установлен!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npm установлен: $(npm --version)${NC}"

# Установка зависимостей frontend
echo ""
echo "📦 Установка зависимостей frontend..."
cd "$(dirname "$0")"
npm install

# Установка зависимостей backend
echo ""
echo "📦 Установка зависимостей backend..."
cd server
npm install
cd ..

# Сборка frontend
echo ""
echo "🔨 Сборка frontend проекта..."
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Ошибка сборки! Папка dist не создана.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Frontend собран успешно!${NC}"

# Проверка .env файлов
echo ""
echo "🔍 Проверка конфигурации..."

if [ ! -f "server/.env" ]; then
    echo -e "${YELLOW}⚠️  Файл server/.env не найден!${NC}"
    echo "Создайте файл server/.env со следующими переменными:"
    echo "  TELEGRAM_BOT_TOKEN=ваш_токен"
    echo "  TELEGRAM_GROUP_CHAT_ID=ваш_chat_id"
    echo "  TELEGRAM_TOPIC_CHAT_CLIENT=id_топика"
    echo "  TELEGRAM_TOPIC_CALCULATOR=id_топика"
    echo "  TELEGRAM_TOPIC_CONTACT_FORM=id_топика"
    echo "  PORT=3001"
    echo ""
    read -p "Продолжить без .env? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ Файл server/.env найден${NC}"
fi

# Копирование файлов на сервер (если нужно)
echo ""
echo "📋 Готово к деплою!"
echo ""
echo "Следующие шаги:"
echo "1. Скопируйте папку 'dist' на сервер"
echo "2. Скопируйте папку 'server' на сервер"
echo "3. Установите конфигурацию nginx (см. nginx-sakoo.conf)"
echo "4. Запустите backend сервер (см. start.sh или используйте PM2)"
echo ""
echo "Или используйте:"
echo "  ./start.sh  - для запуска на текущем сервере"
echo "  pm2 start ecosystem.config.js  - для запуска через PM2"

