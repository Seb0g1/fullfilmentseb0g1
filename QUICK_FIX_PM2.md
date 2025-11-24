# ⚡ Быстрое исправление PM2 на сервере

## Проблема

```
[PM2][ERROR] File ecosystem.config.js malformated
ReferenceError: module is not defined in ES module scope
```

## Причина

На сервере остался старый файл `ecosystem.config.js`, который конфликтует с ES modules.

## Решение (30 секунд)

Выполните на сервере:

```bash
cd /var/www/sakoo.ru

# 1. Удалите старый файл
rm -f ecosystem.config.js

# 2. Обновите код (если еще не обновлен)
git pull

# 3. Перезапустите PM2
pm2 delete fulfillment-backend
pm2 start ecosystem.config.cjs
pm2 save
```

## Или одной командой:

```bash
cd /var/www/sakoo.ru && rm -f ecosystem.config.js && git pull && pm2 delete fulfillment-backend 2>/dev/null; pm2 start ecosystem.config.cjs && pm2 save
```

## Проверка:

```bash
pm2 status
pm2 logs fulfillment-backend
```

Должен быть запущен процесс `fulfillment-backend` без ошибок.

## Если файл ecosystem.config.cjs не найден:

Убедитесь, что код обновлен:

```bash
cd /var/www/sakoo.ru
git pull origin main
ls -la ecosystem.config.*
```

Должен быть файл `ecosystem.config.cjs`.

