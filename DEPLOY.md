# 🚀 Инструкция по деплою на sakoo.ru

## Требования

- Node.js 18+ и npm
- Nginx
- PM2 (опционально, для автозапуска)
- Домен sakoo.ru настроен на сервер

## Шаг 1: Подготовка проекта

### На локальной машине:

```bash
# Клонируйте репозиторий (если еще не склонирован)
git clone https://github.com/Seb0g1/fullfilmentseb0g1.git
cd fullfilmentseb0g1

# Соберите проект
npm install
npm run build

# Установите зависимости backend
cd server
npm install
cd ..
```

### На сервере:

```bash
# Создайте директорию для сайта
sudo mkdir -p /var/www/sakoo.ru
sudo chown -R $USER:$USER /var/www/sakoo.ru

# Скопируйте файлы на сервер
# Вариант 1: Через git
cd /var/www/sakoo.ru
git clone https://github.com/Seb0g1/fullfilmentseb0g1.git .

# Вариант 2: Через scp/rsync
# scp -r dist/ user@server:/var/www/sakoo.ru/
# scp -r server/ user@server:/var/www/sakoo.ru/
```

## Шаг 2: Настройка Backend

```bash
cd /var/www/sakoo.ru/server

# Создайте файл .env
nano .env
```

Добавьте в `.env`:

```env
TELEGRAM_BOT_TOKEN=ваш_токен_бота
TELEGRAM_GROUP_CHAT_ID=ваш_chat_id
TELEGRAM_TOPIC_CHAT_CLIENT=id_топика_чата
TELEGRAM_TOPIC_CALCULATOR=id_топика_калькулятора
TELEGRAM_TOPIC_CONTACT_FORM=id_топика_контактной_формы
PORT=3001
NODE_ENV=production
```

## Шаг 3: Настройка Nginx

```bash
# Скопируйте конфигурацию
sudo cp nginx-sakoo.conf /etc/nginx/sites-available/sakoo.ru

# Создайте симлинк
sudo ln -s /etc/nginx/sites-available/sakoo.ru /etc/nginx/sites-enabled/

# Проверьте конфигурацию
sudo nginx -t

# Перезапустите nginx
sudo systemctl reload nginx
```

**Важно:** Убедитесь, что в конфигурации указан правильный путь:
- `root /var/www/sakoo.ru/dist;` - путь к собранному frontend

## Шаг 4: Запуск Backend сервера

### Вариант 1: Через PM2 (рекомендуется)

```bash
# Установите PM2 глобально
npm install -g pm2

# Запустите через PM2
cd /var/www/sakoo.ru
pm2 start ecosystem.config.js

# Сохраните конфигурацию для автозапуска
pm2 save
pm2 startup
```

### Вариант 2: Через systemd

Создайте файл `/etc/systemd/system/fulfillment.service`:

```ini
[Unit]
Description=Fulfillment Backend Server
After=network.target

[Service]
Type=simple
User=ваш_пользователь
WorkingDirectory=/var/www/sakoo.ru
ExecStart=/usr/bin/node /var/www/sakoo.ru/server/server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=3001

[Install]
WantedBy=multi-user.target
```

Запустите:

```bash
sudo systemctl daemon-reload
sudo systemctl enable fulfillment
sudo systemctl start fulfillment
sudo systemctl status fulfillment
```

### Вариант 3: Через скрипт start.sh

```bash
cd /var/www/sakoo.ru
chmod +x start.sh
./start.sh
```

## Шаг 5: Настройка SSL (HTTPS)

Рекомендуется использовать Let's Encrypt:

```bash
# Установите certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Получите сертификат
sudo certbot --nginx -d sakoo.ru -d www.sakoo.ru

# Certbot автоматически обновит конфигурацию nginx
# После этого раскомментируйте HTTPS секцию в nginx-sakoo.conf
```

## Шаг 6: Проверка работы

1. **Проверьте frontend:**
   ```bash
   curl http://sakoo.ru
   ```

2. **Проверьте backend:**
   ```bash
   curl http://sakoo.ru/health
   ```

3. **Проверьте API:**
   ```bash
   curl http://sakoo.ru/api/chat/messages?userId=test
   ```

4. **Откройте в браузере:**
   - http://sakoo.ru (или https://sakoo.ru после настройки SSL)

## Обновление сайта

```bash
cd /var/www/sakoo.ru

# Обновите код
git pull

# Пересоберите frontend
npm install
npm run build

# Перезапустите backend (если используете PM2)
pm2 restart fulfillment-backend

# Или перезапустите systemd сервис
sudo systemctl restart fulfillment
```

## Мониторинг

### PM2:
```bash
pm2 status
pm2 logs fulfillment-backend
pm2 monit
```

### Systemd:
```bash
sudo systemctl status fulfillment
sudo journalctl -u fulfillment -f
```

### Nginx логи:
```bash
sudo tail -f /var/log/nginx/sakoo.ru.access.log
sudo tail -f /var/log/nginx/sakoo.ru.error.log
```

## Устранение проблем

### Backend не запускается:
1. Проверьте `.env` файл
2. Проверьте логи: `pm2 logs` или `sudo journalctl -u fulfillment`
3. Убедитесь, что порт 3001 свободен: `sudo netstat -tulpn | grep 3001`

### Nginx не работает:
1. Проверьте конфигурацию: `sudo nginx -t`
2. Проверьте логи: `sudo tail -f /var/log/nginx/error.log`
3. Убедитесь, что файлы в `/var/www/sakoo.ru/dist` существуют

### Telegram бот не работает:
1. Проверьте токен в `.env`
2. Проверьте Chat ID
3. Убедитесь, что бот добавлен в группу
4. Проверьте логи backend сервера

## Структура файлов на сервере

```
/var/www/sakoo.ru/
├── dist/                    # Собранный frontend (раздается nginx)
│   ├── index.html
│   ├── assets/
│   └── ...
├── server/                  # Backend сервер
│   ├── server.js
│   ├── package.json
│   ├── .env                 # Конфигурация (не коммитится!)
│   └── node_modules/
├── nginx-sakoo.conf         # Конфигурация nginx
├── ecosystem.config.js      # PM2 конфигурация
├── start.sh                 # Скрипт запуска
└── deploy.sh                # Скрипт деплоя
```

## Безопасность

1. **Не коммитьте `.env` файлы!**
2. Убедитесь, что `.env` имеет правильные права: `chmod 600 server/.env`
3. Настройте firewall для портов 80, 443
4. Регулярно обновляйте зависимости: `npm audit fix`
5. Используйте HTTPS в production

## Поддержка

При возникновении проблем проверьте:
- Логи nginx
- Логи backend сервера
- Статус PM2/systemd
- Конфигурацию `.env`

