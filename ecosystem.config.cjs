// PM2 конфигурация для автозапуска и управления процессами
// Использование: pm2 start ecosystem.config.cjs
// Установка PM2: npm install -g pm2

module.exports = {
  apps: [
    {
      name: 'fulfillment-backend',
      script: './server/server.js',
      cwd: './',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      },
      // Автоперезапуск при изменении файлов (только для разработки)
      watch: false,
      // Максимальное использование памяти (перезапуск при превышении)
      max_memory_restart: '500M',
      // Логи
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      // Автоперезапуск при сбое
      autorestart: true,
      // Количество перезапусков
      max_restarts: 10,
      min_uptime: '10s',
      // Перезапуск при изменении файлов (опционально)
      ignore_watch: ['node_modules', 'logs', 'dist']
    }
  ]
}

