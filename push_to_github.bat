@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo ========================================
echo Загрузка проекта на GitHub
echo ========================================
echo.

REM Проверка наличия Git
where git >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Git не установлен или не найден в PATH
    echo Установите Git с https://git-scm.com/download/win
    pause
    exit /b 1
)

REM Настройка Git config
echo [0/6] Настройка Git...
git config --global user.name "seb0g1" 2>nul
git config --global user.email "seboggame@gmail.com" 2>nul
echo Git настроен: seb0g1 ^<seboggame@gmail.com^>
echo.

REM Инициализация репозитория (если еще не инициализирован)
if not exist ".git" (
    echo [1/6] Инициализация git репозитория...
    git init
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось инициализировать репозиторий
        pause
        exit /b 1
    )
) else (
    echo [1/6] Репозиторий уже инициализирован
)

REM Добавление всех файлов
echo [2/6] Добавление файлов...
git add .
if errorlevel 1 (
    echo [ОШИБКА] Не удалось добавить файлы
    pause
    exit /b 1
)

REM Проверка статуса перед коммитом
echo [3/6] Проверка статуса...
git status --porcelain >nul 2>&1
if errorlevel 1 (
    echo Проверяю наличие коммитов...
    git log --oneline -1 >nul 2>&1
    if errorlevel 1 (
        echo [4/6] Создание первого коммита...
        git commit -m "first commit" --allow-empty
        if errorlevel 1 (
            echo [ОШИБКА] Не удалось создать коммит
            pause
            exit /b 1
        )
    ) else (
        echo [4/6] Коммит уже существует
    )
) else (
    echo [4/6] Создание коммита...
    git commit -m "first commit"
    if errorlevel 1 (
        echo [ОШИБКА] Не удалось создать коммит
        pause
        exit /b 1
    )
)

REM Создание/переименование ветки в main
echo [5/6] Настройка ветки main...
git branch -M main 2>nul
if errorlevel 1 (
    echo Создание ветки main...
    git checkout -b main 2>nul
    if errorlevel 1 (
        git branch main 2>nul
        git checkout main 2>nul
    )
)

REM Добавление remote
echo [6/6] Добавление remote origin...
git remote remove origin 2>nul
git remote add origin https://github.com/Seb0g1/fullfilmentseb0g1.git
if errorlevel 1 (
    echo [ОШИБКА] Не удалось добавить remote
    pause
    exit /b 1
)

REM Отправка на GitHub
echo.
echo ========================================
echo Отправка на GitHub...
echo ========================================
git push -u origin main
if errorlevel 1 (
    echo.
    echo ========================================
    echo [ОШИБКА] Не удалось отправить на GitHub
    echo ========================================
    echo.
    echo Возможные причины:
    echo 1. Требуется аутентификация
    echo 2. Репозиторий на GitHub не пустой
    echo.
    echo Решения:
    echo - Настройте Git: git config --global user.name "Ваше имя"
    echo - Настройте Git: git config --global user.email "ваш@email.com"
    echo - Используйте Personal Access Token вместо пароля
    echo - Или используйте GitHub CLI: gh auth login
    echo.
) else (
    echo.
    echo ========================================
    echo [УСПЕХ] Проект успешно загружен на GitHub!
    echo ========================================
    echo.
    echo Репозиторий: https://github.com/Seb0g1/fullfilmentseb0g1
    echo.
)

pause

