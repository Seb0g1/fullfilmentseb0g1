# 🔧 Исправление ошибки PM2

## Проблема

```
[PM2][ERROR] File ecosystem.config.js malformated
ReferenceError: module is not defined in ES module scope
```

## Причина

Проект использует ES modules (`"type": "module"` в package.json), но `ecosystem.config.js` написан в формате CommonJS.

## Решение

Файл переименован в `ecosystem.config.cjs` (расширение `.cjs` указывает на CommonJS формат).

## Использование

Теперь используйте:

```bash
pm2 start ecosystem.config.cjs
```

Вместо:

```bash
pm2 start ecosystem.config.js  # ❌ Не работает
```

## Обновление на сервере

Если на сервере еще старый файл:

```bash
cd /var/www/sakoo.ru
git pull  # Обновить код
pm2 delete fulfillment-backend
pm2 start ecosystem.config.cjs
pm2 save
```

Или просто запустите скрипт деплоя:

```bash
./deploy-full.sh
```

Он автоматически использует правильный файл.

