<template>
  <canvas 
    ref="canvasRef" 
    class="particle-canvas"
  ></canvas>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'

const canvasRef = ref(null)
let animationId = null
let particles = []
let resizeHandler = null

const createParticle = (canvas) => {
  const colors = [
    { r: 113, g: 59, b: 219 }, // purple
    { r: 203, g: 17, b: 171 },  // pink
    { r: 0, g: 91, b: 255 },    // blue
    { r: 99, g: 102, b: 241 }   // indigo
  ]
  const color = colors[Math.floor(Math.random() * colors.length)]
  
  return {
    x: Math.random() * canvas.width,
    y: Math.random() * canvas.height,
    radius: Math.random() * 3 + 1,
    vx: (Math.random() - 0.5) * 0.8,
    vy: (Math.random() - 0.5) * 0.8,
    opacity: Math.random() * 0.6 + 0.3,
    color: color,
    pulseSpeed: Math.random() * 0.02 + 0.01,
    pulsePhase: Math.random() * Math.PI * 2
  }
}

const initParticles = (canvas) => {
  // Уменьшаем количество частиц для лучшей производительности
  const baseCount = 40
  const maxCount = 60
  const area = canvas.width * canvas.height
  const particleCount = Math.min(maxCount, Math.max(baseCount, Math.floor(area / 20000)))
  particles = []
  for (let i = 0; i < particleCount; i++) {
    particles.push(createParticle(canvas))
  }
}

let time = 0
let lastFrameTime = 0
const targetFPS = 30
const frameInterval = 1000 / targetFPS

const drawParticles = (ctx, canvas, currentTime = performance.now()) => {
  // Ограничение FPS для лучшей производительности
  const elapsed = currentTime - lastFrameTime
  if (elapsed < frameInterval) {
    animationId = requestAnimationFrame((time) => drawParticles(ctx, canvas, time))
    return
  }
  lastFrameTime = currentTime - (elapsed % frameInterval)
  
  time += 0.01
  ctx.clearRect(0, 0, canvas.width, canvas.height)
  
  // Рисуем градиентные орбы
  const orb1 = {
    x: canvas.width * 0.2 + Math.sin(time * 0.5) * 100,
    y: canvas.height * 0.3 + Math.cos(time * 0.3) * 80,
    radius: 200 + Math.sin(time) * 50
  }
  const orb2 = {
    x: canvas.width * 0.8 + Math.cos(time * 0.4) * 120,
    y: canvas.height * 0.7 + Math.sin(time * 0.6) * 90,
    radius: 180 + Math.cos(time * 1.2) * 40
  }
  
  // Градиентный орб 1
  const gradient1 = ctx.createRadialGradient(orb1.x, orb1.y, 0, orb1.x, orb1.y, orb1.radius)
  gradient1.addColorStop(0, 'rgba(113, 59, 219, 0.15)')
  gradient1.addColorStop(0.5, 'rgba(203, 17, 171, 0.08)')
  gradient1.addColorStop(1, 'transparent')
  ctx.fillStyle = gradient1
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  
  // Градиентный орб 2
  const gradient2 = ctx.createRadialGradient(orb2.x, orb2.y, 0, orb2.x, orb2.y, orb2.radius)
  gradient2.addColorStop(0, 'rgba(0, 91, 255, 0.12)')
  gradient2.addColorStop(0.5, 'rgba(99, 102, 241, 0.06)')
  gradient2.addColorStop(1, 'transparent')
  ctx.fillStyle = gradient2
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  
  // Рисуем частицы (оптимизированная версия)
  particles.forEach((particle, i) => {
    // Обновляем пульсацию
    particle.pulsePhase += particle.pulseSpeed
    const pulse = Math.sin(particle.pulsePhase) * 0.3 + 1
    
    // Обновляем позицию
    particle.x += particle.vx
    particle.y += particle.vy
    
    // Отскок от краев
    if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1
    if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1
    
    // Рисуем частицу с градиентом
    const particleGradient = ctx.createRadialGradient(
      particle.x, particle.y, 0,
      particle.x, particle.y, particle.radius * pulse
    )
    particleGradient.addColorStop(0, `rgba(${particle.color.r}, ${particle.color.g}, ${particle.color.b}, ${particle.opacity})`)
    particleGradient.addColorStop(0.5, `rgba(${particle.color.r}, ${particle.color.g}, ${particle.color.b}, ${particle.opacity * 0.5})`)
    particleGradient.addColorStop(1, 'transparent')
    
    ctx.beginPath()
    ctx.arc(particle.x, particle.y, particle.radius * pulse, 0, Math.PI * 2)
    ctx.fillStyle = particleGradient
    ctx.fill()
    
    // Свечение вокруг частицы (упрощенное)
    ctx.shadowBlur = 10
    ctx.shadowColor = `rgba(${particle.color.r}, ${particle.color.g}, ${particle.color.b}, 0.3)`
    ctx.fill()
    ctx.shadowBlur = 0
    
    // Оптимизированные соединения - проверяем только ближайшие частицы
    // Используем пространственное разделение для O(n) вместо O(n²)
    const maxConnectionDistance = 150
    const maxConnections = 3 // Ограничиваем количество соединений на частицу
    
    let connectionCount = 0
    for (let j = i + 1; j < particles.length && connectionCount < maxConnections; j++) {
      const otherParticle = particles[j]
      const dx = particle.x - otherParticle.x
      const dy = particle.y - otherParticle.y
      const distanceSq = dx * dx + dy * dy
      
      // Используем квадрат расстояния для избежания Math.sqrt
      if (distanceSq < maxConnectionDistance * maxConnectionDistance) {
        const distance = Math.sqrt(distanceSq)
        const opacity = 0.15 * (1 - distance / maxConnectionDistance)
        
        // Упрощенный градиент
        ctx.beginPath()
        ctx.moveTo(particle.x, particle.y)
        ctx.lineTo(otherParticle.x, otherParticle.y)
        ctx.strokeStyle = `rgba(${particle.color.r}, ${particle.color.g}, ${particle.color.b}, ${opacity})`
        ctx.lineWidth = 1
        ctx.stroke()
        connectionCount++
      }
    }
  })
  
  animationId = requestAnimationFrame(() => drawParticles(ctx, canvas))
}

onMounted(() => {
  if (!canvasRef.value) return
  
  const canvas = canvasRef.value
  const ctx = canvas.getContext('2d', { alpha: true, desynchronized: true })
  
  // Дебаунсинг для resize
  let resizeTimeout
  const resizeCanvas = () => {
    clearTimeout(resizeTimeout)
    resizeTimeout = setTimeout(() => {
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
      initParticles(canvas)
    }, 150)
  }
  
  resizeCanvas()
  resizeHandler = resizeCanvas
  window.addEventListener('resize', resizeHandler, { passive: true })
  
  drawParticles(ctx, canvas)
})

onUnmounted(() => {
  if (resizeHandler) {
    window.removeEventListener('resize', resizeHandler)
  }
  if (animationId) {
    cancelAnimationFrame(animationId)
  }
})
</script>

<style scoped>
.particle-canvas {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  pointer-events: none;
  opacity: 0.5;
  will-change: contents; /* Оптимизация для canvas анимации */
  contain: strict; /* Изоляция для лучшей производительности */
  transform: translateZ(0); /* GPU ускорение */
}
</style>
