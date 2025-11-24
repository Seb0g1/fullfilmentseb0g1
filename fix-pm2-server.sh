#!/bin/bash

# Быстрый скрипт для исправления PM2 на сервере
# Использование: ./fix-pm2-server.sh

set -e

echo "=========================================="
echo "🔧 Исправление PM2 конфигурации"
echo "=========================================="
echo ""

PROJECT_DIR="/var/www/sakoo.ru"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Директория $PROJECT_DIR не найдена!"
    exit 1
fi

cd "$PROJECT_DIR"

# Удаляем старый файл
if [ -f "ecosystem.config.js" ]; then
    echo "🗑️  Удаляю старый ecosystem.config.js..."
    rm -f ecosystem.config.js
    echo "✅ Старый файл удален"
fi

# Проверяем наличие нового файла
if [ -f "ecosystem.config.cjs" ]; then
    echo "✅ Найден ecosystem.config.cjs"
    
    # Останавливаем старый процесс
    echo "🛑 Останавливаю старый процесс..."
    pm2 delete fulfillment-backend 2>/dev/null || true
    
    # Запускаем с новым файлом
    echo "🚀 Запускаю backend с ecosystem.config.cjs..."
    pm2 start ecosystem.config.cjs
    pm2 save
    
    echo ""
    echo "✅ Backend успешно запущен!"
    echo ""
    pm2 status
else
    echo "❌ Файл ecosystem.config.cjs не найден!"
    echo "Обновите код: git pull"
    exit 1
fi

