@echo off
chcp 65001 >nul
cd /d "%~dp0\server"

echo ========================================
echo 🚀 Запуск Backend сервера
echo ========================================
echo.

REM Проверка Node.js
where node >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Node.js не установлен!
    pause
    exit /b 1
)

REM Проверка зависимостей
if not exist "node_modules" (
    echo [УСТАНОВКА] Устанавливаю зависимости...
    call npm install
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось установить зависимости
        pause
        exit /b 1
    )
)

REM Проверка .env
if not exist ".env" (
    echo [СОЗДАНИЕ] Создаю файл .env...
    (
        echo TELEGRAM_BOT_TOKEN=ваш_токен_бота
        echo TELEGRAM_GROUP_CHAT_ID=ваш_chat_id
        echo TELEGRAM_TOPIC_CHAT_CLIENT=0
        echo TELEGRAM_TOPIC_CALCULATOR=0
        echo TELEGRAM_TOPIC_CONTACT_FORM=0
        echo PORT=3001
        echo NODE_ENV=development
    ) > .env
    echo.
    echo ⚠️  Файл .env создан с шаблоном!
    echo Отредактируйте server\.env и добавьте ваши токены Telegram
    echo.
    pause
)

REM Запуск сервера
echo [ЗАПУСК] Запускаю backend сервер на порту 3001...
echo.
node server.js

