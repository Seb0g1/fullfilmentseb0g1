# ⚡ Быстрый старт

## Для Windows (локальная разработка)

```cmd
# Запустите скрипт
start.bat
```

Скрипт автоматически:
- Проверит наличие Node.js
- Установит зависимости (если нужно)
- Соберет frontend (если нужно)
- Запустит backend сервер

## Для Linux (деплой на сервер)

### 1. Подготовка

```bash
# Сделайте скрипты исполняемыми
chmod +x deploy.sh start.sh

# Запустите деплой
./deploy.sh
```

### 2. Настройка Nginx

```bash
# Скопируйте конфигурацию
sudo cp nginx-sakoo.conf /etc/nginx/sites-available/sakoo.ru

# Активируйте сайт
sudo ln -s /etc/nginx/sites-available/sakoo.ru /etc/nginx/sites-enabled/

# Проверьте и перезапустите
sudo nginx -t
sudo systemctl reload nginx
```

### 3. Запуск через PM2

```bash
# Установите PM2
npm install -g pm2

# Запустите
pm2 start ecosystem.config.cjs

# Автозапуск при перезагрузке
pm2 save
pm2 startup
```

### 4. Настройка Telegram бота

Создайте файл `server/.env`:

```env
TELEGRAM_BOT_TOKEN=ваш_токен
TELEGRAM_GROUP_CHAT_ID=ваш_chat_id
TELEGRAM_TOPIC_CHAT_CLIENT=id_топика
TELEGRAM_TOPIC_CALCULATOR=id_топика
TELEGRAM_TOPIC_CONTACT_FORM=id_топика
PORT=3001
```

## Структура файлов

- `start.bat` / `start.sh` - запуск на локальной машине/сервере
- `deploy.sh` - скрипт деплоя
- `nginx-sakoo.conf` - конфигурация nginx для домена sakoo.ru
- `ecosystem.config.cjs` - конфигурация PM2 для автозапуска
- `DEPLOY.md` - подробная инструкция по деплою

## Проверка работы

1. Frontend: http://sakoo.ru (или http://localhost:3000 в dev режиме)
2. Backend API: http://sakoo.ru/api/health
3. Telegram бот должен отправлять сообщения в группу

## Обновление

```bash
git pull
npm install
npm run build
pm2 restart fulfillment-backend
```

