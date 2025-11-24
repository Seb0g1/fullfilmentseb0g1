@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ========================================
echo 🚀 Запуск сайта fulfillment
echo ========================================
echo.

REM Проверка Node.js
where node >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Node.js не установлен!
    echo Установите Node.js с https://nodejs.org/
    pause
    exit /b 1
)

REM Проверка сборки
if not exist "dist" (
    echo [ПРЕДУПРЕЖДЕНИЕ] Frontend не собран. Запускаю сборку...
    call npm install
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось установить зависимости
        pause
        exit /b 1
    )
    call npm run build
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось собрать проект
        pause
        exit /b 1
    )
)

REM Проверка зависимостей backend
if not exist "server\node_modules" (
    echo [ПРЕДУПРЕЖДЕНИЕ] Зависимости backend не установлены. Устанавливаю...
    cd server
    call npm install
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось установить зависимости backend
        pause
        exit /b 1
    )
    cd ..
)

REM Проверка .env
if not exist "server\.env" (
    echo [ПРЕДУПРЕЖДЕНИЕ] Файл server\.env не найден!
    echo Создайте файл server\.env с настройками Telegram бота
    echo.
    echo Пример содержимого:
    echo   TELEGRAM_BOT_TOKEN=ваш_токен
    echo   TELEGRAM_GROUP_CHAT_ID=ваш_chat_id
    echo   PORT=3001
    echo.
    pause
)

REM Запуск backend сервера
echo.
echo [ЗАПУСК] Backend сервер запускается...
echo.

REM Проверка, запущен ли уже backend
netstat -ano | findstr :3001 >nul 2>&1
if not errorlevel 1 (
    echo [ИНФО] Backend сервер уже запущен на порту 3001
    echo.
) else (
    cd server
    
    REM Создание .env если его нет
    if not exist ".env" (
        echo [СОЗДАНИЕ] Создаю файл .env с шаблоном...
        (
            echo TELEGRAM_BOT_TOKEN=ваш_токен_бота
            echo TELEGRAM_GROUP_CHAT_ID=ваш_chat_id
            echo TELEGRAM_TOPIC_CHAT_CLIENT=0
            echo TELEGRAM_TOPIC_CALCULATOR=0
            echo TELEGRAM_TOPIC_CONTACT_FORM=0
            echo PORT=3001
            echo NODE_ENV=development
        ) > .env
        echo ⚠️  Отредактируйте server\.env и добавьте ваши токены!
        echo.
    )
    
    start "Fulfillment Backend" cmd /k "node server.js"
    cd ..
    echo ✅ Backend сервер запущен в отдельном окне
    echo.
)

echo.
echo ✅ Backend сервер запущен в отдельном окне
echo.
echo 📝 Frontend файлы находятся в папке 'dist'
echo 🌐 Для production используйте nginx (см. nginx-sakoo.conf)
echo.
echo Для разработки запустите в другом терминале:
echo   npm run dev
echo.
pause

