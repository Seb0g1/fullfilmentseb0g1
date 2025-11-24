#!/bin/bash

# Полный скрипт деплоя для размещения в /www на сервере
# Использование: ./deploy-full.sh
# 
# Скрипт автоматически:
# 1. Клонирует/обновляет репозиторий с GitHub
# 2. Устанавливает зависимости
# 3. Собирает frontend
# 4. Настраивает nginx
# 5. Запускает backend через PM2

set -e

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Конфигурация
GITHUB_REPO="https://github.com/Seb0g1/fullfilmentseb0g1.git"
PROJECT_DIR="/var/www/sakoo.ru"
DOMAIN="sakoo.ru"
BACKEND_PORT=3001
NGINX_CONFIG="/etc/nginx/sites-available/${DOMAIN}"

echo -e "${BLUE}=========================================="
echo "🚀 Полный деплой сайта fulfillment"
echo "==========================================${NC}"
echo ""

# Проверка прав root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}⚠️  Скрипт требует прав sudo для настройки nginx${NC}"
    echo "Запустите: sudo ./deploy-full.sh"
    exit 1
fi

# Проверка Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js не установлен!${NC}"
    echo "Установите Node.js:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
    exit 1
fi

echo -e "${GREEN}✅ Node.js: $(node --version)${NC}"
echo -e "${GREEN}✅ npm: $(npm --version)${NC}"

# Проверка PM2
if ! command -v pm2 &> /dev/null; then
    echo ""
    echo -e "${YELLOW}⚠️  PM2 не установлен. Устанавливаю...${NC}"
    npm install -g pm2
    echo -e "${GREEN}✅ PM2 установлен${NC}"
fi

# Создание директории проекта
echo ""
echo -e "${BLUE}[1/7] Подготовка директории проекта...${NC}"
mkdir -p "${PROJECT_DIR}"
cd "${PROJECT_DIR}"

# Клонирование/обновление репозитория
echo ""
echo -e "${BLUE}[2/7] Получение кода с GitHub...${NC}"
if [ -d ".git" ]; then
    echo "Репозиторий уже существует, обновляю..."
    git fetch origin
    git reset --hard origin/main
    git pull origin main
    echo -e "${GREEN}✅ Код обновлен${NC}"
else
    echo "Клонирую репозиторий..."
    git clone "${GITHUB_REPO}" .
    echo -e "${GREEN}✅ Репозиторий склонирован${NC}"
fi

# Установка зависимостей frontend
echo ""
echo -e "${BLUE}[3/7] Установка зависимостей frontend...${NC}"
npm install
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Ошибка установки зависимостей${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Зависимости frontend установлены${NC}"

# Установка зависимостей backend
echo ""
echo -e "${BLUE}[4/7] Установка зависимостей backend...${NC}"
cd server
npm install
cd ..
echo -e "${GREEN}✅ Зависимости backend установлены${NC}"

# Сборка frontend
echo ""
echo -e "${BLUE}[5/7] Сборка frontend проекта...${NC}"
npm run build

if [ ! -d "dist" ]; then
    echo -e "${RED}❌ Ошибка сборки! Папка dist не создана.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Frontend собран успешно${NC}"

# Проверка/создание .env файла
echo ""
echo -e "${BLUE}[6/7] Проверка конфигурации backend...${NC}"
if [ ! -f "server/.env" ]; then
    echo -e "${YELLOW}⚠️  Файл server/.env не найден!${NC}"
    echo "Создаю шаблон..."
    cat > server/.env << EOF
# Telegram Bot Configuration
TELEGRAM_BOT_TOKEN=ваш_токен_бота
TELEGRAM_GROUP_CHAT_ID=ваш_chat_id

# Telegram Topics (опционально)
TELEGRAM_TOPIC_CHAT_CLIENT=0
TELEGRAM_TOPIC_CALCULATOR=0
TELEGRAM_TOPIC_CONTACT_FORM=0

# Server Configuration
PORT=${BACKEND_PORT}
NODE_ENV=production
EOF
    echo -e "${YELLOW}⚠️  Отредактируйте server/.env и добавьте ваши токены!${NC}"
    echo "Нажмите Enter после редактирования..."
    read
else
    echo -e "${GREEN}✅ Файл server/.env найден${NC}"
fi

# Настройка прав доступа
echo ""
echo -e "${BLUE}[7/7] Настройка прав доступа...${NC}"
chown -R www-data:www-data "${PROJECT_DIR}/dist"
chmod -R 755 "${PROJECT_DIR}/dist"
echo -e "${GREEN}✅ Права настроены${NC}"

# Настройка Nginx
echo ""
echo -e "${BLUE}[8/8] Настройка Nginx...${NC}"
if [ -f "nginx-sakoo.conf" ]; then
    cp nginx-sakoo.conf "${NGINX_CONFIG}"
    
    # Обновление путей в конфигурации
    sed -i "s|/var/www/sakoo.ru|${PROJECT_DIR}|g" "${NGINX_CONFIG}"
    
    # Создание симлинка
    if [ ! -L "/etc/nginx/sites-enabled/${DOMAIN}" ]; then
        ln -s "${NGINX_CONFIG}" "/etc/nginx/sites-enabled/${DOMAIN}"
    fi
    
    # Проверка конфигурации
    if nginx -t; then
        systemctl reload nginx
        echo -e "${GREEN}✅ Nginx настроен и перезагружен${NC}"
    else
        echo -e "${RED}❌ Ошибка в конфигурации Nginx!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Файл nginx-sakoo.conf не найден в репозитории${NC}"
    echo "Создаю базовую конфигурацию..."
    
    cat > "${NGINX_CONFIG}" << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN} www.${DOMAIN};

    root ${PROJECT_DIR}/dist;
    index index.html;

    access_log /var/log/nginx/${DOMAIN}.access.log;
    error_log /var/log/nginx/${DOMAIN}.error.log;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    location / {
        try_files \$uri \$uri/ /index.html;
        
        location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)\$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    location /api/ {
        proxy_pass http://localhost:${BACKEND_PORT};
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    location /health {
        proxy_pass http://localhost:${BACKEND_PORT}/health;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
    }

    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF
    
    if [ ! -L "/etc/nginx/sites-enabled/${DOMAIN}" ]; then
        ln -s "${NGINX_CONFIG}" "/etc/nginx/sites-enabled/${DOMAIN}"
    fi
    
    if nginx -t; then
        systemctl reload nginx
        echo -e "${GREEN}✅ Nginx настроен${NC}"
    else
        echo -e "${RED}❌ Ошибка в конфигурации Nginx!${NC}"
        exit 1
    fi
fi

# Запуск/перезапуск backend через PM2
echo ""
echo -e "${BLUE}[9/9] Запуск backend сервера...${NC}"
cd "${PROJECT_DIR}"

if [ -f "ecosystem.config.js" ]; then
    # Останавливаем старый процесс, если существует
    pm2 delete fulfillment-backend 2>/dev/null || true
    
    # Запускаем через PM2
    pm2 start ecosystem.config.js
    pm2 save
    
    echo -e "${GREEN}✅ Backend запущен через PM2${NC}"
else
    echo -e "${YELLOW}⚠️  Файл ecosystem.config.js не найден${NC}"
    echo "Запускаю backend напрямую через PM2..."
    
    pm2 delete fulfillment-backend 2>/dev/null || true
    pm2 start server/server.js --name fulfillment-backend --cwd "${PROJECT_DIR}" --env production
    pm2 save
    
    echo -e "${GREEN}✅ Backend запущен${NC}"
fi

# Настройка автозапуска PM2
pm2 startup systemd -u root --hp /root 2>/dev/null || true

# Итоговая информация
echo ""
echo -e "${GREEN}=========================================="
echo "✅ Деплой завершен успешно!"
echo "==========================================${NC}"
echo ""
echo "📋 Информация:"
echo "   Домен: ${DOMAIN}"
echo "   Frontend: ${PROJECT_DIR}/dist"
echo "   Backend: http://localhost:${BACKEND_PORT}"
echo "   PM2 статус: pm2 status"
echo "   PM2 логи: pm2 logs fulfillment-backend"
echo ""
echo "🔍 Проверка работы:"
echo "   curl http://${DOMAIN}/health"
echo "   curl http://${DOMAIN}/api/health"
echo ""
echo "📝 Не забудьте:"
echo "   1. Отредактировать server/.env с вашими токенами Telegram"
echo "   2. Настроить SSL сертификат (Let's Encrypt)"
echo "   3. Проверить работу сайта: http://${DOMAIN}"
echo ""

